extends StateMachine

var direction = Vector2.RIGHT

func _ready() -> void:
	add_state("IDLE")
	add_state("NEW_DIRECTION")
	add_state("MOVE")
	add_state("STAGGER")
	add_state("DEAD")
	# To ensure the enemy is facing left initially
	call_deferred("set_state", states.NEW_DIRECTION)

func _state_logic(delta):
	match current_state:
		states.IDLE:
			move(delta)
		states.NEW_DIRECTION:
			pass
		states.MOVE:
			move(delta)
		states.STAGGER:
			move(delta)
		states.DEAD:
			move(delta)

func move(delta):
	if current_state == states.MOVE:
		parent._velocity.x = parent.speed.x * direction.x
		parent._velocity.y = WorldData.GRAVITY * delta
	elif current_state == states.IDLE:
		parent._velocity.x = 0.0
		parent._velocity.y = WorldData.GRAVITY * delta
	else:
		parent._velocity.y += WorldData.GRAVITY * delta
		if parent._velocity.y > 0 and parent.is_on_floor():
			parent._velocity.x = 0.0
	parent._velocity.y = parent.move_and_slide(parent._velocity, WorldData.FLOOR_NORMAL).y

func _get_transition(delta):
	match current_state:
		states.IDLE:
			pass
		states.NEW_DIRECTION:
			return states.MOVE
		states.MOVE:
			if parent.is_on_wall() and parent.is_on_floor():
				return states.NEW_DIRECTION
				
			if not parent.get_node("RayCast2D").is_colliding() and parent.is_on_floor():
				return states.NEW_DIRECTION
				
			return states.MOVE
		states.STAGGER:
			pass
		states.DEAD:
			pass
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.IDLE:
			parent.get_node("AnimatedSprite").play("idle")
		states.NEW_DIRECTION:
			direction *= -1
			change_direction()
		states.MOVE:
			parent.get_node("AnimatedSprite").play("walk")
		states.STAGGER:
			if old_state != states.STAGGER:
				parent.get_node("AnimationPlayer").play("damaged")
			change_direction()
		states.DEAD:
			parent.get_node("AnimationPlayer").play("dead")

func change_direction():
	parent.get_node("AnimatedSprite").flip_h = direction.x < 0
	parent.get_node("RayCast2D").position.x = abs(parent.get_node("RayCast2D").position.x) * direction.x

func _exit_state(old_state, new_state):
	pass
