extends CanvasLayer

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Debug"):
		$MarginContainer.visible = not $MarginContainer.visible

	if $MarginContainer.visible:
		var player: = get_tree().get_root().get_node("sandbox/Player")
		if player != null:
			$MarginContainer/HBoxContainer/VBoxContainer/Velocity_x.text = "Velocity_X: " + str(round(player._velocity.x))
			$MarginContainer/HBoxContainer/VBoxContainer/Velocity_y.text = "Velocity_Y: " + str(round(player._velocity.y))
			$MarginContainer/HBoxContainer/VBoxContainer/Ladder_count.text = "ladder_count: " + str(player.get_node("ClimbStateMachine").ladder_count)
			$MarginContainer/HBoxContainer/VBoxContainer/On_ground.text = "was_on_ground: " + str(player.was_on_ground)
			$MarginContainer/HBoxContainer/VBoxContainer/Jump_count.text = "jump_count: " + str(player.jump_count)
			$MarginContainer/HBoxContainer/VBoxContainer/Immune.text = "Immune: " + str(player._is_immune)
			$MarginContainer/HBoxContainer/VBoxContainer/Attack_cooling.text = "Attack_cooling: " + str(player.attack_cooling)
			$MarginContainer/HBoxContainer/VBoxContainer/Glide.text = "is_gliding: " + str(player.is_gliding)
			$MarginContainer/HBoxContainer/VBoxContainer/Shoot_position.text = "shoot_position: " + str(player.get_node("FireballPosition").position.x)
