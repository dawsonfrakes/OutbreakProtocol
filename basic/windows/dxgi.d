module basic.windows.dxgi;

import basic.windows;
import basic.windows.d3d11;

struct DXGI_RATIONAL {
	uint Numerator;
	uint Denominator;
}

enum DXGI_FORMAT : int {
	UNKNOWN = 0,
	R32G32B32A32_TYPELESS = 1,
	R32G32B32A32_FLOAT = 2,
	R32G32B32A32_UINT = 3,
	R32G32B32A32_SINT = 4,
	R32G32B32_TYPELESS = 5,
	R32G32B32_FLOAT = 6,
	R32G32B32_UINT = 7,
	R32G32B32_SINT = 8,
	R16G16B16A16_TYPELESS = 9,
	R16G16B16A16_FLOAT = 10,
	R16G16B16A16_UNORM = 11,
	R16G16B16A16_UINT = 12,
	R16G16B16A16_SNORM = 13,
	R16G16B16A16_SINT = 14,
	R32G32_TYPELESS = 15,
	R32G32_FLOAT = 16,
	R32G32_UINT = 17,
	R32G32_SINT = 18,
	R32G8X24_TYPELESS = 19,
	D32_FLOAT_S8X24_UINT = 20,
	R32_FLOAT_X8X24_TYPELESS = 21,
	X32_TYPELESS_G8X24_UINT = 22,
	R10G10B10A2_TYPELESS = 23,
	R10G10B10A2_UNORM = 24,
	R10G10B10A2_UINT = 25,
	R11G11B10_FLOAT = 26,
	R8G8B8A8_TYPELESS = 27,
	R8G8B8A8_UNORM = 28,
	R8G8B8A8_UNORM_SRGB = 29,
	R8G8B8A8_UINT = 30,
	R8G8B8A8_SNORM = 31,
	R8G8B8A8_SINT = 32,
	R16G16_TYPELESS = 33,
	R16G16_FLOAT = 34,
	R16G16_UNORM = 35,
	R16G16_UINT = 36,
	R16G16_SNORM = 37,
	R16G16_SINT = 38,
	R32_TYPELESS = 39,
	D32_FLOAT = 40,
	R32_FLOAT = 41,
	R32_UINT = 42,
	R32_SINT = 43,
	R24G8_TYPELESS = 44,
	D24_UNORM_S8_UINT = 45,
	R24_UNORM_X8_TYPELESS = 46,
	X24_TYPELESS_G8_UINT = 47,
	R8G8_TYPELESS = 48,
	R8G8_UNORM = 49,
	R8G8_UINT = 50,
	R8G8_SNORM = 51,
	R8G8_SINT = 52,
	R16_TYPELESS = 53,
	R16_FLOAT = 54,
	D16_UNORM = 55,
	R16_UNORM = 56,
	R16_UINT = 57,
	R16_SNORM = 58,
	R16_SINT = 59,
	R8_TYPELESS = 60,
	R8_UNORM = 61,
	R8_UINT = 62,
	R8_SNORM = 63,
	R8_SINT = 64,
	A8_UNORM = 65,
	R1_UNORM = 66,
	R9G9B9E5_SHAREDEXP = 67,
	R8G8_B8G8_UNORM = 68,
	G8R8_G8B8_UNORM = 69,
	BC1_TYPELESS = 70,
	BC1_UNORM = 71,
	BC1_UNORM_SRGB = 72,
	BC2_TYPELESS = 73,
	BC2_UNORM = 74,
	BC2_UNORM_SRGB = 75,
	BC3_TYPELESS = 76,
	BC3_UNORM = 77,
	BC3_UNORM_SRGB = 78,
	BC4_TYPELESS = 79,
	BC4_UNORM = 80,
	BC4_SNORM = 81,
	BC5_TYPELESS = 82,
	BC5_UNORM = 83,
	BC5_SNORM = 84,
	B5G6R5_UNORM = 85,
	B5G5R5A1_UNORM = 86,
	B8G8R8A8_UNORM = 87,
	B8G8R8X8_UNORM = 88,
	R10G10B10_XR_BIAS_A2_UNORM = 89,
	B8G8R8A8_TYPELESS = 90,
	B8G8R8A8_UNORM_SRGB = 91,
	B8G8R8X8_TYPELESS = 92,
	B8G8R8X8_UNORM_SRGB = 93,
	BC6H_TYPELESS = 94,
	BC6H_UF16 = 95,
	BC6H_SF16 = 96,
	BC7_TYPELESS = 97,
	BC7_UNORM = 98,
	BC7_UNORM_SRGB = 99,
	AYUV = 100,
	Y410 = 101,
	Y416 = 102,
	NV12 = 103,
	P010 = 104,
	P016 = 105,
	_420_OPAQUE = 106,
	YUY2 = 107,
	Y210 = 108,
	Y216 = 109,
	NV11 = 110,
	AI44 = 111,
	IA44 = 112,
	P8 = 113,
	A8P8 = 114,
	B4G4R4A4_UNORM = 115,
	P208 = 130,
	V208 = 131,
	V408 = 132,
	SAMPLER_FEEDBACK_MIN_MIP_OPAQUE = 189,
	SAMPLER_FEEDBACK_MIP_REGION_USED_OPAQUE = 190,
	FORCE_UINT = 0xFFFFFFFF,
}

enum DXGI_MODE_SCANLINE_ORDER : int {
	UNSPECIFIED = 0,
	PROGRESSIVE = 1,
	UPPER_FIELD_FIRST = 2,
	LOWER_FIELD_FIRST = 3,
}

enum DXGI_MODE_SCALING : int {
	UNSPECIFIED = 0,
	CENTERED = 1,
	STRETCHED = 2,
}

struct DXGI_MODE_DESC {
	uint Width;
	uint Height;
	DXGI_RATIONAL RefreshRate;
	DXGI_FORMAT Format;
	DXGI_MODE_SCANLINE_ORDER ScanlineOrdering;
	DXGI_MODE_SCALING Scaling;
}

struct DXGI_SAMPLE_DESC {
	uint Count;
	uint Quality;
}

enum DXGI_USAGE : uint {
	SHADER_INPUT = 1 << (0 + 4),
	RENDER_TARGET_OUTPUT = 1 << (1 + 4),
	BACK_BUFFER = 1 << (2 + 4),
	SHARED = 1 << (3 + 4),
	READ_ONLY = 1 << (4 + 4),
	DISCARD_ON_PRESENT = 1 << (5 + 4),
	UNORDERED_ACCESS = 1 << (6 + 4),
}

enum DXGI_SWAP_EFFECT : int {
	DISCARD = 0,
	SEQUENTIAL = 1,
	FLIP_SEQUENTIAL = 3,
	FLIP_DISCARD = 4,
}

struct DXGI_SWAP_CHAIN_DESC {
	DXGI_MODE_DESC BufferDesc;
	DXGI_SAMPLE_DESC SampleDesc;
	DXGI_USAGE BufferUsage;
	uint BufferCount;
	HWND OutputWindow;
	int Windowed;
	DXGI_SWAP_EFFECT SwapEffect;
	uint Flags;
}

struct DXGI_FRAME_STATISTICS {
	uint PresentCount;
	uint PresentRefreshCount;
	uint SyncRefreshCount;
	ulong SyncQPCTime;
	ulong SyncGPUTime;
}

enum DXGI_SWAP_CHAIN_FLAG : int {
	NONPREROTATED = 1,
	ALLOW_MODE_SWITCH = 2,
	GDI_COMPATIBLE = 4,
	RESTRICTED_CONTENT = 8,
	RESTRICT_SHARED_RESOURCE_DRIVER = 16,
	DISPLAY_ONLY = 32,
	FRAME_LATENCY_WAITABLE_OBJECT = 64,
	FOREGROUND_LAYER = 128,
	FULLSCREEN_VIDEO = 256,
	YUV_VIDEO = 512,
	HW_PROTECTED = 1024,
	ALLOW_TEARING = 2048,
	RESTRICTED_TO_ALL_HOLOGRAPHIC_DISPLAYS = 4096,
}

struct IDXGIObject {
	struct VTable {
		IUnknown.VTable iunknown;
		alias this = iunknown;
		extern(Windows) HRESULT function(void*, IID*, void**) GetParent;
		extern(Windows) HRESULT function(void*, const(GUID)*, uint*, void*) GetPrivateData;
		extern(Windows) HRESULT function(void*, const(GUID)*, uint, const(void)*) SetPrivateData;
		extern(Windows) HRESULT function(void*, const(GUID)*, const(IUnknown)*) SetPrivateDataInterface;
	}
	VTable* lpVtbl;
	alias this = lpVtbl;
}

struct IDXGIOutput {
	struct VTable {
		IDXGIObject.VTable idxgiobject;
		alias this = idxgiobject;
		// ...
	}
	VTable* lpVtbl;
	alias this = lpVtbl;
}

struct IDXGIAdapter {
	struct VTable {
		IDXGIObject.VTable idxgiobject;
		alias this = idxgiobject;
		// ...
	}
	VTable* lpVtbl;
	alias this = lpVtbl;
}

struct IDXGIDeviceSubObject {
	struct VTable {
		IDXGIObject.VTable idxgiobject;
		alias this = idxgiobject;
		extern(Windows) HRESULT function(void*, IID*, void**) GetDevice;
	}
	VTable* lpVtbl;
	alias this = lpVtbl;
}

struct IDXGISwapChain {
	struct VTable {
		IDXGIDeviceSubObject.VTable idxgidevicesubobject;
		alias this = idxgidevicesubobject;
		extern(Windows) HRESULT function(void*, uint, IID*, void**) GetBuffer;
		extern(Windows) HRESULT function(void*, IDXGIOutput**) GetContainingOutput;
		extern(Windows) HRESULT function(void*, DXGI_SWAP_CHAIN_DESC*) GetDesc;
		extern(Windows) HRESULT function(void*, DXGI_FRAME_STATISTICS*) GetFrameStatistics;
		extern(Windows) HRESULT function(void*, int, IDXGIOutput**) GetFullscreenState;
		extern(Windows) HRESULT function(void*, uint*) GetLastPresentCount;
		extern(Windows) HRESULT function(void*, uint, uint) Present;
		extern(Windows) HRESULT function(void*, uint, uint, uint, DXGI_FORMAT, uint) ResizeBuffers;
		extern(Windows) HRESULT function(void*, const(DXGI_MODE_DESC)*) ResizeTarget;
		extern(Windows) HRESULT function(void*, int, IDXGIOutput*) SetFullscreenState;
	}
	VTable* lpVtbl;
	alias this = lpVtbl;
}
