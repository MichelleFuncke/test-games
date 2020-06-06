extends Actor

const FIREBALL = preload("res://src/objects/Fireball.tscn")
signal direction_changed


func _ready() -> void:
	# Have to set it here or it uses the default of the Actor.gd
	_health = max_health
	self.connect("direction_changed", self, "change_direction")

func _physics_process(delta: float) -> void:
	if _is_dead == true || _is_damaged == true:
		return

	var direction: = get_direction()
	_velocity = calculate_move_velocity(_velocity, direction, speed)
	animate_sprite(_velocity)
	
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL) # we don't need to multiply by delta because move_and_slide
	
	if Input.is_action_just_pressed("ui_focus_next"):
		var fireball = FIREBALL.instance()
		fireball.set_fireball_direction(sign($Position2D.position.x))
		get_parent().add_child(fireball)
		fireball.position = $Position2D.global_position
	
func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1.0 if Input.is_action_just_pressed("jump") and is_on_floor() else 1.0
	)
	
func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		speed: Vector2
	) -> Vector2:
	var out: = linear_velocity
	out.x = speed.x * direction.x
	out.y += gravity * get_physics_process_delta_time() # this is the delta _process uses	
	if direction.y == -1.0:
		out.y = speed.y * direction.y
	return out
	
	
func animate_sprite(direction: Vector2) -> void:
	if direction.x == 0:
		$AnimatedSprite.play("idle")
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
