#+build windows
package main

import w "core:sys/windows"
import "vendor:directx/d3d11"
import "vendor:directx/dxgi"
import "vendor:directx/d3d_compiler"

@(private="file")
G: struct {
	initted: bool,
	swapchain: ^dxgi.ISwapChain,
	device: ^d3d11.IDevice,
	ctx: ^d3d11.IDeviceContext,
	backbuffer_view: ^d3d11.IRenderTargetView,
	triangle_input_layout: ^d3d11.IInputLayout,
	triangle_vertex_buffer: ^d3d11.IBuffer,
	triangle_vertex_shader: ^d3d11.IVertexShader,
	triangle_pixel_shader: ^d3d11.IPixelShader,
}

d3d11_init :: proc() {
	error: {
		hr: w.HRESULT = ---

		swapchain_descriptor: dxgi.SWAP_CHAIN_DESC
		swapchain_descriptor.BufferDesc.Width = u32(platform_size.x)
		swapchain_descriptor.BufferDesc.Height = u32(platform_size.y)
		swapchain_descriptor.BufferDesc.RefreshRate.Numerator = 144
		swapchain_descriptor.BufferDesc.RefreshRate.Denominator = 1
		swapchain_descriptor.BufferDesc.Format = .R8G8B8A8_UNORM
		swapchain_descriptor.SampleDesc.Count = 8
		swapchain_descriptor.BufferUsage = {.RENDER_TARGET_OUTPUT}
		swapchain_descriptor.BufferCount = 1
		swapchain_descriptor.OutputWindow = platform_hwnd
		swapchain_descriptor.Windowed = true
		swapchain_descriptor.Flags = {.ALLOW_MODE_SWITCH}
		hr = d3d11.CreateDeviceAndSwapChain(nil, .HARDWARE, nil, {.DEBUG}, nil, 0, d3d11.SDK_VERSION, &swapchain_descriptor, &G.swapchain, &G.device, nil, &G.ctx)
		if w.FAILED(hr) do break error

		dxgi_device: ^dxgi.IDevice = ---
		if w.SUCCEEDED(G.swapchain->GetDevice(dxgi.IDevice_UUID, cast(^rawptr) &dxgi_device)) {
			dxgi_adapter: ^dxgi.IAdapter = ---
			if w.SUCCEEDED(dxgi_device->GetAdapter(&dxgi_adapter)) {
				dxgi_factory: ^dxgi.IFactory = ---
				if w.SUCCEEDED(dxgi_adapter->GetParent(dxgi.IFactory_UUID, cast(^rawptr) &dxgi_factory)) {
					dxgi_factory->MakeWindowAssociation(platform_hwnd, {.NO_ALT_ENTER})
					dxgi_factory->Release()
				}
				dxgi_adapter->Release()
			}
			dxgi_device->Release()
		}

		vertices := [][2]f32{
			{0.5, -0.5},
			{-0.5, -0.5},
			{0.0, 0.5},
		}
		triangle_vertex_buffer_descriptor: d3d11.BUFFER_DESC
		triangle_vertex_buffer_descriptor.ByteWidth = u32(size_of([2]f32) * len(vertices))
		triangle_vertex_buffer_descriptor.Usage = .DEFAULT
		triangle_vertex_buffer_descriptor.BindFlags = {.VERTEX_BUFFER}
		triangle_vertex_buffer_descriptor.StructureByteStride = size_of([2]f32)
		triangle_vertex_buffer_initial_data: d3d11.SUBRESOURCE_DATA
		triangle_vertex_buffer_initial_data.pSysMem = raw_data(vertices)
		hr = G.device->CreateBuffer(&triangle_vertex_buffer_descriptor, &triangle_vertex_buffer_initial_data, &G.triangle_vertex_buffer)
		if w.FAILED(hr) do break error

		triangle_src := `
		float4 VShader(float4 position : Position) : SV_Position {
			return position;
		}

		float4 PShader(float4 position : SV_Position) : SV_Target {
			return float4(0.2, 0.9, 1.0, 1.0);
		}
		`
		triangle_vertex_blob: ^d3d11.IBlob = ---
		hr = d3d_compiler.Compile(raw_data(triangle_src), len(triangle_src), nil, nil, nil, "VShader", "vs_5_0", u32(d3d_compiler.D3DCOMPILE.DEBUG) when ODIN_DEBUG else 0, 0, &triangle_vertex_blob, nil)
		if w.FAILED(hr) do break error
		defer triangle_vertex_blob->Release()
		triangle_pixel_blob: ^d3d11.IBlob = ---
		hr = d3d_compiler.Compile(raw_data(triangle_src), len(triangle_src), nil, nil, nil, "PShader", "ps_5_0", u32(d3d_compiler.D3DCOMPILE.DEBUG) when ODIN_DEBUG else 0, 0, &triangle_pixel_blob, nil)
		if w.FAILED(hr) do break error
		defer triangle_pixel_blob->Release()

		hr = G.device->CreateVertexShader(triangle_vertex_blob->GetBufferPointer(), triangle_vertex_blob->GetBufferSize(), nil, &G.triangle_vertex_shader)
		if w.FAILED(hr) do break error
		hr = G.device->CreatePixelShader(triangle_pixel_blob->GetBufferPointer(), triangle_pixel_blob->GetBufferSize(), nil, &G.triangle_pixel_shader)
		if w.FAILED(hr) do break error

		triangle_input_layout_descriptor: d3d11.INPUT_ELEMENT_DESC
		triangle_input_layout_descriptor.SemanticName = "Position"
		triangle_input_layout_descriptor.Format = .R32G32_FLOAT
		triangle_input_layout_descriptor.InputSlotClass = .VERTEX_DATA
		hr = G.device->CreateInputLayout(&triangle_input_layout_descriptor, 1, triangle_vertex_blob->GetBufferPointer(), triangle_vertex_blob->GetBufferSize(), &G.triangle_input_layout)
		if w.FAILED(hr) do break error

		G.initted = true
		return
	}
	d3d11_deinit()
}

d3d11_deinit :: proc() {
	if G.initted {
		G.swapchain->SetFullscreenState(false, nil)
	}
	if G.triangle_pixel_shader != nil do G.triangle_pixel_shader->Release()
	if G.triangle_vertex_shader != nil do G.triangle_vertex_shader->Release()
	if G.triangle_vertex_buffer != nil do G.triangle_vertex_buffer->Release()
	if G.triangle_input_layout != nil do G.triangle_input_layout->Release()
	if G.backbuffer_view != nil do G.backbuffer_view->Release()
	if G.ctx != nil do G.ctx->Release()
	if G.device != nil do G.device->Release()
	if G.swapchain != nil do G.swapchain->Release()
	G = {}
}

d3d11_resize :: proc() {
	if !G.initted do return
	error: {
		hr: w.HRESULT = ---

		if G.backbuffer_view != nil do G.backbuffer_view->Release()

		hr = G.swapchain->ResizeBuffers(1, u32(platform_size.x), u32(platform_size.y), .R8G8B8A8_UNORM, {.ALLOW_MODE_SWITCH})

		backbuffer: ^d3d11.ITexture2D = ---
		hr = G.swapchain->GetBuffer(0, d3d11.ITexture2D_UUID, cast(^rawptr) &backbuffer)
		if w.FAILED(hr) do break error
		defer backbuffer->Release()

		hr = G.device->CreateRenderTargetView(backbuffer, nil, &G.backbuffer_view)
		if w.FAILED(hr) do break error

		return
	}
	d3d11_deinit()
}

d3d11_present :: proc() {
	if !G.initted do return
	G.ctx->ClearRenderTargetView(G.backbuffer_view, &{0.6, 0.2, 0.2, 1.0})
	G.ctx->VSSetShader(G.triangle_vertex_shader, nil, 0)
	G.ctx->PSSetShader(G.triangle_pixel_shader, nil, 0)
	G.ctx->OMSetRenderTargets(1, &G.backbuffer_view, nil)
	G.ctx->IASetPrimitiveTopology(.TRIANGLELIST)
	viewport: d3d11.VIEWPORT
	viewport.Width = f32(platform_size.x)
	viewport.Height = f32(platform_size.y)
	viewport.MaxDepth = 1.0
	G.ctx->RSSetViewports(1, &viewport)
	G.ctx->IASetInputLayout(G.triangle_input_layout)
	stride: u32 = size_of([2]f32)
	offset: u32 = 0
	G.ctx->IASetVertexBuffers(0, 1, &G.triangle_vertex_buffer, &stride, &offset)
	G.ctx->Draw(3, 0)
	G.swapchain->Present(0, {})
}

d3d11_renderer :: Platform_Renderer{
	d3d11_init,
	d3d11_deinit,
	d3d11_resize,
	d3d11_present,
}
