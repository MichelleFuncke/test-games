extends StateMachine

var ladder_count = 0

func _ready() -> void:
	add_state("NO_LADDER")
	add_state("OVER_LADDER")
	add_state("ON_LADDER")
	# To ensure the player is off the ladder initially
	call_deferred("set_state", states.NO_LADDER)
	ladder_count = 0
	
	PlayerData.connect("on_ladder", self, "_on_ladder_changed")

func _state_logic(delta):
	pass

func _get_transition(delta):
	match current_state:
		states.NO_LADDER:
			if ladder_count > 0:
				return states.OVER_LADDER
		states.OVER_LADDER:
			if ladder_count < 1:
				return states.NO_LADDER
			
			if Input.is_action_just_pressed("move_down"):
				return states.ON_LADDER
		
			if Input.is_action_just_pressed("move_up"):
				return states.ON_LADDER
		states.ON_LADDER:
			if ladder_count < 1:
				return states.NO_LADDER
			else:
				if Input.is_action_just_pressed("jump"):
					return states.OVER_LADDER
	return null

func _enter_state(new_state, old_state):
	# Animations are handled in the BasicStateMachine
	match current_state:
		states.NO_LADDER:
			parent.weapon.visible = true
		states.OVER_LADDER:
			parent.weapon.visible = true
		states.ON_LADDER:
			parent.weapon.visible = false


func _exit_state(old_state, new_state):
	pass


func _on_ladder_changed(state: bool) -> void:
	if state:
		ladder_count += 1
	else:
		ladder_count -= 1
