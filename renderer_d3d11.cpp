#include <D3D11.h>
#include <Dxgi.h>
#include <D3Dcompiler.h>

struct D3D11_Quad_Instance {
  m4 transform;
};

struct D3D11_Mesh_Instance {
  m4 transform;
  Game_Mesh mesh_index;
};

static struct {
  bool initted;

  IDXGISwapChain* swapchain;
  ID3D11Device* device;
  ID3D11DeviceContext* ctx;
  ID3D11DepthStencilState* depthbuffer_state;

  ID3D11RenderTargetView* backbuffer_view;

  ID3D11Texture2D* depthbuffer;
  ID3D11DepthStencilView* depthbuffer_view;

  ID3D11Buffer* quad_vertex_buffer;
  ID3D11Buffer* quad_index_buffer;
  ID3D11Buffer* quad_instance_buffer;
  ID3D11VertexShader* quad_vertex_shader;
  ID3D11PixelShader* quad_pixel_shader;
  ID3D11InputLayout* quad_input_layout;

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
      "\n"
      "VOutput vmain(VInput input) {\n"
      "  VOutput output;\n"
      "  output.position = mul(float4(input.position, 1.0f), input.transform);\n"
      "  output.texcoord = input.texcoord;\n"
      "  return output;\n"
      "}\n"
      "\n"
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
    for (usize i = 2; i < 6; i += 1) {
      quad_input_layout_elements[i].SemanticName = "Transform";
      quad_input_layout_elements[i].SemanticIndex = cast(u32, i - 2);
      quad_input_layout_elements[i].Format = DXGI_FORMAT_R32G32B32A32_FLOAT;
      quad_input_layout_elements[i].InputSlot = 1;
      quad_input_layout_elements[i].AlignedByteOffset = cast(u32, offset_of(D3D11_Quad_Instance, transform) + (i - 2) * sizeof(v4));
      quad_input_layout_elements[i].InputSlotClass = D3D11_INPUT_PER_INSTANCE_DATA;
      quad_input_layout_elements[i].InstanceDataStepRate = 1;
    }
    hr = d3d11.device->CreateInputLayout(quad_input_layout_elements, cast(u32, len(quad_input_layout_elements)), quad_vblob->GetBufferPointer(), quad_vblob->GetBufferSize(), &d3d11.quad_input_layout);
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
      "\n"
      "VOutput vmain(VInput input) {\n"
      "  VOutput output;\n"
      "  output.position = mul(float4(input.position, 1.0f), input.transform);\n"
      "  output.normal = input.normal;\n"
      "  output.texcoord = input.texcoord;\n"
      "  return output;\n"
      "}\n"
      "\n"
      "float4 pmain(VOutput input) : SV_Target0 {\n"
      "  return float4(input.texcoord, 0.0f, 1.0f);\n"
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
    for (usize i = 3; i < 7; i += 1) {
      mesh_input_layout_elements[i].SemanticName = "Transform";
      mesh_input_layout_elements[i].SemanticIndex = cast(u32, i - 3);
      mesh_input_layout_elements[i].Format = DXGI_FORMAT_R32G32B32A32_FLOAT;
      mesh_input_layout_elements[i].InputSlot = 1;
      mesh_input_layout_elements[i].AlignedByteOffset = cast(u32, offset_of(D3D11_Mesh_Instance, transform) + (i - 3) * sizeof(v4));
      mesh_input_layout_elements[i].InputSlotClass = D3D11_INPUT_PER_INSTANCE_DATA;
      mesh_input_layout_elements[i].InstanceDataStepRate = 1;
    }
    hr = d3d11.device->CreateInputLayout(mesh_input_layout_elements, cast(u32, len(mesh_input_layout_elements)), mesh_vblob->GetBufferPointer(), mesh_vblob->GetBufferSize(), &d3d11.mesh_input_layout);
    if (FAILED(hr)) goto defer;

    d3d11.initted = true;
  }
defer:
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

  if (d3d11.quad_input_layout) d3d11.quad_input_layout->Release();
  if (d3d11.quad_pixel_shader) d3d11.quad_pixel_shader->Release();
  if (d3d11.quad_vertex_shader) d3d11.quad_vertex_shader->Release();
  if (d3d11.quad_instance_buffer) d3d11.quad_instance_buffer->Release();
  if (d3d11.quad_index_buffer) d3d11.quad_index_buffer->Release();
  if (d3d11.quad_vertex_buffer) d3d11.quad_vertex_buffer->Release();

  if (d3d11.depthbuffer_view) d3d11.depthbuffer_view->Release();
  if (d3d11.depthbuffer) d3d11.depthbuffer->Release();
  if (d3d11.backbuffer_view) d3d11.backbuffer_view->Release();

  if (d3d11.depthbuffer_state) d3d11.depthbuffer_state->Release();
  if (d3d11.ctx) d3d11.ctx->Release();
  if (d3d11.device) d3d11.device->Release();
  if (d3d11.swapchain) d3d11.swapchain->Release();
  d3d11 = {};
}

static void d3d11_resize() {
  HRESULT hr = 0;
  ID3D11Texture2D* backbuffer = nullptr;
  {
    if (!d3d11.initted || platform_size[0] == 0 || platform_size[1] == 0) return;

    if (d3d11.depthbuffer_view) d3d11.depthbuffer_view->Release();
    if (d3d11.depthbuffer) d3d11.depthbuffer->Release();
    if (d3d11.backbuffer_view) d3d11.backbuffer_view->Release();

    hr = d3d11.swapchain->ResizeBuffers(1, platform_size[0], platform_size[1], DXGI_FORMAT_UNKNOWN, DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH);
    if (FAILED(hr)) goto defer;

    hr = d3d11.swapchain->GetBuffer(0, __uuidof(ID3D11Texture2D), cast(void**, &backbuffer));
    if (FAILED(hr)) goto defer;

    hr = d3d11.device->CreateRenderTargetView(backbuffer, nullptr, &d3d11.backbuffer_view);
    if (FAILED(hr)) goto defer;

    D3D11_TEXTURE2D_DESC depthbuffer_desc = {};
    depthbuffer_desc.Width = platform_size[0];
    depthbuffer_desc.Height = platform_size[1];
    depthbuffer_desc.ArraySize = 1;
    depthbuffer_desc.Format = DXGI_FORMAT_D32_FLOAT;
    depthbuffer_desc.SampleDesc.Count = 1;
    depthbuffer_desc.Usage = D3D11_USAGE_DEFAULT;
    depthbuffer_desc.BindFlags = D3D11_BIND_DEPTH_STENCIL;
    hr = d3d11.device->CreateTexture2D(&depthbuffer_desc, nullptr, &d3d11.depthbuffer);
    if (FAILED(hr)) goto defer;

    hr = d3d11.device->CreateDepthStencilView(d3d11.depthbuffer, nullptr, &d3d11.depthbuffer_view);
    if (FAILED(hr)) goto defer;
  }
defer:
  if (backbuffer) backbuffer->Release();
  if (hr != 0) d3d11_deinit();
}

static void d3d11_present(Game_Renderer* game_renderer) {
  if (!d3d11.initted || platform_size[0] == 0 || platform_size[1] == 0) return;

  d3d11.ctx->ClearRenderTargetView(d3d11.backbuffer_view, game_renderer->clear_color0);
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

  m4 vp3d = m4_translate(-game_renderer->camera.position) * m4_perspective(
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

  d3d11.ctx->OMSetDepthStencilState(d3d11.depthbuffer_state, 0);
  d3d11.ctx->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
  d3d11.ctx->OMSetRenderTargets(1, &d3d11.backbuffer_view, d3d11.depthbuffer_view);
  D3D11_VIEWPORT viewport = {};
  viewport.Width = platform_size[0];
  viewport.Height = platform_size[1];
  viewport.MaxDepth = 1.0f;
  d3d11.ctx->RSSetViewports(1, &viewport);

  d3d11.ctx->IASetInputLayout(d3d11.quad_input_layout);
  d3d11.ctx->VSSetShader(d3d11.quad_vertex_shader, nullptr, 0);
  d3d11.ctx->PSSetShader(d3d11.quad_pixel_shader, nullptr, 0);
  ID3D11Buffer* quad_buffers[2] = {d3d11.quad_vertex_buffer, d3d11.quad_instance_buffer};
  u32 quad_strides[2] = {sizeof(Game_Quad_Vertex), sizeof(D3D11_Quad_Instance)};
  u32 quad_offsets[2] = {0, 0};
  d3d11.ctx->IASetVertexBuffers(0, cast(u32, len(quad_buffers)), quad_buffers, quad_strides, quad_offsets);
  d3d11.ctx->IASetIndexBuffer(d3d11.quad_index_buffer, DXGI_FORMAT_R16_UINT, 0);
  d3d11.ctx->DrawIndexedInstanced(cast(u32, len(quad_indices)), cast(u32, quad_instances_count), 0, 0, 0);

  d3d11.ctx->IASetInputLayout(d3d11.mesh_input_layout);
  d3d11.ctx->VSSetShader(d3d11.mesh_vertex_shader, nullptr, 0);
  d3d11.ctx->PSSetShader(d3d11.mesh_pixel_shader, nullptr, 0);
  ID3D11Buffer* mesh_buffers[2] = {d3d11.mesh_vertex_buffer, d3d11.mesh_instance_buffer};
  u32 mesh_strides[2] = {sizeof(Game_Mesh_Vertex), sizeof(D3D11_Mesh_Instance)};
  u32 mesh_offsets[2] = {0, 0};
  d3d11.ctx->IASetVertexBuffers(0, cast(u32, len(mesh_buffers)), mesh_buffers, mesh_strides, mesh_offsets);
  d3d11.ctx->IASetIndexBuffer(d3d11.mesh_index_buffer, DXGI_FORMAT_R16_UINT, 0);
  d3d11.ctx->DrawIndexedInstanced(cast(u32, len(cube_indices)), cast(u32, mesh_instances_count), 0, 0, 0);

  d3d11.swapchain->Present(1, 0);
}

static Platform_Renderer d3d11_renderer = {
  d3d11_init,
  d3d11_deinit,
  d3d11_resize,
  d3d11_present,
};
