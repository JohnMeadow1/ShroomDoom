extends StaticBody

onready var cloud = $Cloud
onready var label = $Viewport/Label

const CLOUD_TIME_BETWEEN = 3
const CLOUD_TIME_ON = 5

var timer = 0
var messageIndex = 0

var neededShrooms = 20

var messages = ["I live on %s\nYellow\nSub-Shrooms"
,"I need shrooms!\nBring me\n%s SHROOMS!"
,"Welcome!\nStay a %s Shrooms\nand listen."
,"Blood for Blood\nShroom for\n%s Shroom soups!"]

func _ready():
	cloud.visible = false;
	label.text = messages[messageIndex]
	pass

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
	
	pass

func checkWin(player):
	var score = globals.player_score_label[player.PLAYER_NUM-1]
	
	cloud.visible = true
	
	if score > neededShrooms:
		label.text = "Is it supose\nto be like that?"
		timer = -5000
	else:
		label.text = "It's not enough\nI need\n%s more shrooms!" % neededShrooms
		timer = 0
	pass