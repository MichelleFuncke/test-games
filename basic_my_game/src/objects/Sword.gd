extends Weapon

onready var Machine = $States


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
		Machine.current_state = Machine.states.IDLE


func _trigger_attack() -> void:
	if not visible:
		return
		
	if Machine == null:
		return
	
	if direction.x > 0:
		Machine.current_state = Machine.states.ATTACK_RIGHT
	else:
		Machine.current_state = Machine.states.ATTACK_LEFT
