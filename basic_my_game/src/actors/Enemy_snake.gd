extends KinematicBody2D


export var score: = 100
export var damage: = 100
export var speed: = Vector2(50.0, 0.0)
export var max_health: = 100
export var bounce: = 200.0
var _health : = max_health
var _is_immune: = false
var _velocity: = Vector2.ZERO
var weapon = null
var weapon_path = ""


func _ready() -> void:
	# Have to set it here or it uses the default of the Actor.gd
	_health = max_health


func _physics_process(delta: float) -> void:
	if $StateMachine.current_state != null:
		$state.text = $StateMachine.states.keys()[$StateMachine.current_state]
	
		if Input.is_action_just_pressed("Debug"):
			$state.visible = not $state.visible


func take_damage(damage: int, direction: Vector2) -> void:
	# Don't want to take damage if it's already dead
	if $StateMachine.current_state != $StateMachine.states.DEAD:
		_health -= damage
		$Damage_timer.start()
		stagger(direction)
		
		if _health <= 0:
			die()


func stagger(direction: Vector2) -> void:
	$StateMachine.current_state = $StateMachine.states.STAGGER
	
	_velocity = bounce_velocity(direction, bounce)
	move_and_slide(_velocity)
	
	
func bounce_velocity(
		attack_direction: Vector2,
		impulse: float
	) -> Vector2:
	var out: = Vector2(0, 0)
	var direction: = -1.0 if attack_direction.y < 0 else 1.0
	out.y = -impulse * direction
	
	direction = -1.0 if attack_direction.x < 0 else 1.0
	out.x = impulse * direction
	
	return out


func die() -> void:
	# This is to make sure the enemy can only interact with the world
	set_collision_mask_bit(1, false)
	$StateMachine.current_state = $StateMachine.states.DEAD
	$Death_timer.start()


func _on_Damage_timeout() -> void:
	if $StateMachine.current_state != $StateMachine.states.DEAD:
		$StateMachine.current_state = $StateMachine.states.MOVE


func _on_Death_timeout() -> void:
	PlayerData.score += score
	queue_free()


func _on_Area2D_body_entered(body: Node) -> void:
	if "Player" in body.name:
		if body._velocity.x == 0:
			body.take_damage(damage, _velocity)
		else:
			# The player will be knocked in the opposite direction to their movement
			body.take_damage(damage, -1 * body._velocity)

func _on_screen_entered() -> void:
	$StateMachine.current_state = $StateMachine.states.MOVE


func _on_screen_exited() -> void:
	$StateMachine.current_state = $StateMachine.states.IDLE
