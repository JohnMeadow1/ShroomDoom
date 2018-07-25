extends Control

var original_size = Vector2()

func _ready():
	original_size = Vector2(1024,600)
	$Node2D.scale = $TextureRect.rect_size/original_size
	$HBoxContainer/Control/Start.rect_scale = $TextureRect.rect_size/original_size
	_on_TextureRect_resized()

func _on_TextureRect_resized():
	$Node2D.scale = $TextureRect.rect_size/original_size
	$HBoxContainer/Control/Start.rect_scale = $TextureRect.rect_size/original_size

func _physics_process(delta):
	for i in range(4):
		if Input.is_action_just_pressed("action_p" + str(i+1)):
			get_tree().change_scene("res://viewports.tscn")
