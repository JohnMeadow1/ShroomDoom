extends Control

var tempBG     = Vector2() 
var tempShroom = Vector2() 
var tempBack   = Vector2() 
var tempFront  = Vector2() 
var timer      = 8
#var ratio      = Vector2()

func _ready():
	scale = get_viewport().size / globals.screen
	$Label.text += globals.victory_label +" player won?"
	logging.save_logs()

func _physics_process(delta):
	
	if timer<=0:
		get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
	else:
		timer -= delta
	$background.position -= tempBG
	tempBG = Vector2(randf_range(-timer/8,timer/8)*randf_range(-timer/8,timer/8),randf_range(-timer/8,timer/8)*randf_range(-timer/8,timer/8))
	$background.position += Vector2(0,-0.11*timer) + tempBG
	
	$shroom.position -= tempShroom
	tempShroom = Vector2(randf_range(-timer/6,timer/6)*randf_range(-timer/6,timer/6),randf_range(-timer/6,timer/6)*randf_range(-timer/6,timer/6))
	$shroom.position += Vector2(0,-0.14*timer) + tempShroom

	$back_cloud.position -= tempBack
	tempBack = Vector2(randf_range(-timer/5,timer/5)*randf_range(-timer/5,timer/5),randf_range(-timer/5,timer/5)*randf_range(-timer/5,timer/5))
	$back_cloud.position += Vector2(0,-0.05*timer) + tempBack

	$front_cloud.position -= tempFront
	tempFront = Vector2(randf_range(-timer/4,timer/4)*randf_range(-timer/4,timer/4),randf_range(-timer/4,timer/4)*randf_range(-timer/4,timer/4))
	$front_cloud.position += Vector2(0,-0.035*timer) + tempFront
