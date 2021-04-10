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
	
	model = link_parent_and_children(model)
	
	if response.code == Helpers.IMPORT_RETURN.ERROR:
		print("IMPORT ERROR: %s" % response.message)
		return null
		
	return model

func test(start_index, model):
	var index = start_index
	
	var world_obj = model.world_objs[index]
	while world_obj:
		
		# -1
		if world_obj.child_index != 65535:
			model.world_objs[index].child = model.world_objs[world_obj.child_index]
			model.world_objs[world_obj.child_index].parent = model.world_objs[index]
			
			self.test(world_obj.child_index, model)

		
		if world_obj.next_index == 65535:
			return
		
		world_obj = model.world_objs[world_obj.next_index]
		
		

func link_parent_and_children(model):
	
	for index in range(len(model.world_objs)):
		var world_obj = model.world_objs[index]
		
		if world_obj.child_index == 65535:
			continue

		model.world_objs[index].child = model.world_objs[world_obj.child_index]
		model.world_objs[world_obj.child_index].parent = model.world_objs[index]
		
		# Bit hacky, but it works!
		var next_index = model.world_objs[world_obj.child_index].next_index
		while next_index != 65535:
			model.world_objs[next_index].parent = model.world_objs[index]
			next_index = model.world_objs[next_index].next_index
		
		
		
#	var index = 0
#	while index != 65535:
#		var world_obj = model.world_objs[index]
#
#		if world_obj.child_index == 65535:
#			index = world_obj.next_index
#			continue
#
#		model.world_objs[index].child = model.world_objs[world_obj.child_index]
#		model.world_objs[world_obj.child_index].parent = model.world_objs[index]
#
#		index = world_obj.next_index
#
#	# End While
	
	return model
