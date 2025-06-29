module basic.windows.d3d11;

import basic.windows;
import basic.windows.dxgi;

enum D3D11_SDK_VERSION = 7;

enum D3D_DRIVER_TYPE : int {
	UNKNOWN = 0,
	HARDWARE = 1,
	REFERENCE = 2,
	NULL = 3,
	SOFTWARE = 4,
	WARP = 5,
}

enum D3D_FEATURE_LEVEL : int {
	_1_0_GENERIC = 0,
	_1_0_CORE = 1,
	_9_1 = 2,
	_9_2 = 3,
	_9_3 = 4,
	_10_0 = 5,
	_10_1 = 6,
	_11_0 = 7,
	_11_1 = 8,
	_12_0 = 9,
	_12_1 = 10,
	_12_2 = 11,
}

enum D3D11_CREATE_DEVICE_FLAG : int {
	SINGLETHREADED = 0x1,
	DEBUG = 0x2,
	SWITCH_TO_REF = 0x4,
	PREVENT_INTERNAL_THREADING_OPTIMIZATIONS = 0x8,
	BGRA_SUPPORT = 0x20,
	DEBUGGABLE = 0x40,
	PREVENT_ALTERING_LAYER_SETTINGS_FROM_REGISTRY = 0x80,
	DISABLE_GPU_TIMEOUT = 0x100,
	VIDEO_SUPPORT = 0x800,
}

enum D3D11_RESOURCE_DIMENSION : int {
	UNKNOWN = 0,
	BUFFER = 1,
	TEXTURE1D = 2,
	TEXTURE2D = 3,
	TEXTURE3D = 4,
}

enum D3D11_USAGE {
	DEFAULT = 0,
	IMMUTABLE = 1,
	DYNAMIC = 2,
	STAGING = 3,
}

struct D3D11_TEXTURE2D_DESC {
	uint Width;
	uint Height;
	uint MipLevels;
	uint ArraySize;
	DXGI_FORMAT Format;
	DXGI_SAMPLE_DESC SampleDesc;
	D3D11_USAGE Usage;
	uint BindFlags;
	uint CPUAccessFlags;
	uint MiscFlags;
}

enum D3D11_COUNTER : int {
	D3D11_COUNTER_DEVICE_DEPENDENT_0 = 0x40000000,
}

struct D3D11_COUNTER_DESC {
	D3D11_COUNTER Counter;
	uint MiscFlags;
}

enum D3D11_COUNTER_TYPE : int {
	FLOAT32 = 0,
	UINT16 = 1,
	UINT32 = 2,
	UINT64 = 3,
}

struct D3D11_COUNTER_INFO {
	D3D11_COUNTER LastDeviceDependentCounter;
	uint NumSimultaneousCounters;
	ubyte NumDetectableParallelUnits;
}

enum D3D11_BLEND : int {
	ZERO = 1,
	ONE = 2,
	SRC_COLOR = 3,
	INV_SRC_COLOR = 4,
	SRC_ALPHA = 5,
	INV_SRC_ALPHA = 6,
	DEST_ALPHA = 7,
	INV_DEST_ALPHA = 8,
	DEST_COLOR = 9,
	INV_DEST_COLOR = 10,
	SRC_ALPHA_SAT = 11,
	BLEND_FACTOR = 14,
	INV_BLEND_FACTOR = 15,
	SRC1_COLOR = 16,
	INV_SRC1_COLOR = 17,
	SRC1_ALPHA = 18,
	INV_SRC1_ALPHA = 19,
}

enum D3D11_BLEND_OP : int {
	D3D11_BLEND_OP_ADD = 1,
	D3D11_BLEND_OP_SUBTRACT = 2,
	D3D11_BLEND_OP_REV_SUBTRACT = 3,
	D3D11_BLEND_OP_MIN = 4,
	D3D11_BLEND_OP_MAX = 5,
}

struct D3D11_RENDER_TARGET_BLEND_DESC {
	int BlendEnable;
	D3D11_BLEND SrcBlend;
	D3D11_BLEND DestBlend;
	D3D11_BLEND_OP BlendOp;
	D3D11_BLEND SrcBlendAlpha;
	D3D11_BLEND DestBlendAlpha;
	D3D11_BLEND_OP BlendOpAlpha;
	ubyte RenderTargetWriteMask;
}

struct D3D11_BLEND_DESC {
	int AlphaToCoverageEnable;
	int IndependentBlendEnable;
	D3D11_RENDER_TARGET_BLEND_DESC[8] RenderTarget;
}

enum D3D11_FEATURE : int {
	THREADING = 0,
	DOUBLES = 1,
	FORMAT_SUPPORT = 2,
	FORMAT_SUPPORT2 = 3,
	D3D10_X_HARDWARE_OPTIONS = 4,
	D3D11_OPTIONS = 5,
	ARCHITECTURE_INFO = 6,
	D3D9_OPTIONS = 7,
	SHADER_MIN_PRECISION_SUPPORT = 8,
	D3D9_SHADOW_SUPPORT = 9,
	D3D11_OPTIONS1 = 10,
	D3D9_SIMPLE_INSTANCING_SUPPORT = 11,
	MARKER_SUPPORT = 12,
	D3D9_OPTIONS1 = 13,
	D3D11_OPTIONS2 = 14,
	D3D11_OPTIONS3 = 15,
	GPU_VIRTUAL_ADDRESS_SUPPORT = 16,
	D3D11_OPTIONS4 = 17,
	SHADER_CACHE = 18,
	D3D11_OPTIONS5 = 19,
	DISPLAYABLE = 20,
	D3D11_OPTIONS6 = 21,
}

enum D3D11_RTV_DIMENSION {
	UNKNOWN = 0,
	BUFFER = 1,
	TEXTURE1D = 2,
	TEXTURE1DARRAY = 3,
	TEXTURE2D = 4,
	TEXTURE2DARRAY = 5,
	TEXTURE2DMS = 6,
	TEXTURE2DMSARRAY = 7,
	TEXTURE3D = 8,
}

struct D3D11_BUFFER_RTV {
	union {
		uint FirstElement;
		uint ElementOffset;
	}
	union {
		uint NumElements;
		uint ElementWidth;
	}
}

struct D3D11_TEX1D_RTV {
	uint MipSlice;
}

struct D3D11_TEX1D_ARRAY_RTV {
	uint MipSlice;
	uint FirstArraySlice;
	uint ArraySize;
}

struct D3D11_TEX2D_RTV {
	uint MipSlice;
}

struct D3D11_TEX2D_ARRAY_RTV {
	uint MipSlice;
	uint FirstArraySlice;
	uint ArraySize;
}

struct D3D11_TEX2DMS_RTV {
	uint UnusedField_NothingToDefine;
}

struct D3D11_TEX2DMS_ARRAY_RTV {
	uint FirstArraySlice;
	uint ArraySize;
}

struct D3D11_TEX3D_RTV {
	uint MipSlice;
	uint FirstWSlice;
	uint WSize;
}

struct D3D11_RENDER_TARGET_VIEW_DESC {
	DXGI_FORMAT Format;
	D3D11_RTV_DIMENSION ViewDimension;
	union {
		D3D11_BUFFER_RTV Buffer;
		D3D11_TEX1D_RTV Texture1D;
		D3D11_TEX1D_ARRAY_RTV Texture1DArray;
		D3D11_TEX2D_RTV Texture2D;
		D3D11_TEX2D_ARRAY_RTV Texture2DArray;
		D3D11_TEX2DMS_RTV Texture2DMS;
		D3D11_TEX2DMS_ARRAY_RTV Texture2DMSArray;
		D3D11_TEX3D_RTV Texture3D;
	}
}

struct ID3D11Device {
	struct VTable {
		IUnknown.VTable iunknown;
		alias this = iunknown;
		extern(Windows) HRESULT function(void*, const(D3D11_COUNTER_DESC)*, D3D11_COUNTER_TYPE*, uint, char*, uint, char*, uint, char*, uint) CheckCounter;
		extern(Windows) void function(void*, D3D11_COUNTER_INFO*) CheckCounterInfo;
		extern(Windows) HRESULT function(void*, D3D11_FEATURE, void*, uint) CheckFeatureSupport;
		extern(Windows) HRESULT function(void*, DXGI_FORMAT, uint) CheckFormatSupport;
		extern(Windows) HRESULT function(void*, DXGI_FORMAT, uint, uint*) CheckMultisampleQualityLevels;
		extern(Windows) HRESULT function(void*, const(D3D11_BLEND_DESC)*, ID3D11BlendState**) CreateBlendState;
		void* CreateBuffer;
		void* CreateClassLinkage;
		void* CreateComputeShader;
		void* CreateCounter;
		void* CreateDeferredContext;
		void* CreateDepthStencilState;
		void* CreateDepthStencilView;
		void* CreateDomainShader;
		void* CreateGeometryShader;
		void* CreateGeometryShaderWithStreamOutput;
		void* CreateHullShader;
		void* CreateInputLayout;
		void* CreatePixelShader;
		void* CreatePredicate;
		void* CreateQuery;
		void* CreateRasterizerState;
		extern(Windows) HRESULT function(void*, ID3D11Resource*, const(D3D11_RENDER_TARGET_VIEW_DESC)*, ID3D11RenderTargetView**) CreateRenderTargetView;
		// ... yes there are more somehow.
	}
	VTable* lpVtbl;
	alias this = lpVtbl;
}

struct ID3D11DeviceChild {
	struct VTable {
		IUnknown.VTable iunknown;
		alias this = iunknown;
		// ...
	}
	VTable* lpVtbl;
	alias this = lpVtbl;
}

struct ID3D11BlendState {
	struct VTable {
		ID3D11DeviceChild.VTable id3d11devicechild;
		alias this = id3d11devicechild;
		extern(Windows) void function(void*, D3D11_BLEND_DESC*) GetDesc;
	}
	VTable* lpVtbl;
	alias this = lpVtbl;
}

struct ID3D11Resource {
	struct VTable {
		ID3D11DeviceChild.VTable id3d11devicechild;
		alias this = id3d11devicechild;
		extern(Windows) uint function(void*) GetEvictionPriority;
		extern(Windows) void function(void*, D3D11_RESOURCE_DIMENSION*) GetType;
		extern(Windows) void function(void*, uint) SetEvictionPriority;
	}
	VTable* lpVtbl;
	alias this = lpVtbl;
}

struct ID3D11View {
	struct VTable {
		ID3D11DeviceChild.VTable id3d11devicechild;
		alias this = id3d11devicechild;
		extern(Windows) void function(void*, ID3D11Resource**) GetResource;
	}
	VTable* lpVtbl;
	alias this = lpVtbl;
}

struct ID3D11RenderTargetView {
	struct VTable {
		ID3D11View.VTable id3d11view;
		alias this = id3d11view;
		extern(Windows) void function(void*, D3D11_RENDER_TARGET_VIEW_DESC*) GetDesc;
	}
	VTable* lpVtbl;
	alias this = lpVtbl;
}

struct ID3D11Texture2D {
	__gshared immutable uuidof = IID(0x6F15AAF2, 0xD208, 0x4E89, [0x9A, 0xB4, 0x48, 0x95, 0x35, 0xD3, 0x4F, 0x9C]);
	struct VTable {
		ID3D11Resource.VTable id3d11resource;
		alias this = id3d11resource;
		extern(Windows) void function(void*, D3D11_TEXTURE2D_DESC*) GetDesc;
	}
	VTable* lpVtbl;
	alias this = lpVtbl;
}

struct ID3D11DeviceContext {
	struct VTable {
		ID3D11DeviceChild.VTable id3d11devicechild;
		alias this = id3d11devicechild;
		void* Begin;
		void* ClearDepthStencilView;
		extern(Windows) void function(void*, ID3D11RenderTargetView*, const(float)[4]) ClearRenderTargetView;
		// ...
	}
	VTable* lpVtbl;
	alias this = lpVtbl;
}

extern(Windows) HRESULT D3D11CreateDeviceAndSwapChain(IDXGIAdapter*, D3D_DRIVER_TYPE, HMODULE, uint, const(D3D_FEATURE_LEVEL)*, uint, uint, const(DXGI_SWAP_CHAIN_DESC)*, IDXGISwapChain**, ID3D11Device**, D3D_FEATURE_LEVEL*, ID3D11DeviceContext**);
