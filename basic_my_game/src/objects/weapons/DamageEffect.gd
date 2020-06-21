extends Sprite


func _ready() -> void:
	$EffectTimer.start()


func _on_EffectTimer_timeout() -> void:
	queue_free()
