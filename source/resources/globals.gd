extends Node

const BLINDER_TIME = 3

var player_score       := [0,0,0,0]
var player_score_label := [null,null,null,null]
var player_label       := ["Red", "Green", "Violet", "Blue"]
var player_count       := 2
var players_enabled    := [true,false,false,false]
var victory_label      := "no"
#var blinder            := null
#var winnerLabel        := null
var won                := false
var timer              := 3.0
var screen             := Vector2()
var cameras            := [null,null,null,null]

func _ready():
	timer = 3

#func _physics_process(delta):
##	if won && timer > 0:
##		timer -= delta
##	elif won && timer <= 0:
##		get_tree().change_scene_to_file("res://start.tscn")
#pass

func add_score(player_id, value):
	player_id-=1 # because array is from 0-3, and players are from 1-4
	player_score[player_id] += value
	player_score[player_id] = clamp(player_score[player_id], 0, 2563)
	player_score_label[player_id].text = str(player_score[player_id]) + "/20"

func get_score(player_id):
	player_id-=1 # because array is from 0-3, and players are from 1-4
	return player_score[player_id] 
	
func get_lead():
	var lead = -1
	if player_score[0] > player_score[1]:
		lead = 0
	if player_score[0] < player_score[1]:
		lead = 1
	if player_score[lead] < player_score[2]:
		lead = 2
	if player_score[lead] < player_score[3]:
		lead = 3
	return lead
	
func win(player):
	victory_label = player_label[player.PLAYER_NUM-1]
#	blinder.color.a = 1
#	timer = BLINDER_TIME
#	winnerLabel.text = "%s player wins" % globals.player_label[player.PLAYER_NUM-1]
#	won = true
	
