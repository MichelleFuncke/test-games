extends Area2D

export var damage: = 10
const SPEED = 100
var velocity = Vector2()
var direction = 1


func _physics_process(delta: float) -> void:
	velocity = Vector2(direction, 0.0)


func _on_hit(body: Node) -> void:
	if body.name == "Player":
		return

	if "Enemy" in body.name:
		body.take_damage(damage, velocity)


func set_sword_direction(dir):
	direction = dir


func _on_animation_finished(anim_name: String) -> void:
	if "attack" in anim_name:
		$AnimationPlayer.play("idle")
