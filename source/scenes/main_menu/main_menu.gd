extends Control

var original_size = Vector2()

func _ready():
	original_size = Vector2(1024,600)
	$Node2D.scale = $TextureRect.size/original_size
	$HBoxContainer/Control/Start.scale = $TextureRect.size/original_size
	_on_TextureRect_resized()
	logging.start_log()

func _on_TextureRect_resized():
	$Node2D.scale = $TextureRect.size/original_size
	$HBoxContainer/Control/Start.scale = $TextureRect.size/original_size

func _physics_process(_delta):
	if Input.is_action_just_released("ui_select"):
		get_tree().change_scene_to_file("res://scenes/game/main.tscn")
