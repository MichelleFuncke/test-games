extends TextureProgress

func _ready() -> void:
	max_value = PlayerData.max_health
	value = PlayerData.current_health
	
	PlayerData.connect("health_updated", self, "_on_PlayerData_player_damaged")

func _on_PlayerData_player_damaged() -> void:
	value = PlayerData.current_health
