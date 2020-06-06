extends Node

signal score_updated
signal player_died
signal max_health_updated
signal health_updated

var score: = 0 setget set_score
var deaths: = 0 setget set_deaths
var max_health: = 2000 setget set_max_health
var current_health: = max_health setget set_health


func reset() -> void:
	score = 0
	deaths = 0
	current_health = max_health

func set_score(value: int) -> void:
	score = value
	emit_signal("score_updated")

func set_deaths(value: int) -> void:
	deaths = value
	emit_signal("player_died")
	
func set_max_health(value: int) -> void:
	max_health = value
	emit_signal("max_health_updated")

func set_health(value: int) -> void:
	current_health = value
	emit_signal("health_updated")
