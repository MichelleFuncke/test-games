extends StateMachine

var player_count = 0

func _ready() -> void:
	add_state("CLOSED")
	add_state("OPENNING")
	add_state("OPEN")
	call_deferred("set_state", states.CLOSED)


func _state_logic(delta):
	pass


func _get_transition(delta):
	match current_state:
		states.CLOSED:
			if player_count > 0:
				if Input.is_action_just_pressed("use_object"):
					return states.OPENNING
		states.OPENNING:
			return states.OPEN
		states.OPEN:
			pass
	return null


func _enter_state(new_state, old_state):
	match new_state:
		states.CLOSED:
			parent.get_node("AnimatedSprite").play("closed")
		states.OPENNING:
			parent.get_node("AnimatedSprite").play("openning")
			parent.drop_item()
		states.OPEN:
			parent.get_node("AnimatedSprite").play("open")
			set_physics_process(false)
			parent.set_physics_process(false)


func _exit_state(old_state, new_state):
	pass
