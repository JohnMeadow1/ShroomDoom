extends Node

var timer = 5

func _ready():
	globals.player_score_label[0] = $GUI/MarginContainer/VBoxContainer/HBoxContainer/Player_score1
	globals.player_score_label[1] = $GUI/MarginContainer/VBoxContainer/HBoxContainer/Player_score2
	globals.player_score_label[2] = $GUI/MarginContainer/VBoxContainer/HBoxContainer2/Player_score3
	globals.player_score_label[3] = $GUI/MarginContainer/VBoxContainer/HBoxContainer2/Player_score4
	globals.blinder               = $GUI/Blinder
	globals.winnerLabel           = $GUI/Blinder/winner
	globals.player_score          = [0,0,0,0]
	globals.players_enabled       = [true,false,false,false]
	globals.player_count          = 2

func _physics_process(delta):
	if globals.player_count <= 4:
		for i in range(2, 5 ):
#			print(i, globals.player_count,globals.players_enabled)
			if Input.is_action_just_pressed("action_p" + str(i)) && !globals.players_enabled[i-1]:
#				print(globals.player_count)
				globals.players_enabled[i-1] = true
				if globals.player_count == 3:
					get_node("ViewportsContainer/Player"+str(1)).visible = false
					get_node("ViewportsContainer/Player"+str(1)).visible = true
					get_node("ViewportsContainer/Player"+str(2)).visible = false
					get_node("ViewportsContainer/Player"+str(2)).visible = true
					get_node("ViewportsContainer/Player"+str(3)).visible = false
					get_node("ViewportsContainer/Player"+str(3)).visible = true
				get_node("ViewportsContainer/Player"+str(globals.player_count)).visible = true
				get_node("ViewportsContainer/Player"+str(globals.player_count)+"/Viewport/player").visible = true
				get_node("ViewportsContainer/Player"+str(globals.player_count)+"/Viewport/player").enable_player(i)
				globals.player_count += 1
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://final.tscn")
	if timer > 0:
		timer -= delta
		$GUI/MarginContainer/VBoxContainer/Control.modulate.a = timer / 1
		if timer < 0:
			$GUI/MarginContainer/VBoxContainer/Control.visible = false