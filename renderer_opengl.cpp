// 1.0
#define GL_COLOR_BUFFER_BIT 0x00004000
#define GL_TRIANGLES 0x0004
#define GL_GEQUAL 0x0206
#define GL_SRC_ALPHA 0x0302
#define GL_ONE_MINUS_SRC_ALPHA 0x0303
#define GL_FRONT_AND_BACK 0x0408
#define GL_CW 0x0900
#define GL_CCW 0x0901
#define GL_CULL_FACE 0x0B44
#define GL_DEPTH_TEST 0x0B71
#define GL_BLEND 0x0BE2
#define GL_TEXTURE_2D 0x0DE1
#define GL_UNSIGNED_BYTE 0x1401
#define GL_UNSIGNED_SHORT 0x1403
#define GL_UNSIGNED_INT 0x1405
#define GL_FLOAT 0x1406
#define GL_COLOR 0x1800
#define GL_DEPTH 0x1801
#define GL_RED 0x1903
#define GL_GREEN 0x1904
#define GL_BLUE 0x1905
#define GL_ALPHA 0x1906
#define GL_RGB 0x1907
#define GL_RGBA 0x1908
#define GL_POINT 0x1B00
#define GL_LINE 0x1B01
#define GL_FILL 0x1B02
#define GL_VENDOR 0x1F00
#define GL_RENDERER 0x1F01
#define GL_VERSION 0x1F02
#define GL_NEAREST 0x2600
#define GL_LINEAR 0x2601
#define GL_NEAREST_MIPMAP_NEAREST 0x2700
#define GL_LINEAR_MIPMAP_NEAREST 0x2701
#define GL_NEAREST_MIPMAP_LINEAR 0x2702
#define GL_LINEAR_MIPMAP_LINEAR 0x2703
#define GL_TEXTURE_MAG_FILTER 0x2800
#define GL_TEXTURE_MIN_FILTER 0x2801
#define GL_TEXTURE_WRAP_S 0x2802
#define GL_TEXTURE_WRAP_T 0x2803
#define GL_REPEAT 0x2901

#define GL10_FUNCTIONS \
  X(void, glEnable, u32) \
  X(void, glDisable, u32) \
  X(const char*, glGetString, u32) \
  X(void, glGetIntegerv, u32, s32*) \
  X(void, glFrontFace, u32) \
  X(void, glDepthFunc, u32) \
  X(void, glBlendFunc, u32, u32) \
  X(void, glViewport, s32, s32, u32, u32) \
  X(void, glClearColor, f32, f32, f32, f32) \
  X(void, glClear, u32)

// 1.1
#define GL11_FUNCTIONS \
  X(void, glDrawElements, u32, u32, u32, const void*)

// 1.5
#define GL_STATIC_DRAW 0x88E4
#define GL_DYNAMIC_DRAW 0x88E8

// 2.0
#define GL_FRAGMENT_SHADER 0x8B30
#define GL_VERTEX_SHADER 0x8B31
#define GL_LOWER_LEFT 0x8CA1

#define GL20_FUNCTIONS \
  X(u32, glCreateProgram, void) \
  X(void, glAttachShader, u32, u32) \
  X(void, glDetachShader, u32, u32) \
  X(void, glLinkProgram, u32) \
  X(void, glUseProgram, u32) \
  X(u32, glCreateShader, u32) \
  X(void, glShaderSource, u32, u32, const char* const*, const s32*) \
  X(void, glCompileShader, u32)

// 3.0
#define GL_RGBA16F 0x881A
#define GL_DEPTH_COMPONENT32F 0x8CAC
#define GL_COLOR_ATTACHMENT0 0x8CE0
#define GL_COLOR_ATTACHMENT1 0x8CE1
#define GL_DEPTH_ATTACHMENT 0x8D00
#define GL_FRAMEBUFFER 0x8D40
#define GL_RENDERBUFFER 0x8D41
#define GL_FRAMEBUFFER_SRGB 0x8DB9

#define GL30_FUNCTIONS \
  X(void, glBindFramebuffer, u32, u32) \
  X(void, glBindVertexArray, u32)

// 3.1
#define GL31_FUNCTIONS \
  X(void, glDrawElementsInstanced, u32, u32, u32, const void*, u32)

// 3.2
#define GL_MAX_COLOR_TEXTURE_SAMPLES 0x910E
#define GL_MAX_DEPTH_TEXTURE_SAMPLES 0x910F

// 4.3
#define GL_DEBUG_OUTPUT 0x92E0

typedef void (*GLDEBUGPROC)(u32, u32, u32, u32, u32, const char*, const void*); // @Cleanup callconv

#define GL43_FUNCTIONS \
  X(void, glDebugMessageCallback, GLDEBUGPROC, const void*)

// 4.5
#define GL_ZERO_TO_ONE 0x935F

#define GL45_FUNCTIONS \
  X(void, glClipControl, u32, u32) \
  X(void, glCreateFramebuffers, u32, u32*) \
  X(void, glNamedFramebufferRenderbuffer, u32, u32, u32, u32) \
  X(void, glClearNamedFramebufferfv, u32, u32, s32, const f32*) \
  X(void, glBlitNamedFramebuffer, u32, u32, s32, s32, s32, s32, s32, s32, s32, s32, u32, u32) \
  X(void, glCreateRenderbuffers, u32, u32*) \
  X(void, glNamedRenderbufferStorageMultisample, u32, u32, u32, u32, u32) \
  X(void, glCreateVertexArrays, u32, u32*) \
  X(void, glVertexArrayElementBuffer, u32, u32) \
  X(void, glVertexArrayVertexBuffer, u32, u32, u32, ssize, u32) \
  X(void, glVertexArrayBindingDivisor, u32, u32, u32) \
  X(void, glEnableVertexArrayAttrib, u32, u32) \
  X(void, glVertexArrayAttribBinding, u32, u32, u32) \
  X(void, glVertexArrayAttribFormat, u32, u32, s32, u32, bool, u32) \
  X(void, glCreateBuffers, u32, u32*) \
  X(void, glNamedBufferData, u32, ssize, const void*, u32) \
  X(void, glNamedBufferSubData, u32, ssize, ssize, const void*)

#if OP_OS_WINDOWS
  #define WGL_CONTEXT_MAJOR_VERSION_ARB 0x2091
  #define WGL_CONTEXT_MINOR_VERSION_ARB 0x2092
  #define WGL_CONTEXT_LAYER_PLANE_ARB 0x2093
  #define WGL_CONTEXT_FLAGS_ARB 0x2094
  #define WGL_CONTEXT_PROFILE_MASK_ARB 0x9126
  #define WGL_CONTEXT_DEBUG_BIT_ARB 0x0001
  #define WGL_CONTEXT_CORE_PROFILE_BIT_ARB 0x00000001

  static HGLRC platform_hglrc;

  #define X(RET, NAME, ...) extern "C" RET WINAPI NAME(__VA_ARGS__);
    GL10_FUNCTIONS
    GL11_FUNCTIONS
  #undef X
  #define X(RET, NAME, ...) static RET (WINAPI* NAME)(__VA_ARGS__);
    GL20_FUNCTIONS
    GL30_FUNCTIONS
    GL31_FUNCTIONS
    GL43_FUNCTIONS
    GL45_FUNCTIONS
  #undef X

  static void opengl_platform_init() {
    PIXELFORMATDESCRIPTOR pfd = {};
    pfd.nSize = sizeof(PIXELFORMATDESCRIPTOR);
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
    pfd.cColorBits = 24;
    s32 format = ChoosePixelFormat(platform_hdc, &pfd);
    SetPixelFormat(platform_hdc, format, &pfd);

    HGLRC temp_ctx = wglCreateContext(platform_hdc);
    wglMakeCurrent(platform_hdc, temp_ctx);

    typedef HGLRC (WINAPI* PFN_wglCreateContextAttribsARB)(HDC, HGLRC, s32*);
    auto wglCreateContextAttribsARB = cast(
      PFN_wglCreateContextAttribsARB,
      wglGetProcAddress("wglCreateContextAttribsARB"));

    static s32 attribs[] = {
      WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
      WGL_CONTEXT_MINOR_VERSION_ARB, 5,
      WGL_CONTEXT_FLAGS_ARB, OP_DEBUG ? WGL_CONTEXT_DEBUG_BIT_ARB : 0,
      WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
      0,
    };
    platform_hglrc = wglCreateContextAttribsARB(platform_hdc, nullptr, attribs);
    wglMakeCurrent(platform_hdc, platform_hglrc);

    #define X(RET, NAME, ...) NAME = cast(RET (WINAPI*)(__VA_ARGS__), wglGetProcAddress(#NAME));
      GL20_FUNCTIONS
      GL30_FUNCTIONS
      GL31_FUNCTIONS
      GL43_FUNCTIONS
      GL45_FUNCTIONS
    #undef X

    wglDeleteContext(temp_ctx);
  }

  static void opengl_platform_deinit() {
    if (platform_hglrc) {
      wglMakeCurrent(platform_hdc, nullptr);
      wglDeleteContext(platform_hglrc);
    }
    platform_hglrc = nullptr;
  }

  static void opengl_platform_present() {
    SwapBuffers(platform_hdc);
  }
#endif

struct OpenGL_Quad_Instance {
  m4 transform;
};

static struct {
  bool initted;

  u32 main_fbo;
  u32 main_fbo_color0;
  u32 main_fbo_depth;

  u32 quad_shader;
  u32 quad_vao;
  u32 quad_ibo;
} opengl;

static void opengl_debug_proc(u32 source, u32 type, u32 id, u32 severity, u32 length, const char *message, const void *param) {
  (void) source; (void) type; (void) id; (void) severity; (void) param;
  platform_log({length, message});
}

static void opengl_init() {
  opengl_platform_init();

  #if OP_DEBUG
    glEnable(GL_DEBUG_OUTPUT);
    glDebugMessageCallback(opengl_debug_proc, nullptr);

    platform_log("OpenGL Renderer Info:");
    platform_log(glGetString(GL_VENDOR));
    platform_log(glGetString(GL_RENDERER));
    platform_log(glGetString(GL_VERSION));
  #endif

  glClipControl(GL_LOWER_LEFT, GL_ZERO_TO_ONE);

  glCreateFramebuffers(1, &opengl.main_fbo);
  glCreateRenderbuffers(1, &opengl.main_fbo_color0);
  glCreateRenderbuffers(1, &opengl.main_fbo_depth);

  {
    string vsrc =
    "#version 450\n"
    "layout(location = 0) in vec3 a_position;\n"
    "layout(location = 1) in vec2 a_texcoord;\n"
    "layout(location = 2) in mat4 i_transform;\n"
    "layout(location = 1) out vec2 f_texcoord;\n"
    "void main() {\n"
    "  gl_Position = i_transform * vec4(a_position, 1.0);\n"
    "  f_texcoord = a_texcoord;\n"
    "}\n";
    const char* vsrcs[1] = {vsrc.data};
    u32 vshader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vshader, 1, vsrcs, nullptr);
    glCompileShader(vshader);

    string fsrc =
    "#version 450\n"
    "layout(location = 1) in vec2 f_texcoord;\n"
    "layout(location = 0) out vec4 color;\n"
    "void main() {\n"
    "  color = vec4(f_texcoord, 0.0, 1.0);\n"
    "}\n";
    const char* fsrcs[1] = {fsrc.data};
    u32 fshader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fshader, 1, fsrcs, nullptr);
    glCompileShader(fshader);

    opengl.quad_shader = glCreateProgram();
    glAttachShader(opengl.quad_shader, vshader);
    glAttachShader(opengl.quad_shader, fshader);
    glLinkProgram(opengl.quad_shader);
    glDetachShader(opengl.quad_shader, fshader);
    glDetachShader(opengl.quad_shader, vshader);
  }

  u32 quad_vbo;
  glCreateBuffers(1, &quad_vbo);
  glNamedBufferData(quad_vbo, size_of(quad_vertices), quad_vertices, GL_STATIC_DRAW);

  u32 quad_ebo;
  glCreateBuffers(1, &quad_ebo);
  glNamedBufferData(quad_ebo, size_of(quad_indices), quad_indices, GL_STATIC_DRAW);

  glCreateBuffers(1, &opengl.quad_ibo);
  glNamedBufferData(opengl.quad_ibo, type_of_field(Game_Renderer, quad_instances)::capacity * sizeof(OpenGL_Quad_Instance), nullptr, GL_DYNAMIC_DRAW);

  u32 vbo_binding = 0;
  u32 ibo_binding = 1;
  glCreateVertexArrays(1, &opengl.quad_vao);
  glVertexArrayElementBuffer(opengl.quad_vao, quad_ebo);
  glVertexArrayVertexBuffer(opengl.quad_vao, vbo_binding, quad_vbo, 0, sizeof(Game_Quad_Vertex));
  glVertexArrayVertexBuffer(opengl.quad_vao, ibo_binding, opengl.quad_ibo, 0, sizeof(OpenGL_Quad_Instance));
  glVertexArrayBindingDivisor(opengl.quad_vao, ibo_binding, 1);

  u32 position_attrib = 0;
  glEnableVertexArrayAttrib(opengl.quad_vao, position_attrib);
  glVertexArrayAttribBinding(opengl.quad_vao, position_attrib, vbo_binding);
  glVertexArrayAttribFormat(opengl.quad_vao, position_attrib, 3, GL_FLOAT, false, offset_of(Game_Quad_Vertex, position));

  u32 texcoord_attrib = 1;
  glEnableVertexArrayAttrib(opengl.quad_vao, texcoord_attrib);
  glVertexArrayAttribBinding(opengl.quad_vao, texcoord_attrib, vbo_binding);
  glVertexArrayAttribFormat(opengl.quad_vao, texcoord_attrib, 2, GL_FLOAT, false, offset_of(Game_Quad_Vertex, texcoord));

  for (u32 i = 2; i < 6; i += 1) {
    glEnableVertexArrayAttrib(opengl.quad_vao, i);
    glVertexArrayAttribBinding(opengl.quad_vao, i, ibo_binding);
    glVertexArrayAttribFormat(opengl.quad_vao, i, 4, GL_FLOAT, false, offset_of(OpenGL_Quad_Instance, transform) + (i - 2) * sizeof(v4));
  }

  opengl.initted = true;
}

static void opengl_deinit() {
  opengl_platform_deinit();
}

static void opengl_resize() {
  if (!opengl.initted || platform_size[0] == 0 || platform_size[1] == 0) return;

  s32 fbo_color_samples_max;
  glGetIntegerv(GL_MAX_COLOR_TEXTURE_SAMPLES, &fbo_color_samples_max);
  s32 fbo_depth_samples_max;
  glGetIntegerv(GL_MAX_DEPTH_TEXTURE_SAMPLES, &fbo_depth_samples_max);
  u32 fbo_samples = cast(u32, max(1, min(fbo_color_samples_max, fbo_depth_samples_max)));

  glNamedRenderbufferStorageMultisample(opengl.main_fbo_color0, fbo_samples, GL_RGBA16F, platform_size[0], platform_size[1]);
  glNamedFramebufferRenderbuffer(opengl.main_fbo, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, opengl.main_fbo_color0);

  glNamedRenderbufferStorageMultisample(opengl.main_fbo_depth, fbo_samples, GL_DEPTH_COMPONENT32F, platform_size[0], platform_size[1]);
  glNamedFramebufferRenderbuffer(opengl.main_fbo, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, opengl.main_fbo_depth);
}

static void opengl_present(Game_Renderer* game_renderer) {
  if (!opengl.initted || platform_size[0] == 0 || platform_size[1] == 0) return;

  f32 clear_depth = 0.0f;
  glClearNamedFramebufferfv(opengl.main_fbo, GL_DEPTH, 0, &clear_depth);
  glClearNamedFramebufferfv(opengl.main_fbo, GL_COLOR, 0, game_renderer->clear_color0);

  static OpenGL_Quad_Instance quad_instances[type_of_field(Game_Renderer, quad_instances)::capacity];
  usize quad_instances_count = 0;
  for (usize i = 0; i < game_renderer->quad_instances.count; i += 1) {
    quad_instances[quad_instances_count++].transform = m4_translate<true>(game_renderer->quad_instances[i].position);
  }
  glNamedBufferSubData(opengl.quad_ibo, 0, quad_instances_count * sizeof(OpenGL_Quad_Instance), quad_instances);

  glViewport(0, 0, platform_size[0], platform_size[1]);
  glBindFramebuffer(GL_FRAMEBUFFER, opengl.main_fbo);
  glDepthFunc(GL_GEQUAL);
  glEnable(GL_DEPTH_TEST);
  glFrontFace(GL_CW);
  glEnable(GL_CULL_FACE);
  glUseProgram(opengl.quad_shader);
  glBindVertexArray(opengl.quad_vao);
  glDrawElementsInstanced(GL_TRIANGLES, cast(u32, len(quad_indices)), GL_UNSIGNED_SHORT, cast(void*, 0), cast(u32, quad_instances_count));

  #if OP_DEBUG
    glBindVertexArray(0);
    glUseProgram(0);
    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
  #endif

  glClear(0); // NOTE(dfra): this fixes intel default framebuffer resize bug.

  glEnable(GL_FRAMEBUFFER_SRGB);
  glBlitNamedFramebuffer(opengl.main_fbo, 0,
    0, 0, platform_size[0], platform_size[1],
    0, 0, platform_size[0], platform_size[1],
    GL_COLOR_BUFFER_BIT, GL_NEAREST);
  glDisable(GL_FRAMEBUFFER_SRGB);

  opengl_platform_present();
}

static Platform_Renderer opengl_renderer = {
  opengl_init,
  opengl_deinit,
  opengl_resize,
  opengl_present,
};
