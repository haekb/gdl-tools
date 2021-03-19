extends Node

#
# Helpers
# 
enum IMPORT_RETURN{SUCCESS, ERROR}
func make_response(code, message = ''):
	return { 'code': code, 'message': message }
# End Func


# Determine the amount of alignment that's needed
func alignment_required(to, f):
	var align = f.get_position() % to
	if (align == 0):
		return align
	return to - align
# End Func

#Align our file pointer by `to` bytes
func align(to, f):
	var align = alignment_required(to, f)
	if align == 0:
		return
	f.seek(align + f.get_position())
# End Func

func get_model_flag_string(flags):
	var to_string = {
		Constants.Model_Flags.ALPHA: "Alpha",
		Constants.Model_Flags.VNORMS: "Vertex Normals",
		Constants.Model_Flags.VCOLORS: "Vertex Colours",
		Constants.Model_Flags.MESH: "Mesh",
		Constants.Model_Flags.TEX2: "Tex2", # Second set of UVs?
		Constants.Model_Flags.LMAP: "LMap", # Light map?
		Constants.Model_Flags.SHARP: "Sharp",
		Constants.Model_Flags.BLUR: "Blur",
		Constants.Model_Flags.CHROME: "Chrome",
		Constants.Model_Flags.ERROR: "Error",
		Constants.Model_Flags.SORTA: "Sort A", # Alpha?
		Constants.Model_Flags.SORT: "Sort",
		Constants.Model_Flags.FMT_BASIC: "Format Basic", #?
		Constants.Model_Flags.FMT_MASK: "Format Mask", #?
		Constants.Model_Flags.LIT_MASK: "Lit Mask", #?
		Constants.Model_Flags.NON_LIT: "Non Lit",
		Constants.Model_Flags.PRE_LIT: "Pre Lit",
		Constants.Model_Flags.LMAP_LIT: "LMap Lit",
		Constants.Model_Flags.NORM_LIT: "Normal Lit",
		Constants.Model_Flags.DYN_LIGHT: "Dynamic Lit",
		Constants.Model_Flags.END: "End",
	}
	var to_string_flags = []
	for flag in to_string.keys():
		if (flag & flags):
			to_string_flags.append(to_string[flag])
		# End If
	# End For

	return to_string_flags
# End Func

func get_texture_format_string(format):
	var to_string = {
		Constants.Tex_Formats.ABGR_1555: "ABGR 1555",
		Constants.Tex_Formats.BGR_555: "BGR 555",
		Constants.Tex_Formats.ABGR_8888: "ABGR 8888",
		Constants.Tex_Formats.BGR_888: "BGR 888",
		Constants.Tex_Formats.IDX_4_ABGR_1555: "IDX 4 - ABGR 1555",
		Constants.Tex_Formats.IDX_4_BGR_555: "IDX 4 - BGR 555",
		Constants.Tex_Formats.IDX_4_ABGR_8888: "IDX 4 - ABGR 8888",
		Constants.Tex_Formats.IDX_4_BGR_888: "IDX 4 - BGR 888",
		Constants.Tex_Formats.IDX_8_ABGR_1555: "IDX 8 - ABGR 1555",
		Constants.Tex_Formats.IDX_8_BGR_555: "IDX 8 - BGR 555",
		Constants.Tex_Formats.IDXA_88: "IDXA 88",
		Constants.Tex_Formats.IDX_8_ABGR_8888: "IDX 8 - ABGR 8888",
		Constants.Tex_Formats.IDX_8_BGR_888: "IDX 8 - BGR 888",
		Constants.Tex_Formats.IDX_8_A_8: "IDX 8 A 8",
		Constants.Tex_Formats.IDX_8_I_8: "IDX 8 I 8",
		Constants.Tex_Formats.IDX_4_A_4: "IDX 4 A 4",
		Constants.Tex_Formats.IDX_4_I_4: "IDX 4 I 4",
	}
	
	if format in to_string:
		return to_string[format]
	
	return "Unknown"
# End Func

# Signed to unsigned byte
func stub(value):
	if value < 0:
		return value + 256

	return value

# Unsigned to signed byte
func utsb(value):
	if value > 127:
		return value - 256
	
	return value

# Unsigned to signed short
func utsh(value):
	if value > 32767:
		return value - 65536

	return value
	
func utsi(value):
	if value > 2147483647:
		return value - 4294967296
	
	return value

func read_c_string(f : File):
	var string = ""
	while true:
		var next_value = f.get_8()
		if next_value == 0x0:
			break
		string += char(next_value)
	# End While
	return string
# End Func

func read_vector3(f : File):
	var x = f.get_float()
	var y = f.get_float()
	var z = f.get_float()
	return Vector3(x, y, z)

# Equiv of f.seek(amount, 1) in python
func seek_ahead(amount, f : File):
	f.seek(f.get_position() + amount)
# End If
