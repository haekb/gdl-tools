extends Node

func _init():
	VisualServer.set_debug_generate_wireframes(true)

func _input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_F1):
		var viewport = get_viewport()
		# DEBUG_DRAW_DISABLED = 0 DEBUG_DRAW_WIREFRAME = 3
		viewport.debug_draw = (viewport.debug_draw + 3) % 6
