import basic;
import basic.maths : min, max;
static import game;

version (Windows) {
  version = D3D11;
  version = OpenGL;
}

struct Platform_Renderer {
  void function() init_;
  void function() deinit;
  void function() resize;
  void function(game.Renderer*) present;
}

struct TriangleVertex {
  align(16) float[3] position;
  align(16) float[4] color;
}

__gshared immutable triangle_vertices = [
  TriangleVertex([+0.5, -0.5, 0.0], [1.0, 0.0, 0.0, 1.0]),
  TriangleVertex([-0.5, -0.5, 0.0], [0.0, 1.0, 0.0, 1.0]),
  TriangleVertex([-0.5, +0.5, 0.0], [0.0, 0.0, 1.0, 1.0]),
  TriangleVertex([+0.5, +0.5, 0.0], [1.0, 0.0, 1.0, 1.0]),
];
__gshared immutable u16[6] triangle_elements = [0, 1, 2, 2, 3, 0];

__gshared immutable null_renderer = Platform_Renderer(
  {},
  {},
  {},
  (renderer) {},
);

version (D3D11) {
  import basic.windows;
  import main : platform_hwnd, platform_size;

  struct D3D11_Data {
    bool initted;
    IDXGISwapChain* swapchain;
    ID3D11Device* device;
    ID3D11DeviceContext* ctx;

    ID3D11RenderTargetView* backbuffer_view;

    ID3D11Texture2D* depthbuffer;
    ID3D11DepthStencilView* depthbuffer_view;
    ID3D11DepthStencilState* depthstate;

    ID3D11VertexShader* triangle_vshader;
    ID3D11PixelShader* triangle_pshader;
    ID3D11InputLayout* triangle_input_layout;
    ID3D11Buffer* triangle_vbo;
    ID3D11Buffer* triangle_ebo;
  }

  __gshared D3D11_Data d3d11;

  void d3d11_init() {
    {
      HRESULT hr = void;

      DXGI_SWAP_CHAIN_DESC swapchain_descriptor;
      swapchain_descriptor.BufferDesc.Width = platform_size[0];
      swapchain_descriptor.BufferDesc.Height = platform_size[1];
      swapchain_descriptor.BufferDesc.Format = DXGI_FORMAT.R8G8B8A8_UNORM_SRGB;
      swapchain_descriptor.SampleDesc.Count = 1;
      swapchain_descriptor.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
      swapchain_descriptor.BufferCount = 1;
      swapchain_descriptor.OutputWindow = platform_hwnd;
      swapchain_descriptor.Windowed = true;
      swapchain_descriptor.Flags = DXGI_SWAP_CHAIN_FLAG.ALLOW_MODE_SWITCH;
      hr = D3D11CreateDeviceAndSwapChain(null, D3D_DRIVER_TYPE.HARDWARE, null,
        D3D11_CREATE_DEVICE_FLAG.DEBUG, null, 0, D3D11_SDK_VERSION,
        &swapchain_descriptor, &d3d11.swapchain, &d3d11.device, null, &d3d11.ctx);
      if (hr < 0) goto error;

      IDXGIDevice* dxgi_device = void;
      if (d3d11.swapchain.GetDevice(&dxgi_device.uuidof, cast(void**) &dxgi_device) >= 0) {
        IDXGIAdapter* dxgi_adapter = void;
        if (dxgi_device.GetAdapter(&dxgi_adapter) >= 0) {
          IDXGIFactory* dxgi_factory = void;
          if (dxgi_adapter.GetParent(&dxgi_factory.uuidof, cast(void**) &dxgi_factory) >= 0) {
            hr = dxgi_factory.MakeWindowAssociation(platform_hwnd, DXGI_MWA.NO_ALT_ENTER);
            dxgi_factory.Release();
          }
          dxgi_adapter.Release();
        }
        dxgi_device.Release();
      }

      string source = `
      struct VInput {
        float3 position : Position;
        float4 color : Color;
      };
      struct VOutput {
        float4 position : SV_Position;
        float4 color : Color;
      };

      VOutput vmain(VInput input) {
        VOutput output;
        output.position = float4(input.position, 1.0f);
        output.color = input.color;
        return output;
      }

      float4 pmain(VOutput input) : SV_Target0 {
        return input.color;
      }
      `;

      ID3DBlob* vblob = void;
      hr = D3DCompile(source.ptr, source.length, null, null, null, "vmain", "vs_5_0", D3DCOMPILE.DEBUG, 0, &vblob, null);
      if (hr < 0) goto error;
      scope(exit) vblob.Release();

      ID3DBlob* pblob = void;
      hr = D3DCompile(source.ptr, source.length, null, null, null, "pmain", "ps_5_0", D3DCOMPILE.DEBUG, 0, &pblob, null);
      if (hr < 0) goto error;
      scope(exit) pblob.Release();

      hr = d3d11.device.CreateVertexShader(vblob.GetBufferPointer(), vblob.GetBufferSize(), null, &d3d11.triangle_vshader);
      if (hr < 0) goto error;

      hr = d3d11.device.CreatePixelShader(pblob.GetBufferPointer(), pblob.GetBufferSize(), null, &d3d11.triangle_pshader);
      if (hr < 0) goto error;

      D3D11_INPUT_ELEMENT_DESC[2] input_descs;
      input_descs[0].SemanticName = "Position";
      input_descs[0].SemanticIndex = 0;
      input_descs[0].Format = DXGI_FORMAT.R32G32B32_FLOAT;
      input_descs[0].AlignedByteOffset = TriangleVertex.position.offsetof;
      input_descs[0].InputSlotClass = D3D11_INPUT_CLASSIFICATION.VERTEX_DATA;
      input_descs[1].SemanticName = "Color";
      input_descs[1].SemanticIndex = 0;
      input_descs[1].Format = DXGI_FORMAT.R32G32B32A32_FLOAT;
      input_descs[1].AlignedByteOffset = TriangleVertex.color.offsetof;
      input_descs[1].InputSlotClass = D3D11_INPUT_CLASSIFICATION.VERTEX_DATA;
      hr = d3d11.device.CreateInputLayout(input_descs.ptr, cast(u32) input_descs.length, vblob.GetBufferPointer(), vblob.GetBufferSize(), &d3d11.triangle_input_layout);
      if (hr < 0) goto error;

      D3D11_BUFFER_DESC triangle_vbo_desc;
      triangle_vbo_desc.ByteWidth = cast(u32) triangle_vertices.length * cast(u32) TriangleVertex.sizeof;
      triangle_vbo_desc.Usage = D3D11_USAGE.DEFAULT;
      triangle_vbo_desc.BindFlags = D3D11_BIND_FLAG.VERTEX_BUFFER;
      triangle_vbo_desc.StructureByteStride = TriangleVertex.sizeof;
      D3D11_SUBRESOURCE_DATA triangle_vbo_data;
      triangle_vbo_data.pSysMem = triangle_vertices.ptr;
      hr = d3d11.device.CreateBuffer(&triangle_vbo_desc, &triangle_vbo_data, &d3d11.triangle_vbo);
      if (hr < 0) goto error;

      D3D11_BUFFER_DESC triangle_ebo_desc;
      triangle_ebo_desc.ByteWidth = cast(u32) triangle_elements.length * cast(u32) triangle_elements[0].sizeof;
      triangle_ebo_desc.Usage = D3D11_USAGE.DEFAULT;
      triangle_ebo_desc.BindFlags = D3D11_BIND_FLAG.INDEX_BUFFER;
      triangle_ebo_desc.StructureByteStride = triangle_elements[0].sizeof;
      D3D11_SUBRESOURCE_DATA triangle_ebo_data;
      triangle_ebo_data.pSysMem = triangle_elements.ptr;
      hr = d3d11.device.CreateBuffer(&triangle_ebo_desc, &triangle_ebo_data, &d3d11.triangle_ebo);
      if (hr < 0) goto error;

      D3D11_DEPTH_STENCIL_DESC depthstate_desc;
      depthstate_desc.DepthEnable = true;
      depthstate_desc.DepthWriteMask = D3D11_DEPTH_WRITE_MASK.ALL;
      depthstate_desc.DepthFunc = D3D11_COMPARISON_FUNC.GREATER_EQUAL;
      hr = d3d11.device.CreateDepthStencilState(&depthstate_desc, &d3d11.depthstate);
      if (hr < 0) goto error;

      d3d11.initted = true;
      return;
    }
  error:
    d3d11_deinit();
  }

  void d3d11_deinit() {
    if (d3d11.depthstate) d3d11.depthstate.Release();
    if (d3d11.depthbuffer_view) d3d11.depthbuffer_view.Release();
    if (d3d11.depthbuffer) d3d11.depthbuffer.Release();

    if (d3d11.triangle_ebo) d3d11.triangle_ebo.Release();
    if (d3d11.triangle_vbo) d3d11.triangle_vbo.Release();
    if (d3d11.triangle_input_layout) d3d11.triangle_input_layout.Release();
    if (d3d11.triangle_pshader) d3d11.triangle_pshader.Release();
    if (d3d11.triangle_vshader) d3d11.triangle_vshader.Release();

    if (d3d11.backbuffer_view) d3d11.backbuffer_view.Release();

    if (d3d11.ctx) d3d11.ctx.Release();
    if (d3d11.device) d3d11.device.Release();
    if (d3d11.swapchain) d3d11.swapchain.Release();
    d3d11 = d3d11.init;
  }

  void d3d11_resize() {
    if (!d3d11.initted || platform_size[0] == 0 || platform_size[1] == 0) return;
    {
      HRESULT hr = void;

      if (d3d11.depthbuffer_view) d3d11.depthbuffer_view.Release();
      if (d3d11.depthbuffer) d3d11.depthbuffer.Release();
      if (d3d11.backbuffer_view) d3d11.backbuffer_view.Release();

      hr = d3d11.swapchain.ResizeBuffers(1, platform_size[0], platform_size[1], DXGI_FORMAT.UNKNOWN, DXGI_SWAP_CHAIN_FLAG.ALLOW_MODE_SWITCH);
      if (hr < 0) goto error;

      ID3D11Texture2D* backbuffer = void;
      hr = d3d11.swapchain.GetBuffer(0, &backbuffer.uuidof, cast(void**) &backbuffer);
      if (hr < 0) goto error;
      scope(exit) backbuffer.Release();

      hr = d3d11.device.CreateRenderTargetView(cast(ID3D11Resource*) backbuffer, null, &d3d11.backbuffer_view);
      if (hr < 0) goto error;

      D3D11_TEXTURE2D_DESC depthbuffer_desc;
      depthbuffer_desc.Width = platform_size[0];
      depthbuffer_desc.Height = platform_size[1];
      depthbuffer_desc.MipLevels = 0;
      depthbuffer_desc.ArraySize = 1;
      depthbuffer_desc.Format = DXGI_FORMAT.D32_FLOAT;
      depthbuffer_desc.SampleDesc.Count = 1;
      depthbuffer_desc.Usage = D3D11_USAGE.DEFAULT;
      depthbuffer_desc.BindFlags = D3D11_BIND_FLAG.DEPTH_STENCIL;
      hr = d3d11.device.CreateTexture2D(&depthbuffer_desc, null, &d3d11.depthbuffer);
      if (hr < 0) goto error;

      hr = d3d11.device.CreateDepthStencilView(cast(ID3D11Resource*) d3d11.depthbuffer, null, &d3d11.depthbuffer_view);
      if (hr < 0) goto error;

      return;
    }
  error:
    d3d11_deinit();
  }

  void d3d11_present(game.Renderer* game_renderer) {
    if (!d3d11.initted) return;
    d3d11.ctx.ClearRenderTargetView(d3d11.backbuffer_view, game_renderer.clear_color0.ptr);
    d3d11.ctx.ClearDepthStencilView(d3d11.depthbuffer_view, D3D11_CLEAR_FLAG.DEPTH, 0.0, cast(u8) 0);

    d3d11.ctx.VSSetShader(d3d11.triangle_vshader, null, 0);
    d3d11.ctx.PSSetShader(d3d11.triangle_pshader, null, 0);
    d3d11.ctx.IASetInputLayout(d3d11.triangle_input_layout);
    d3d11.ctx.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY.TRIANGLELIST);
    d3d11.ctx.OMSetRenderTargets(1, &d3d11.backbuffer_view, d3d11.depthbuffer_view);
    d3d11.ctx.OMSetDepthStencilState(d3d11.depthstate, 0);
    u32 stride = TriangleVertex.sizeof;
    u32 offset = 0;
    d3d11.ctx.IASetVertexBuffers(0, 1, &d3d11.triangle_vbo, &stride, &offset);
    d3d11.ctx.IASetIndexBuffer(d3d11.triangle_ebo, DXGI_FORMAT.R16_UINT, 0);
    D3D11_VIEWPORT viewport;
    viewport.TopLeftX = 0;
    viewport.TopLeftY = 0;
    viewport.Width = platform_size[0];
    viewport.Height = platform_size[1];
    viewport.MinDepth = 0.0;
    viewport.MaxDepth = 1.0;
    d3d11.ctx.RSSetViewports(1, &viewport);
    d3d11.ctx.DrawIndexed(cast(u32) triangle_elements.length, 0, 0);

    d3d11.swapchain.Present(1, 0);
  }

  __gshared immutable d3d11_renderer = Platform_Renderer(
    &d3d11_init,
    &d3d11_deinit,
    &d3d11_resize,
    &d3d11_present,
  );
}

version (OpenGL) {
  version (Windows) {
    static import basic.opengl;
    import main : platform_hdc;

    struct OpenGL_Platform_Data {
      bool initted;
      HGLRC ctx;
    }

    __gshared OpenGL_Platform_Data opengl_platform;

    static foreach (member; __traits(allMembers, basic.opengl)) {
      static if (is(typeof(__traits(getMember, basic.opengl, member)) == function)) {
        static foreach (attribute; __traits(getAttributes, __traits(getMember, basic.opengl, member))) {
          static if (is(typeof(attribute) == basic.opengl.gl_version)) {
            static if (attribute.major == 1 && attribute.minor <= 1) {
              mixin("alias "~member~" = basic.opengl."~member~";");
            } else {
              mixin("__gshared typeof(basic.opengl."~member~")* "~member~";");
            }
          }
        }
      } else static if (!__traits(isModule, (__traits(getMember, basic.opengl, member)))) {
        mixin("alias "~member~" = basic.opengl."~member~";");
      }
    }

    void opengl_platform_init() {
      PIXELFORMATDESCRIPTOR pfd;
      pfd.nSize = PIXELFORMATDESCRIPTOR.sizeof;
      pfd.nVersion = 1;
      pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
      const format = ChoosePixelFormat(platform_hdc, &pfd);
      SetPixelFormat(platform_hdc, format, &pfd);

      HGLRC temp_ctx = wglCreateContext(platform_hdc);
      wglMakeCurrent(platform_hdc, temp_ctx);
      scope(exit) wglDeleteContext(temp_ctx);

      alias PFN_wglCreateContextAttribsARB = extern(Windows) HGLRC function(HDC, HGLRC, const(s32)*);
      auto wglCreateContextAttribsARB =
        cast(PFN_wglCreateContextAttribsARB)
        wglGetProcAddress("wglCreateContextAttribsARB");

      debug enum flags = WGL_CONTEXT_DEBUG_BIT_ARB;
      else  enum flags = 0;
      __gshared immutable s32[9] attribs = [
        WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
        WGL_CONTEXT_MINOR_VERSION_ARB, 5,
        WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
        WGL_CONTEXT_FLAGS_ARB, flags,
        0,
      ];
      opengl_platform.ctx = wglCreateContextAttribsARB(platform_hdc, null, attribs.ptr);
      wglMakeCurrent(platform_hdc, opengl_platform.ctx);

      static foreach (member; __traits(allMembers, basic.opengl)) {
        static if (is(typeof(__traits(getMember, basic.opengl, member)) == function)) {
          static foreach (attribute; __traits(getAttributes, __traits(getMember, basic.opengl, member))) {
            static if (is(typeof(attribute) == basic.opengl.gl_version)) {
              static if (attribute.major != 1 || attribute.minor > 1) {
                mixin(member~" = cast(typeof("~member~")) wglGetProcAddress(\""~member~"\");");
              }
            }
          }
        }
      }

      opengl_platform.initted = true;
    }

    void opengl_platform_deinit() {
      if (opengl_platform.ctx) wglDeleteContext(opengl_platform.ctx);
      opengl_platform = opengl_platform.init;
    }

    void opengl_platform_resize() {
      if (!opengl_platform.initted || platform_size[0] == 0 || platform_size[1] == 0) return;
    }

    void opengl_platform_present() {
      if (!opengl_platform.initted) return;
      SwapBuffers(platform_hdc);
    }
  }

  struct OpenGL_Data {
    u32 main_fbo;
    u32 main_fbo_color0;
    u32 main_fbo_depth;

    u32 triangle_shader;
    u32 triangle_vao;
  }

  __gshared OpenGL_Data opengl;

  extern(System) void opengl_debug_proc(u32 source, u32 type, u32 id, u32 severity, u32 length, const(char)* message, const(void)* param) {
    import main : platform_log, platform_error;
    auto log = type == GL_DEBUG_TYPE_ERROR ? &platform_error : &platform_log;
    log(message[0..length]);
  }

  void opengl_init() {
    static if (__traits(compiles, opengl_platform_init))
      opengl_platform_init();

    debug {
      glEnable(GL_DEBUG_OUTPUT);
      glDebugMessageCallback(&opengl_debug_proc, null);
    }

    glClipControl(GL_LOWER_LEFT, GL_ZERO_TO_ONE);

    glCreateFramebuffers(1, &opengl.main_fbo);
    glCreateRenderbuffers(1, &opengl.main_fbo_color0);
    glCreateRenderbuffers(1, &opengl.main_fbo_depth);

    u32 triangle_vbo = void;
    glCreateBuffers(1, &triangle_vbo);
    glNamedBufferData(triangle_vbo, triangle_vertices.length * triangle_vertices[0].sizeof, triangle_vertices.ptr, GL_STATIC_DRAW);

    u32 triangle_ebo = void;
    glCreateBuffers(1, &triangle_ebo);
    glNamedBufferData(triangle_ebo, triangle_elements.length * triangle_elements[0].sizeof, triangle_elements.ptr, GL_STATIC_DRAW);

    u32 vbo_binding = 0;
    glCreateVertexArrays(1, &opengl.triangle_vao);
    glVertexArrayElementBuffer(opengl.triangle_vao, triangle_ebo);
    glVertexArrayVertexBuffer(opengl.triangle_vao, vbo_binding, triangle_vbo, 0, TriangleVertex.sizeof);

    u32 position_attrib = 0;
    glEnableVertexArrayAttrib(opengl.triangle_vao, position_attrib);
    glVertexArrayAttribBinding(opengl.triangle_vao, position_attrib, vbo_binding);
    glVertexArrayAttribFormat(opengl.triangle_vao, position_attrib, 3, GL_FLOAT, false, TriangleVertex.position.offsetof);

    u32 color_attrib = 1;
    glEnableVertexArrayAttrib(opengl.triangle_vao, color_attrib);
    glVertexArrayAttribBinding(opengl.triangle_vao, color_attrib, vbo_binding);
    glVertexArrayAttribFormat(opengl.triangle_vao, color_attrib, 4, GL_FLOAT, false, TriangleVertex.color.offsetof);

    string vsrc =
    `#version 450

    layout(location = 0) in vec3 a_position;
    layout(location = 1) in vec4 a_color;

    layout(location = 1) out vec4 f_color;

    void main() {
      gl_Position = vec4(a_position, 1.0);
      f_color = a_color;
    }`;
    const(char)*[1] vsrcs = [vsrc.ptr];
    u32 vshader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vshader, cast(u32) vsrcs.length, vsrcs.ptr, null);
    glCompileShader(vshader);

    string fsrc =
    `#version 450

    layout(location = 1) in vec4 f_color;

    layout(location = 0) out vec4 color;

    void main() {
      color = f_color;
    }`;
    const(char)*[1] fsrcs = [fsrc.ptr];
    u32 fshader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fshader, cast(u32) fsrcs.length, fsrcs.ptr, null);
    glCompileShader(fshader);

    opengl.triangle_shader = glCreateProgram();
    glAttachShader(opengl.triangle_shader, vshader);
    glAttachShader(opengl.triangle_shader, fshader);
    glLinkProgram(opengl.triangle_shader);
    glDetachShader(opengl.triangle_shader, fshader);
    glDetachShader(opengl.triangle_shader, vshader);

    glDeleteShader(fshader);
    glDeleteShader(vshader);
  }

  void opengl_deinit() {
    opengl = opengl.init;
    static if (__traits(compiles, opengl_platform_deinit))
      opengl_platform_deinit();
  }

  void opengl_resize() {
    static if (__traits(compiles, opengl_platform_resize))
      opengl_platform_resize();

    if (platform_size[0] == 0 || platform_size[1] == 0) return;

    glViewport(0, 0, platform_size[0], platform_size[1]);

    s32 fbo_color_samples_max = void;
    glGetIntegerv(GL_MAX_COLOR_TEXTURE_SAMPLES, &fbo_color_samples_max);
    s32 fbo_depth_samples_max = void;
    glGetIntegerv(GL_MAX_DEPTH_TEXTURE_SAMPLES, &fbo_depth_samples_max);
    u32 fbo_samples = max(1, min(fbo_color_samples_max, fbo_depth_samples_max));

    glNamedRenderbufferStorageMultisample(opengl.main_fbo_color0, fbo_samples, GL_RGBA16F, platform_size[0], platform_size[1]);
    glNamedFramebufferRenderbuffer(opengl.main_fbo, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, opengl.main_fbo_color0);

    glNamedRenderbufferStorageMultisample(opengl.main_fbo_depth, fbo_samples, GL_DEPTH_COMPONENT32F, platform_size[0], platform_size[1]);
    glNamedFramebufferRenderbuffer(opengl.main_fbo, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, opengl.main_fbo_depth);
  }

  void opengl_present(game.Renderer* game_renderer) {
    glClearNamedFramebufferfv(opengl.main_fbo, GL_COLOR, 0, game_renderer.clear_color0.ptr);
    glClearNamedFramebufferfv(opengl.main_fbo, GL_DEPTH, 0, &game_renderer.clear_depth);

    glBindFramebuffer(GL_FRAMEBUFFER, opengl.main_fbo);
    glFrontFace(GL_CW);
    glEnable(GL_CULL_FACE);
    glDepthFunc(GL_GEQUAL);
    glEnable(GL_DEPTH_TEST);
    glUseProgram(opengl.triangle_shader);
    glBindVertexArray(opengl.triangle_vao);
    glDrawElements(GL_TRIANGLES, cast(u32) triangle_elements.length, GL_UNSIGNED_SHORT, cast(void*) 0);
    debug {
      glDisable(GL_DEPTH_TEST);
      glDisable(GL_CULL_FACE);
      glBindVertexArray(0);
      glUseProgram(0);
      glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }

    glClear(0); // NOTE(dfra): this fixes intel default framebuffer bug.

    glEnable(GL_FRAMEBUFFER_SRGB);
    glBlitNamedFramebuffer(opengl.main_fbo, 0,
      0, 0, platform_size[0], platform_size[1],
      0, 0, platform_size[0], platform_size[1],
      GL_COLOR_BUFFER_BIT, GL_NEAREST);
    glDisable(GL_FRAMEBUFFER_SRGB);

    static if (__traits(compiles, opengl_platform_present))
      opengl_platform_present();
  }

  __gshared immutable opengl_renderer = Platform_Renderer(
    &opengl_init,
    &opengl_deinit,
    &opengl_resize,
    &opengl_present,
  );
}
