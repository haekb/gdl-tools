class Texture_8_A_8:
	static func process(data, rom_tex, options = []):
		var width = rom_tex.width
		var height = rom_tex.height
		var flags = rom_tex.flags
		
		var data_len = len(data)
		var image_data = []
		
		for y in range(height):
			for x in range(width):
				var pixel = data[ y * width + x ]
				
				image_data.append(255)
				image_data.append(255)
				image_data.append(255)
				image_data.append(pixel)
			# End For
		# End For
		
		return image_data
	# End Func
# End Class
