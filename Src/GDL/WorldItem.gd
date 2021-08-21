extends Spatial

# Declare member variables here. Examples:
# var a: 2
# var b: "text"

var item_instance = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_extras():
	var item_types_to_string = {
		Constants.Item_Type.ITEM_RANDOM: 'Random',
		Constants.Item_Type.ITEM_POWERUP: 'Powerup',
		Constants.Item_Type.ITEM_CONTAINER: 'Container',
		Constants.Item_Type.ITEM_GENERATOR: 'Generator',
		Constants.Item_Type.ITEM_ENEMYINFO: 'Enemy Info',
		Constants.Item_Type.ITEM_TRIGGER: 'Trigger',
		Constants.Item_Type.ITEM_TRAP: 'Trap',
		Constants.Item_Type.ITEM_DOOR: 'Door',
		Constants.Item_Type.ITEM_DAMAGETILE: 'Damage Tile',
		Constants.Item_Type.ITEM_EXIT: 'Exit',
		Constants.Item_Type.ITEM_OBSTICLE: 'Obstacle',
		Constants.Item_Type.ITEM_TRANSPORTER: 'Transporter',
		Constants.Item_Type.ITEM_ROTATOR: 'Rotator',
		Constants.Item_Type.ITEM_SOUND: 'Sound',
	}
	var item_sub_types_to_string = {
		Constants.Item_Subtype.ITEM_GOLD: 'Item: Gold',
		Constants.Item_Subtype.ITEM_KEY: 'Item: Key',
		Constants.Item_Subtype.ITEM_FOOD: 'Item: Food',
		Constants.Item_Subtype.ITEM_POTION: 'Item: Potion',
		Constants.Item_Subtype.ITEM_WEAPON: 'Item: Weapon',
		Constants.Item_Subtype.ITEM_ARMOR: 'Item: Armour',
		Constants.Item_Subtype.ITEM_SPEED: 'Item: Speed',
		Constants.Item_Subtype.ITEM_MAGIC: 'Item: Magic',
		Constants.Item_Subtype.ITEM_SPECIAL: 'Item: Special',
		Constants.Item_Subtype.ITEM_RUNESTONE: 'Item: Runestone',
		Constants.Item_Subtype.ITEM_BOSSKEY: 'Item: Bosskey',
		Constants.Item_Subtype.ITEM_OBELISK: 'Item: Obelisk',
		Constants.Item_Subtype.ITEM_QUEST: 'Item: Quest',
		Constants.Item_Subtype.ITEM_SCROLL: 'Item: Scroll',
		Constants.Item_Subtype.ITEM_GEMSTONE: 'Item: Gemstone',
		Constants.Item_Subtype.ITEM_FEATHER: 'Item: Feather',
		Constants.Item_Subtype.SUB_BRIDGEPAD: 'Sub: Bridge Pad',
		Constants.Item_Subtype.SUB_DOORPAD: 'Sub: Door Pad',
		Constants.Item_Subtype.SUB_BRIDGESWITCH: 'Sub: Bridge Switch',
		Constants.Item_Subtype.SUB_DOORSWITCH: 'Sub: Door Switch',
		Constants.Item_Subtype.SUB_ACTIVESWITCH: 'Sub: Active Switch',
		Constants.Item_Subtype.SUB_ELEVPAD: 'Sub: Elevator Pad',
		Constants.Item_Subtype.SUB_ELEVSWITCH: 'Sub: Elevator Switch',
		Constants.Item_Subtype.SUB_LIFTPAD: 'Sub: Lift Pad',
		Constants.Item_Subtype.SUB_LIFTSTART: 'Sub: Lift Start',
		Constants.Item_Subtype.SUB_LIFTEND: 'Sub: Lift End',
		Constants.Item_Subtype.SUB_NOWEAPCOL: 'Sub: No Weapon Collision',
		Constants.Item_Subtype.SUB_SHOOTTRIG: 'Sub: Shoot Trigger',
		Constants.Item_Subtype.SUB_ROCKFALL: 'Sub: Rock Fall',
		Constants.Item_Subtype.SUB_SAFEROCK: 'Sub: Safe Rock',
		Constants.Item_Subtype.SUB_WALL: 'Sub: Wall',
		Constants.Item_Subtype.SUB_BARREL: 'Sub: Barrel',
		Constants.Item_Subtype.SUB_BARREL_EXP: 'Sub: Explosive Barrel',
		Constants.Item_Subtype.SUB_BARREL_POI: 'Sub: Poison Barrel',
		Constants.Item_Subtype.SUB_CHEST: 'Sub: Chest',
		Constants.Item_Subtype.SUB_CHEST_GOLD: 'Sub: Chest Gold',
		Constants.Item_Subtype.SUB_CHEST_SILVER: 'Sub: Chest Silver',
		Constants.Item_Subtype.SUB_LEAFFALL: 'Sub: Leaf Fall',
		Constants.Item_Subtype.SUB_SECRET: 'Sub: Secret',
		Constants.Item_Subtype.SUB_ROCKFLY: 'Sub: Rock Fly',
		Constants.Item_Subtype.SUB_SHOOTFALL: 'Sub: Shoot Fall',
		Constants.Item_Subtype.SUB_ROCKSINK: 'Sub: Rock Sink',
	}
	
	var info = self.item_instance.item_info
	
	var type = info.type
	var sub_type = info.sub_type
	var type_name = "- NO TYPE -"
	var sub_type_name = "- NO SUB TYPE -"
	
	if item_types_to_string.has(type):
		type_name = item_types_to_string[type]
	if item_sub_types_to_string.has(sub_type):
		sub_type_name = item_sub_types_to_string[sub_type]
	
	var extras = {
		'type_name': type_name,
		'sub_type_name': sub_type_name,
		'type': type,
		'sub_type': sub_type,
		'collision_flags': info.colision_flags,
		'collision_type': info.colision_type,
		'collision_offset': info.colision_offset,
		'radius': info.radius,
		'height': info.height,
		'x_dim': info.x_dim,
		'z_dim': info.z_dim,
		'description': info.description,
		'mb_flags': info.mb_flags,
		'properties': info.properties,
		'value': info.value,
		'armour': info.armour,
		'hitpoints': info.hitpoints,
		'active_type': info.active_type,
		'active_off': info.active_off,
		'active_on': info.active_on,
		
		# Instance Info
		'world_obj_description': self.item_instance.description,
		'min_players': self.item_instance.min_players,
		'flags': self.item_instance.flags,
		'collision_triangle_index': self.item_instance.collision_triangle_index,
	}
	
	# Mixin the params dictionary!
	for i in range(0, len(self.item_instance.parameters.keys())):
		var key = self.item_instance.parameters.keys()[i]
		var value = self.item_instance.parameters.values()[i]
		
		extras["p_%s" % key] = value
		
	return extras
	
func get_class():
	return 'WorldItem'

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
