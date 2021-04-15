extends Node

var cached_textures = {}
var cache_use = 0
var cache_miss = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func cache(name, texture):
	self.cached_textures[name] = texture
	
func clear():
	self.cached_textures = {}
	self.cache_use = 0
	self.cache_miss = 0

func get(name):
	if name in cached_textures:
		self.cache_use += 1
		return self.cached_textures[name]
	self.cache_miss += 1
	return null
	
func report():
	print("Cache hits %d | Cache misses %d" % [self.cache_use, self.cache_miss])
