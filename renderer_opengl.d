import basic;
import basic.maths;
static import game;
import renderer : Platform_Renderer;
import static_meshes;

version (Windows) {
  import basic.windows;

  enum WGL_CONTEXT_MAJOR_VERSION_ARB = 0x2091;
  enum WGL_CONTEXT_MINOR_VERSION_ARB = 0x2092;
  enum WGL_CONTEXT_FLAGS_ARB = 0x2094;
  enum WGL_CONTEXT_PROFILE_MASK_ARB = 0x9126;
  enum WGL_CONTEXT_DEBUG_BIT_ARB = 0x0001;
  enum WGL_CONTEXT_CORE_PROFILE_BIT_ARB = 0x00000001;

  struct OpenGL_Platform_Data {
    HGLRC ctx;
    HDC hdc;
  }

  __gshared OpenGL_Platform_Data opengl_platform;

  static import basic.opengl;
  static foreach (member; __traits(allMembers, basic.opengl)) {
    static if (is(typeof(__traits(getMember, basic.opengl, member)) == function) &&
      (__traits(getAttributes, __traits(getMember, basic.opengl, member))[0].major != 1 ||
      __traits(getAttributes, __traits(getMember, basic.opengl, member))[0].minor > 1))
    {
      mixin("__gshared typeof(basic.opengl."~member~")* "~member~";");
    } else static if (!__traits(isModule, __traits(getMember, basic.opengl, member))) {
      mixin("alias "~member~" = basic.opengl."~member~";");
    }
  }

  bool opengl_platform_init(Platform_Renderer.Init_Data* init_data) {
    opengl_platform.hdc = init_data.hdc;

    PIXELFORMATDESCRIPTOR pfd;
    pfd.nSize = PIXELFORMATDESCRIPTOR.sizeof;
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
    pfd.cColorBits = 24;
    s32 format = ChoosePixelFormat(init_data.hdc, &pfd);
    SetPixelFormat(init_data.hdc, format, &pfd);

    HGLRC temp_ctx = wglCreateContext(init_data.hdc);
    wglMakeCurrent(init_data.hdc, temp_ctx);

    alias PFN_wglCreateContextAttribsARB = extern(Windows) HGLRC function(HDC, HGLRC, const(s32)*);
    auto wglCreateContextAttribsARB =
      cast(PFN_wglCreateContextAttribsARB)
      wglGetProcAddress("wglCreateContextAttribsARB");

    debug enum flags = WGL_CONTEXT_DEBUG_BIT_ARB;
    else  enum flags = 0;
    __gshared immutable s32[9] attribs = [
      WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
      WGL_CONTEXT_MINOR_VERSION_ARB, 5,
      WGL_CONTEXT_FLAGS_ARB, flags,
      WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
      0,
    ];
    opengl_platform.ctx = wglCreateContextAttribsARB(init_data.hdc, null, attribs.ptr);
    wglMakeCurrent(init_data.hdc, opengl_platform.ctx);

    wglDeleteContext(temp_ctx);

    static foreach (member; __traits(allMembers, basic.opengl)) {
      static if (is(typeof(__traits(getMember, basic.opengl, member)) == function) &&
        (__traits(getAttributes, __traits(getMember, basic.opengl, member))[0].major != 1 ||
        __traits(getAttributes, __traits(getMember, basic.opengl, member))[0].minor > 1))
      {
        mixin(member~" = cast(typeof("~member~")) wglGetProcAddress(\""~member~"\");");
      }
    }

    return true;
  }

  void opengl_platform_deinit() {
    wglDeleteContext(opengl_platform.ctx);
    opengl_platform = opengl_platform.init;
  }

  void opengl_platform_present() {
    if (!opengl_platform.hdc) return;
    SwapBuffers(opengl_platform.hdc);
  }

  pragma(lib, "gdi32");
  pragma(lib, "opengl32");
}

struct OpenGL_Data {
  bool initted;
  void function(const(char)[]) log;
  u16[2] size;

  u32 main_fbo;
  u32 main_fbo_color0;
  u32 main_fbo_depth;

  u32 mesh_shader;
  u32 mesh_vao;
  u32 mesh_ibo;
}

__gshared OpenGL_Data opengl;

extern(System) void opengl_debug_proc(u32 source, u32 type, u32 id, u32 severity, u32 length, const(char)* message, const(void)* param) {
  opengl.log(message[0..length]);
}

void opengl_init(Platform_Renderer.Init_Data* init_data) {
  opengl.initted = opengl_platform_init(init_data);
  opengl.log = init_data.log;

  debug {
    glEnable(GL_DEBUG_OUTPUT);
    glDebugMessageCallback(&opengl_debug_proc, null);
  }

  glClipControl(GL_LOWER_LEFT, GL_ZERO_TO_ONE);

  glCreateFramebuffers(1, &opengl.main_fbo);
  glCreateRenderbuffers(1, &opengl.main_fbo_color0);
  glCreateRenderbuffers(1, &opengl.main_fbo_depth);

  {
    string vsrc =
    `#version 450

    layout(location = 0) in vec3 a_position;
    layout(location = 1) in vec3 a_normal;
    layout(location = 2) in vec2 a_texcoord;
    layout(location = 3) in uint a_texture_index;
    layout(location = 4) in mat4 i_world_transform;
    layout(location = 8) in mat4 i_model_transform;

    layout(location = 2) out vec2 f_texcoord;

    void main() {
      gl_Position = i_world_transform * vec4(a_position, 1.0);
      f_texcoord = a_texcoord;
    }
    `;
    const(char)*[1] vsrcs = [vsrc.ptr];
    u32 vshader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vshader, vsrcs.length, vsrcs.ptr, null);
    glCompileShader(vshader);

    string fsrc =
    `#version 450

    layout(location = 2) in vec2 f_texcoord;

    layout(location = 0) out vec4 color;

    void main() {
      color = vec4(f_texcoord, 0.0, 1.0);
    }
    `;
    const(char)*[1] fsrcs = [fsrc.ptr];
    u32 fshader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fshader, fsrcs.length, fsrcs.ptr, null);
    glCompileShader(fshader);

    opengl.mesh_shader = glCreateProgram();
    glAttachShader(opengl.mesh_shader, vshader);
    glAttachShader(opengl.mesh_shader, fshader);
    glLinkProgram(opengl.mesh_shader);
    glDetachShader(opengl.mesh_shader, fshader);
    glDetachShader(opengl.mesh_shader, vshader);

    glDeleteShader(fshader);
    glDeleteShader(vshader);
  }

  {
    u32 mesh_vbo = void;
    glCreateBuffers(1, &mesh_vbo);
    glNamedBufferData(mesh_vbo, mesh_vertices.length * mesh_vertices[0].sizeof, mesh_vertices.ptr, GL_STATIC_DRAW);

    u32 mesh_ebo = void;
    glCreateBuffers(1, &mesh_ebo);
    glNamedBufferData(mesh_ebo, mesh_indices.length * mesh_indices[0].sizeof, mesh_indices.ptr, GL_STATIC_DRAW);

    glCreateBuffers(1, &opengl.mesh_ibo);
    glNamedBufferData(opengl.mesh_ibo, game.Game_Renderer.meshes.N * game.Game_Mesh_Instance.sizeof, null, GL_DYNAMIC_DRAW);

    u32 vbo_binding = 0;
    u32 ibo_binding = 1;
    glCreateVertexArrays(1, &opengl.mesh_vao);
    glVertexArrayVertexBuffer(opengl.mesh_vao, vbo_binding, mesh_vbo, 0, game.Game_Mesh_Vertex.sizeof);
    glVertexArrayVertexBuffer(opengl.mesh_vao, ibo_binding, opengl.mesh_ibo, 0, game.Game_Mesh_Instance.sizeof);
    glVertexArrayBindingDivisor(opengl.mesh_vao, ibo_binding, 1);
    glVertexArrayElementBuffer(opengl.mesh_vao, mesh_ebo);

    u32 position_attrib = 0;
    glEnableVertexArrayAttrib(opengl.mesh_vao, position_attrib);
    glVertexArrayAttribBinding(opengl.mesh_vao, position_attrib, vbo_binding);
    glVertexArrayAttribFormat(opengl.mesh_vao, position_attrib, 3, GL_FLOAT, false, game.Game_Mesh_Vertex.position.offsetof);

    u32 normal_attrib = 1;
    glEnableVertexArrayAttrib(opengl.mesh_vao, normal_attrib);
    glVertexArrayAttribBinding(opengl.mesh_vao, normal_attrib, vbo_binding);
    glVertexArrayAttribFormat(opengl.mesh_vao, normal_attrib, 3, GL_FLOAT, false, game.Game_Mesh_Vertex.normal.offsetof);

    u32 texcoord_attrib = 2;
    glEnableVertexArrayAttrib(opengl.mesh_vao, texcoord_attrib);
    glVertexArrayAttribBinding(opengl.mesh_vao, texcoord_attrib, vbo_binding);
    glVertexArrayAttribFormat(opengl.mesh_vao, texcoord_attrib, 2, GL_FLOAT, false, game.Game_Mesh_Vertex.texcoord.offsetof);

    u32 texture_index_attrib = 3;
    glEnableVertexArrayAttrib(opengl.mesh_vao, texture_index_attrib);
    glVertexArrayAttribBinding(opengl.mesh_vao, texture_index_attrib, vbo_binding);
    glVertexArrayAttribIFormat(opengl.mesh_vao, texture_index_attrib, 1, GL_UNSIGNED_INT, game.Game_Mesh_Vertex.texture_index.offsetof);

    enum world_transform_attrib = 4;
    static foreach (i; world_transform_attrib..world_transform_attrib + 4) {
      glEnableVertexArrayAttrib(opengl.mesh_vao, i);
      glVertexArrayAttribBinding(opengl.mesh_vao, i, ibo_binding);
      glVertexArrayAttribFormat(opengl.mesh_vao, i, 4, GL_FLOAT, false, game.Game_Mesh_Instance.world_transform.offsetof + (i - world_transform_attrib) * v4.sizeof);
    }

    enum model_transform_attrib = 8;
    static foreach (i; model_transform_attrib..model_transform_attrib + 4) {
      glEnableVertexArrayAttrib(opengl.mesh_vao, i);
      glVertexArrayAttribBinding(opengl.mesh_vao, i, ibo_binding);
      glVertexArrayAttribFormat(opengl.mesh_vao, i, 4, GL_FLOAT, false, game.Game_Mesh_Instance.model_transform.offsetof + (i - model_transform_attrib) * v4.sizeof);
    }
  }
}

void opengl_deinit() {
  opengl = opengl.init;
  opengl_platform_deinit();
}

void opengl_resize(u16[2] size) {
  opengl.size = size;
  if (!opengl.initted || opengl.size[0] == 0 || opengl.size[1] == 0) return;

  s32 fbo_color_samples_max = void;
  glGetIntegerv(GL_MAX_COLOR_TEXTURE_SAMPLES, &fbo_color_samples_max);
  s32 fbo_depth_samples_max = void;
  glGetIntegerv(GL_MAX_DEPTH_TEXTURE_SAMPLES, &fbo_depth_samples_max);
  u32 fbo_samples = cast(u32) max(1, min(fbo_color_samples_max, fbo_depth_samples_max, 16));

  if (fbo_samples == 16) opengl.log("Samples: 16"); // @StringFormatting
  else if (fbo_samples == 8) opengl.log("Samples: 8");
  else if (fbo_samples == 4) opengl.log("Samples: 4");
  else if (fbo_samples == 2) opengl.log("Samples: 2");
  else if (fbo_samples == 1) opengl.log("Samples: 1");

  glNamedRenderbufferStorageMultisample(opengl.main_fbo_color0, fbo_samples, GL_RGBA16F, size[0], size[1]);
  glNamedFramebufferRenderbuffer(opengl.main_fbo, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, opengl.main_fbo_color0);

  glNamedRenderbufferStorageMultisample(opengl.main_fbo_depth, fbo_samples, GL_DEPTH_COMPONENT32F, size[0], size[1]);
  glNamedFramebufferRenderbuffer(opengl.main_fbo, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, opengl.main_fbo_depth);
}

void opengl_present(game.Game_Renderer* game_renderer) {
  if (!opengl.initted || opengl.size[0] == 0 || opengl.size[1] == 0) return;

  glClearNamedFramebufferfv(opengl.main_fbo, GL_COLOR, 0, game_renderer.clear_color0.ptr);

  glNamedBufferSubData(opengl.mesh_ibo, 0, game_renderer.meshes.length * game.Game_Mesh_Instance.sizeof, game_renderer.meshes.ptr);

  glBindFramebuffer(GL_FRAMEBUFFER, opengl.main_fbo);
  glViewport(0, 0, opengl.size[0], opengl.size[1]);
  glFrontFace(GL_CW);
  glEnable(GL_CULL_FACE);
  glDepthFunc(GL_GEQUAL);
  glEnable(GL_DEPTH_TEST);
  glUseProgram(opengl.mesh_shader);
  glBindVertexArray(opengl.mesh_vao);
  glDrawElements(GL_TRIANGLES, mesh_indices.length, GL_UNSIGNED_SHORT, cast(void*) 0);

  // NOTE(dfra): Clear(0) fixes intel default framebuffer resize bug.
  glBindFramebuffer(GL_FRAMEBUFFER, 0);
  glClear(0);

  glEnable(GL_FRAMEBUFFER_SRGB);
  glBlitNamedFramebuffer(opengl.main_fbo, 0,
    0, 0, opengl.size[0], opengl.size[1],
    0, 0, opengl.size[0], opengl.size[1],
    GL_COLOR_BUFFER_BIT, GL_NEAREST);
  glDisable(GL_FRAMEBUFFER_SRGB);

  opengl_platform_present();
}

immutable opengl_renderer = Platform_Renderer(
  &opengl_init,
  &opengl_deinit,
  &opengl_resize,
  &opengl_present,
);

version (DLL) mixin DLLExport!opengl_renderer;
