extends StateMachine

var direction: = Vector2.RIGHT

func _ready() -> void:
	add_state("IDLE")
	add_state("ATTACK_LEFT")
	add_state("ATTACK_RIGHT")
	add_state("ATTACKING")
	call_deferred("set_state", states.IDLE)

func _state_logic(delta):
	pass

func _get_transition(delta):
	match current_state:
		states.IDLE:
			pass
		states.ATTACK_LEFT:
			return states.ATTACKING
		states.ATTACK_RIGHT:
			return states.ATTACKING
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.IDLE:
			parent.get_node("AnimationPlayer").play("idle")
		states.ATTACK_LEFT:
			parent.get_node("AnimationPlayer").play("attack_left")
		states.ATTACK_RIGHT:
			parent.get_node("AnimationPlayer").play("attack_right")
		states.ATTACKING:
			pass

func _exit_state(old_state, new_state):
	pass
