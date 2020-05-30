extends Actor

export var score: = 100

func _ready() -> void:
	set_physics_process(false)
	# Have to set it here or it uses the default of the Actor.gd
	_health = max_health
	#_velocity.x = -speed.x

func _physics_process(delta: float) -> void:
	_velocity.y += gravity * delta
	if is_on_wall():
		_velocity.x *= -1.0
	
	if $RayCast2D.is_colliding() == false:
		_velocity.x *= -1.0
		
	animate_sprite(_velocity)
	ledge_detection(_velocity)
	
	_velocity.y = move_and_slide(_velocity, FLOOR_NORMAL).y


func animate_sprite(direction: Vector2) -> void:
	if direction.x == 0:
		$AnimatedSprite.play("idle")
	else:
		$AnimatedSprite.play("walk")
		$AnimatedSprite.flip_h = direction.x < 0
		
func ledge_detection(direction: Vector2) -> void:
	if sign($RayCast2D.position.x) != sign(direction.x):
		$RayCast2D.position.x *= -1.0


func _on_screen_entered() -> void:
	set_physics_process(true)
	_velocity.x = -speed.x


func _on_Timer_timeout() -> void:
	queue_free()
