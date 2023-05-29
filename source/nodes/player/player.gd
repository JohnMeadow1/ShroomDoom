extends CharacterBody3D
class_name Player

const MOVE_SPEED  := 50
const STUN_TIME   := 1

@export var PLAYER_NUM := 1
var PLAYER_CONTROLS := 1
@export var player_texture: Texture2D
@export var player_enabled := false
enum {STATE_IDLE, STATE_WALK, STATE_FIGHT, STATE_STUN, STATE_DYING}
var states = ["STATE_IDLE", "STATE_WALK", "STATE_FIGHT", "STATE_STUN", "STATE_DYING"]
@export var camera_node :Marker3D
var camera    :Camera3D
var drag_item :Node3D = null
var state     := STATE_IDLE
var stun_time := 0.0

var move           := Vector3()
var walk_cycle     := 0.0
var player_hit     := false
var originPosition := Vector3()
var base_rotation  := [Vector3(),Vector3()]
var timer          := 5.0

var death_rotation  := Vector3()
var origin_rotation := Vector3()
var drop_shroom_object := preload("res://nodes/drops/drop_shroom.tscn")
var player_move_request := false
var requested_move_vector := Vector3.ZERO

@onready var eye_1 := $Node3D/MeshInstance3D/eye_node
@onready var eye_2 := $Node3D/MeshInstance3D/eye_node2
var player_actions := [ "up", "down", "left", "right", "swing", "score", "check_victory", "hits_player", "gets_stunned", "stunned", "flying", "died", "flying", "respawn"]
var bbox_points  := PackedVector3Array([Vector3(1.5,0,1), Vector3(-1.5,0,1), Vector3(1.5,3,0), Vector3(-1.5,3,0)])

var is_on_screen    := false
var is_on_specific_screen := [false,false,false,false]

var last_bounding_box := Rect2()

@onready var aoi_handler := AOI_handler.new("player"+name)

func _ready():
	originPosition   = position
	origin_rotation  = %Node3D.rotation
	state       = STATE_IDLE
	base_rotation[0] = eye_1.rotation
	base_rotation[1] = eye_2.rotation
	%Node3D/MeshInstance3D.material_override = preload("res://nodes/player/model/player.material").duplicate()
	%Node3D/MeshInstance3D.material_override.set("albedo_texture",player_texture)
	camera = camera_node.get_child(0)
	globals.cameras[PLAYER_NUM-1] = camera
	globals.players[PLAYER_NUM-1] = self
	
	%Label3D.text = str("player:",PLAYER_NUM-1," camera:",PLAYER_NUM)
	enable_player(PLAYER_NUM)
	aoi_handler.__set_aoi_type("Player")
	%on_screen_debug.__set_bbox_color(Color.BLUE)
	prints("camera added:", PLAYER_NUM)

func _physics_process(delta):
	update_on_screen_bbox(true)
	%Label3D.visible = globals.debug
	%CanvasLayer.visible = globals.debug
	logging.add_player_position_velocity(PLAYER_NUM, Vector2(global_position.x, global_position.z), Vector2(velocity.x, velocity.z) )
	requested_move_vector = get_input_vector()
	
	if timer > 0:
		timer -= delta
	else:
		player_hit = false
		
	match state:
		STATE_IDLE:
			move += requested_move_vector * MOVE_SPEED * delta
			if Input.is_action_just_pressed("action_p" + str(PLAYER_CONTROLS)):
				do_attack()
			if player_move_request:
				state = STATE_WALK
				walk_cycle += 0.2
				if walk_cycle >= PI:
					walk_cycle -= PI
					%steps.play()

		STATE_WALK:
			move += requested_move_vector * MOVE_SPEED * delta
			if Input.is_action_just_pressed("action_p" + str(PLAYER_CONTROLS)):
				do_attack()
			update_move_animation()

		STATE_STUN:
			logging.add_player_input(PLAYER_NUM, "stunned")
			stun_time += delta
			if stun_time >= STUN_TIME:
				stun_time = 0
				state = STATE_IDLE
			update_move_animation()

		STATE_DYING:
			dying(delta)

	%Node3D.position.y =  -sin( walk_cycle ) * 0.2
	eye_1.rotation.x = base_rotation[0].x + sin( walk_cycle ) * 0.4 
	eye_1.rotation.z = base_rotation[0].z + sin( walk_cycle ) - PI/4
	eye_2.rotation.x = base_rotation[1].x + sin( walk_cycle ) * 0.2 
	eye_2.rotation.z = base_rotation[1].z + cos( walk_cycle ) * 0.6 - PI/5

	set_velocity(move)
	move_and_slide()
	move = velocity
	
	if state != STATE_DYING:
		position.y = originPosition.y
		move      *= 0.90
	
	%Node3D.rotation.y = atan2(move.x,move.z)
	camera_node.global_position = global_position
	
	
func do_attack():
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
		%AnimationPlayer.play("swing")
		for body in get_tree().get_nodes_in_group("players"):
			if body != self && body.position.distance_to(position) < 3:
				var direction = body.position - position
				body.push(direction.normalized() / 4, self)
				push(-direction.normalized() / 4, self)
				player_hit = true
		
		if !player_hit:
			logging.add_player_input(PLAYER_NUM, "hits_player")
			player_hit = true
			timer = 20
			%taunts.play()
			%talk.visible = true
	
		for body in get_tree().get_nodes_in_group("sage"):
			if body.position.distance_to(position) < 4:
				logging.add_player_input(PLAYER_NUM, "check_victory")
				body.checkWin(self)
				
func update_move_animation():
	if player_move_request:
#		state = STATE_WALK
		walk_cycle += 0.2
		if walk_cycle >= PI:
			walk_cycle -= PI
			%steps.play()
	else:
		if walk_cycle > PI * 0.5:
			walk_cycle += 0.2
		else:
			walk_cycle -= 0.2
			
		if walk_cycle < 0 or walk_cycle > PI:
			if !walk_cycle == 0:
				%steps.play()
			walk_cycle = 0
			state = STATE_IDLE

func get_input_vector():
	player_move_request = false
	var input_vector := Vector3.ZERO
	if Input.is_action_pressed("move_up_p" + str(PLAYER_CONTROLS)):
		logging.add_player_input(PLAYER_NUM, "up")
		input_vector.z      -= 1
		player_move_request = true

	if Input.is_action_pressed("move_down_p" + str(PLAYER_CONTROLS)):
		logging.add_player_input(PLAYER_NUM, "down")
		input_vector.z      += 1
		player_move_request = true
	
	if Input.is_action_pressed("move_left_p" + str(PLAYER_CONTROLS)):
		logging.add_player_input(PLAYER_NUM, "left")
		input_vector.x      -= 1
		player_move_request = true

	if Input.is_action_pressed("move_right_p" + str(PLAYER_CONTROLS)):
		logging.add_player_input(PLAYER_NUM, "right")
		input_vector.x      += 1
		player_move_request = true
		
	return input_vector

func enable_player(player_id):
#	PLAYER_CONTROLS = 1
	PLAYER_CONTROLS = player_id
	player_enabled = true
	globals.player_count += 1
#	globals.add_score(PLAYER_NUM, 0)

func dying(delta:float):
	timer -= delta
	move += Vector3(0,-0.5,0)
	%Node3D.rotation += death_rotation/20
	if timer < 0 || Input.is_action_just_pressed("action_p" + str(PLAYER_CONTROLS)):
		logging.add_player_input(PLAYER_NUM, "respawn")
		player_enabled = true
		position       = originPosition
		state          = STATE_IDLE
		%Node3D.rotation    = origin_rotation
	else:
		logging.add_player_input(PLAYER_NUM, "flying")
	
func push(direction:Vector3, player: Player):
	if state == STATE_STUN:
		var score = globals.get_score(PLAYER_NUM)

		if player:
			globals.add_score(player.PLAYER_NUM, score+7)
		
		pop_shrooms(score)
		state = STATE_DYING
		logging.add_player_input(PLAYER_NUM, "died")
		player_enabled = false
		timer          = 3
		move          += Vector3(0,20,0) + direction * 40
		death_rotation = Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
		$GPUParticles3D.emitting = true
	else:
		logging.add_player_input(PLAYER_NUM, "gets_stunned")
		move += direction * 50
		state = STATE_STUN
		$GPUParticles3D.emitting = true
	
func pop_shrooms(amount):
#	var score = globals.player_score_label[PLAYER_NUM]
	var spawn = min(globals.get_score(PLAYER_NUM), amount)
	logging.add_player_input(PLAYER_NUM, "")
	globals.add_score(PLAYER_NUM, - spawn)
	
	for i in range(spawn):
		var new_pop = drop_shroom_object.instantiate()
		new_pop.position = position
		get_parent().add_child(new_pop)
	
func update_on_screen_bbox(active:bool) -> void:
	var bounding_box:Rect2 = Rect2()
	for player_id in globals.players.size():
		if globals.players[player_id] == self:
			continue

		bounding_box = Rect2()
		bounding_box.position = camera.unproject_position( globals.players[player_id].global_position ) 
		for i in bbox_points.size():
			if not camera.is_position_in_frustum( globals.players[player_id].global_position ):
				continue
			bounding_box = bounding_box.expand(camera.unproject_position( globals.players[player_id].to_global(globals.players[player_id].bbox_points[i]) ) )
		
		bounding_box = get_truncated_bbox_to_vieport_rect(bounding_box, PLAYER_NUM-1)

		if bounding_box.size.x * bounding_box.size.y > 16:
			%on_screen_debug.__update_rect_for_camera(bounding_box)
			aoi_handler.add_aoi(bounding_box, player_id, active)
			is_on_specific_screen[player_id] = true
			last_bounding_box = bounding_box
		else:
			if is_on_specific_screen[player_id]:
				aoi_handler.add_aoi(last_bounding_box, player_id, false)
				is_on_specific_screen[player_id] = false

func get_truncated_bbox_to_vieport_rect(bounding_box:Rect2, camera_id:int):
	var vieport_size = get_viewport().size * 0.5
	var vieport_rect = Rect2(Vector2.ZERO, vieport_size)
	bounding_box = bounding_box.intersection(vieport_rect)
#	var vieport_offset = Vector2( (floori(camera_id/2.0))%2, camera_id%2)
	bounding_box.position += globals.cameras_offeset[camera_id] * vieport_size
	return bounding_box

func _on_taunts_finished():
	%talk.visible = false
	
func _exit_tree():
	aoi_handler.__push_log()

