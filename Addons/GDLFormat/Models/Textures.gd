extends Node

class Textures:
	var image = null
	var format = null
		
	func read_texture(f : File, rom_tex, options = []):
		var size = rom_tex.size
		var width = rom_tex.width
		var height = rom_tex.height
		var pformat = rom_tex.format
		var flags = rom_tex.flags
		var platform = rom_tex.platform
		
		var read_width = width
		var read_height = height
		var bytes = 1
		
		var tex_data = []
		#if flags & Constants.Tex_Flags.HALF_RES:
		#	read_width /= 2
		#	read_height /= 2
		
		var read = read_width * read_height
		
		# TODO: Figure out how to stick these in the processors...
		if rom_tex.platform == "ps2":
			# Include the palette
			if pformat == Constants.Tex_Formats.IDX_8_ABGR_8888:
				read += 1024
			elif pformat == Constants.Tex_Formats.IDX_8_ABGR_1555:
				read += 512
			#elif pformat == Constants.Tex_Formats.UNK_DREAMCAST:
			#	read *= 2
				
			if pformat == Constants.Tex_Formats.ABGR_1555:
				# Two bytes per pixel
				read *= 2
			#if format == Constants.Tex_Formats.IDX_8_ABGR_1555:
			#	# Two bytes per pixel
			#	read *= 2
		
			if !f.endian_swap:
				tex_data = Array(f.get_buffer(read))
			else:
				for _i in range(read):
					tex_data.append(Helpers.flip_byte(f.get_8()))
				# End For
			# End If
		else:
			read = size/2
			for _i in range(read):
				tex_data.append(f.get_16())
			# End For
		
		var processors = null
		if platform == "ps2":
			processors = load('res://Src/Processors/processors.gd').Processors.new()
		elif platform == "dc":
			processors = load('res://Src/Processors/processors_dc.gd').DCProcessors.new()
		
		var return_data = processors.process(tex_data, rom_tex, options)
		
		if !return_data:
			return null
		
		var image = Image.new()
		image.create_from_data(width, height, false, Image.FORMAT_RGBA8, return_data)
		
		
#		var image = Image.new()
#		image.create_from_data(width, height, false, Image.FORMAT_RGBA8, tex_data_rgb888a)
#		image.save_png("./texture_test.png")
		
		
		
		return image
	# End Func

	func read(f : File, rom_tex, options = []):
		var size = rom_tex.size
		var width = rom_tex.width
		var height = rom_tex.height
		var lformat = rom_tex.format
		var flags = rom_tex.flags
		
		f.seek(rom_tex.tex_data_pointer)
		
		if !("no_log" in options):
			var string_flags = Helpers.get_texture_flag_string(flags)
			print("Texture Flags: ", string_flags)
		
		self.format = lformat
		self.image = read_texture(f, rom_tex, options)
		
		return Helpers.make_response(Helpers.IMPORT_RETURN.SUCCESS)
	# End Func
# End Class
