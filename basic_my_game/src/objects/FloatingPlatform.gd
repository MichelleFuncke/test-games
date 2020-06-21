extends StaticBody2D



func _on_timeout() -> void:
	set_collision_layer_bit(3, true)
