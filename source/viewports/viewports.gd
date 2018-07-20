extends Node

onready var mainScene = $ViewportsContainer/Player1/Viewport1/main

onready var viewport1 = $ViewportsContainer/Player1/Viewport1
onready var viewport2 = $ViewportsContainer/Player2/Viewport2
onready var viewport3 = $ViewportsContainer/Player3/Viewport3
onready var viewport4 = $ViewportsContainer/Player4/Viewport4

onready var camera1 = $ViewportsContainer/Player1/Viewport1/Camera2D
onready var camera2 = $ViewportsContainer/Player2/Viewport2/Camera2D
onready var camera3 = $ViewportsContainer/Player3/Viewport3/Camera2D
onready var camera4 = $ViewportsContainer/Player4/Viewport4/Camera2D

func _ready():
	
	viewport2.world = viewport1.world
	viewport3.world = viewport1.world
	viewport4.world = viewport1.world
	
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
