extends "res://src/Actors/Actor.gd"


onready var stomp_area: Area2D = $StompDetector

export var score: = 100

func _ready() -> void:
	set_physics_process(false) # This will make sure the enemy only starts moving once it becomes part of the view
	_velocity.x = -speed.x


func _on_StompDetector_body_entered(body: PhysicsBody2D) -> void:
	if body.global_position.y > stomp_area.global_position.y:
		return
	get_node("CollisionShape2D").disabled = true
	die()


func _physics_process(delta: float) -> void:
	_velocity.y += gravity * delta
	if is_on_wall():
		_velocity *= -1.0
	_velocity.y = move_and_slide(_velocity, FLOOR_NORMAL).y


func die() -> void:
	queue_free()
	PlayerData.score += score
