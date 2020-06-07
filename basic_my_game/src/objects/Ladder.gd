extends Area2D


func _ready() -> void:
	pass

func _on_body_entered(body: Node) -> void:
	if "Player" in body.name:
		PlayerData.set_on_ladder(true)


func _on_body_exited(body: Node) -> void:
	if "Player" in body.name:
		PlayerData.set_on_ladder(false)
