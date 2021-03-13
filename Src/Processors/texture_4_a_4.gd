class Texture_4_A_4:
	
	static func process(data, width, height, flags):
		var data_len = len(data)
		var image_data = []
		
		var working_width = width / 2
		var working_height = height / 2
		
		if flags & Constants.Tex_Flags.HALF_RES:
			working_width = working_width / 2
			#working_height = working_height / 2
		

		for y in range(working_height):
			for x in range(working_width):
				var pixel = data[ y * width + x ]
				var alpha = data[ working_width + (y * width + x) ]
				
				image_data.append(pixel)
				image_data.append(pixel)
				image_data.append(pixel)
				image_data.append(255)
		
		
		var img = Image.new()

		img.create_from_data(working_width, working_height, false, Image.FORMAT_RGBA8, image_data)
		#img.resize(width, height, Image.INTERPOLATE_NEAREST)
		img.save_png("./texture_4_a_4.png")
		return data
	# End Func
# End Class
