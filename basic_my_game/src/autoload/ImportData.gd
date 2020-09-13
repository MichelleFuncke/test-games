extends Node

var item_data
var loot_data

func _ready() -> void:
	var itemdata_file = File.new()
	itemdata_file.open("res://data/ItemTable.json", File.READ)
	var itemdata_json = JSON.parse(itemdata_file.get_as_text())
	itemdata_file.close()
	item_data = itemdata_json.result
	
	var lootdata_file = File.new()
	lootdata_file.open("res://data/LootTable.json", File.READ)
	var lootdata_json = JSON.parse(lootdata_file.get_as_text())
	lootdata_file.close()
	loot_data = lootdata_json.result
