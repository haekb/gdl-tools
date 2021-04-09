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
		
		return Helpers.make_response(Helpers.IMPORT_RETURN.SUCCESS)
	# End Func
	
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
		
		func read(world : World, f : File):
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
