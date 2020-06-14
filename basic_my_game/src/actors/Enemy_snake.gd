extends KinematicBody2D

enum states {
		IDLE,
		NEW_DIRECTION,
		MOVE,
		STAGGER,
		DEAD
	}
	
export var score: = 100
export var damage: = 100
export var speed: = Vector2(50.0, 0.0)
export var max_health: = 100
export var bounce: = 200.0
var _health : = max_health
var _is_dead: = false

var state = states.MOVE
var direction = Vector2.RIGHT
var _velocity: = Vector2.ZERO

func _physics_process(delta: float) -> void:
	$state.text = states.keys()[state]
	
	match state:
		states.IDLE:
			$AnimatedSprite.play("idle")
		states.NEW_DIRECTION:
			direction *= -1
			change_direction()
		states.MOVE:
			$AnimatedSprite.play("walk")
			move(delta)
		states.STAGGER:
			move_damaged(delta)
		states.DEAD:
			move_damaged(delta)
	state = get_new_state(state)

func move(delta):
	_velocity.x = speed.x * direction.x
	_velocity.y = WorldData.GRAVITY * delta
	_velocity.y = move_and_slide(_velocity, WorldData.FLOOR_NORMAL).y
	
func move_damaged(delta):
	_velocity.y += WorldData.GRAVITY * delta
	if _velocity.y > 0 and is_on_floor():
		_velocity.x = 0.0
	_velocity.y = move_and_slide(_velocity, WorldData.FLOOR_NORMAL).y

func change_direction():
	if state == states.STAGGER:
		$AnimatedSprite.flip_h = _velocity.x > 0
		var animate_direction: = -1.0 if $AnimatedSprite.flip_h else 1.0
		$RayCast2D.position.x = abs($RayCast2D.position.x) * animate_direction
	else:
		$AnimatedSprite.flip_h = direction.x < 0
		$RayCast2D.position.x = abs($RayCast2D.position.x) * direction.x
	
func get_new_state(old_state):
	match old_state:
		states.IDLE:
			pass
		states.NEW_DIRECTION:
			return states.MOVE
		states.MOVE:
			if is_on_wall() and is_on_floor():
				return states.NEW_DIRECTION
				
			if not $RayCast2D.is_colliding() and is_on_floor():
				return states.NEW_DIRECTION
				
			return states.MOVE
		states.STAGGER:
			return states.STAGGER
		states.DEAD:
			return states.DEAD
	return states.IDLE

func take_damage(damage: int, direction: Vector2) -> void:
	# Don't want to play the animation if it's already dead
	if _is_dead != true:
		_health -= damage
		$Damage_timer.start()
		stagger(direction)
		
		if _health <= 0:
			die()
			
func stagger(direction: Vector2) -> void:
	state = states.STAGGER
	
	$AnimationPlayer.play("damaged")
	#_velocity = bounce_velocity(_velocity, direction, bounce)
	_velocity = bounce_velocity(direction, bounce)
	change_direction()
	move_and_slide(_velocity)
	
	
func bounce_velocity(
		#linear_velocity: Vector2,
		attack_direction: Vector2,
		impulse: float
	) -> Vector2:
	var out: = Vector2(0, 0)
	var direction: = -1.0 if attack_direction.y < 0 else 1.0
	out.y = -impulse * direction
	
	direction = -1.0 if attack_direction.x < 0 else 1.0
	out.x = impulse * direction
	
	return out

func die() -> void:
	# This is to make sure the enemy can only interact with the world
	set_collision_mask_bit(1, false)

	state = states.DEAD
	$AnimationPlayer.play("dead")
	$Death_timer.start()


func _on_Damage_timeout() -> void:
	if state != states.DEAD:
		state = states.MOVE
		change_direction()


func _on_Death_timeout() -> void:
	PlayerData.score += score
	queue_free()


func _on_Area2D_body_entered(body: Node) -> void:
	if "Player" in body.name:
		body.take_damage(damage, _velocity)
