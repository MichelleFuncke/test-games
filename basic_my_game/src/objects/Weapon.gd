extends Area2D
class_name Weapon

export(int) var damage = 1
var velocity: = Vector2()
var direction: = Vector2.RIGHT


func _ready():
	pass


func _physics_process(delta):
	pass


func is_owner(node):
	return node.weapon_path == get_path()


func set_attack_direction(dir: Vector2):
	direction = dir
	velocity = dir
