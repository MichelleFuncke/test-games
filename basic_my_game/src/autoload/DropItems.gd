extends Node


const STACK = preload("res://src/objects/treasure/GoldStack.tscn")
const PILE = preload("res://src/objects/treasure/GoldPile.tscn")
const BAR = preload("res://src/objects/treasure/GoldBars.tscn")
const CROWN = preload("res://src/objects/treasure/Crown.tscn")
var items = [STACK, PILE, BAR, CROWN]


func _ready() -> void:
	randomize()


func get_random_item():
	var unknown = randi() % items.size()
	return items[unknown].instance()
