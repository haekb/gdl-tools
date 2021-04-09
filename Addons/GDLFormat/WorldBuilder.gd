extends Node

func build(source_file, options):
	var file = File.new()
	if file.open(source_file, File.READ) != OK:
		print("Failed to open %s" % source_file)
		return null
		
	print("Opened %s" % source_file)
	
	var path = "%s/Models/Worlds.gd" % self.get_script().get_path().get_base_dir()
	var obj_file = load(path)
	var model = obj_file.Worlds.new()
		
	var response = model.read(file)

	file.close()
	
	if response.code == Helpers.IMPORT_RETURN.ERROR:
		print("IMPORT ERROR: %s" % response.message)
		return null
		
	return model
