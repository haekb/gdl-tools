extends Node

class TextureFormat:
	const FMT_ABGR_1555 = 0
	const FMT_BGR_555 = 1
	const FMT_ABGR_8888 = 2
	const FMT_BGR_888 = 3
	const FMT_IDX_4_ABGR_1555 = 16
	const FMT_IDX_4_BGR_555 = 17
	const FMT_IDX_4_ABGR_8888 = 34
	const FMT_IDX_4_BGR_888 = 35
	const FMT_IDX_8_ABGR_1555 = 48
	const FMT_IDX_8_BGR_555 = 49
	const FMT_IDXA_88 = 56
	const FMT_IDX_8_ABGR_8888 = 66
	const FMT_IDX_8_BGR_888 = 67
	const FMT_IDX_8_A_8 = 130
	const FMT_IDX_8_I_8 = 131
	const FMT_IDX_4_A_4 = 146
	const FMT_IDX_4_I_4 = 147
	const FMT_END = 255
	
	const FLAG_HALF_RES = 1
	const FLAG_SEE_ALPHA = 2
	const FLAG_CLAMP_S = 4
	const FLAG_CLAMP_T = 8
	const FLAG_ANIM = 16
	const FLAG_EXTERN = 32
	const FLAG_TEX_SHIFT = 64
	const FLAG_HAS_ALPHA = 128
	const FLAG_INVALID = 256
	const FLAG_DUAL_TEX = 512
	
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
	
	static func cast(data, width, height, flags, format):
		var return_data = []
		
		if format == FMT_IDX_4_A_4:
			
			var previous_pixel = 0
			var read_alpha = false
			var adjust_half_res = false
			
			var pos = 0
			var full_size = len(data)
			var size = full_size / 2

			var data_b = data.slice(size, full_size)
			
			var slice_w = width# / 2
			var slice_h = height# / 2
			
			if flags & TextureFormat.FLAG_HALF_RES:
				slice_w = width / 4
				slice_h = height / 2
			
			var image1 = Image.new()
			image1.create_from_data(slice_w, slice_h, false, Image.FORMAT_R8, data_b)
			image1.save_png("./dump.png")
			
			while pos < size:# - 1:
				var pixel = data[pos]
				#var pixel2 = data_b[pos]

				return_data.append(pixel) # R
				return_data.append(pixel) # G
				return_data.append(pixel) # B
				return_data.append(255) # A

				if flags & TextureFormat.FLAG_HALF_RES:
					return_data.append(pixel) # R
					return_data.append(pixel) # G
					return_data.append(pixel) # B
					return_data.append(255) # A
				# End If
				
				return_data.append(pixel) # R
				return_data.append(pixel) # G
				return_data.append(pixel) # B
				return_data.append(255) # A
#
				if flags & TextureFormat.FLAG_HALF_RES:
					return_data.append(pixel) # R
					return_data.append(pixel) # G
					return_data.append(pixel) # B
					return_data.append(255) # A
				# End If
				
				return_data.append(pixel) # R
				return_data.append(pixel) # G
				return_data.append(pixel) # B
				return_data.append(255) # A
#
				if flags & TextureFormat.FLAG_HALF_RES:
					return_data.append(pixel) # R
					return_data.append(pixel) # G
					return_data.append(pixel) # B
					return_data.append(255) # A
				# End If
				
				return_data.append(pixel) # R
				return_data.append(pixel) # G
				return_data.append(pixel) # B
				return_data.append(255) # A
#
				if flags & TextureFormat.FLAG_HALF_RES:
					return_data.append(pixel) # R
					return_data.append(pixel) # G
					return_data.append(pixel) # B
					return_data.append(255) # A
				# End If
				
				pos += 1
			# End While
		# End If
		
		var image = Image.new()
		image.create_from_data(width, height, false, Image.FORMAT_RGBA8, return_data)
		#image.resize(width, height, Image.INTERPOLATE_NEAREST)
		image.save_png("./dump.png")
		
		return return_data
	# End Func
# End Class

class Textures:
	
	func read_texture(f : File, width, height, flags, format):
		var read_width = width
		var read_height = height
		var bytes = 1
		
		var tex_data = []
		if flags & TextureFormat.FLAG_HALF_RES:
			read_width /= 2
			read_height /= 2
		
		#if flags & TextureFormat.FLAG_HAS_ALPHA:
		#	bytes += 1
		# End If
		
		var read = read_width * read_height * bytes
		
		if !f.endian_swap:
			tex_data = Array(f.get_buffer(read))
		else:
			for _i in range(read):
				tex_data.append(TextureFormat.flip_byte(f.get_8()))
			# End For
		# End If

		var tex_data_rgb888a = TextureFormat.cast(tex_data, width, height, flags, format)
		
		var image = Image.new()
		#image.create_from_data(width, height, false, Image.FORMAT_R8, tex_data)
		image.create_from_data(width, height, false, Image.FORMAT_RGBA8, tex_data_rgb888a)
		image.save_png("./texture_test.png")
		
		return tex_data_rgb888a
	
	func read_grid(f : File):
		# This data would come from Objects.ps2 under RomTex
		var size = 32
		var width = 32
		var height = 32
		var format = TextureFormat.FMT_IDX_4_A_4
		var flags = 141
		
		return read_texture(f, width, height, flags, format)

	# 8192 bytes long
	# 128x64?? Might need to double on one axis
	func read_fonts(f : File):
		f.seek(512)
		#This data would come from Objects.ps2 under RomTex
		var size = 32
		var width = 128
		var height = 128
		var format = TextureFormat.FMT_IDX_4_A_4
		var flags = 140
		
		return read_texture(f, width, height, flags, format)

	func read(f : File):
		var data = self.read_grid(f)
		
		return data
	# End Func
# End Class
