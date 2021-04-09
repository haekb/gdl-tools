extends Node

func build(source_file, options):
	var no_log = "no_log" in options
	
	var file = File.new()
	if file.open(source_file, File.READ) != OK:
		print("Failed to open %s" % source_file)
		return null
		
	if !no_log:
		print("Opened %s" % source_file)
	
	# Not needed?
	#if ".ngc" in source_file:
	#	file.set_endian_swap(true)
	#	print("Nintendo Gamecube file detected. Swapping endian.")
	
	file.seek(64)
	var version = file.get_32()
	file.seek(0)
	
	var model = null
	var response = null
	
	# Gauntlet Legends (Dreamcast)
	if version == 0xF00B0001:
		var path = "%s/Models/ObjectsGL.gd" % self.get_script().get_path().get_base_dir()
		var obj_file = load(path)
		model = obj_file.Objects.new()
	# Gauntlet Dark Legacy (PS2, Xbox, Gamecube)
	elif version == 0xF00B000C or version == 0xF00B000D:
		var path = "%s/Models/Objects.gd" % self.get_script().get_path().get_base_dir()
		var obj_file = load(path)
		model = obj_file.Objects.new()
	else:
		if !no_log:
			print("Unknown Objects format %d" % version)
		return null
	# End If
		
	response = model.read(file)

	file.close()
	
	if response.code == Helpers.IMPORT_RETURN.ERROR:
		print("IMPORT ERROR: %s" % response.message)
		return null
		
	return model
