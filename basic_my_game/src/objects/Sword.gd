extends Weapon


func _ready():
	pass


func _physics_process(delta: float) -> void:
	pass


func _on_hit(body: Node) -> void:
	if is_owner(body):
		return
	body.take_damage(damage, velocity)


func _on_animation_finished(anim_name: String) -> void:
	if "attack" in anim_name:
		$States.current_state = $States.states.IDLE


func _trigger_attack() -> void:
	if not visible:
		return
	if direction.x > 0:
		$States.current_state = $States.states.ATTACK_RIGHT
	else:
		$States.current_state = $States.states.ATTACK_LEFT
