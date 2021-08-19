class DCProcessors:
	# See: https://openkh.dev/common/tm2.html and https://psi-rockin.github.io/ps2tek/ (GS Textures)
	var processors = {
		Constants.DC_Tex_Formats.RGB_565: load('res://Src/Processors/dc/texture_565.gd').Texture_565,
		#Constants.DC_Tex_Formats.RGB_555: load('res://Src/Processors/dc/texture_565.gd').Texture_565,
	}
	
	func process(data, rom_tex, options = []):
		
		for format in processors.keys():
			if format & rom_tex.attributes:
				return self.processors[format].process(data, rom_tex, options)
		
		#if rom_tex.format in self.processors:
		#	return self.processors[rom_tex.format].process(data, rom_tex, options)
		# End If
		print("Format %d is not yet supported!" % rom_tex.attributes)
		return null
	# End Func
# End Class
