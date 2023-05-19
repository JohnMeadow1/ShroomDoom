extends StaticBody3D

@onready var cloud = $Cloud
@onready var label_bak = $SubViewport/Label
@onready var label = $Cloud/Label3D

const CLOUD_TIME_BETWEEN = 3
const CLOUD_TIME_ON = 5
const MORE_SHEROOMS = 7

var timer = 0
var messageIndex = 0

var neededShrooms = 20

var messages = ["I live checked %s\nYellow\nSub-Shrooms"
,"I need shrooms!\nBring me\n%s SHROOMS!"
,"Welcome!\nStay a %s Shrooms\nand listen."
,"Blood for Blood\nShroom for\n%s Shroom soups!"]
@onready var mumble = $mumble

func _ready():
	cloud.visible = false;
	label.text = messages[messageIndex]

func _physics_process(delta):
	
	timer += delta
	
	if cloud.visible && timer >= CLOUD_TIME_ON:
		cloud.visible = false
		messageIndex = (messageIndex+1) % messages.size()
		timer = 0
	
	if !cloud.visible && timer >= CLOUD_TIME_BETWEEN:
		label.text = messages[messageIndex] % neededShrooms
		cloud.visible = true
		timer = 0
		mumble.play()


func checkWin(player):
	var score = globals.player_score[player.PLAYER_NUM-1]
	
	cloud.visible = true
	
	if score >= neededShrooms:
		label.text = "Hmm.\nActualy I need\n%s more shrooms" % neededShrooms
		globals.win(player)
		get_tree().change_scene_to_file("res://scenes/victory_screen/victory_screen.tscn")
		timer = -5000
	else:
		label.text = "It's not enough\nYou need\n%s more shrooms!" % (neededShrooms - score)
		timer = 0
