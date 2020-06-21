extends CanvasLayer

func _physics_process(delta: float) -> void:
	$MarginContainer/HBoxContainer/VBoxContainer/Stat01.text = "Number of deaths: " + str(PlayerData.deaths)
	$MarginContainer/HBoxContainer/VBoxContainer/Stat02.text = "Score: " + str(PlayerData.score)
