extends Actor

const FIREBALL = preload("res://src/objects/Fireball.tscn")
signal direction_changed
var is_on_ladder: = false


func _ready() -> void:
	# Have to set it here or it uses the default of the Actor.gd
	self.connect("direction_changed", self, "change_direction")

func _physics_process(delta: float) -> void:
	if _is_dead == true || _is_damaged == true:
		return

	var is_jump_interrupted: = Input.is_action_just_released("jump") and _velocity.y < 0.0
	var direction: = get_direction()
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	animate_sprite(_velocity)
	
	_velocity = move_and_slide(_velocity, WorldData.FLOOR_NORMAL) # we don't need to multiply by delta because move_and_slide
	
	if Input.is_action_just_pressed("ui_focus_next") and not is_on_ladder:
		var fireball = FIREBALL.instance()
		fireball.set_fireball_direction(sign($Position2D.position.x))
		get_parent().add_child(fireball)
		fireball.position = $Position2D.global_position


func get_direction() -> Vector2:
	var side_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var vertical_movement = 1.0
	if is_on_ladder:
		vertical_movement = Input.get_action_strength("move_down") - Input.get_action_strength("jump")
	else:
		vertical_movement = -1.0 if Input.is_action_just_pressed("jump") and is_on_floor() else 1.0
	return Vector2(side_movement, vertical_movement)


func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		speed: Vector2,
		is_jump_interrupted: bool
	) -> Vector2:
	var out: = linear_velocity
	out.x = speed.x * direction.x
	
	if is_on_ladder:
		out.y = climb_speed * direction.y
	else:
		out.y += WorldData.GRAVITY * get_physics_process_delta_time() # this is the delta _process uses	
	
		if direction.y == -1.0:
			out.y = speed.y * direction.y
	
	if is_jump_interrupted: # Jump is now modulated by how long you press jump
		out.y = 0.0
	return out
	
	
func animate_sprite(direction: Vector2) -> void:
	if direction.x == 0:
		if is_on_ladder:
			$AnimatedSprite.play("on_ladder")
		else:
			$AnimatedSprite.play("idle")
	else:
		if is_on_ladder:
			$AnimatedSprite.play("climb")
		else:
			$AnimatedSprite.play("walk")
		$AnimatedSprite.flip_h = direction.x < 0
	emit_signal("direction_changed")


func change_direction() -> void:
	var direction: = -1.0 if $AnimatedSprite.flip_h else 1.0
	$Position2D.position.x = abs($Position2D.position.x) * direction


func _on_Timer_timeout() -> void:
	PlayerData.deaths += 1
	queue_free()
	# Maybe end the game
	# get_tree().change_scene("TitleScreen.tscn")


func _on_Damage_timeout() -> void:
	_is_damaged = false


func _on_Immune_timeout() -> void:
	_is_immune = false
	$AnimationPlayer.stop()
	
	# Added this because players could hide on enemies while they were immune and then take no damage
	for item in $ObjectDetector.get_overlapping_bodies():
		if "Enemy" in item.name:
			item._on_Area2D_body_entered(get_node("."))
