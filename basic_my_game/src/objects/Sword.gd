extends Area2D

export var damage: = 10
var velocity: = Vector2()
var direction: = 1


func _ready():
	pass


func _physics_process(delta: float) -> void:
	pass


func _on_hit(body: Node) -> void:
	if is_owner(body):
		return
	body.take_damage(damage, velocity)


func set_attack_direction(dir):
	direction = dir
	velocity = Vector2(direction, 0.0)
	$CollisionShape2D.rotation_degrees = abs($CollisionShape2D.rotation_degrees) * -1 * direction


func _on_animation_finished(anim_name: String) -> void:
	if "attack" in anim_name:
		$States.current_state = $States.states.IDLE


func is_owner(node):
	return node.weapon_path == get_path()


func _trigger_attack() -> void:
	if not visible:
		return
	if direction > 0:
		$States.current_state = $States.states.ATTACK_RIGHT
	else:
		$States.current_state = $States.states.ATTACK_LEFT
