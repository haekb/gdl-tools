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

enum Item_Type {
  ITEM_RANDOM = 0xFFFFFFFF,
  ITEM_POWERUP = 0x1,
  ITEM_CONTAINER = 0x2,
  ITEM_GENERATOR = 0x3,
  ITEM_ENEMYINFO = 0x4,
  ITEM_TRIGGER = 0x5,
  ITEM_TRAP = 0x6,
  ITEM_DOOR = 0x7,
  ITEM_DAMAGETILE = 0x8,
  ITEM_EXIT = 0x9,
  ITEM_OBSTICLE = 0xA,
  ITEM_TRANSPORTER = 0xB,
  ITEM_ROTATOR = 0xC,
  ITEM_SOUND = 0xD,
}

enum Item_Subtype {
  ITEM_GOLD = 0x1,
  ITEM_KEY = 0x2,
  ITEM_FOOD = 0x3,
  ITEM_POTION = 0x4,
  ITEM_WEAPON = 0x5,
  ITEM_ARMOR = 0x6,
  ITEM_SPEED = 0x7,
  ITEM_MAGIC = 0x8,
  ITEM_SPECIAL = 0x9,
  ITEM_RUNESTONE = 0xA,
  ITEM_BOSSKEY = 0xB,
  ITEM_OBELISK = 0xC,
  ITEM_QUEST = 0xD,
  ITEM_SCROLL = 0xE,
  ITEM_GEMSTONE = 0xF,
  ITEM_FEATHER = 0x10,
  SUB_BRIDGEPAD = 0x14,
  SUB_DOORPAD = 0x15,
  SUB_BRIDGESWITCH = 0x16,
  SUB_DOORSWITCH = 0x17,
  SUB_ACTIVESWITCH = 0x18,
  SUB_ELEVPAD = 0x19,
  SUB_ELEVSWITCH = 0x1A,
  SUB_LIFTPAD = 0x1B,
  SUB_LIFTSTART = 0x1C,
  SUB_LIFTEND = 0x1D,
  SUB_NOWEAPCOL = 0x1E,
  SUB_SHOOTTRIG = 0x1F,
  SUB_ROCKFALL = 0x28,
  SUB_SAFEROCK = 0x29,
  SUB_WALL = 0x2A,
  SUB_BARREL = 0x2B,
  SUB_BARREL_EXP = 0x2C,
  SUB_BARREL_POI = 0x2D,
  SUB_CHEST = 0x2E,
  SUB_CHEST_GOLD = 0x2F,
  SUB_CHEST_SILVER = 0x30,
  SUB_LEAFFALL = 0x31,
  SUB_SECRET = 0x32,
  SUB_ROCKFLY = 0x33,
  SUB_SHOOTFALL = 0x34,
  SUB_ROCKSINK = 0x35,
}

