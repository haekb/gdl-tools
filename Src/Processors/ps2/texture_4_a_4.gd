class Texture_4_A_4:
	static func process(data, rom_tex, options = []):
		var width = rom_tex.width
		var height = rom_tex.height
		var flags = rom_tex.flags
		
		var data_len = len(data)
		var image_data = []
		var alpha_as_albedo = "alpha_as_albedo" in options
		
		var working_width = width / 2
		var working_height = height / 2
		
		# Original width/height
		var full_width = width
		var full_height = height
		
		var repeated_line = false
		var y = 0

		while y < working_height:
			for x in range(working_width):
				var pixel = data[ y * width + x ]
				var alt_pixel = data[ working_width + (y * width + x) ]

				var first_pixel = (pixel & 0x0f)
				var second_pixel = (pixel & 0xf0) >> 4
				
				if repeated_line:
					first_pixel = (alt_pixel & 0x0f)
					second_pixel = (alt_pixel & 0xf0) >> 4
				
				first_pixel *= 16
				second_pixel *= 16
	
				if alpha_as_albedo:
					image_data.append(first_pixel)
					image_data.append(first_pixel)
					image_data.append(first_pixel)
					image_data.append(255)
					image_data.append(second_pixel)
					image_data.append(second_pixel)
					image_data.append(second_pixel)
					image_data.append(255)
				else:
					image_data.append(255)
					image_data.append(255)
					image_data.append(255)
					image_data.append(first_pixel)
					
					image_data.append(255)
					image_data.append(255)
					image_data.append(255)
					image_data.append(second_pixel)
			# End For
			if repeated_line:
				y += 1
			repeated_line = !repeated_line
		# End While
		
		return image_data
	# End Func
# End Class
