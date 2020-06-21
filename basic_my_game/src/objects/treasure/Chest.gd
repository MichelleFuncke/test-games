extends Area2D

onready var Machine = $States
const CROWN = preload("res://src/objects/treasure/Crown.tscn")


func _physics_process(delta: float) -> void:
	pass


func _on_Chest_entered(body: Node) -> void:
	if "Player" in body.name:
		Machine.player_count += 1


func _on_Chest_exited(body: Node) -> void:
	if "Player" in body.name:
		Machine.player_count -= 1


func drop_item() -> void:
	var item = CROWN.instance()
	get_tree().get_root().add_child(item)
	item.position = position
