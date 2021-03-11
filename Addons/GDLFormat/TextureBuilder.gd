extends Node

func _ready():
	#self.build("D:\\Emulation\\GameCube Games\\GDL11\\files\\Gauntlet\\STATIC\\textures.ngc", [])
	#self.build("D:\\GameDev\\opengdl\\GameData\\STATIC\\textures.ps2", [])
	pass

func build(source_file, options):
	var file = File.new()
	if file.open(source_file, File.READ) != OK:
		print("Failed to open %s" % source_file)
		return null
		
	print("Opened %s" % source_file)
	
	
	if ".ngc" in source_file:
		file.set_endian_swap(true)
		print("Nintendo Gamecube file detected. Swapping endian.")
	
	var path = "%s/Models/Textures.gd" % self.get_script().get_path().get_base_dir()
	var tex_file = load(path)
	
	# Model as in MVC model, not mesh model!
	var model = tex_file.Textures.new()
	
	var response = model.read(file)
	
	file.close()
	
	if response.code == model.IMPORT_RETURN.ERROR:
		print("IMPORT ERROR: %s" % response.message)
		return null
		
	var texture = ImageTexture.new()
	texture.create_from_image(model.image)
	texture.set_flags(ImageTexture.FLAGS_DEFAULT + ImageTexture.FLAG_ANISOTROPIC_FILTER + ImageTexture.FLAG_CONVERT_TO_LINEAR)
	
	return texture
