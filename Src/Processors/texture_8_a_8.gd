class Texture_8_A_8:
	static func process(data, width, height, flags):
		var data_len = len(data)
		var image_data = []
		
		# Probably wrong
		if flags & Constants.Tex_Flags.HALF_RES:
			width /= 2
			height /= 2
		
		for y in range(height):
			for x in range(width):
				var pixel = data[ y * width + x ]
				
				image_data.append(255)
				image_data.append(255)
				image_data.append(255)
				image_data.append(pixel)
			# End For
		# End For
		
		# Debug
		var img = Image.new()
		img.create_from_data(width, height, false, Image.FORMAT_RGBA8, image_data)
		img.save_png("./texture_8_a_8.png")

		return data
	# End Func
# End Class
