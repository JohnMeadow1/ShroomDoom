extends Node

var timer        = 3
var previos_leed = -1

func _ready():
	globals.player_score_label[0] = $GUI/Margin/VBox/HBox/HBox/Player_score1
	globals.player_score_label[1] = $GUI/Margin/VBox/HBox/HBox2/Player_score2
	globals.player_score_label[2] = $GUI/Margin/VBox/HBox2/HBox/Player_score3
	globals.player_score_label[3] = $GUI/Margin/VBox/HBox2/HBox2/Player_score4
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
					get_node("ViewportsContainer/Player"+str(4)).visible = true
				get_node("ViewportsContainer/Player"+str(globals.player_count)).visible = true
				get_node("ViewportsContainer/Player"+str(globals.player_count)+"/Viewport/player").visible = true
				get_node("ViewportsContainer/Player"+str(globals.player_count)+"/Viewport/player").enable_player(i)
				globals.player_count += 1
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://final.tscn")
	if timer > 0:
		timer -= delta
		$GUI/Margin/VBox/Control.modulate.a = min(timer / 1, 1)
		if timer < 0 && previos_leed == -1:
			$GUI/Margin/VBox/Control/TextureRect.visible = false
			$GUI/Margin/VBox/Control/Score.text = ""
			
	var lead = globals.get_lead()
	if lead != previos_leed:
		previos_leed = lead
		if lead > -1:
			$GUI/Margin/VBox/Control/Score.text = globals.player_label[lead] + " is in the lead"
			if lead == 0:
				$GUI/Margin/VBox/Control/Score.set("custom_colors/font_color",Color(1,0,0))
			if lead == 1:
				$GUI/Margin/VBox/Control/Score.set("custom_colors/font_color",Color(0,1,0))
			if lead == 2:
				$GUI/Margin/VBox/Control/Score.set("custom_colors/font_color",Color(1,0,1))
			if lead == 3:
				$GUI/Margin/VBox/Control/Score.set("custom_colors/font_color",Color(0,0,1))
			timer = 1.5
	elif globals.player_score[lead]>=15 && timer<0.2:
		timer = 1
			