extends Node

var player_score = [0,0,0,0]
var player_score_label = [null,null,null,null]

func _ready():
	pass
	
func add_score(player_id, value):
	player_id-=1 # because array is from 0-3, and players are from 1-4
	player_score[player_id] += value
	player_score_label[player_id].text = "shrooms: "+str(player_score[player_id])
	
	