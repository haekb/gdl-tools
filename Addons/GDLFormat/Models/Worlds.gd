extends Node

class Worlds:
	const GDL_WORLD_FORMAT = 0xF00BAB02
	
	var world_obj_count = 0
	var world_obj_pointer = 0
	
	var collision_triangle_count = 0
	var collision_triangle_pointer = 0
	
	var grid_entry_count = 0
	var grid_entry_pointer = 0
	
	var grid_list_value_count = 0
	var grid_list_pointer = 0
	
	var grid_row_pointer = 0
	
	var world_min_bounds = Vector3()
	var world_max_bounds = Vector3()
	var grid_size = 0.0
	var grid_number_x = 0
	var grid_number_y = 0
	
	var item_info_count = 0
	var item_info_pointer = 0
	
	var item_instance_count = 0
	var item_instance_pointer = 0
	
	var locator_count = 0
	var locator_pointer = 0

	var world_format = 0
	
	var anim_header_pointer = 0
	var world_anim_count = 0
	
	var world_psys = 0
	var world_psys_pointer = 0
	
	# Processed
	var item_infos = []
	var item_instances = []
	var world_objs = []
	
	func read(f : File):
		self.world_obj_count = f.get_32()
		self.world_obj_pointer = f.get_32()
		self.collision_triangle_count = f.get_32()
		self.collision_triangle_pointer = f.get_32()
		self.grid_entry_count = f.get_32()
		self.grid_entry_pointer = f.get_32()
		self.grid_list_value_count = f.get_32()
		self.grid_list_pointer = f.get_32()
		self.grid_row_pointer = f.get_32()
		self.world_min_bounds = Helpers.read_vector3(f)
		self.world_max_bounds = Helpers.read_vector3(f)
		self.grid_size = f.get_float()
		self.grid_number_x = f.get_32()
		self.grid_number_y = f.get_32()
		self.item_info_count = f.get_32()
		self.item_info_pointer = f.get_32()
		self.item_instance_count = f.get_32()
		self.item_instance_pointer = f.get_32()
		self.locator_count = f.get_32()
		self.locator_pointer = f.get_32()
		self.world_format = f.get_32()
		if self.world_format != self.GDL_WORLD_FORMAT:
			print("Warning: World format (%d) is not %d" % [self.world_format, self.GDL_WORLD_FORMAT])
		# End If
		self.anim_header_pointer = f.get_32()
		self.world_anim_count = f.get_32()
		self.world_psys = f.get_32()
		self.world_psys_pointer = f.get_32()
		
		f.seek(self.world_obj_pointer)
		for _i in range(self.world_obj_count):
			var world_obj = WorldObject.new()
			world_obj.read(self, f)
			self.world_objs.append(world_obj)
		# End For
		
		f.seek(self.item_info_pointer)
		for _i in range(self.item_info_count):
			var item_info = ItemInfo.new()
			item_info.read(self, f)
			self.item_infos.append(item_info)
		# End For
		
		f.seek(self.item_instance_pointer)
		for _i in range(self.item_instance_count):
			var item_inst = ItemInstance.new()
			item_inst.read(self, f)
			self.item_instances.append(item_inst)
		# End For
		
		return Helpers.make_response(Helpers.IMPORT_RETURN.SUCCESS)
	# End Func
	
	class ItemInfo:
		var type = 0
		var sub_type = 0
		var colision_type = 0
		var colision_flags = 0
		var radius = 1.0
		var height = 1.0
		var x_dim = 0.0
		var z_dim = 0.0
		var colision_offset = Vector3()
		var description = ""
		var mb_flags = 0
		var properties = 0
		var value = 0
		var armour = 0
		var hitpoints = 0
		var active_type = 0
		var active_off = 0
		var active_on = 0
		
		# Always null
		var animation_tree_header_ptr = 0
		
		func read(world : Worlds, f : File):
			self.type = f.get_32()
			self.sub_type = f.get_32()
			self.colision_type = f.get_16()
			self.colision_flags = f.get_16()
			self.radius = f.get_float()
			self.height = f.get_float()
			self.x_dim = f.get_float()
			self.z_dim = f.get_float()
			self.colision_offset = Helpers.read_vector3(f)
			self.description = f.get_buffer(16).get_string_from_ascii()
			self.mb_flags = f.get_32()
			self.properties = f.get_32()
			self.value = f.get_16()
			self.armour = f.get_16()
			self.hitpoints = f.get_16()
			self.active_type = f.get_16()
			self.active_off = f.get_16()
			self.active_on = f.get_16()
			self.animation_tree_header_ptr = f.get_32()
			
		
	class ItemInstance:
		# Processed
		var item_info = null
		
		# Raw
		var index = 0 # Index to ItemInfo
		var min_players = 1 # To spawn
		var flags = 0
		var collision_triangle_index = 0
		var collision_triangle_count = 0
		var description = ""
		var position = Vector3()
		var rotation = Vector3() # Pitch Yaw Roll
		var parameters = {} # 12 bytes of polymorphic madness!
		
		func read(world : Worlds, f : File):
			self.index = f.get_16()
			self.min_players = f.get_8()
			self.flags = f.get_8()
			self.collision_triangle_index = f.get_16()
			self.collision_triangle_count = f.get_16()
			self.description = f.get_buffer(16).get_string_from_ascii()
			self.position = Helpers.read_vector3(f)
			self.rotation = Helpers.read_vector3(f)
			
			# Apply the item info
			self.item_info = world.item_infos[self.index]
			
			if item_info.type == Constants.Item_Type.ITEM_CONTAINER:
				self.parameters = {
					'index': f.get_32(),
					'value': f.get_16(),
					'filler': f.get_buffer(6),
				}
			
			elif item_info.type == Constants.Item_Type.ITEM_TRAP or item_info.type == Constants.Item_Type.ITEM_DAMAGETILE:
				self.parameters = {
					'damage': f.get_16(),
					'interval': f.get_16(),
					'filler': f.get_buffer(8),
				}
			elif item_info.type == Constants.Item_Type.ITEM_ENEMYINFO:
				self.parameters = {
					'strength': f.get_16(),
					'ai': f.get_16(),
					'radius': f.get_float(),
					'interval': f.get_16(),
					'dummy': f.get_16()
				}
			elif item_info.type == Constants.Item_Type.ITEM_EXIT:
				self.parameters = {
					'next': f.get_32(),
					'desc': f.get_buffer(4).get_string_from_ascii(),
					'filler': f.get_buffer(4)
				}
			elif item_info.type == Constants.Item_Type.ITEM_GENERATOR:
				self.parameters = {
					'strength': f.get_16(),
					'ai': f.get_16(),
					'maxenemies': f.get_16(),
					'interval': f.get_16(),
					'filler': f.get_buffer(4),
				}
			elif item_info.type == Constants.Item_Type.ITEM_OBSTICLE:
				self.parameters = {
					'subtype': f.get_16(),
					'strength': f.get_16(),
					'filler': f.get_buffer(8),
				}
			elif item_info.type == Constants.Item_Type.ITEM_POWERUP:
				self.parameters = {
					'value': f.get_16(),
					'filler': f.get_buffer(10)
				}
			elif item_info.type == Constants.Item_Type.ITEM_ROTATOR:
				self.parameters = {
					'targetwobjidx': f.get_32(),
					'speed': f.get_float(),
					'delta': f.get_float(),
				}
			elif item_info.type == Constants.Item_Type.ITEM_SOUND:
				self.parameters = {
					'radius': f.get_float(),
					'musicarea': f.get_32(),
					'fade': f.get_16(),
					'flags': f.get_16(),
					'filler': f.get_buffer(2),
				}
			elif item_info.type == Constants.Item_Type.ITEM_TRANSPORTER:
				self.parameters = {
					'id': f.get_32(),
					'destid': f.get_32(),
					'filler': f.get_filler(4)
				}
			elif item_info.type == Constants.Item_Type.ITEM_TRIGGER:
				self.parameters = {
					'targetwobjidx': f.get_16(),
					'flags': f.get_16(),
					'radius': f.get_8(),
					'soundid': f.get_8(),
					'id': f.get_8(),
					'nextid': f.get_8(),
					'starty': f.get_16(),
					'endy': f.get_16(),
				}
			else: # :shrug:
				self.parameters = {
					'filler': f.get_buffer(12)
				}
				
		
	class WorldObject:
		var name = "" # World Obj name from Objects.PS2
		var flags = 0
		var trigger_type = 0
		var trigger_state = 0
		var trigger_state_p = 0 # Previous?
		var parent_index = 0 # ID?
		var position = Vector3()
		var node_pointer = 0
		var next_index = 0
		var child_index = 0
		var radius = 0
		var checked = 0
		var no_collision = 0 # nocol? 
		var collision_triangle_count = 0
		var collision_triangle_index = 0
		
		var parent = null
		var child = null
		
		func read(world : Worlds, f : File):
			self.name = f.get_buffer(16).get_string_from_ascii()
			self.flags = f.get_32()
			self.trigger_type = f.get_16()
			self.trigger_state = f.get_8()
			self.trigger_state_p = f.get_8()
			self.parent_index = f.get_32()
			self.position = Helpers.read_vector3(f)
			self.node_pointer = f.get_32()
			self.next_index = f.get_16()
			self.child_index = f.get_16()
			self.radius = f.get_float()
			self.checked = f.get_8()
			self.no_collision = f.get_8()
			self.collision_triangle_count = f.get_16()
			self.collision_triangle_index = f.get_32()
		# End Func
	# End Class
# End Class
