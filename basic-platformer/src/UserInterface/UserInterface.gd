extends Control


onready var scene_tree: = get_tree()
onready var pause_overlay: ColorRect = get_node("PauseOverlay")

var paused: = false setget set_paused

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		self.paused = not paused # Goes through the setter function
		scene_tree.set_input_as_handled() # Stops the "pause" event from triggering other areas of the code

func set_paused(value: bool) -> void:
	paused = value
	scene_tree.paused = value
	pause_overlay.visible = value
