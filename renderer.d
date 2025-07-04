import basic;

version (Windows) {
  version = D3D11;
  version = OpenGL;
}

struct Platform_Renderer {
  void function() init_;
  void function() deinit;
  void function() resize;
  void function() present;
}

align(16) struct TriangleVertex {
  float[3] position;
}

__gshared immutable triangle_vertices = [
  TriangleVertex([+0.5, -0.5, 0.0]),
  TriangleVertex([-0.5, -0.5, 0.0]),
  TriangleVertex([+0.0, +0.5, 0.0]),
];

version (D3D11) {
  import basic.windows;
  import main : platform_hwnd, platform_size;

  struct D3D11_Data {
    bool initted;
    IDXGISwapChain* swapchain;
    ID3D11Device* device;
    ID3D11DeviceContext* ctx;

    ID3D11RenderTargetView* backbuffer_view;

    ID3D11VertexShader* triangle_vshader;
    ID3D11PixelShader* triangle_pshader;
    ID3D11InputLayout* triangle_input_layout;
    ID3D11Buffer* triangle_vbo;
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
      float4 vmain(float3 a_position : Position) : SV_Position {
        return float4(a_position, 1.0f);
      }

      float4 pmain() : SV_Target0 {
        return float4(1.0f, 1.0f, 1.0f, 1.0f);
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

      D3D11_INPUT_ELEMENT_DESC[1] input_descs;
      input_descs[0].SemanticName = "Position";
      input_descs[0].SemanticIndex = 0;
      input_descs[0].Format = DXGI_FORMAT.R32G32B32_FLOAT;
      input_descs[0].AlignedByteOffset = TriangleVertex.position.offsetof;
      input_descs[0].InputSlotClass = D3D11_INPUT_CLASSIFICATION.VERTEX_DATA;
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

      d3d11.initted = true;
      return;
    }
  error:
    d3d11_deinit();
  }

  void d3d11_deinit() {
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
    if (!d3d11.initted) return;
    {
      HRESULT hr = void;

      if (d3d11.backbuffer_view) d3d11.backbuffer_view.Release();

      ID3D11Texture2D* backbuffer = void;
      hr = d3d11.swapchain.GetBuffer(0, &backbuffer.uuidof, cast(void**) &backbuffer);
      if (hr < 0) goto error;
      scope(exit) backbuffer.Release();

      hr = d3d11.device.CreateRenderTargetView(cast(ID3D11Resource*) backbuffer, null, &d3d11.backbuffer_view);
      if (hr < 0) goto error;

      return;
    }
  error:
    d3d11_deinit();
  }

  void d3d11_present() {
    if (!d3d11.initted) return;
    float[4] clear_color0 = [0.6, 0.2, 0.2, 1.0];
    d3d11.ctx.ClearRenderTargetView(d3d11.backbuffer_view, clear_color0.ptr);

    D3D11_VIEWPORT viewport;
    viewport.Width = platform_size[0];
    viewport.Height = platform_size[1];
    viewport.MaxDepth = 1.0;
    d3d11.ctx.RSSetViewports(1, &viewport);
    d3d11.ctx.VSSetShader(d3d11.triangle_vshader, null, 0);
    d3d11.ctx.PSSetShader(d3d11.triangle_pshader, null, 0);
    d3d11.ctx.IASetInputLayout(d3d11.triangle_input_layout);
    d3d11.ctx.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY.TRIANGLELIST);
    d3d11.ctx.OMSetRenderTargets(1, &d3d11.backbuffer_view, null);
    u32 stride = TriangleVertex.sizeof;
    u32 offset = 0;
    d3d11.ctx.IASetVertexBuffers(0, 1, &d3d11.triangle_vbo, &stride, &offset);
    d3d11.ctx.Draw(3, 0);

    d3d11.swapchain.Present(1, 0);
  }

  __gshared immutable d3d11_renderer = Platform_Renderer(
    &d3d11_init,
    &d3d11_deinit,
    &d3d11_resize,
    &d3d11_present,
  );
}
