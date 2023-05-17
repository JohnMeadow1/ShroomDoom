extends Node

var timer        := 1.0
var previos_leed := -1
@onready var score = $GUI/Margin/VBox/Control/Score
@onready var viewports_container = $ViewportsContainer
var paused := false

var colors: PackedColorArray = PackedColorArray( [Color(1,0,0), Color(0,1,0), Color(1,0,1), Color(0,0,1)] )

func _ready():
	globals.player_score_label[0] = $GUI/Margin/VBox/HBox/HBox/Player_score1
	globals.player_score_label[1] = $GUI/Margin/VBox/HBox/HBox2/Player_score2
	globals.player_score_label[2] = $GUI/Margin/VBox/HBox2/HBox/Player_score3
	globals.player_score_label[3] = $GUI/Margin/VBox/HBox2/HBox2/Player_score4
	globals.player_score          = [0,0,0,0]
	globals.players_enabled       = [true,false,false,false]
	globals.player_count          = 2
	for i in range(2, 5):
		enable_player(i)
	get_tree().paused = true
#	process_mode = PROCESS_MODE_PAUSABLE
		
func _physics_process(delta):
#	if globals.player_count <= 4:
#		for i in range(2, 5):
##			print(i, globals.player_count,globals.players_enabled)
#			if Input.is_action_just_pressed("action_p" + str(i)) && !globals.players_enabled[i-1]:
#				enable_player(i)
#
#				if globals.player_count == 2:
#					viewports_container.columns = 2
#				globals.player_count += 1
		
	if timer > 0:
		timer -= delta
#		score.modulate.a = min(timer, 1)
		$GUI/Margin/VBox/Control.modulate.a = min(timer, 1)
		if timer < 0 && previos_leed == -1:
			$GUI/Margin/VBox/Control/TextureRect.visible = false
			$GUI/Margin/VBox/Control/TextureRect2.visible = false
			$GUI/Margin/VBox/Control/Enter_to_start.visible = false
			score.visible = true
			score.text = ""
			
	var lead = globals.get_lead()
	if lead != previos_leed:
		previos_leed = lead
		if lead > -1:
			score.text = globals.player_label[lead] + " is in the lead"
			score.label_settings.font_color = colors[lead]
			timer = 1.5
	elif globals.player_score[lead]>=15 && timer<0.2:
		timer = 1
		
	logging.add_frame()
	
	if Input.is_action_just_pressed("Escape"):
		get_tree().change_scene_to_file("res://scenes/victory_screen/final.tscn")

func enable_player(id:int) -> void:
		globals.players_enabled[id-1] = true
		if globals.player_count == 3:
			get_node("ViewportsContainer/Player"+str(4)).visible = true
		get_node("ViewportsContainer/Player"+str(globals.player_count)).visible = true
		var new_player = preload("res://nodes/player/player.tscn").instantiate()
		var spawn_position = get_node("ViewportsContainer/Player"+str(globals.player_count)+"/SubViewport/player_spawn").global_position
		new_player.player_texture = load("res://nodes/player/model/player_"+str(globals.player_count)+".png")
		new_player.PLAYER_NUM = globals.player_count
		get_node("ViewportsContainer/Player"+str(globals.player_count)+"/SubViewport/player_spawn").replace_by(new_player)
		new_player.enable_player(id)
		new_player.global_position = spawn_position
		new_player.originPosition = spawn_position
		
		if globals.player_count == 2:
			viewports_container.columns = 2
		globals.player_count += 1

