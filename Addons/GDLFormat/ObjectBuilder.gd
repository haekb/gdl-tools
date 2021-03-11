extends Node

func build(source_file, options):
	var file = File.new()
	if file.open(source_file, File.READ) != OK:
		print("Failed to open %s" % source_file)
		return null
		
	print("Opened %s" % source_file)
	
	# Not needed?
	#if ".ngc" in source_file:
	#	file.set_endian_swap(true)
	#	print("Nintendo Gamecube file detected. Swapping endian.")
	
	var path = "%s/Models/Objects.gd" % self.get_script().get_path().get_base_dir()
	var obj_file = load(path)
	
	# Model as in MVC model, not mesh model!
	var model = obj_file.Objects.new()
	
	var response = model.read(file)
	
	file.close()
	
	if response.code == model.IMPORT_RETURN.ERROR:
		print("IMPORT ERROR: %s" % response.message)
		return null
		
	return model
