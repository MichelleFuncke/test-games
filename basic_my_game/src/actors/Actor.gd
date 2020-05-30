extends KinematicBody2D
class_name Actor


const FLOOR_NORMAL: = Vector2.UP

export var speed: = Vector2(100.0, 500.0)
export var gravity: = 3000.0
var _velocity: = Vector2.ZERO
var _is_dead: = false
export var max_health: = 3000
var _health : = max_health

func take_damage(damage: int) -> void:
	# Don't want to play the animation if it's already dead
	if _is_dead != true:
		_health -= damage
		get_node("AnimationPlayer").play("damaged")
		if _health <= 0:
			die()

func die() -> void:
	_velocity = Vector2(0, 0)
	
	# This is to make sure the player/enemy can only interact with the world
	set_collision_mask_bit(0, false)
	set_collision_mask_bit(1, false)

	# This could be the death animation
	get_node("AnimatedSprite").play("idle")
	_is_dead = true
	get_node("Timer").start()
