extends Area2D

onready var Machine = $States


func _physics_process(delta: float) -> void:
	pass


func _on_Chest_entered(body: Node) -> void:
	if "Player" in body.name:
		Machine.player_count += 1


func _on_Chest_exited(body: Node) -> void:
	if "Player" in body.name:
		Machine.player_count -= 1


func drop_item() -> void:
	var item = DropItems.get_random_item()
	get_tree().get_root().add_child(item)
	item.position = position
