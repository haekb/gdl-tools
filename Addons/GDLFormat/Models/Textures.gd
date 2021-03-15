extends Node

class TextureFormat:	
	# From: https://stackoverflow.com/a/3124978
	static func flip_byte(x):
		var nibble1 = (x & 0x0F)
		var nibble2 = ((x & 0xF0) >> 4)
		
		# Flip those numbers!
		return ((nibble1 << 4) | nibble2)
		
	static func get_nibbles(x):
		var nibble1 = (x & 0x0F)
		var nibble2 = ((x & 0xF0) >> 4)
		return [nibble1, nibble2]
	
	static func signed_to_unsigned(value):
		if value < 0:
			return value + (128*2)
			
		return value
	
	static func cast(data, width, height, flags, format):
		var return_data = []
		
		print("FORMAT %d" % format)
		
		var processors = load('res://Src/Processors/processors.gd').Processors.new()
		
		return_data = processors.process(data, width, height, flags, format)
		
		var image = Image.new()
		image.create_from_data(width, height, false, Image.FORMAT_RGBA8, return_data)
		
		#image.resize(width, height, Image.INTERPOLATE_NEAREST)
		#image.save_png("./dump.png")
		
		return image
	# End Func
# End Class

class Textures:
	var image = null
	
	func read_texture(f : File, width, height, flags, format):
		var read_width = width
		var read_height = height
		var bytes = 1
		
		var tex_data = []
		#if flags & Constants.Tex_Flags.HALF_RES:
		#	read_width /= 2
		#	read_height /= 2
		
		var read = read_width * read_height
		
		# TODO: Figure out how to stick these in the processors...
		
		# Include the palette
		if format == Constants.Tex_Formats.IDX_8_ABGR_8888:
			read += 1024
			
		if format == Constants.Tex_Formats.ABGR_1555:
			# Two bytes per pixel
			read *= 2
		
		if !f.endian_swap:
			tex_data = Array(f.get_buffer(read))
		else:
			for _i in range(read):
				tex_data.append(TextureFormat.flip_byte(f.get_8()))
			# End For
		# End If

		var tex_data_rgb888a = TextureFormat.cast(tex_data, width, height, flags, format)
		
#		var image = Image.new()
#		image.create_from_data(width, height, false, Image.FORMAT_RGBA8, tex_data_rgb888a)
#		image.save_png("./texture_test.png")
		
		return tex_data_rgb888a
	# End Func

	func read(f : File, rom_tex):
		var size = rom_tex.size
		var width = rom_tex.width
		var height = rom_tex.height
		var format = rom_tex.format
		var flags = rom_tex.flags
		
		f.seek(rom_tex.tex_data_pointer)
		
		self.image = read_texture(f, width, height, flags, format)
		
		return Helpers.make_response(Helpers.IMPORT_RETURN.SUCCESS)
	# End Func
# End Class
