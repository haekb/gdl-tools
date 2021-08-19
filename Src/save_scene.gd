extends Node

func _input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_F2):
		var packed_scene = PackedScene.new()
		packed_scene.pack(get_tree().get_current_scene())
		ResourceSaver.save("res://exported_scene.tscn", packed_scene)

		print("Scene exported as exported_scene.tscn")
		
	if event is InputEventKey and Input.is_key_pressed(KEY_F3):
		#var packed_scene = PackedScene.new()
		#packed_scene.pack(get_tree().get_current_scene())
		
		var gltf_exporter = load('res://Src/gltf_exporter.gd').GLTFExporter.new()
		gltf_exporter.process(get_tree().get_current_scene())
		
		print("Scene exported as exported_scene.gltf")
