extends Area2D

export var damage: = 10
const SPEED = 100
var velocity = Vector2()
var direction = 1


func _physics_process(delta: float) -> void:
	velocity.x = SPEED * delta * direction
	translate(velocity)

func _on_hit(body: Node) -> void:
	if body.name == "Player":
		return

	if "Enemy" in body.name:
		body.take_damage(damage)
	queue_free()

func _on_screen_exited() -> void:
	queue_free()

func set_fireball_direction(dir):
	direction = dir
