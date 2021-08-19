extends Node

# Thanks https://www.pioneer2.net/community/threads/pso-dev-wiki-staging-thread.14913/page-2#post-129046
enum DC_Tex_Attributes {
	TWIDDLED           = 0x0100,
	TWIDDLED_MM        = 0x0200,
	VQ                 = 0x0300,
	VQ_MM              = 0x0400,
	PALETTIZE4         = 0x0500,
	PALETTIZE4_MM      = 0x0600,
	PALETTIZE8         = 0x0700,
	PALETTIZE8_MM      = 0x0800,
	RECTANGLE          = 0x0900,
	STRIDE             = 0x0B00,
	TWIDDLED_RECTANGLE = 0x0D00,
	ABGR               = 0x0E00,
	ABGR_MM            = 0x0F00,
	SMALLVQ            = 0x1000,
	SMALLVQ_MM         = 0x1100,
	TWIDDLED_MM_ALIAS  = 0x1200,
}

enum DC_Tex_Formats {
	ARGB_1555          = 0x00,
	RGB_565            = 0x01,
	ARGB_4444          = 0x02,
	YUV_422            = 0x03,
	BUMP               = 0x04,
	RGB_555            = 0x05,
	YUV_420            = 0x06,
}

# Texture Formats (GDL)
enum Tex_Formats {
	ABGR_1555 = 0,
	BGR_555 = 1,
	ABGR_8888 = 2,
	BGR_888 = 3,
	IDX_4_ABGR_1555 = 16,
	IDX_4_BGR_555 = 17,
	IDX_4_ABGR_8888 = 34,
	IDX_4_BGR_888 = 35,
	IDX_8_ABGR_1555 = 48,
	IDX_8_BGR_555 = 49,
	IDXA_88 = 56,
	IDX_8_ABGR_8888 = 66,
	IDX_8_BGR_888 = 67,
	IDX_8_A_8 = 130,
	IDX_8_I_8 = 131,
	IDX_4_A_4 = 146,
	IDX_4_I_4 = 147,
}

enum Tex_Flags {
	HALF_RES = 1,
	SEE_ALPHA = 2,
	CLAMP_S = 4,
	CLAMP_T = 8,
	ANIM = 16,
	EXTERN = 32,
	TEX_SHIFT = 64
	HAS_ALPHA = 128
	INVALID = 256,
	DUAL_TEX = 512,
}

enum Model_Flags {
	ALPHA = 1,
	VNORMS = 2,
	VCOLORS = 4,
	MESH = 8,
	TEX2 = 16,
	LMAP = 32,
	SHARP = 64,
	BLUR = 128,
	CHROME = 256,
	ERROR = 512,
	SORTA = 1024,
	SORT =  2048,
	# ?
	FMT_BASIC = 0,
	FMT_MASK = 61440,
	# ?
	LIT_MASK = 983040,
	# Lighting settings
	NON_LIT = 0,
	PRE_LIT = 65536,
	LMAP_LIT = 131072,
	NORM_LIT = 196608,
	DYN_LIGHT = 1048576,
	END = 1048577,
}

enum Bone_Types {
	EMPTY = 0xFFFFFFFF,
	NULL = 0,
	SKEL_ANIM = 1,
	OBJ_ANIM = 2,
	TEX_ANIM = 3,
	PSYS_ANIM = 4,
}

const Normal_Scale = 0.06666667
const Mesh_Scale = 0.0078125 # 1 / 128
