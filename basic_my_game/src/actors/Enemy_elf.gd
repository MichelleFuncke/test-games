extends Actor

export var score: = 100
export var damage: = 100
signal direction_changed

func _ready() -> void:
	# Have to set it here or it uses the default of the Actor.gd
	_health = max_health
	self.connect("direction_changed", self, "change_direction")

func _physics_process(delta: float) -> void:
	if _is_dead == true || _is_damaged == true:
		return
	
	_velocity.y = gravity * delta
	if is_on_wall() and is_on_floor():
		_velocity.x *= -1.0
	
	if $RayCast2D.is_colliding() == false and is_on_floor():
		_velocity.x *= -1.0

	animate_sprite(_velocity)
	
	_velocity.y = move_and_slide(_velocity, FLOOR_NORMAL).y


func animate_sprite(direction: Vector2) -> void:
	if direction.x == 0:
		$AnimatedSprite.play("idle")
	else:
		$AnimatedSprite.play("walk")
		$AnimatedSprite.flip_h = direction.x < 0
	emit_signal("direction_changed")


func change_direction() -> void:
	var direction: = -1.0 if $AnimatedSprite.flip_h else 1.0
	$RayCast2D.position.x = abs($RayCast2D.position.x) * direction


func _on_screen_entered() -> void:
	_velocity.x = -speed.x
	animate_sprite(_velocity)


func _on_Timer_timeout() -> void:
	queue_free()


func _on_Area2D_body_entered(body: Node) -> void:
	if "Player" in body.name:
		body.take_damage(damage, _velocity)


func _on_Damage_timeout() -> void:
	_is_damaged = false
	if _is_dead == true:
		_velocity.x = 0
	elif _velocity.x != speed.x:
		var direction: = 1.0 if $AnimatedSprite.flip_h else -1.0
		
		_velocity.x = speed.x * direction
		move_and_slide(_velocity)
		animate_sprite(_velocity)
