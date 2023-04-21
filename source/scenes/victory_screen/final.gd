extends Node2D

var tempBG     = Vector2() 
var tempShroom = Vector2() 
var tempBack   = Vector2() 
var tempFront  = Vector2() 
var timer      = 8
#var ratio      = Vector2()

func _ready():
	scale = get_viewport().size / globals.screen
	$Control.text += globals.victory_label +" player won?"

func _physics_process(delta):
	
	if timer<=0:
		get_tree().change_scene_to_file("res://start.tscn")
	else:
		timer -= delta
	$BG.position -= tempBG
	tempBG = Vector2(randf_range(-timer/8,timer/8)*randf_range(-timer/8,timer/8),randf_range(-timer/8,timer/8)*randf_range(-timer/8,timer/8))
	$BG.position += Vector2(0,-0.11*timer) + tempBG
	
	$shroom.position -= tempShroom
	tempShroom = Vector2(randf_range(-timer/6,timer/6)*randf_range(-timer/6,timer/6),randf_range(-timer/6,timer/6)*randf_range(-timer/6,timer/6))
	$shroom.position += Vector2(0,-0.14*timer) + tempShroom

	$backCloud.position -= tempBack
	tempBack = Vector2(randf_range(-timer/5,timer/5)*randf_range(-timer/5,timer/5),randf_range(-timer/5,timer/5)*randf_range(-timer/5,timer/5))
	$backCloud.position += Vector2(0,-0.05*timer) + tempBack

	$frontCloud.position -= tempFront
	tempFront = Vector2(randf_range(-timer/4,timer/4)*randf_range(-timer/4,timer/4),randf_range(-timer/4,timer/4)*randf_range(-timer/4,timer/4))
	$frontCloud.position += Vector2(0,-0.035*timer) + tempFront
