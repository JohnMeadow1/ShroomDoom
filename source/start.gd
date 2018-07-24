extends Control

var original_size = Vector2()

func _ready():
	original_size = $TextureRect.rect_size
	$Node2D.scale = $TextureRect.rect_size/original_size
	$HBoxContainer/Control/Start.rect_scale = $TextureRect.rect_size/original_size


func _on_TextureRect_resized():
	$Node2D.scale = $TextureRect.rect_size/original_size
	$HBoxContainer/Control/Start.rect_scale = $TextureRect.rect_size/original_size
