#+build windows
package main

import w "core:sys/windows"
import "vendor:directx/d3d11"
import "vendor:directx/dxgi"

@(private="file")
G: struct {
	initted: bool,
	swapchain: ^dxgi.ISwapChain,
	device: ^d3d11.IDevice,
	ctx: ^d3d11.IDeviceContext,
	backbuffer: ^d3d11.ITexture2D,
	backbuffer_view: ^d3d11.IRenderTargetView,
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
		swapchain_descriptor.SampleDesc.Count = 1
		swapchain_descriptor.BufferUsage = {.RENDER_TARGET_OUTPUT}
		swapchain_descriptor.BufferCount = 1
		swapchain_descriptor.OutputWindow = platform_hwnd
		swapchain_descriptor.Windowed = true
		swapchain_descriptor.Flags = {.ALLOW_MODE_SWITCH}
		hr = d3d11.CreateDeviceAndSwapChain(nil, .HARDWARE, nil, {.DEBUG}, nil, 0, d3d11.SDK_VERSION, &swapchain_descriptor, &G.swapchain, &G.device, nil, &G.ctx)
		if w.FAILED(hr) do break error

		hr = G.swapchain->GetBuffer(0, d3d11.ITexture2D_UUID, cast(^rawptr) &G.backbuffer)
		if w.FAILED(hr) do break error

		hr = G.device->CreateRenderTargetView(G.backbuffer, nil, &G.backbuffer_view)
		if w.FAILED(hr) do break error

		G.initted = true
		return
	}
	d3d11_deinit()
}

d3d11_deinit :: proc() {
	if G.backbuffer_view != nil do G.backbuffer_view->Release()
	if G.ctx != nil do G.ctx->Release()
	if G.device != nil do G.device->Release()
	if G.swapchain != nil do G.swapchain->Release()
	G = {}
}

d3d11_resize :: proc() {
	if !G.initted do return
	G.swapchain->ResizeBuffers(1, u32(platform_size.x), u32(platform_size.y), .R8G8B8A8_UNORM, {.ALLOW_MODE_SWITCH})
}

d3d11_present :: proc() {
	if !G.initted do return
	G.ctx->ClearRenderTargetView(G.backbuffer_view, &{0.6, 0.2, 0.2, 1.0})
	G.swapchain->Present(0, {})
}

d3d11_renderer :: Platform_Renderer{
	d3d11_init,
	d3d11_deinit,
	d3d11_resize,
	d3d11_present,
}
