extends Node

const BLINDER_TIME = 3

var player_score = [0,0,0,0]
var player_score_label = [null,null,null,null]
var blinder = null
var won = false
var timer = 3

func _ready():
	pass

func _physics_process(delta):
	if won && blinder.color.a > 0:
		if timer <= 0:
			blinder.color.a -= delta / 4
		else:
			timer -= delta

func add_score(player_id, value):
	player_id-=1 # because array is from 0-3, and players are from 1-4
	player_score[player_id] += value
	player_score[player_id] = clamp(player_score[player_id], 0, 2563)
	player_score_label[player_id].text = "shrooms: "+str(player_score[player_id])

func get_score(player_id):
	player_id-=1 # because array is from 0-3, and players are from 1-4
	return player_score[player_id] 
	
func win(player):
	blinder.color.a = 1
	timer = BLINDER_TIME
	won = true