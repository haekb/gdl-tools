class Processors:
	# See: https://openkh.dev/common/tm2.html and https://psi-rockin.github.io/ps2tek/ (GS Textures)
	var processors = {
		Constants.Tex_Formats.IDX_4_A_4: load('res://Src/Processors/texture_4_a_4.gd').Texture_4_A_4,
		Constants.Tex_Formats.IDX_8_A_8: load('res://Src/Processors/texture_8_a_8.gd').Texture_8_A_8,
	}
	
	
	func process(data, width, height, flags, format):
		if format in self.processors:
			return self.processors[format].process(data, width, height, flags)
		# End If
		return null
	# End Func
# End Class