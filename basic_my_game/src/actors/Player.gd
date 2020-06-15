extends Actor

const FIREBALL = preload("res://src/objects/Fireball.tscn")
signal direction_changed
var is_on_ladder: = false
var ladder_count: = 0
var was_on_ground: = true
var jump_count: = 0
var is_jump_interrupted: = false
var is_gliding: = false


func _ready() -> void:
	# Have to set it here or it uses the default of the Actor.gd
	PlayerData.connect("on_ladder", self, "_on_ladder_changed")
	jump_count = 0

# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	if $BasicStateMachine.current_state != null:
		$state.text = $BasicStateMachine.states.keys()[$BasicStateMachine.current_state]
	
	was_on_ground = get_next_on_ground_state(was_on_ground)
	
	if [$BasicStateMachine.states.DEAD, $BasicStateMachine.states.STAGGER].has($BasicStateMachine.current_state):
		return
		
	if Input.is_action_just_pressed("ui_focus_next") and not is_on_ladder:
		var fireball = FIREBALL.instance()
		fireball.set_fireball_direction(sign($Position2D.position.x))
		get_parent().add_child(fireball)
		fireball.position = $Position2D.global_position


func handle_move_input():
	if Input.is_action_just_pressed("jump") and jump_count < 2:
		$BasicStateMachine.current_state = $BasicStateMachine.states.JUMP
		jump_count += 1
	
	is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
	is_on_ladder = get_on_ladder(is_on_ladder)
	
	is_gliding = get_gliding(is_gliding)
	
	if Input.is_action_just_pressed("move_down") and not is_on_ladder:
		for item in $FloatingObjectDetector.get_overlapping_bodies():
			item.get_node("PassThroughTimer").start()
			item.set_collision_layer_bit(3, false)
			$BasicStateMachine.current_state = $BasicStateMachine.states.FALL


func apply_movement(state):
	var direction: = get_direction(state)
	if state == $BasicStateMachine.states.STAGGER:
		direction = $BasicStateMachine.direction
	else:
		$BasicStateMachine.direction = direction
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted, is_gliding)
	_velocity = move_and_slide(_velocity, WorldData.FLOOR_NORMAL) # we don't need to multiply by delta because move_and_slide


func get_direction(state) -> Vector2:
	var side_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var vertical_movement = 1.0
	if is_on_ladder:
		vertical_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	else:
		vertical_movement = -1.0 if state == $BasicStateMachine.states.JUMP else 1.0
	return Vector2(side_movement, vertical_movement)


func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		speed: Vector2,
		is_jump_interrupted: bool,
		is_gliding: bool
	) -> Vector2:
	var out: = linear_velocity
	if $BasicStateMachine.current_state == $BasicStateMachine.states.STAGGER:
		if out.y > 0 and is_on_floor():
				out.x = 0.0
	else:
		out.x = speed.x * direction.x
	
	if is_on_ladder:
		out.y = climb_speed * direction.y
	else:
		if $BasicStateMachine.current_state == $BasicStateMachine.states.STAGGER:
			out.y += WorldData.GRAVITY * get_physics_process_delta_time() # this is the delta _process uses
			if out.y > 0 and is_on_floor():
				out.x = 0.0
		else:
			if direction.y < 0:
				out.y = speed.y * direction.y
				
			if is_gliding:
				out.y += glide_speed * get_physics_process_delta_time() # this is the delta _process uses
			else:
				out.y += WorldData.GRAVITY * get_physics_process_delta_time() # this is the delta _process uses
	
	if is_jump_interrupted: # Jump is now modulated by how long you press jump
		out.y = 0.0
	return out


func _on_Timer_timeout() -> void:
	PlayerData.deaths += 1
	queue_free()
	# Maybe end the game
	# get_tree().change_scene("TitleScreen.tscn")


func _on_Damage_timeout() -> void:
	if $BasicStateMachine.current_state != $BasicStateMachine.states.DEAD:
		$BasicStateMachine.current_state = $BasicStateMachine.states.IDLE


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


func get_on_ladder(previous_value: bool) -> bool:
	if ladder_count < 1:
		return false
		
	if Input.is_action_just_pressed("jump"):
		return false
		
	if previous_value:
		return true
	
	if Input.is_action_just_pressed("move_down"):
		return true
		
	if Input.is_action_just_pressed("move_up"):
		return true
	
	return false


func get_next_on_ground_state(previous_value: bool) -> bool:
	if is_on_floor() || is_on_ladder:
		if not previous_value:
			jump_count = 0
		return true
	else:
		if previous_value:
			jump_count = 1
		return false


func get_gliding(previous_value: bool) -> bool:
	if Input.is_action_just_released("move_up"):
		return false
		
	if Input.is_action_just_pressed("move_up") and not is_on_ladder and not is_on_floor():
		return true
	
	if previous_value and not is_on_ladder and not is_on_floor():
		return true
	else:
		return false

