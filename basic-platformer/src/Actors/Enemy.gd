extends "res://src/Actors/Actor.gd"


func _ready() -> void:
	set_physics_process(false) # This will make sure the enemy only starts moving once it becomes part of the view
	_velocity.x = -speed.x

func _physics_process(delta: float) -> void:
	_velocity.y += gravity * delta
	if is_on_wall():
		_velocity *= -1.0
	_velocity.y = move_and_slide(_velocity, FLOOR_NORMAL).y
