extends Node

# Texture Formats
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
	IDX_4_I_4 = 147
	
	END = 255
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
