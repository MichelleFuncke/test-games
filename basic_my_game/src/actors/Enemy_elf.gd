extends Actor

export var score: = 100

func _ready() -> void:
	# set_physics_process(false)
	_velocity.x = -speed.x

func _physics_process(delta: float) -> void:
	_velocity.y += gravity * delta
	if is_on_wall():
		_velocity *= -1.0
	animate_sprite(_velocity)
	_velocity.y = move_and_slide(_velocity, FLOOR_NORMAL).y


func animate_sprite(direction: Vector2) -> void:
	if direction.x == 0:
		$AnimatedSprite.play("idle")
	else:
		$AnimatedSprite.play("walk")
		$AnimatedSprite.flip_h = direction.x < 0
