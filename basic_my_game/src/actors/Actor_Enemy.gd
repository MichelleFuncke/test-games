extends KinematicBody2D
class_name ActorEnemy

export var speed: = Vector2(100.0, 500.0)
export var max_health: = 3000
export var bounce: = 250.0
var _velocity: = Vector2.ZERO
var _health : = max_health
var _is_dead: = false
var _is_damaged: = false

func take_damage(damage: int, direction: Vector2) -> void:
	# Don't want to play the animation if it's already dead
	if _is_dead != true:
		_health -= damage
		_is_damaged = true
		get_node("Damage_timer").start()
		animate_damage(direction)
		
		if _health <= 0:
			die()


func animate_damage(direction: Vector2) -> void:
	get_node("AnimationPlayer").play("damaged")
	
	#_velocity = bounce_velocity(_velocity, direction, bounce)
	_velocity = bounce_velocity(direction, bounce)
	move_and_slide(_velocity)
	$AnimatedSprite.flip_h = _velocity.x > 0
	emit_signal("direction_changed")


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
	
	# This is to make sure the enemy can only interact with the world
	set_collision_mask_bit(1, false)

	_is_dead = true
	get_node("AnimationPlayer").play("dead")
	get_node("Timer").start()
