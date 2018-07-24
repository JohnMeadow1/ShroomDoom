extends Node

func _ready():
	globals.player_score_label[0] = $GUI/MarginContainer/VBoxContainer/HBoxContainer/Player_score1
	globals.player_score_label[1] = $GUI/MarginContainer/VBoxContainer/HBoxContainer/Player_score2
	globals.player_score_label[2] = $GUI/MarginContainer/VBoxContainer/HBoxContainer2/Player_score3
	globals.player_score_label[3] = $GUI/MarginContainer/VBoxContainer/HBoxContainer2/Player_score4
	globals.blinder               = $GUI/Blinder
	globals.winnerLabel           = $GUI/Blinder/winner

func _physics_process(delta):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://final.tscn")