extends StaticBody

onready var cloud = $Cloud
onready var label = $Viewport/Label

const CLOUD_TIME_BETWEEN = 3
const CLOUD_TIME_ON = 5

var timer = 0
var messageIndex = 0

var messages = ["I need shrooms!\nBring me SHROOMS!"
,"Welcome!\nStay a while\nand listen."
,"Blood for Blood\nShroom for Shroom\nGOD!"]

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
		label.text = messages[messageIndex]
		cloud.visible = true
		timer = 0
	
	pass
