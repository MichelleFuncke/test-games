extends KinematicBody2D
class_name Actor


const FLOOR_NORMAL: = Vector2.UP

export var speed: = Vector2(100.0, 500.0)
export var gravity: = 3000.0
var _velocity: = Vector2.ZERO
export var max_health: = 3000
var _health : = max_health

func take_damage(damage: int) -> void:
	_health -= damage
	if _health <= 0:
		die()

func die() -> void:
	# Might want to play death animation or count the dealths
	get_node("AnimationPlayer").play("damaged")
	queue_free()
