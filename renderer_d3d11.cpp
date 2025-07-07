#include <D3D11.h>
#include <Dxgi.h>
#include <D3Dcompiler.h>

struct D3D11_Quad_Instance {
  m4 transform;
};

struct D3D11_Mesh_Instance {
  m4 transform;
  Game_Mesh::Type mesh_index;
};

static struct {
  bool initted;

  IDXGISwapChain* swapchain;
  ID3D11Device* device;
  ID3D11DeviceContext* ctx;
  ID3D11DepthStencilState* depthbuffer_state;
  ID3D11VertexShader* fullscreen_vertex_shader;
  ID3D11PixelShader* tonemap_pixel_shader;
  ID3D11SamplerState* linear_sampler;

  ID3D11RenderTargetView* swapchain_backbuffer_view;
  ID3D11Texture2D* multisampled_backbuffer;
  ID3D11RenderTargetView* multisampled_backbuffer_view;
  ID3D11Texture2D* backbuffer;
  ID3D11ShaderResourceView* backbuffer_view;
  ID3D11Texture2D* depthbuffer;
  ID3D11DepthStencilView* depthbuffer_view;

  ID3D11Buffer* quad_vertex_buffer;
  ID3D11Buffer* quad_index_buffer;
  ID3D11Buffer* quad_instance_buffer;
  ID3D11VertexShader* quad_vertex_shader;
  ID3D11PixelShader* quad_pixel_shader;
  ID3D11InputLayout* quad_input_layout;

  ID3D11Texture2D* mesh_textures[Game_Mesh::COUNT];
  ID3D11ShaderResourceView* mesh_texture_views[Game_Mesh::COUNT];
  ID3D11Buffer* mesh_vertex_buffer;
  ID3D11Buffer* mesh_index_buffer;
  ID3D11Buffer* mesh_instance_buffer;
  ID3D11VertexShader* mesh_vertex_shader;
  ID3D11PixelShader* mesh_pixel_shader;
  ID3D11InputLayout* mesh_input_layout;
} d3d11;

static void d3d11_deinit();

static void d3d11_init() {
  HRESULT hr = 0;
  ID3DBlob* quad_vblob = nullptr;
  ID3DBlob* quad_pblob = nullptr;
  ID3DBlob* mesh_vblob = nullptr;
  ID3DBlob* mesh_pblob = nullptr;
  ID3DBlob* fullscreen_vblob = nullptr;
  ID3DBlob* fullscreen_pblob = nullptr;
  {
    DXGI_SWAP_CHAIN_DESC swapchain_descriptor = {};
    swapchain_descriptor.BufferDesc.Width = platform_size[0];
    swapchain_descriptor.BufferDesc.Height = platform_size[1];
    swapchain_descriptor.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM_SRGB;
    swapchain_descriptor.SampleDesc.Count = 1;
    swapchain_descriptor.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
    swapchain_descriptor.BufferCount = 1;
    swapchain_descriptor.OutputWindow = platform_hwnd;
    swapchain_descriptor.Windowed = true;
    swapchain_descriptor.Flags = DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH;
    hr = D3D11CreateDeviceAndSwapChain(nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr,
      D3D11_CREATE_DEVICE_DEBUG, nullptr, 0, D3D11_SDK_VERSION,
      &swapchain_descriptor, &d3d11.swapchain, &d3d11.device, nullptr, &d3d11.ctx);
    if (FAILED(hr)) goto defer;

    IDXGIDevice* dxgi_device;
    if (SUCCEEDED(d3d11.swapchain->GetDevice(__uuidof(IDXGIDevice), cast(void**, &dxgi_device)))) {
      IDXGIAdapter* dxgi_adapter;
      if (SUCCEEDED(dxgi_device->GetAdapter(&dxgi_adapter))) {
        IDXGIFactory* dxgi_factory;
        if (SUCCEEDED(dxgi_adapter->GetParent(__uuidof(IDXGIFactory), cast(void**, &dxgi_factory)))) {
          dxgi_factory->MakeWindowAssociation(platform_hwnd, DXGI_MWA_NO_ALT_ENTER);
          dxgi_factory->Release();
        }
        dxgi_adapter->Release();
      }
      dxgi_device->Release();
    }

    D3D11_DEPTH_STENCIL_DESC depthbuffer_state_desc = {};
    depthbuffer_state_desc.DepthEnable = true;
    depthbuffer_state_desc.DepthWriteMask = D3D11_DEPTH_WRITE_MASK_ALL;
    depthbuffer_state_desc.DepthFunc = D3D11_COMPARISON_GREATER_EQUAL;
    hr = d3d11.device->CreateDepthStencilState(&depthbuffer_state_desc, &d3d11.depthbuffer_state);
    if (FAILED(hr)) goto defer;

    string fullscreen_shader_source =
      "struct VS_OUTPUT {\n"
      "  float4 Pos : SV_POSITION;\n"
      "  float2 UV : TEXCOORD0;\n"
      "};\n"
      "VS_OUTPUT vmain(uint id : SV_VertexID) {\n"
      "  VS_OUTPUT output;\n"
      "  float2 pos = float2((id << 1) & 2, id & 2);\n"
      "  output.Pos = float4(pos * float2(2.0, -2.0) + float2(-1.0, 1.0), 0, 1);\n"
      "  output.UV = pos;\n"
      "  return output;\n"
      "}\n"
      "float3 ACESFilm(float3 x) {\n"
      "  float a = 2.51;\n"
      "  float b = 0.03;\n"
      "  float c = 2.43;\n"
      "  float d = 0.59;\n"
      "  float e = 0.14;\n"
      "  return saturate((x * (a * x + b)) / (x * (c * x + d) + e));\n"
      "}\n"
      "Texture2D HDRTexture : register(t0);\n"
      "SamplerState Sampler : register(s0);\n"
      "float4 pmain(VS_OUTPUT input) : SV_Target {\n"
      "  float3 hdrColor = HDRTexture.Sample(Sampler, input.UV).rgb;\n"
      "  float exposure = 1.0;\n"
      "  hdrColor *= exposure;\n"
      "  // float3 tonemapped = ACESFilm(hdrColor);\n"
      "  return float4(hdrColor, 1.0);\n"
      "}\n";

    hr = D3DCompile(fullscreen_shader_source.data, fullscreen_shader_source.count, nullptr, nullptr, nullptr, "vmain", "vs_5_0", D3DCOMPILE_DEBUG, 0, &fullscreen_vblob, nullptr);
    if (FAILED(hr)) goto defer;

    hr = D3DCompile(fullscreen_shader_source.data, fullscreen_shader_source.count, nullptr, nullptr, nullptr, "pmain", "ps_5_0", D3DCOMPILE_DEBUG, 0, &fullscreen_pblob, nullptr);
    if (FAILED(hr)) goto defer;

    hr = d3d11.device->CreateVertexShader(fullscreen_vblob->GetBufferPointer(), fullscreen_vblob->GetBufferSize(), nullptr, &d3d11.fullscreen_vertex_shader);
    if (FAILED(hr)) goto defer;

    hr = d3d11.device->CreatePixelShader(fullscreen_pblob->GetBufferPointer(), fullscreen_pblob->GetBufferSize(), nullptr, &d3d11.tonemap_pixel_shader);
    if (FAILED(hr)) goto defer;

    D3D11_SAMPLER_DESC linear_sampler_desc = {};
    linear_sampler_desc.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
    linear_sampler_desc.AddressU = D3D11_TEXTURE_ADDRESS_CLAMP;
    linear_sampler_desc.AddressV = D3D11_TEXTURE_ADDRESS_CLAMP;
    linear_sampler_desc.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
    linear_sampler_desc.ComparisonFunc = D3D11_COMPARISON_NEVER;
    linear_sampler_desc.MinLOD = 0;
    linear_sampler_desc.MaxLOD = D3D11_FLOAT32_MAX;
    hr = d3d11.device->CreateSamplerState(&linear_sampler_desc, &d3d11.linear_sampler);
    if (FAILED(hr)) goto defer;

    D3D11_BUFFER_DESC quad_vertex_buffer_desc = {};
    quad_vertex_buffer_desc.ByteWidth = cast(u32, size_of(quad_vertices));
    quad_vertex_buffer_desc.Usage = D3D11_USAGE_DEFAULT;
    quad_vertex_buffer_desc.BindFlags = D3D11_BIND_VERTEX_BUFFER;
    quad_vertex_buffer_desc.StructureByteStride = sizeof(Game_Quad_Vertex);
    D3D11_SUBRESOURCE_DATA quad_vertex_buffer_data = {};
    quad_vertex_buffer_data.pSysMem = quad_vertices;
    hr = d3d11.device->CreateBuffer(&quad_vertex_buffer_desc, &quad_vertex_buffer_data, &d3d11.quad_vertex_buffer);
    if (FAILED(hr)) goto defer;

    D3D11_BUFFER_DESC quad_index_buffer_desc = {};
    quad_index_buffer_desc.ByteWidth = cast(u32, size_of(quad_indices));
    quad_index_buffer_desc.Usage = D3D11_USAGE_DEFAULT;
    quad_index_buffer_desc.BindFlags = D3D11_BIND_INDEX_BUFFER;
    quad_index_buffer_desc.StructureByteStride = sizeof(quad_indices[0]);
    D3D11_SUBRESOURCE_DATA quad_index_buffer_data = {};
    quad_index_buffer_data.pSysMem = quad_indices;
    hr = d3d11.device->CreateBuffer(&quad_index_buffer_desc, &quad_index_buffer_data, &d3d11.quad_index_buffer);
    if (FAILED(hr)) goto defer;

    D3D11_BUFFER_DESC quad_instance_buffer_desc = {};
    quad_instance_buffer_desc.ByteWidth = type_of_field(Game_Renderer, quad_instances)::capacity * sizeof(D3D11_Quad_Instance);
    quad_instance_buffer_desc.Usage = D3D11_USAGE_DYNAMIC;
    quad_instance_buffer_desc.BindFlags = D3D11_BIND_VERTEX_BUFFER;
    quad_instance_buffer_desc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
    quad_instance_buffer_desc.StructureByteStride = sizeof(D3D11_Quad_Instance);
    hr = d3d11.device->CreateBuffer(&quad_instance_buffer_desc, nullptr, &d3d11.quad_instance_buffer);
    if (FAILED(hr)) goto defer;

    string quad_shader_source =
      "struct VInput {\n"
      "  float3 position : Position;\n"
      "  float2 texcoord : Texcoord;\n"
      "  matrix transform : Transform;\n"
      "};\n"
      "struct VOutput {\n"
      "  float4 position : SV_Position;\n"
      "  float2 texcoord : Texcoord;\n"
      "};\n"
      "VOutput vmain(VInput input) {\n"
      "  VOutput output;\n"
      "  output.position = mul(float4(input.position, 1.0f), input.transform);\n"
      "  output.texcoord = input.texcoord;\n"
      "  return output;\n"
      "}\n"
      "float4 pmain(VOutput input) : SV_Target0 {\n"
      "  return float4(input.texcoord, 0.0f, 1.0f);\n"
      "}\n";

    hr = D3DCompile(quad_shader_source.data, quad_shader_source.count, nullptr, nullptr, nullptr, "vmain", "vs_5_0", D3DCOMPILE_DEBUG, 0, &quad_vblob, nullptr);
    if (FAILED(hr)) goto defer;

    hr = D3DCompile(quad_shader_source.data, quad_shader_source.count, nullptr, nullptr, nullptr, "pmain", "ps_5_0", D3DCOMPILE_DEBUG, 0, &quad_pblob, nullptr);
    if (FAILED(hr)) goto defer;

    hr = d3d11.device->CreateVertexShader(quad_vblob->GetBufferPointer(), quad_vblob->GetBufferSize(), nullptr, &d3d11.quad_vertex_shader);
    if (FAILED(hr)) goto defer;

    hr = d3d11.device->CreatePixelShader(quad_pblob->GetBufferPointer(), quad_pblob->GetBufferSize(), nullptr, &d3d11.quad_pixel_shader);
    if (FAILED(hr)) goto defer;

    D3D11_INPUT_ELEMENT_DESC quad_input_layout_elements[6] = {};
    quad_input_layout_elements[0].SemanticName = "Position";
    quad_input_layout_elements[0].Format = DXGI_FORMAT_R32G32B32_FLOAT;
    quad_input_layout_elements[0].AlignedByteOffset = offset_of(Game_Quad_Vertex, position);
    quad_input_layout_elements[0].InputSlotClass = D3D11_INPUT_PER_VERTEX_DATA;
    quad_input_layout_elements[1].SemanticName = "Texcoord";
    quad_input_layout_elements[1].Format = DXGI_FORMAT_R32G32_FLOAT;
    quad_input_layout_elements[1].AlignedByteOffset = offset_of(Game_Quad_Vertex, texcoord);
    quad_input_layout_elements[1].InputSlotClass = D3D11_INPUT_PER_VERTEX_DATA;
    usize quad_transform_base = 2;
    for (usize i = quad_transform_base; i < quad_transform_base + 4; i += 1) {
      quad_input_layout_elements[i].SemanticName = "Transform";
      quad_input_layout_elements[i].SemanticIndex = cast(u32, i - quad_transform_base);
      quad_input_layout_elements[i].Format = DXGI_FORMAT_R32G32B32A32_FLOAT;
      quad_input_layout_elements[i].InputSlot = 1;
      quad_input_layout_elements[i].AlignedByteOffset = cast(u32, offset_of(D3D11_Quad_Instance, transform) + (i - quad_transform_base) * sizeof(v4));
      quad_input_layout_elements[i].InputSlotClass = D3D11_INPUT_PER_INSTANCE_DATA;
      quad_input_layout_elements[i].InstanceDataStepRate = 1;
    }
    hr = d3d11.device->CreateInputLayout(quad_input_layout_elements, cast(u32, len(quad_input_layout_elements)), quad_vblob->GetBufferPointer(), quad_vblob->GetBufferSize(), &d3d11.quad_input_layout);
    if (FAILED(hr)) goto defer;

    static u8 bmp_file_backing[1024 * 1024 * 4];
    slice<u8> bmp_file = platform_read_entire_file("textures/container.bmp", bmp_file_backing);
    s32 bmp_width = *cast(s32*, bmp_file.data + 18);
    s32 bmp_height = *cast(s32*, bmp_file.data + 22);
    u8* bmp_image_data = cast(u8*, bmp_file.data + *cast(u32*, bmp_file.data + 10));

    // convert from 24-bit to 32-bit in place.
    for (s32 i = bmp_width * bmp_height - 1; i >= 0; i -= 1) {
      bmp_image_data[i * 4 + 0] = bmp_image_data[i * 3 + 0];
      bmp_image_data[i * 4 + 1] = bmp_image_data[i * 3 + 1];
      bmp_image_data[i * 4 + 2] = bmp_image_data[i * 3 + 2];
      bmp_image_data[i * 4 + 3] = 0xFF;
    }

    D3D11_TEXTURE2D_DESC mesh_texture_desc = {};
    mesh_texture_desc.Width = bmp_width;
    mesh_texture_desc.Height = bmp_height;
    mesh_texture_desc.MipLevels = 1;
    mesh_texture_desc.ArraySize = 1;
    mesh_texture_desc.Format = DXGI_FORMAT_B8G8R8A8_UNORM;
    mesh_texture_desc.SampleDesc.Count = 1;
    mesh_texture_desc.Usage = D3D11_USAGE_DEFAULT;
    mesh_texture_desc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
    D3D11_SUBRESOURCE_DATA mesh_texture_data = {};
    mesh_texture_data.pSysMem = bmp_image_data;
    mesh_texture_data.SysMemPitch = bmp_width * sizeof(u32);
    hr = d3d11.device->CreateTexture2D(&mesh_texture_desc, &mesh_texture_data, &d3d11.mesh_textures[Game_Mesh::CUBE]);
    if (FAILED(hr)) goto defer;

    hr = d3d11.device->CreateShaderResourceView(d3d11.mesh_textures[Game_Mesh::CUBE], nullptr, &d3d11.mesh_texture_views[Game_Mesh::CUBE]);
    if (FAILED(hr)) goto defer;

    D3D11_BUFFER_DESC mesh_vertex_buffer_desc = {};
    mesh_vertex_buffer_desc.ByteWidth = cast(u32, size_of(cube_vertices));
    mesh_vertex_buffer_desc.Usage = D3D11_USAGE_DEFAULT;
    mesh_vertex_buffer_desc.BindFlags = D3D11_BIND_VERTEX_BUFFER;
    mesh_vertex_buffer_desc.StructureByteStride = sizeof(Game_Quad_Vertex);
    D3D11_SUBRESOURCE_DATA mesh_vertex_buffer_data = {};
    mesh_vertex_buffer_data.pSysMem = cube_vertices;
    hr = d3d11.device->CreateBuffer(&mesh_vertex_buffer_desc, &mesh_vertex_buffer_data, &d3d11.mesh_vertex_buffer);
    if (FAILED(hr)) goto defer;

    D3D11_BUFFER_DESC mesh_index_buffer_desc = {};
    mesh_index_buffer_desc.ByteWidth = cast(u32, size_of(cube_indices));
    mesh_index_buffer_desc.Usage = D3D11_USAGE_DEFAULT;
    mesh_index_buffer_desc.BindFlags = D3D11_BIND_INDEX_BUFFER;
    mesh_index_buffer_desc.StructureByteStride = sizeof(cube_indices[0]);
    D3D11_SUBRESOURCE_DATA mesh_index_buffer_data = {};
    mesh_index_buffer_data.pSysMem = cube_indices;
    hr = d3d11.device->CreateBuffer(&mesh_index_buffer_desc, &mesh_index_buffer_data, &d3d11.mesh_index_buffer);
    if (FAILED(hr)) goto defer;

    D3D11_BUFFER_DESC mesh_instance_buffer_desc = {};
    mesh_instance_buffer_desc.ByteWidth = type_of_field(Game_Renderer, mesh_instances)::capacity * sizeof(D3D11_Quad_Instance);
    mesh_instance_buffer_desc.Usage = D3D11_USAGE_DYNAMIC;
    mesh_instance_buffer_desc.BindFlags = D3D11_BIND_VERTEX_BUFFER;
    mesh_instance_buffer_desc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
    mesh_instance_buffer_desc.StructureByteStride = sizeof(D3D11_Quad_Instance);
    hr = d3d11.device->CreateBuffer(&mesh_instance_buffer_desc, nullptr, &d3d11.mesh_instance_buffer);
    if (FAILED(hr)) goto defer;

    string mesh_shader_source =
      "struct VInput {\n"
      "  float3 position : Position;\n"
      "  float3 normal : Normal;\n"
      "  float2 texcoord : Texcoord;\n"
      "  matrix transform : Transform;\n"
      "};\n"
      "struct VOutput {\n"
      "  float4 position : SV_Position;\n"
      "  float3 normal : Normal;\n"
      "  float2 texcoord : Texcoord;\n"
      "};\n"
      "VOutput vmain(VInput input) {\n"
      "  VOutput output;\n"
      "  output.position = mul(float4(input.position, 1.0f), input.transform);\n"
      "  output.normal = input.normal;\n"
      "  output.texcoord = input.texcoord;\n"
      "  return output;\n"
      "}\n"
      "Texture2D tex;\n"
      "SamplerState samp;\n"
      "float4 pmain(VOutput input) : SV_Target0 {\n"
      "  return tex.Sample(samp, input.texcoord);\n"
      "}\n";

    hr = D3DCompile(mesh_shader_source.data, mesh_shader_source.count, nullptr, nullptr, nullptr, "vmain", "vs_5_0", D3DCOMPILE_DEBUG, 0, &mesh_vblob, nullptr);
    if (FAILED(hr)) goto defer;

    hr = D3DCompile(mesh_shader_source.data, mesh_shader_source.count, nullptr, nullptr, nullptr, "pmain", "ps_5_0", D3DCOMPILE_DEBUG, 0, &mesh_pblob, nullptr);
    if (FAILED(hr)) goto defer;

    hr = d3d11.device->CreateVertexShader(mesh_vblob->GetBufferPointer(), mesh_vblob->GetBufferSize(), nullptr, &d3d11.mesh_vertex_shader);
    if (FAILED(hr)) goto defer;

    hr = d3d11.device->CreatePixelShader(mesh_pblob->GetBufferPointer(), mesh_pblob->GetBufferSize(), nullptr, &d3d11.mesh_pixel_shader);
    if (FAILED(hr)) goto defer;

    D3D11_INPUT_ELEMENT_DESC mesh_input_layout_elements[7] = {};
    mesh_input_layout_elements[0].SemanticName = "Position";
    mesh_input_layout_elements[0].Format = DXGI_FORMAT_R32G32B32_FLOAT;
    mesh_input_layout_elements[0].AlignedByteOffset = offset_of(Game_Mesh_Vertex, position);
    mesh_input_layout_elements[0].InputSlotClass = D3D11_INPUT_PER_VERTEX_DATA;
    mesh_input_layout_elements[1].SemanticName = "Normal";
    mesh_input_layout_elements[1].Format = DXGI_FORMAT_R32G32B32_FLOAT;
    mesh_input_layout_elements[1].AlignedByteOffset = offset_of(Game_Mesh_Vertex, normal);
    mesh_input_layout_elements[1].InputSlotClass = D3D11_INPUT_PER_VERTEX_DATA;
    mesh_input_layout_elements[2].SemanticName = "Texcoord";
    mesh_input_layout_elements[2].Format = DXGI_FORMAT_R32G32_FLOAT;
    mesh_input_layout_elements[2].AlignedByteOffset = offset_of(Game_Mesh_Vertex, texcoord);
    mesh_input_layout_elements[2].InputSlotClass = D3D11_INPUT_PER_VERTEX_DATA;
    usize mesh_transform_base = 3;
    for (usize i = mesh_transform_base; i < mesh_transform_base + 4; i += 1) {
      mesh_input_layout_elements[i].SemanticName = "Transform";
      mesh_input_layout_elements[i].SemanticIndex = cast(u32, i - mesh_transform_base);
      mesh_input_layout_elements[i].Format = DXGI_FORMAT_R32G32B32A32_FLOAT;
      mesh_input_layout_elements[i].InputSlot = 1;
      mesh_input_layout_elements[i].AlignedByteOffset = cast(u32, offset_of(D3D11_Mesh_Instance, transform) + (i - mesh_transform_base) * sizeof(v4));
      mesh_input_layout_elements[i].InputSlotClass = D3D11_INPUT_PER_INSTANCE_DATA;
      mesh_input_layout_elements[i].InstanceDataStepRate = 1;
    }
    hr = d3d11.device->CreateInputLayout(mesh_input_layout_elements, cast(u32, len(mesh_input_layout_elements)), mesh_vblob->GetBufferPointer(), mesh_vblob->GetBufferSize(), &d3d11.mesh_input_layout);
    if (FAILED(hr)) goto defer;

    d3d11.initted = true;
  }
defer:
  if (fullscreen_pblob) fullscreen_pblob->Release();
  if (fullscreen_vblob) fullscreen_vblob->Release();
  if (mesh_pblob) mesh_pblob->Release();
  if (mesh_vblob) mesh_vblob->Release();
  if (quad_pblob) quad_pblob->Release();
  if (quad_vblob) quad_vblob->Release();
  if (hr != 0) d3d11_deinit();
}

static void d3d11_deinit() {
  if (d3d11.mesh_input_layout) d3d11.mesh_input_layout->Release();
  if (d3d11.mesh_pixel_shader) d3d11.mesh_pixel_shader->Release();
  if (d3d11.mesh_vertex_shader) d3d11.mesh_vertex_shader->Release();
  if (d3d11.mesh_instance_buffer) d3d11.mesh_instance_buffer->Release();
  if (d3d11.mesh_index_buffer) d3d11.mesh_index_buffer->Release();
  if (d3d11.mesh_vertex_buffer) d3d11.mesh_vertex_buffer->Release();
  for (usize i = 0; i < Game_Mesh::COUNT; i += 1) {
    if (d3d11.mesh_texture_views[i]) d3d11.mesh_texture_views[i]->Release();
    if (d3d11.mesh_textures[i]) d3d11.mesh_textures[i]->Release();
  }

  if (d3d11.quad_input_layout) d3d11.quad_input_layout->Release();
  if (d3d11.quad_pixel_shader) d3d11.quad_pixel_shader->Release();
  if (d3d11.quad_vertex_shader) d3d11.quad_vertex_shader->Release();
  if (d3d11.quad_instance_buffer) d3d11.quad_instance_buffer->Release();
  if (d3d11.quad_index_buffer) d3d11.quad_index_buffer->Release();
  if (d3d11.quad_vertex_buffer) d3d11.quad_vertex_buffer->Release();

  if (d3d11.depthbuffer_view) d3d11.depthbuffer_view->Release();
  if (d3d11.depthbuffer) d3d11.depthbuffer->Release();
  if (d3d11.backbuffer_view) d3d11.backbuffer_view->Release();
  if (d3d11.backbuffer) d3d11.backbuffer->Release();
  if (d3d11.multisampled_backbuffer_view) d3d11.multisampled_backbuffer_view->Release();
  if (d3d11.multisampled_backbuffer) d3d11.multisampled_backbuffer->Release();
  if (d3d11.swapchain_backbuffer_view) d3d11.swapchain_backbuffer_view->Release();

  if (d3d11.linear_sampler) d3d11.linear_sampler->Release();
  if (d3d11.tonemap_pixel_shader) d3d11.tonemap_pixel_shader->Release();
  if (d3d11.fullscreen_vertex_shader) d3d11.fullscreen_vertex_shader->Release();
  if (d3d11.depthbuffer_state) d3d11.depthbuffer_state->Release();
  if (d3d11.ctx) d3d11.ctx->Release();
  if (d3d11.device) d3d11.device->Release();
  if (d3d11.swapchain) d3d11.swapchain->Release();
  d3d11 = {};
}

static void d3d11_resize() {
  HRESULT hr = 0;
  ID3D11Texture2D* swapchain_backbuffer = nullptr;
  {
    if (!d3d11.initted || platform_size[0] == 0 || platform_size[1] == 0) return;

    if (d3d11.depthbuffer_view) d3d11.depthbuffer_view->Release();
    if (d3d11.depthbuffer) d3d11.depthbuffer->Release();
    if (d3d11.backbuffer_view) d3d11.backbuffer_view->Release();
    if (d3d11.backbuffer) d3d11.backbuffer->Release();
    if (d3d11.multisampled_backbuffer_view) d3d11.multisampled_backbuffer_view->Release();
    if (d3d11.multisampled_backbuffer) d3d11.multisampled_backbuffer->Release();
    if (d3d11.swapchain_backbuffer_view) d3d11.swapchain_backbuffer_view->Release();

    hr = d3d11.swapchain->ResizeBuffers(1, platform_size[0], platform_size[1], DXGI_FORMAT_UNKNOWN, DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH);
    if (FAILED(hr)) goto defer;

    hr = d3d11.swapchain->GetBuffer(0, __uuidof(ID3D11Texture2D), cast(void**, &swapchain_backbuffer));
    if (FAILED(hr)) goto defer;

    hr = d3d11.device->CreateRenderTargetView(swapchain_backbuffer, nullptr, &d3d11.swapchain_backbuffer_view);
    if (FAILED(hr)) goto defer;

    u32 samples = 1;
    for (u32 i = 32; i > 1; i >>= 1) {
      u32 quality_levels;
      hr = d3d11.device->CheckMultisampleQualityLevels(DXGI_FORMAT_R16G16B16A16_FLOAT, i, &quality_levels);
      if (SUCCEEDED(hr) && quality_levels > 0) {
        samples = i;
        break;
      }
    }

    // @Cleanup: string formatting.
    if (samples == 32) platform_log("Samples: 32");
    else if (samples == 16) platform_log("Samples: 16");
    else if (samples == 8) platform_log("Samples: 8");
    else if (samples == 4) platform_log("Samples: 4");
    else if (samples == 2) platform_log("Samples: 2");
    else if (samples == 1) platform_log("Samples: 1");

    D3D11_TEXTURE2D_DESC multisampled_backbuffer_desc = {};
    multisampled_backbuffer_desc.Width = platform_size[0];
    multisampled_backbuffer_desc.Height = platform_size[1];
    multisampled_backbuffer_desc.MipLevels = 1;
    multisampled_backbuffer_desc.ArraySize = 1;
    multisampled_backbuffer_desc.Format = DXGI_FORMAT_R16G16B16A16_FLOAT;
    multisampled_backbuffer_desc.SampleDesc.Count = samples;
    multisampled_backbuffer_desc.Usage = D3D11_USAGE_DEFAULT;
    multisampled_backbuffer_desc.BindFlags = D3D11_BIND_RENDER_TARGET;
    hr = d3d11.device->CreateTexture2D(&multisampled_backbuffer_desc, nullptr, &d3d11.multisampled_backbuffer);
    if (FAILED(hr)) goto defer;

    hr = d3d11.device->CreateRenderTargetView(d3d11.multisampled_backbuffer, nullptr, &d3d11.multisampled_backbuffer_view);
    if (FAILED(hr)) goto defer;

    D3D11_TEXTURE2D_DESC backbuffer_desc = multisampled_backbuffer_desc;
    backbuffer_desc.SampleDesc.Count = 1;
    backbuffer_desc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
    hr = d3d11.device->CreateTexture2D(&backbuffer_desc, nullptr, &d3d11.backbuffer);
    if (FAILED(hr)) goto defer;

    hr = d3d11.device->CreateShaderResourceView(d3d11.backbuffer, nullptr, &d3d11.backbuffer_view);
    if (FAILED(hr)) goto defer;

    D3D11_TEXTURE2D_DESC depthbuffer_desc = {};
    depthbuffer_desc.Width = platform_size[0];
    depthbuffer_desc.Height = platform_size[1];
    depthbuffer_desc.MipLevels = 1;
    depthbuffer_desc.ArraySize = 1;
    depthbuffer_desc.Format = DXGI_FORMAT_D32_FLOAT;
    depthbuffer_desc.SampleDesc.Count = samples;
    depthbuffer_desc.Usage = D3D11_USAGE_DEFAULT;
    depthbuffer_desc.BindFlags = D3D11_BIND_DEPTH_STENCIL;
    hr = d3d11.device->CreateTexture2D(&depthbuffer_desc, nullptr, &d3d11.depthbuffer);
    if (FAILED(hr)) goto defer;

    hr = d3d11.device->CreateDepthStencilView(d3d11.depthbuffer, nullptr, &d3d11.depthbuffer_view);
    if (FAILED(hr)) goto defer;
  }
defer:
  if (swapchain_backbuffer) swapchain_backbuffer->Release();
  if (hr != 0) d3d11_deinit();
}

static void d3d11_present(Game_Renderer* game_renderer) {
  if (!d3d11.initted || platform_size[0] == 0 || platform_size[1] == 0) return;

  d3d11.ctx->ClearRenderTargetView(d3d11.multisampled_backbuffer_view, game_renderer->clear_color0);
  d3d11.ctx->ClearDepthStencilView(d3d11.depthbuffer_view, D3D11_CLEAR_DEPTH, 0.0f, 0);

  m4 vp2d = m4_translate(-game_renderer->camera2d.position) * m4_scale({1.0f / game_renderer->camera2d.viewport_size, 1.0f});

  static D3D11_Quad_Instance quad_instances[type_of_field(Game_Renderer, quad_instances)::capacity];
  usize quad_instances_count = 0;
  for (usize i = 0; i < game_renderer->quad_instances.count; i += 1) {
    Game_Quad_Instance* instance = game_renderer->quad_instances.data + i;
    quad_instances[quad_instances_count++].transform =
      m4_scale({instance->transform.scale, 1.0f}) *
      m4_rotate_z(instance->transform.rotation) *
      m4_translate(instance->transform.position) *
      vp2d;
  }

  D3D11_MAPPED_SUBRESOURCE mapped;
  HRESULT hr = d3d11.ctx->Map(d3d11.quad_instance_buffer, 0, D3D11_MAP_WRITE_DISCARD, 0, &mapped);
  if (SUCCEEDED(hr)) {
    memcpy(mapped.pData, quad_instances, quad_instances_count * sizeof(D3D11_Quad_Instance));
    d3d11.ctx->Unmap(d3d11.quad_instance_buffer, 0);
  }

    m4 vp3d = m4_from_q4(game_renderer->camera.rotation) * m4_translate(-game_renderer->camera.position) * m4_perspective(
    game_renderer->camera.fov_y,
    game_renderer->camera.aspect_ratio,
    game_renderer->camera.z_near,
    game_renderer->camera.z_far);

  static D3D11_Mesh_Instance mesh_instances[type_of_field(Game_Renderer, mesh_instances)::capacity];
  usize mesh_instances_count = 0;
  for (usize i = 0; i < game_renderer->mesh_instances.count; i += 1) {
    Game_Mesh_Instance* instance = game_renderer->mesh_instances.data + i;
    mesh_instances[mesh_instances_count].transform =
      m4_scale(instance->transform.scale) *
      m4_from_q4(instance->transform.rotation) *
      m4_translate(instance->transform.position) *
      vp3d;
    mesh_instances[mesh_instances_count].mesh_index = instance->mesh_index;
    mesh_instances_count++;
  }

  mapped = {};
  hr = d3d11.ctx->Map(d3d11.mesh_instance_buffer, 0, D3D11_MAP_WRITE_DISCARD, 0, &mapped);
  if (SUCCEEDED(hr)) {
    memcpy(mapped.pData, mesh_instances, mesh_instances_count * sizeof(D3D11_Mesh_Instance));
    d3d11.ctx->Unmap(d3d11.mesh_instance_buffer, 0);
  }

  D3D11_VIEWPORT viewport = {};
  viewport.Width = platform_size[0];
  viewport.Height = platform_size[1];
  viewport.MaxDepth = 1.0f;
  d3d11.ctx->RSSetViewports(1, &viewport);

  d3d11.ctx->OMSetDepthStencilState(d3d11.depthbuffer_state, 0);
  d3d11.ctx->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
  d3d11.ctx->OMSetRenderTargets(1, &d3d11.multisampled_backbuffer_view, d3d11.depthbuffer_view);

  d3d11.ctx->IASetInputLayout(d3d11.quad_input_layout);
  d3d11.ctx->VSSetShader(d3d11.quad_vertex_shader, nullptr, 0);
  d3d11.ctx->PSSetShader(d3d11.quad_pixel_shader, nullptr, 0);
  ID3D11Buffer* quad_buffers[2] = {d3d11.quad_vertex_buffer, d3d11.quad_instance_buffer};
  u32 quad_strides[2] = {sizeof(Game_Quad_Vertex), sizeof(D3D11_Quad_Instance)};
  u32 quad_offsets[2] = {0, 0};
  d3d11.ctx->IASetVertexBuffers(0, cast(u32, len(quad_buffers)), quad_buffers, quad_strides, quad_offsets);
  d3d11.ctx->IASetIndexBuffer(d3d11.quad_index_buffer, DXGI_FORMAT_R16_UINT, 0);
  d3d11.ctx->DrawIndexedInstanced(cast(u32, len(quad_indices)), cast(u32, quad_instances_count), 0, 0, 0);

  d3d11.ctx->PSSetShaderResources(0, 1, &d3d11.mesh_texture_views[Game_Mesh::CUBE]);
  d3d11.ctx->PSSetSamplers(0, 1, &d3d11.linear_sampler);
  d3d11.ctx->IASetInputLayout(d3d11.mesh_input_layout);
  d3d11.ctx->VSSetShader(d3d11.mesh_vertex_shader, nullptr, 0);
  d3d11.ctx->PSSetShader(d3d11.mesh_pixel_shader, nullptr, 0);
  ID3D11Buffer* mesh_buffers[2] = {d3d11.mesh_vertex_buffer, d3d11.mesh_instance_buffer};
  u32 mesh_strides[2] = {sizeof(Game_Mesh_Vertex), sizeof(D3D11_Mesh_Instance)};
  u32 mesh_offsets[2] = {0, 0};
  d3d11.ctx->IASetVertexBuffers(0, cast(u32, len(mesh_buffers)), mesh_buffers, mesh_strides, mesh_offsets);
  d3d11.ctx->IASetIndexBuffer(d3d11.mesh_index_buffer, DXGI_FORMAT_R16_UINT, 0);
  d3d11.ctx->DrawIndexedInstanced(cast(u32, len(cube_indices)), cast(u32, mesh_instances_count), 0, 0, 0);

  d3d11.ctx->ResolveSubresource(d3d11.backbuffer, 0, d3d11.multisampled_backbuffer, 0, DXGI_FORMAT_R16G16B16A16_FLOAT);

  d3d11.ctx->OMSetDepthStencilState(nullptr, 0);
  d3d11.ctx->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
  d3d11.ctx->IASetInputLayout(nullptr);
  d3d11.ctx->VSSetShader(d3d11.fullscreen_vertex_shader, nullptr, 0);
  d3d11.ctx->PSSetShader(d3d11.tonemap_pixel_shader, nullptr, 0);
  d3d11.ctx->OMSetRenderTargets(1, &d3d11.swapchain_backbuffer_view, nullptr);
  d3d11.ctx->PSSetShaderResources(0, 1, &d3d11.backbuffer_view);
  d3d11.ctx->PSSetSamplers(0, 1, &d3d11.linear_sampler);
  d3d11.ctx->Draw(3, 0);
  d3d11.swapchain->Present(1, 0);
}

static Platform_Renderer d3d11_renderer = {
  d3d11_init,
  d3d11_deinit,
  d3d11_resize,
  d3d11_present,
};
