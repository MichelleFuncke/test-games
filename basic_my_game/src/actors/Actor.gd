extends KinematicBody2D
class_name Actor


export var speed: = Vector2(300.0, 500.0)
export var climb_speed: = 270.0
export var glide_speed: = 100.0
export var gravity: = 3000.0
var _velocity: = Vector2.ZERO
var _is_dead: = false
export var max_health: = 3000
export var bounce: = 250.0
var _is_immune: = false

func take_damage(damage: int, direction: Vector2) -> void:
	# Don't want to play the animation if it's already dead
	if $BasicStateMachine.current_state != $BasicStateMachine.states.DEAD and _is_immune != true:
		PlayerData.current_health -= damage
		get_node("Damage_timer").start()
		stagger(direction)
		
		if PlayerData.current_health <= 0:
			die()
			return
		
		if has_node("Immune_timer"):
			_is_immune = true
			get_node("Immune_timer").start()
			get_node("AnimationPlayer").play("immune")


func stagger(direction: Vector2) -> void:
	_velocity = bounce_velocity(direction, bounce)
	$BasicStateMachine.direction = Vector2.RIGHT if direction.x < 0 else Vector2.LEFT
	$BasicStateMachine.current_state = $BasicStateMachine.states.STAGGER
	move_and_slide(_velocity)


func bounce_velocity(
		#linear_velocity: Vector2,
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
	_velocity = Vector2(0, 0)
	
	# This is to make sure the player can only interact with the world
	set_collision_mask_bit(0, false)
	$BasicStateMachine.current_state = $BasicStateMachine.states.DEAD
	$Death_timer.start()
