extends StateMachine

var direction = Vector2.RIGHT

func _ready() -> void:
	add_state("IDLE")
	add_state("WALK")
	add_state("JUMP")
	add_state("UP")
	add_state("FALL")
	add_state("STAGGER")
	add_state("DEAD")
	# To ensure the player is idle initially
	call_deferred("set_state", states.IDLE)


func _state_logic(delta):
	if parent._velocity.x != 0:
		change_direction()

	parent.handle_move_input()
	parent.apply_movement(current_state)
	parent.was_on_ground = parent.get_next_on_ground_state(parent.was_on_ground)


func _get_transition(delta):
	match current_state:
		states.IDLE:
			if parent._velocity.x != 0:
				return states.WALK
			
			if parent._velocity.y != 0 and on_ladder():
				return states.WALK
		states.WALK:
			if not parent.is_on_floor() and not on_ladder():
				return states.FALL
			if parent._velocity.x == 0 and not on_ladder():
				return states.IDLE
			elif parent._velocity.y == 0 and on_ladder():
				return states.IDLE
			else:
				return states.WALK
		states.JUMP:
			if parent._velocity.y < 0:
				return states.UP
			else:
				return states.FALL
		states.UP:
			if parent._velocity.y == 0 and on_ladder():
				return states.IDLE
			if parent._velocity.y >= 0:
				return states.FALL
		states.FALL:
			if parent._velocity.y == 0 and on_ladder():
				return states.IDLE
			if parent.is_on_floor():
				return states.IDLE
		states.STAGGER:
			pass
		states.DEAD:
			pass
	return null


func _enter_state(new_state, old_state):
	match new_state:
		states.IDLE:
			if on_ladder():
				parent.get_node("AnimatedSprite").play("on_ladder")
			else:
				parent.get_node("AnimatedSprite").play("idle")
		states.WALK:
			if on_ladder():
				parent.get_node("AnimatedSprite").play("climb")
			else:
				parent.get_node("AnimatedSprite").play("walk")
		states.JUMP:
			parent.get_node("AnimatedSprite").play("idle")
		states.UP:
			parent.get_node("AnimatedSprite").play("idle")
		states.FALL:
			if parent.is_gliding:
				parent.get_node("AnimatedSprite").play("glide")
			else:
				parent.get_node("AnimatedSprite").play("idle")
		states.STAGGER:
			if old_state != states.STAGGER:
				parent.get_node("AnimationPlayer").play("damaged")
			change_direction()
		states.DEAD:
			parent._velocity = Vector2(0, 0)
			# This is to make sure the player can only interact with the world
			parent.set_collision_mask_bit(0, false)
			parent.get_node("Death_timer").start()
			parent.get_node("AnimationPlayer").play("dead")


func change_direction():
	parent.get_node("AnimatedSprite").flip_h = direction.x < 0
	parent.get_node("Position2D").position.x = abs(parent.get_node("Position2D").position.x) * direction.x


func _exit_state(old_state, new_state):
	pass
	
func on_ladder():
	var climbMachine = parent.get_node("ClimbStateMachine")
	return climbMachine.current_state == climbMachine.states.ON_LADDER
