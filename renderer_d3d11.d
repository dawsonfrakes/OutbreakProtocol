import basic;
import basic.maths;
import basic.windows;
static import game;
import renderer : Platform_Renderer;
import static_meshes;

struct D3D11_Data {
  bool initted;
  void function(const(char)[]) log;
  u16[2] size;

  IDXGISwapChain* swapchain;
  ID3D11Device* device;
  ID3D11DeviceContext* ctx;

  ID3D11DepthStencilState* depth_state;
  ID3D11SamplerState* linear_sampler;
  ID3D11VertexShader* fullscreen_vertex_shader;
  ID3D11PixelShader* fullscreen_pixel_shader;

  ID3D11RenderTargetView* swapchain_backbuffer_view;
  ID3D11Texture2D* multisampled_backbuffer;
  ID3D11RenderTargetView* multisampled_backbuffer_view;
  ID3D11Texture2D* resolved_backbuffer;
  ID3D11ShaderResourceView* resolved_backbuffer_view;
  ID3D11Texture2D* depthbuffer;
  ID3D11DepthStencilView* depthbuffer_view;

  ID3D11Buffer* mesh_vertex_buffer;
  ID3D11Buffer* mesh_index_buffer;
  ID3D11Buffer* mesh_instance_buffer;
  ID3D11VertexShader* mesh_vertex_shader;
  ID3D11PixelShader* mesh_pixel_shader;
  ID3D11InputLayout* mesh_input_layout;
}

__gshared D3D11_Data d3d11;

void d3d11_init(Platform_Renderer.Init_Data* init_data) {
  d3d11.log = init_data.log;
  HRESULT hr;
  ID3DBlob* blob;
  {
    DXGI_SWAP_CHAIN_DESC swapchain_descriptor;
    swapchain_descriptor.BufferDesc.Width = init_data.size[0];
    swapchain_descriptor.BufferDesc.Height = init_data.size[1];
    swapchain_descriptor.BufferDesc.Format = DXGI_FORMAT.R8G8B8A8_UNORM_SRGB;
    swapchain_descriptor.SampleDesc.Count = 1;
    swapchain_descriptor.BufferUsage = DXGI_USAGE.RENDER_TARGET_OUTPUT;
    swapchain_descriptor.BufferCount = 1;
    swapchain_descriptor.OutputWindow = init_data.hwnd;
    swapchain_descriptor.Windowed = true;
    swapchain_descriptor.Flags = DXGI_SWAP_CHAIN_FLAG.ALLOW_MODE_SWITCH;
    hr = D3D11CreateDeviceAndSwapChain(null, D3D_DRIVER_TYPE.HARDWARE, null,
      D3D11_CREATE_DEVICE_FLAG.DEBUG, null, 0, D3D11_SDK_VERSION,
      &swapchain_descriptor, &d3d11.swapchain, &d3d11.device, null, &d3d11.ctx);
    if (hr < 0) goto defer;

    IDXGIDevice* dxgi_device = void;
    if (d3d11.swapchain.GetDevice(&IDXGIDevice.uuidof, cast(void**) &dxgi_device) >= 0) {
      IDXGIAdapter* dxgi_adapter = void;
      if (dxgi_device.GetAdapter(&dxgi_adapter) >= 0) {
        IDXGIFactory* dxgi_factory = void;
        if (dxgi_adapter.GetParent(&IDXGIFactory.uuidof, cast(void**) &dxgi_factory) >= 0) {
          /*hr = */dxgi_factory.MakeWindowAssociation(init_data.hwnd, DXGI_MWA.NO_ALT_ENTER);
          dxgi_factory.Release();
        }
        dxgi_adapter.Release();
      }
      dxgi_device.Release();
    }

    D3D11_DEPTH_STENCIL_DESC depth_state_desc;
    depth_state_desc.DepthEnable = true;
    depth_state_desc.DepthWriteMask = D3D11_DEPTH_WRITE_MASK.ALL;
    depth_state_desc.DepthFunc = D3D11_COMPARISON_FUNC.LESS_EQUAL;
    hr = d3d11.device.CreateDepthStencilState(&depth_state_desc, &d3d11.depth_state);
    if (hr < 0) goto defer;

    D3D11_SAMPLER_DESC linear_sampler_desc;
    linear_sampler_desc.Filter = D3D11_FILTER.MIN_MAG_MIP_LINEAR;
    linear_sampler_desc.AddressU = D3D11_TEXTURE_ADDRESS_MODE.CLAMP;
    linear_sampler_desc.AddressV = D3D11_TEXTURE_ADDRESS_MODE.CLAMP;
    linear_sampler_desc.AddressW = D3D11_TEXTURE_ADDRESS_MODE.CLAMP;
    linear_sampler_desc.ComparisonFunc = D3D11_COMPARISON_FUNC.NEVER;
    linear_sampler_desc.MipLODBias = 0;
    linear_sampler_desc.MinLOD = 0;
    linear_sampler_desc.MaxLOD = f32.max;
    hr = d3d11.device.CreateSamplerState(&linear_sampler_desc, &d3d11.linear_sampler);
    if (hr < 0) goto defer;

    string fullscreen_source = `
      struct VOutput {
        float4 position : SV_Position;
        float2 texcoord : Texcoord0;
      };

      VOutput vmain(uint id : SV_VertexID) {
        VOutput output;
        float2 position = float2((id << 1) & 2, id & 2);
        output.position = float4(position * float2(2.0f, -2.0f) + float2(-1.0f, 1.0f), 0.0f, 1.0f);
        output.texcoord = position;
        return output;
      }

      float3 ACESFilm(float3 x) {
        float a = 2.51f;
        float b = 0.03f;
        float c = 2.43f;
        float d = 0.59f;
        float e = 0.14f;
        return saturate((x * (a * x + b)) / (x * (c * x + d) + e));
      }

      Texture2D hdr_texture : register(t0);
      SamplerState linear_sampler : register(s0);

      float4 pmain(VOutput input) : SV_Target0 {
        float3 hdr_color = hdr_texture.Sample(linear_sampler, input.texcoord).rgb;
        // float3 tonemapped = ACESFilm(hdr_color);
        return float4(hdr_color, 1.0f);
      }
    `;

    hr = D3DCompile(fullscreen_source.ptr, fullscreen_source.length, null, null, null, "vmain", "vs_5_0", D3DCOMPILE_FLAG.DEBUG, 0, &blob, null);
    if (hr < 0) goto defer;

    hr = d3d11.device.CreateVertexShader(blob.GetBufferPointer(), blob.GetBufferSize(), null, &d3d11.fullscreen_vertex_shader);
    if (hr < 0) goto defer;
    blob.Release();
    blob = null;

    hr = D3DCompile(fullscreen_source.ptr, fullscreen_source.length, null, null, null, "pmain", "ps_5_0", D3DCOMPILE_FLAG.DEBUG, 0, &blob, null);
    if (hr < 0) goto defer;

    hr = d3d11.device.CreatePixelShader(blob.GetBufferPointer(), blob.GetBufferSize(), null, &d3d11.fullscreen_pixel_shader);
    if (hr < 0) goto defer;
    blob.Release();
    blob = null;

    string mesh_source = `
      struct VInput {
        float3 position : Position;
        float3 normal : Normal;
        float2 texcoord : Texcoord;
        uint texture_index : Texture_Index;
        matrix world_transform : World_Transform;
        matrix model_transform : Model_Transform;
      };

      struct VOutput {
        float4 position : SV_Position;
        float3 normal : Normal;
        float2 texcoord : Texcoord;
      };

      VOutput vmain(VInput input) {
        VOutput output;
        output.position = float4(input.position, 1.0f);
        output.normal = input.normal;
        output.texcoord = input.texcoord;
        return output;
      }

      float4 pmain(VOutput input) : SV_Target0 {
        return float4(input.texcoord, 0.0f, 1.0f);
      }
    `;

    hr = D3DCompile(mesh_source.ptr, mesh_source.length, null, null, null, "vmain", "vs_5_0", D3DCOMPILE_FLAG.DEBUG, 0, &blob, null);
    if (hr < 0) goto defer;

    hr = d3d11.device.CreateVertexShader(blob.GetBufferPointer(), blob.GetBufferSize(), null, &d3d11.mesh_vertex_shader);
    if (hr < 0) goto defer;

    D3D11_INPUT_ELEMENT_DESC[12] mesh_input_layout_desc;
    mesh_input_layout_desc[0].SemanticName = "Position";
    mesh_input_layout_desc[0].SemanticIndex = 0;
    mesh_input_layout_desc[0].Format = DXGI_FORMAT.R32G32B32_FLOAT;
    mesh_input_layout_desc[0].InputSlot = 0;
    mesh_input_layout_desc[0].AlignedByteOffset = game.Game_Mesh_Vertex.position.offsetof;
    mesh_input_layout_desc[0].InputSlotClass = D3D11_INPUT_CLASSIFICATION.VERTEX_DATA;
    mesh_input_layout_desc[0].InstanceDataStepRate = 0;
    mesh_input_layout_desc[1].SemanticName = "Normal";
    mesh_input_layout_desc[1].SemanticIndex = 0;
    mesh_input_layout_desc[1].Format = DXGI_FORMAT.R32G32B32_FLOAT;
    mesh_input_layout_desc[1].InputSlot = 0;
    mesh_input_layout_desc[1].AlignedByteOffset = game.Game_Mesh_Vertex.normal.offsetof;
    mesh_input_layout_desc[1].InputSlotClass = D3D11_INPUT_CLASSIFICATION.VERTEX_DATA;
    mesh_input_layout_desc[1].InstanceDataStepRate = 0;
    mesh_input_layout_desc[2].SemanticName = "Texcoord";
    mesh_input_layout_desc[2].SemanticIndex = 0;
    mesh_input_layout_desc[2].Format = DXGI_FORMAT.R32G32_FLOAT;
    mesh_input_layout_desc[2].InputSlot = 0;
    mesh_input_layout_desc[2].AlignedByteOffset = game.Game_Mesh_Vertex.texcoord.offsetof;
    mesh_input_layout_desc[2].InputSlotClass = D3D11_INPUT_CLASSIFICATION.VERTEX_DATA;
    mesh_input_layout_desc[2].InstanceDataStepRate = 0;
    mesh_input_layout_desc[3].SemanticName = "Texture_Index";
    mesh_input_layout_desc[3].SemanticIndex = 0;
    mesh_input_layout_desc[3].Format = DXGI_FORMAT.R32_UINT;
    mesh_input_layout_desc[3].InputSlot = 0;
    mesh_input_layout_desc[3].AlignedByteOffset = game.Game_Mesh_Vertex.texture_index.offsetof;
    mesh_input_layout_desc[3].InputSlotClass = D3D11_INPUT_CLASSIFICATION.VERTEX_DATA;
    mesh_input_layout_desc[3].InstanceDataStepRate = 0;
    enum world_transform_base = 4;
    static foreach (i; world_transform_base..world_transform_base + 4) {
      mesh_input_layout_desc[i].SemanticName = "World_Transform";
      mesh_input_layout_desc[i].SemanticIndex = i - world_transform_base;
      mesh_input_layout_desc[i].Format = DXGI_FORMAT.R32G32B32A32_FLOAT;
      mesh_input_layout_desc[i].InputSlot = 1;
      mesh_input_layout_desc[i].AlignedByteOffset = game.Game_Mesh_Instance.world_transform.offsetof + (i - world_transform_base) * v4.sizeof;
      mesh_input_layout_desc[i].InputSlotClass = D3D11_INPUT_CLASSIFICATION.INSTANCE_DATA;
      mesh_input_layout_desc[i].InstanceDataStepRate = 1;
    }
    enum model_transform_base = 8;
    static foreach (i; model_transform_base..model_transform_base + 4) {
      mesh_input_layout_desc[i].SemanticName = "Model_Transform";
      mesh_input_layout_desc[i].SemanticIndex = i - model_transform_base;
      mesh_input_layout_desc[i].Format = DXGI_FORMAT.R32G32B32A32_FLOAT;
      mesh_input_layout_desc[i].InputSlot = 1;
      mesh_input_layout_desc[i].AlignedByteOffset = game.Game_Mesh_Instance.model_transform.offsetof + (i - model_transform_base) * v4.sizeof;
      mesh_input_layout_desc[i].InputSlotClass = D3D11_INPUT_CLASSIFICATION.INSTANCE_DATA;
      mesh_input_layout_desc[i].InstanceDataStepRate = 1;
    }
    hr = d3d11.device.CreateInputLayout(mesh_input_layout_desc.ptr, cast(u32) mesh_input_layout_desc.length, blob.GetBufferPointer(), blob.GetBufferSize(), &d3d11.mesh_input_layout);
    if (hr < 0) goto defer;

    blob.Release();
    blob = null;

    hr = D3DCompile(mesh_source.ptr, mesh_source.length, null, null, null, "pmain", "ps_5_0", D3DCOMPILE_FLAG.DEBUG, 0, &blob, null);
    if (hr < 0) goto defer;

    hr = d3d11.device.CreatePixelShader(blob.GetBufferPointer(), blob.GetBufferSize(), null, &d3d11.mesh_pixel_shader);
    if (hr < 0) goto defer;
    blob.Release();
    blob = null;

    D3D11_BUFFER_DESC mesh_vertex_buffer_desc;
    mesh_vertex_buffer_desc.ByteWidth = mesh_vertices.length * mesh_vertices[0].sizeof;
    mesh_vertex_buffer_desc.Usage = D3D11_USAGE.DEFAULT;
    mesh_vertex_buffer_desc.BindFlags = D3D11_BIND_FLAG.VERTEX_BUFFER;
    mesh_vertex_buffer_desc.StructureByteStride = mesh_vertices[0].sizeof;
    D3D11_SUBRESOURCE_DATA mesh_vertex_buffer_data;
    mesh_vertex_buffer_data.pSysMem = mesh_vertices.ptr;
    hr = d3d11.device.CreateBuffer(&mesh_vertex_buffer_desc, &mesh_vertex_buffer_data, &d3d11.mesh_vertex_buffer);
    if (hr < 0) goto defer;

    D3D11_BUFFER_DESC mesh_index_buffer_desc;
    mesh_index_buffer_desc.ByteWidth = mesh_indices.length * mesh_indices[0].sizeof;
    mesh_index_buffer_desc.Usage = D3D11_USAGE.DEFAULT;
    mesh_index_buffer_desc.BindFlags = D3D11_BIND_FLAG.INDEX_BUFFER;
    mesh_index_buffer_desc.StructureByteStride = mesh_indices[0].sizeof;
    D3D11_SUBRESOURCE_DATA mesh_index_buffer_data;
    mesh_index_buffer_data.pSysMem = mesh_indices.ptr;
    hr = d3d11.device.CreateBuffer(&mesh_index_buffer_desc, &mesh_index_buffer_data, &d3d11.mesh_index_buffer);
    if (hr < 0) goto defer;

    D3D11_BUFFER_DESC mesh_instance_buffer_desc;
    mesh_instance_buffer_desc.ByteWidth = game.Game_Renderer.meshes.N * game.Game_Mesh_Instance.sizeof;
    mesh_instance_buffer_desc.Usage = D3D11_USAGE.DYNAMIC;
    mesh_instance_buffer_desc.BindFlags = D3D11_BIND_FLAG.VERTEX_BUFFER;
    mesh_instance_buffer_desc.CPUAccessFlags = D3D11_CPU_ACCESS_FLAG.WRITE;
    mesh_instance_buffer_desc.StructureByteStride = game.Game_Mesh_Instance.sizeof;
    hr = d3d11.device.CreateBuffer(&mesh_instance_buffer_desc, null, &d3d11.mesh_instance_buffer);
    if (hr < 0) goto defer;

    d3d11.initted = true;
  }
defer:
  if (blob) blob.Release();
  if (hr != 0) d3d11_deinit();
}

void d3d11_deinit_swapchain() {
  if (d3d11.depthbuffer_view) d3d11.depthbuffer_view.Release();
  if (d3d11.depthbuffer) d3d11.depthbuffer.Release();
  if (d3d11.resolved_backbuffer_view) d3d11.resolved_backbuffer_view.Release();
  if (d3d11.resolved_backbuffer) d3d11.resolved_backbuffer.Release();
  if (d3d11.multisampled_backbuffer_view) d3d11.multisampled_backbuffer_view.Release();
  if (d3d11.multisampled_backbuffer) d3d11.multisampled_backbuffer.Release();
  if (d3d11.swapchain_backbuffer_view) d3d11.swapchain_backbuffer_view.Release();
}

void d3d11_deinit() {
  if (d3d11.mesh_vertex_shader) d3d11.mesh_vertex_shader.Release();
  if (d3d11.mesh_pixel_shader) d3d11.mesh_pixel_shader.Release();
  if (d3d11.mesh_input_layout) d3d11.mesh_input_layout.Release();
  if (d3d11.mesh_instance_buffer) d3d11.mesh_instance_buffer.Release();
  if (d3d11.mesh_index_buffer) d3d11.mesh_index_buffer.Release();
  if (d3d11.mesh_vertex_buffer) d3d11.mesh_vertex_buffer.Release();

  d3d11_deinit_swapchain();
  if (d3d11.fullscreen_pixel_shader) d3d11.fullscreen_pixel_shader.Release();
  if (d3d11.fullscreen_vertex_shader) d3d11.fullscreen_vertex_shader.Release();
  if (d3d11.linear_sampler) d3d11.linear_sampler.Release();
  if (d3d11.depth_state) d3d11.depth_state.Release();
  if (d3d11.ctx) d3d11.ctx.Release();
  if (d3d11.device) d3d11.device.Release();
  if (d3d11.swapchain) d3d11.swapchain.Release();
  d3d11 = d3d11.init;
}

void d3d11_resize(u16[2] size) {
  d3d11.size = size;
  HRESULT hr;
  ID3D11Texture2D* swapchain_backbuffer = void;
  {
    if (!d3d11.initted || size[0] == 0 || size[1] == 0) return;

    d3d11_deinit_swapchain();

    hr = d3d11.swapchain.ResizeBuffers(1, size[0], size[1], DXGI_FORMAT.UNKNOWN, DXGI_SWAP_CHAIN_FLAG.ALLOW_MODE_SWITCH);
    if (hr < 0) goto defer;

    hr = d3d11.swapchain.GetBuffer(0, &swapchain_backbuffer.uuidof, cast(void**) &swapchain_backbuffer);
    if (hr < 0) goto defer;

    hr = d3d11.device.CreateRenderTargetView(cast(ID3D11Resource*) swapchain_backbuffer, null, &d3d11.swapchain_backbuffer_view);
    if (hr < 0) goto defer;

    u32 color_samples_max = 1;
    for (u32 i = 16; i > 1; i >>= 1) {
      u32 quality_levels = void;
      hr = d3d11.device.CheckMultisampleQualityLevels(DXGI_FORMAT.R16G16B16A16_FLOAT, i, &quality_levels);
      if (hr < 0) goto defer;
      if (quality_levels > 0) {
        color_samples_max = i;
        break;
      }
    }
    u32 depth_samples_max = 1;
    for (u32 i = 16; i > 1; i >>= 1) {
      u32 quality_levels = void;
      hr = d3d11.device.CheckMultisampleQualityLevels(DXGI_FORMAT.D32_FLOAT, i, &quality_levels);
      if (hr < 0) goto defer;
      if (quality_levels > 0) {
        depth_samples_max = i;
        break;
      }
    }
    u32 samples = max(color_samples_max, depth_samples_max);
    if (samples == 16) d3d11.log("Samples: 16"); // @StringFormatting
    else if (samples == 8) d3d11.log("Samples: 8");
    else if (samples == 4) d3d11.log("Samples: 4");
    else if (samples == 2) d3d11.log("Samples: 2");
    else if (samples == 1) d3d11.log("Samples: 1");

    D3D11_TEXTURE2D_DESC multisampled_backbuffer_desc;
    multisampled_backbuffer_desc.Width = size[0];
    multisampled_backbuffer_desc.Height = size[1];
    multisampled_backbuffer_desc.MipLevels = 1;
    multisampled_backbuffer_desc.ArraySize = 1;
    multisampled_backbuffer_desc.Format = DXGI_FORMAT.R16G16B16A16_FLOAT;
    multisampled_backbuffer_desc.SampleDesc.Count = samples;
    multisampled_backbuffer_desc.Usage = D3D11_USAGE.DEFAULT;
    multisampled_backbuffer_desc.BindFlags = D3D11_BIND_FLAG.RENDER_TARGET;
    hr = d3d11.device.CreateTexture2D(&multisampled_backbuffer_desc, null, &d3d11.multisampled_backbuffer);
    if (hr < 0) goto defer;

    hr = d3d11.device.CreateRenderTargetView(cast(ID3D11Resource*) d3d11.multisampled_backbuffer, null, &d3d11.multisampled_backbuffer_view);
    if (hr < 0) goto defer;

    D3D11_TEXTURE2D_DESC depthbuffer_desc;
    depthbuffer_desc.Width = size[0];
    depthbuffer_desc.Height = size[1];
    depthbuffer_desc.MipLevels = 1;
    depthbuffer_desc.ArraySize = 1;
    depthbuffer_desc.Format = DXGI_FORMAT.D32_FLOAT;
    depthbuffer_desc.SampleDesc.Count = samples;
    depthbuffer_desc.Usage = D3D11_USAGE.DEFAULT;
    depthbuffer_desc.BindFlags = D3D11_BIND_FLAG.DEPTH_STENCIL;
    hr = d3d11.device.CreateTexture2D(&depthbuffer_desc, null, &d3d11.depthbuffer);
    if (hr < 0) goto defer;

    hr = d3d11.device.CreateDepthStencilView(cast(ID3D11Resource*) d3d11.depthbuffer, null, &d3d11.depthbuffer_view);
    if (hr < 0) goto defer;

    D3D11_TEXTURE2D_DESC resolved_backbuffer_desc = multisampled_backbuffer_desc;
    resolved_backbuffer_desc.SampleDesc.Count = 1;
    resolved_backbuffer_desc.BindFlags = D3D11_BIND_FLAG.SHADER_RESOURCE;
    hr = d3d11.device.CreateTexture2D(&resolved_backbuffer_desc, null, &d3d11.resolved_backbuffer);
    if (hr < 0) goto defer;

    hr = d3d11.device.CreateShaderResourceView(cast(ID3D11Resource*) d3d11.resolved_backbuffer, null, &d3d11.resolved_backbuffer_view);
    if (hr < 0) goto defer;
  }
defer:
  if (swapchain_backbuffer) swapchain_backbuffer.Release();
  if (hr != 0) d3d11_deinit();
}

void d3d11_present(game.Game_Renderer* game_renderer) {
  if (!d3d11.initted || d3d11.size[0] == 0 || d3d11.size[1] == 0) return;

  d3d11.ctx.ClearRenderTargetView(d3d11.multisampled_backbuffer_view, game_renderer.clear_color0.ptr);
  d3d11.ctx.ClearDepthStencilView(d3d11.depthbuffer_view, D3D11_CLEAR_FLAG.DEPTH, 0.0, cast(u8) 0);

  D3D11_MAPPED_SUBRESOURCE mapped = void;
  HRESULT hr = d3d11.ctx.Map(cast(ID3D11Resource*) d3d11.mesh_instance_buffer, 0, D3D11_MAP.WRITE_DISCARD, 0, &mapped);
  if (hr >= 0) {
    (cast(game.Game_Mesh_Instance*) mapped.pData)[0..game_renderer.meshes.length] = game_renderer.meshes[];
    d3d11.ctx.Unmap(cast(ID3D11Resource*) d3d11.mesh_instance_buffer, 0);
  }

  D3D11_VIEWPORT viewport;
  viewport.TopLeftX = 0.0;
  viewport.TopLeftY = 0.0;
  viewport.Width = d3d11.size[0];
  viewport.Height = d3d11.size[1];
  viewport.MinDepth = 0.0;
  viewport.MaxDepth = 1.0;
  d3d11.ctx.RSSetViewports(1, &viewport);
  d3d11.ctx.OMSetRenderTargets(1, &d3d11.multisampled_backbuffer_view, d3d11.depthbuffer_view);
  d3d11.ctx.OMSetDepthStencilState(d3d11.depth_state, 0);

  d3d11.ctx.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY.TRIANGLELIST);
  ID3D11Buffer*[2] mesh_buffers = [d3d11.mesh_vertex_buffer, d3d11.mesh_instance_buffer];
  u32[mesh_buffers.length] mesh_strides = [game.Game_Mesh_Vertex.sizeof, game.Game_Mesh_Instance.sizeof];
  u32[mesh_buffers.length] mesh_offsets = [0, 0];
  d3d11.ctx.IASetVertexBuffers(0, cast(u32) mesh_buffers.length, mesh_buffers.ptr, mesh_strides.ptr, mesh_offsets.ptr);
  d3d11.ctx.IASetIndexBuffer(d3d11.mesh_index_buffer, DXGI_FORMAT.R16_UINT, 0);
  d3d11.ctx.IASetInputLayout(d3d11.mesh_input_layout);
  d3d11.ctx.VSSetShader(d3d11.mesh_vertex_shader, null, 0);
  d3d11.ctx.PSSetShader(d3d11.mesh_pixel_shader, null, 0);
  d3d11.ctx.DrawIndexedInstanced(6, 1, 0, 0, 0);

  d3d11.ctx.ResolveSubresource(cast(ID3D11Resource*) d3d11.resolved_backbuffer, 0, cast(ID3D11Resource*) d3d11.multisampled_backbuffer, 0, DXGI_FORMAT.R16G16B16A16_FLOAT);

  d3d11.ctx.OMSetRenderTargets(1, &d3d11.swapchain_backbuffer_view, null);
  d3d11.ctx.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY.TRIANGLELIST);
  d3d11.ctx.IASetInputLayout(null);
  d3d11.ctx.VSSetShader(d3d11.fullscreen_vertex_shader, null, 0);
  d3d11.ctx.PSSetShader(d3d11.fullscreen_pixel_shader, null, 0);
  d3d11.ctx.PSSetShaderResources(0, 1, &d3d11.resolved_backbuffer_view);
  d3d11.ctx.PSSetSamplers(0, 1, &d3d11.linear_sampler);
  d3d11.ctx.Draw(3, 0);

  d3d11.swapchain.Present(0, 0);
}

immutable d3d11_renderer = Platform_Renderer(
  &d3d11_init,
  &d3d11_deinit,
  &d3d11_resize,
  &d3d11_present,
);

version (DLL) mixin DLLExport!d3d11_renderer;

pragma(lib, "D3D11");
pragma(lib, "D3DCompiler");
