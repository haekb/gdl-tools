extends Node

func _ready():
	#self.build("D:\\Emulation\\GameCube Games\\GDL11\\files\\Gauntlet\\STATIC\\textures.ngc", [])
	#self.build("D:\\GameDev\\opengdl\\GameData\\STATIC\\textures.ps2", [])
	pass

var model = null
var texture = null

func build(source_file, rom_tex, tex_index, options):
	var no_log = "no_log" in options
	
	var cached_texture = TextureCache.get(tex_index)
	if cached_texture:
		self.texture = cached_texture
		return cached_texture
	
	var file = File.new()
	if file.open(source_file, File.READ) != OK:
		print("Failed to open %s" % source_file)
		return null
	
	if !no_log:
		print("Opened %s" % source_file)
	
	
	#if ".ngc" in source_file:
	#	file.set_endian_swap(true)
	#	print("Nintendo Gamecube file detected. Swapping endian.")
	
	var path = "%s/Models/Textures.gd" % self.get_script().get_path().get_base_dir()
	var tex_file = load(path)
	
	# Model as in MVC model, not mesh model!
	var model = tex_file.Textures.new()
	
	var response = model.read(file, rom_tex, options)
	self.model = model
	
	file.close()
	
	if model.image == null or response.code == Helpers.IMPORT_RETURN.ERROR:
		print("IMPORT ERROR: %s" % response.message)
		return null
		
	var texture = ImageTexture.new()
	texture.create_from_image(model.image)
	
	if 'no_filter' in options:
		texture.set_flags(0)
		
	self.texture = texture
	
	TextureCache.cache(tex_index, texture)
	
	return texture
