extends Camera

export(float, 0.0, 1.0) var sensitivity = 0.25

# Mouse state
var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0

# Movement state
var _direction = Vector3(0.0, 0.0, 0.0)
var _velocity = Vector3(0.0, 0.0, 0.0)
var _acceleration = 30
var _deceleration = -10
var _vel_multiplier = 4

# Keyboard state
var _w = false
var _s = false
var _a = false
var _d = false
var _q = false
var _e = false

var controls_enabled = true

# Default bindings
var bindings = {
	KEY_W : "move_forwards",
	KEY_S : "move_backwards",
	KEY_A : "move_left",
	KEY_D : "move_right",
	KEY_Q : "move_up",
	KEY_E : "move_down",
}

func read_keys_from_config():
	var config = ConfigFile.new()
	var err = config.load("./settings.cfg")

	if err != OK:
		return
		
	# I hope no one ever discovers I wrote this crappy code
	var code = config.get_value("Bindings", "move_forwards", KEY_W)
	bindings[code] = "move_forwards"
	code = config.get_value("Bindings", "move_backwards", KEY_S)
	bindings[code] = "move_backwards"
	code = config.get_value("Bindings", "move_left", KEY_A)
	bindings[code] = "move_left"
	code = config.get_value("Bindings", "move_right", KEY_D)
	bindings[code] = "move_right"
	code = config.get_value("Bindings", "move_up", KEY_Q)
	bindings[code] = "move_up"
	code = config.get_value("Bindings", "move_down", KEY_E)
	bindings[code] = "move_down"

# End Func

func _init():
	self.read_keys_from_config()
	GlobalSignals.connect("OnMouseLeaveFileList", self, "on_mouse_activate")
	GlobalSignals.connect("OnMouseEnterFileList", self, "on_mouse_deactivate")
	
func on_mouse_activate():
	controls_enabled = true
	
func on_mouse_deactivate():
	controls_enabled = false

func _input(event):
	if !controls_enabled:
		return
	
	# Receives mouse motion
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
	
	# Receives mouse button input
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_RIGHT: # Only allows rotation if right click down
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
			BUTTON_WHEEL_UP: # Increases max velocity
				_vel_multiplier = clamp(_vel_multiplier * 1.1, 0.2, 256)
			BUTTON_WHEEL_DOWN: # Decereases max velocity
				_vel_multiplier = clamp(_vel_multiplier / 1.1, 0.2, 256)

	# Receives key input
	if event is InputEventKey:
		
		# Crappy way to do this...
		if event.scancode in bindings:
			var action = bindings[event.scancode]
			
			if action == "move_forwards":
				_w = event.pressed
			if action == "move_backwards":
				_s = event.pressed
			if action == "move_left":
				_a = event.pressed
			if action == "move_right":
				_d = event.pressed
			if action == "move_up":
				_q = event.pressed
			if action == "move_down":
				_e = event.pressed
				
		get_tree().set_input_as_handled()
#		match event.scancode:
#			KEY_W:
#				_w = event.pressed
#			KEY_S:
#				_s = event.pressed
#			KEY_A:
#				_a = event.pressed
#			KEY_D:
#				_d = event.pressed
#			KEY_Q:
#				_q = event.pressed
#			KEY_E:
#				_e = event.pressed

# Updates mouselook and movement every frame
func _process(delta):
	if !controls_enabled:
		return
	
	_update_mouselook()
	_update_movement(delta)

# Updates camera movement
func _update_movement(delta):
	# Computes desired direction from key states
	_direction = Vector3(_d as float - _a as float, 
						 _e as float - _q as float,
						 _s as float - _w as float)
	
	# Computes the change in velocity due to desired direction and "drag"
	# The "drag" is a constant acceleration on the camera to bring it's velocity to 0
	var offset = _direction.normalized() * _acceleration * _vel_multiplier * delta \
		+ _velocity.normalized() * _deceleration * _vel_multiplier * delta
	
	# Checks if we should bother translating the camera
	if _direction == Vector3.ZERO and offset.length_squared() > _velocity.length_squared():
		# Sets the velocity to 0 to prevent jittering due to imperfect deceleration
		_velocity = Vector3.ZERO
	else:
		# Clamps speed to stay within maximum value (_vel_multiplier)
		_velocity.x = clamp(_velocity.x + offset.x, -_vel_multiplier, _vel_multiplier)
		_velocity.y = clamp(_velocity.y + offset.y, -_vel_multiplier, _vel_multiplier)
		_velocity.z = clamp(_velocity.z + offset.z, -_vel_multiplier, _vel_multiplier)
	
		translate(_velocity * delta)

# Updates mouse look 
func _update_mouselook():
	# Only rotates mouse if the mouse is captured
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sensitivity
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		_mouse_position = Vector2(0, 0)
		
		# Prevents looking up/down too far
		pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
		_total_pitch += pitch
	
		rotate_y(deg2rad(-yaw))
		rotate_object_local(Vector3(1,0,0), deg2rad(-pitch))
