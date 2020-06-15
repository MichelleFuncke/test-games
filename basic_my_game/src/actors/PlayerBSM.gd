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
	# To ensure the enemy is facing left initially
	call_deferred("set_state", states.IDLE)


func _state_logic(delta):
	if parent._velocity.x != 0:
		change_direction()

	parent.handle_move_input()
	parent.apply_movement(current_state)


func _get_transition(delta):
	match current_state:
		states.IDLE:
			if parent._velocity.x != 0:
				return states.WALK
			
			if parent._velocity.y != 0 and parent.is_on_ladder:
				return states.WALK
		states.WALK:
			if not parent.is_on_floor() and not parent.is_on_ladder:
				return states.FALL
			if parent._velocity.x == 0 and not parent.is_on_ladder:
				return states.IDLE
			elif parent._velocity.y == 0 and parent.is_on_ladder:
				return states.IDLE
			else:
				return states.WALK
		states.JUMP:
			if parent._velocity.y < 0:
				return states.UP
			else:
				return states.FALL
		states.UP:
			if parent._velocity.y >= 0:
				return states.FALL
		states.FALL:
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
			if parent.is_on_ladder:
				parent.get_node("AnimatedSprite").play("on_ladder")
			else:
				parent.get_node("AnimatedSprite").play("idle")
		states.WALK:
			if parent.is_on_ladder:
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
			parent.get_node("AnimationPlayer").play("dead")


func change_direction():
	parent.get_node("AnimatedSprite").flip_h = direction.x < 0
	parent.get_node("Position2D").position.x = abs(parent.get_node("Position2D").position.x) * direction.x


func _exit_state(old_state, new_state):
	pass
