extends CanvasLayer

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Debug"):
		$MarginContainer.visible = not $MarginContainer.visible

	if $MarginContainer.visible:
		var player: = get_tree().get_root().get_node("sandbox/Player")
		$MarginContainer/HBoxContainer/VBoxContainer/Velocity_x.text = "Velocity_X: " + str(round(player._velocity.x))
		$MarginContainer/HBoxContainer/VBoxContainer/Velocity_y.text = "Velocity_Y: " + str(round(player._velocity.y))
		$MarginContainer/HBoxContainer/VBoxContainer/On_ladder.text = "is_on_ladder: " + str(player.is_on_ladder)
		$MarginContainer/HBoxContainer/VBoxContainer/Ladder_count.text = "ladder_count: " + str(player.ladder_count)
		$MarginContainer/HBoxContainer/VBoxContainer/On_ground.text = "was_on_ground: " + str(player.was_on_ground)
		$MarginContainer/HBoxContainer/VBoxContainer/Jump_count.text = "jump_count: " + str(player.jump_count)
		$MarginContainer/HBoxContainer/VBoxContainer/Damaged.text = "Damaged: " + str(player._is_damaged)
		$MarginContainer/HBoxContainer/VBoxContainer/Immune.text = "Immune: " + str(player._is_immune)
		$MarginContainer/HBoxContainer/VBoxContainer/Glide.text = "is_gliding: " + str(player.is_gliding)
