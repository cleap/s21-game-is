extends Camera


func _physics_process(delta):
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var z_input = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	var y_input = Input.get_action_strength("move_jump") - Input.get_action_strength("move_crouch")
	transform.origin += Vector3(x_input, y_input, z_input) * delta * 100.0
