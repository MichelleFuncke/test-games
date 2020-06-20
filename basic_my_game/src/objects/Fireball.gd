extends Weapon

const SPEED = 150


func _physics_process(delta: float) -> void:
	velocity.x = SPEED * delta * direction.x
	translate(velocity)


func _on_hit(body: Node) -> void:
	if body.name == "Player":
		return

	if "Enemy" in body.name:
		body.take_damage(damage, velocity)
	queue_free()


func _on_screen_exited() -> void:
	queue_free()


func set_attack_direction(dir):
	direction = dir


func _trigger_attack() -> void:
	if not visible:
		return
	if direction.x > 0:
		$States.current_state = $States.states.ATTACK_RIGHT
	else:
		$States.current_state = $States.states.ATTACK_LEFT
