extends Area2D



func _on_body_entered(body: Node) -> void:
	if "Player" in body.name:
		body.is_on_ladder = true


func _on_body_exited(body: Node) -> void:
	if "Player" in body.name:
		body.is_on_ladder = false
