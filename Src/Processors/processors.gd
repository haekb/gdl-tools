class Processors:
	# See: https://openkh.dev/common/tm2.html and https://psi-rockin.github.io/ps2tek/ (GS Textures)
	var processors = {
		Constants.Tex_Formats.ABGR_1555: load('res://Src/Processors/ps2/texture_abgr_1555.gd').Texture_ABGR_1555,
		Constants.Tex_Formats.IDX_8_ABGR_8888: load('res://Src/Processors/ps2/texture_idx_8_abgr_8888.gd').Texture_IDX_8_ABGR_8888,
		Constants.Tex_Formats.IDX_8_ABGR_1555: load('res://Src/Processors/ps2/texture_idx_8_abgr_1555.gd').Texture_IDX_8_ABGR_1555,
		Constants.Tex_Formats.IDX_4_A_4: load('res://Src/Processors/ps2/texture_4_a_4.gd').Texture_4_A_4,
		Constants.Tex_Formats.IDX_8_A_8: load('res://Src/Processors/ps2/texture_8_a_8.gd').Texture_8_A_8,
	}
	
	func process(data, rom_tex, options = []):
		if rom_tex.format in self.processors:
			return self.processors[rom_tex.format].process(data, rom_tex, options)
		# End If
		print("Format %s is not yet supported!" % Helpers.get_texture_format_string(rom_tex.format))
		return null
	# End Func
# End Class
