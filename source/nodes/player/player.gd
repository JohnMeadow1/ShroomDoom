extends CharacterBody3D


const MOVE_SPEED  = 50
const STUN_TIME   = 1

@export var PLAYER_NUM :int = 1
var PLAYER_CONTROLS :int = 1
@export var player_texture: Texture2D
@export var player_enabled = false
enum {STATE_IDLE, STATE_WALK, STATE_FIGHT, STATE_STUN}

var drag_item :Node3D = null
var state     := 0
var stun_time := 0.0

var move       := Vector3()
var walk_cycle := 0.0
var player_hit := false
var originPosition := Vector3()
var base_rotation  := [Vector3(),Vector3()]
var timer := 5.0
var is_dying := false
var death_rotation  := Vector3()
var origin_rotation := Vector3()
var drop_shroom_object := preload("res://nodes/drops/drop_shroom.tscn")

@onready var eye_1 := $Node3D/MeshInstance3D/eye_node
@onready var eye_2 := $Node3D/MeshInstance3D/eye_node2
var player_actions = [ "up", "down", "left", "right", "swing", "score", "check_victory", "hits_player", "gets_stunned", "stunned", "flying", "died", "flying", "respawn"]
var b_box_points  := PackedVector3Array([Vector3(1.5,0,1), Vector3(-1.5,0,1), Vector3(1.5,3,0), Vector3(-1.5,3,0)])

var aoi_count := 0
var aoi := {
	"Blue": 255,
	"Green": 0,
	"Red": 0,
#	"Tags": [],
	"Name": "Player",
	"KeyFrames": [
#		{
#			"IsActive": false,
#			"Seconds": 0.0,
#			"Vertices": [
#				{"X": 0.0, "Y": 0.0},
#				{"X": 1.0, "Y": 0.0},
#				{"X": 1.0, "Y": 1.0},
#				{"X": 0.0, "Y": 1.0}
#			]
#		}
	]
}
func _ready():
	originPosition   = self.position
	origin_rotation  = $Node3D.rotation
	self.state       = STATE_IDLE
	base_rotation[0] = eye_1.rotation
	base_rotation[1] = eye_2.rotation
	$Node3D/MeshInstance3D.material_override = preload("res://nodes/player/model/player.material").duplicate()
	$Node3D/MeshInstance3D.material_override.set("albedo_texture",player_texture)
	globals.cameras[PLAYER_NUM-1] = %Camera3D
	globals.players[PLAYER_NUM-1] = self
	aoi.Name = name
	
	prints("camera added:", PLAYER_NUM)
	$Label3D.text = str("player:",PLAYER_NUM-1," camera:",PLAYER_NUM)

func _physics_process(delta):
	update_on_screen_rect(true)
	$Label3D.visible = globals.debug
	$CanvasLayer.visible = globals.debug
	logging.add_player_position_velocity(PLAYER_NUM, Vector2(global_position.x, global_position.z), Vector2(velocity.x, velocity.z) )
	if is_dying:
		timer -= delta
		move += Vector3(0,-0.5,0)
		$Node3D.rotation += death_rotation/20
		if timer < 0 || Input.is_action_just_pressed("action_p" + str(PLAYER_CONTROLS)):
			logging.add_player_input(PLAYER_NUM, "respawn")
			self.player_enabled = true
			self.position       = originPosition
			self.is_dying       = false
			self.state          = STATE_IDLE
			$Node3D.rotation    = origin_rotation
		else:
			logging.add_player_input(PLAYER_NUM, "flying")
			
	if timer > 0:
		timer -= delta
	else:
		player_hit = false
#	# Fight 
	if self.state == STATE_STUN:
		logging.add_player_input(PLAYER_NUM, "stunned")
		stun_time += delta
		if stun_time >= STUN_TIME:
			stun_time = 0
			self.state = STATE_IDLE
	elif player_enabled && Input.is_action_just_pressed("action_p" + str(PLAYER_CONTROLS)):
		logging.add_player_input(PLAYER_NUM, "swing")
		var pick_up = false
		for node in get_tree().get_nodes_in_group("pickables"+str(PLAYER_NUM)):
			node.queue_free()
			globals.add_score(PLAYER_NUM,1)
			pick_up = true
		if pick_up:
			%pickup.play()
			logging.add_player_input(PLAYER_NUM, "score")
		else:
			$AnimationPlayer.play("swing")
			for body in get_tree().get_nodes_in_group("players"):
				if body != self && body.position.distance_to(self.position) < 3:
					var direction = body.position - self.position
					body.push(direction.normalized() / 4, self)
					push(-direction.normalized() / 4, self)
					player_hit = true
			
			if !player_hit:
				logging.add_player_input(PLAYER_NUM, "hits_player")
				player_hit = true
				timer = 20
				%taunts.play()
				$talk.visible = true
			
			for body in get_tree().get_nodes_in_group("sage"):
				if body.position.distance_to(self.position) < 4:
					logging.add_player_input(PLAYER_NUM, "check_victory")
					body.checkWin(self)

	elif player_enabled :
		var offset = MOVE_SPEED * delta
		var player_moved = false
		
		if Input.is_action_pressed("move_up_p" + str(PLAYER_CONTROLS)):
			logging.add_player_input(PLAYER_NUM, "up")
			move.z      -= offset
			player_moved = true
	
		if Input.is_action_pressed("move_down_p" + str(PLAYER_CONTROLS)):
			logging.add_player_input(PLAYER_NUM, "down")
			move.z      += offset
			player_moved = true
		
		if Input.is_action_pressed("move_left_p" + str(PLAYER_CONTROLS)):
			logging.add_player_input(PLAYER_NUM, "left")
			move.x      -= offset
			player_moved = true
	
		if Input.is_action_pressed("move_right_p" + str(PLAYER_CONTROLS)):
			logging.add_player_input(PLAYER_NUM, "right")
			move.x      += offset
			player_moved = true
	
		if player_moved:
			self.state = STATE_WALK
			walk_cycle += 0.2
			if walk_cycle >= PI:
				walk_cycle -= PI
				%steps.play()
		elif self.state != STATE_IDLE:

			if walk_cycle > PI * 0.5:
				walk_cycle += 0.2
			else:
				walk_cycle -= 0.2
				
			if walk_cycle < 0 or walk_cycle > PI:
				if !walk_cycle == 0:
					%steps.play()
				walk_cycle = 0
				self.state = STATE_IDLE

	$Node3D.position.y =  -sin( walk_cycle ) * 0.2
	set_velocity(move)
	move_and_slide()
	move                   = velocity
	if !is_dying:
		position.y      = originPosition.y
		move               *= 0.90
	$Node3D.rotation.y    = atan2(move.x,move.z)
	
	eye_1.rotation.x = base_rotation[0].x + sin( walk_cycle ) * 0.4 
	eye_1.rotation.z = base_rotation[0].z + sin( walk_cycle ) - PI/4
	eye_2.rotation.x = base_rotation[1].x + sin( walk_cycle ) * 0.2 
	eye_2.rotation.z = base_rotation[1].z + cos( walk_cycle ) * 0.6 - PI/5
#	$Node3D/eye_node2.rotation = base_rotation[1]

func enable_player(player_id):
#	PLAYER_CONTROLS = 1
	PLAYER_CONTROLS = player_id
	player_enabled = true
	globals.add_score(self.PLAYER_NUM, 0)

	
func push(direction, player):
	if self.state == STATE_STUN:
		var score = globals.get_score(self.PLAYER_NUM)
		
		if player:
			globals.add_score(player.PLAYER_NUM, score+7)
		
		pop_shrooms(score)
		is_dying       = true
		logging.add_player_input(PLAYER_NUM, "died")
		player_enabled = false
		timer          = 3
		move          += Vector3(0,20,0) + direction * 40
		death_rotation = Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
		$GPUParticles3D.emitting = true
	else:
		logging.add_player_input(PLAYER_NUM, "gets_stunned")
		move += direction * 50
		self.state = STATE_STUN
		$GPUParticles3D.emitting = true
	
func pop_shrooms(amount):
#	var score = globals.player_score_label[PLAYER_NUM]
	var spawn = min(globals.get_score(PLAYER_NUM), amount)
	logging.add_player_input(PLAYER_NUM, "")
	globals.add_score(PLAYER_NUM, - spawn)
	
	for i in range(spawn):
		var new_pop = drop_shroom_object.instantiate()
		new_pop.position = self.position
		$"../../../../world".add_child(new_pop)
	
func update_on_screen_rect(active:bool):
	var bounding_rect:Rect2 = Rect2()

	for player_id in globals.players.size():
		if globals.players[player_id] == self:
			continue
		var tested_global_position = globals.players[player_id].global_position
		if not %Camera3D.is_position_behind(tested_global_position):
			continue
			
		bounding_rect = Rect2() 
		bounding_rect.position = %Camera3D.unproject_position( tested_global_position ) 
		var bounding_rect_1 = bounding_rect
		var bounding_rects = []
		bounding_rects.resize(b_box_points.size())
		for i in b_box_points.size():
			tested_global_position = globals.players[player_id].b_box_points[i]
			bounding_rect = bounding_rect.expand(%Camera3D.unproject_position(globals.players[player_id].to_global(tested_global_position)))
			bounding_rects[i] = bounding_rect
		var vieport_size = get_viewport().size
		var vieport_rect = Rect2(Vector2.ZERO,vieport_size)
		bounding_rect = bounding_rect.intersection(vieport_rect)

		var vieport_offset = Vector2i( (floori((PLAYER_NUM-1)/2.0))%2, (PLAYER_NUM-1)%2)
#
#		bounding_rect.position += Vector2(vieport_offset * vieport_size) 
		if bounding_rect.size.length()>4:
#			if bounding_rect.get_area() > (vieport_size.x * vieport_size.y)*0.6:
#				prints( %Camera3D.global_position.z, tested_global_position_center)
#				print (bounding_rect)    
  
			%on_screen_debug._update_rect_for_camera(bounding_rect, player_id, Color.BLUE)
			bounding_rect.position += Vector2(vieport_offset * vieport_size) 
#			bounding_rect.size *= 0.5
#			print("-----player ",PLAYER_NUM-1,"-------cam ",player_id+1,bounding_rect)
			add_aoi(bounding_rect, active)
			
func add_aoi(bbox:Rect2, active:bool) ->void :
	bbox.position = bbox.position.round()
	bbox.size = bbox.size.round()
	var new_aoi = {
			"IsActive": active,
			"Seconds": logging.time_elapsed_sec,
			"Vertices": [
				{"X": bbox.position.x, "Y": bbox.position.y},
				{"X": bbox.position.x + bbox.size.x, "Y": bbox.position.y},
				{"X": bbox.position.x + bbox.size.x, "Y": bbox.position.y + bbox.size.y},
				{"X": bbox.position.x, "Y": bbox.position.y + bbox.size.y}
			]
		}
	aoi.KeyFrames.append(new_aoi)
	aoi_count += 1
	
func _exit_tree():
	if aoi_count > 0:
		logging.add_aoi(aoi)

func _on_taunts_finished():
	$talk.visible = false
