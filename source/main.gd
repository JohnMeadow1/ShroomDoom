extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _physics_process(delta):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://escape_menu.tscn")