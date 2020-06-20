extends Actor

const FIREBALL = preload("res://src/objects/Fireball.tscn")
const SWORD = preload("res://src/objects/Sword.tscn")
var was_on_ground: = true
var jump_count: = 0
var is_jump_interrupted: = false
var is_gliding: = false

var weapon = null
var weapon_path = ""
var attack_cooling = false
signal attack_triggered

func _ready() -> void:
	var melee = SWORD.instance()
	$MeleePosition.add_child(melee)
	weapon = $MeleePosition.get_child(0)
	weapon_path = weapon.get_path()
	
	connect("attack_triggered", weapon, "_trigger_attack")
	PlayerData.connect("score_updated", self, "_upgrade_weapon")


# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	if $BasicStateMachine.current_state != null:
		$Basicstate.text = $BasicStateMachine.states.keys()[$BasicStateMachine.current_state]
	
	if $ClimbStateMachine.current_state != null:
		$Climbstate.text = $ClimbStateMachine.states.keys()[$ClimbStateMachine.current_state]
	
	if [$BasicStateMachine.states.DEAD, $BasicStateMachine.states.STAGGER].has($BasicStateMachine.current_state):
		return
		
	if can_attack():
		if weapon.is_in_group("Range"):
			# Need to add the projectile to the scene
			add_projective_to_scene(weapon)
		
		emit_signal("attack_triggered")

		attack_cooling = true
		$Attack_timer.start()

		if weapon.is_in_group("Range"):
			# Create a new instance to use in next attack
			weapon = FIREBALL.instance()
			connect("attack_triggered", weapon, "_trigger_attack")
	
	if Input.is_action_just_pressed("Debug"):
		$Basicstate.visible = not $Basicstate.visible
		$Climbstate.visible = not $Climbstate.visible


func handle_move_input():
	if Input.is_action_just_pressed("jump") and jump_count < 2:
		$BasicStateMachine.current_state = $BasicStateMachine.states.JUMP
		jump_count += 1
	
	is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
	
	is_gliding = get_gliding(is_gliding)
	
	if Input.is_action_just_pressed("move_down") and [$ClimbStateMachine.states.NO_LADDER, $ClimbStateMachine.states.OVER_LADDER].has($ClimbStateMachine.current_state):
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
	_velocity = calculate_move_velocity(state, _velocity, direction, speed, is_jump_interrupted)
	_velocity = apply_gravity(state, _velocity, direction, is_gliding)
	_velocity = move_and_slide(_velocity, WorldData.FLOOR_NORMAL) # we don't need to multiply by delta because move_and_slide


func get_direction(state) -> Vector2:
	var side_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var vertical_movement = 1.0
	if $ClimbStateMachine.states.ON_LADDER == $ClimbStateMachine.current_state:
		vertical_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	else:
		vertical_movement = -1.0 if state == $BasicStateMachine.states.JUMP else 1.0
	return Vector2(side_movement, vertical_movement)


func calculate_move_velocity(
		state,
		linear_velocity: Vector2,
		direction: Vector2,
		speed: Vector2,
		is_jump_interrupted: bool
	) -> Vector2:
	var out: = linear_velocity
	if state == $BasicStateMachine.states.STAGGER:
		if out.y > 0 and is_on_floor():
			out.x = 0.0
	else:
		out.x = speed.x * direction.x
	
	if is_jump_interrupted: # Jump is now modulated by how long you press jump
		out.y = 0.0
		
	if $ClimbStateMachine.states.ON_LADDER == $ClimbStateMachine.current_state:
		out.y = climb_speed * direction.y
	else:
		if direction.y < 0 and state != $BasicStateMachine.states.STAGGER:
			out.y = speed.y * direction.y
	return out


func apply_gravity(
		state,
		linear_velocity: Vector2,
		direction: Vector2,
		is_gliding: bool
	) -> Vector2:
	var out: = linear_velocity
	if $ClimbStateMachine.states.ON_LADDER != $ClimbStateMachine.current_state:
		if state == $BasicStateMachine.states.STAGGER:
			out.y += WorldData.GRAVITY * get_physics_process_delta_time() # this is the delta _process uses
		else:
			if is_gliding:
				out.y += glide_speed * get_physics_process_delta_time() # this is the delta _process uses
			else:
				out.y += WorldData.GRAVITY * get_physics_process_delta_time() # this is the delta _process uses
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


func get_next_on_ground_state(previous_value: bool) -> bool:
	if is_on_floor() || $ClimbStateMachine.states.ON_LADDER == $ClimbStateMachine.current_state:
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
		
	if Input.is_action_just_pressed("move_up") and not $ClimbStateMachine.states.ON_LADDER == $ClimbStateMachine.current_state and not is_on_floor():
		return true
	
	if previous_value and not $ClimbStateMachine.states.ON_LADDER == $ClimbStateMachine.current_state and not is_on_floor():
		return true
	else:
		return false


func can_attack() -> bool:
	if attack_cooling:
		return false
	if Input.is_action_just_pressed("ui_focus_next"):
		if $ClimbStateMachine.states.ON_LADDER != $ClimbStateMachine.current_state:
			if weapon.is_in_group("Melee"):
				if weapon.get_node("States").current_state == weapon.get_node("States").states.IDLE:
					return true
			if weapon.is_in_group("Range"):
				return true
	return false


func _on_Attack_cooldown_timeout() -> void:
	attack_cooling = false


func _upgrade_weapon() -> void:
	if PlayerData.score > 100:
		weapon = FIREBALL.instance()
		connect("attack_triggered", weapon, "_trigger_attack")
		# Disable the sword by making it invisible
		$MeleePosition.get_node("Sword").visible = false


func add_projective_to_scene(projectile: Weapon) -> void:
	get_parent().add_child(projectile)
	projectile.position = $FireballPosition.global_position
	projectile.set_attack_direction(Vector2(sign($FireballPosition.position.x),0.0))
