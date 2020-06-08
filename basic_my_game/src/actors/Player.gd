extends Actor

const FIREBALL = preload("res://src/objects/Fireball.tscn")
signal direction_changed
var is_on_ladder: = false
var ladder_count: = 0
var was_on_ground: = true
var jump_count: = 0


func _ready() -> void:
	# Have to set it here or it uses the default of the Actor.gd
	self.connect("direction_changed", self, "change_direction")
	PlayerData.connect("on_ladder", self, "_on_ladder_changed")
	jump_count = 0

# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	if _is_dead == true || _is_damaged == true:
		return
	
	var can_jump: = false
	if Input.is_action_just_pressed("jump") and jump_count < 2:
		jump_count += 1
		can_jump = true
	
	var is_jump_interrupted: = Input.is_action_just_released("jump") and _velocity.y < 0.0
	is_on_ladder = ladder_count > 0
	
	if Input.is_action_just_pressed("move_down") and not is_on_ladder:
		for item in $FloatingObjectDetector.get_overlapping_bodies():
			item.get_node("PassThroughTimer").start()
			item.set_collision_layer_bit(3, false)
	
	var direction: = get_direction(can_jump)
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	animate_sprite(_velocity)
	
	_velocity = move_and_slide(_velocity, WorldData.FLOOR_NORMAL) # we don't need to multiply by delta because move_and_slide
	
	was_on_ground = is_on_floor() || is_on_ladder
	if was_on_ground:
		jump_count = 0
	
	if Input.is_action_just_pressed("ui_focus_next") and not is_on_ladder:
		var fireball = FIREBALL.instance()
		fireball.set_fireball_direction(sign($Position2D.position.x))
		get_parent().add_child(fireball)
		fireball.position = $Position2D.global_position


func get_direction(can_jump: bool) -> Vector2:
	var side_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var vertical_movement = 1.0
	if is_on_ladder:
		vertical_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	else:
		vertical_movement = -1.0 if can_jump else 1.0
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
		if direction.y < 0:
			out.y = speed.y * direction.y
			
		out.y += WorldData.GRAVITY * get_physics_process_delta_time() # this is the delta _process uses
	
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
			
func _on_ladder_changed(state: bool) -> void:
	if state:
		ladder_count += 1
	else:
		ladder_count -= 1
