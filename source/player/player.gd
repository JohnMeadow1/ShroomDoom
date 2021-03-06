extends KinematicBody


const MOVE_SPEED  = 50
const STUN_TIME   = 1

export(int) var PLAYER_NUM
var PLAYER_CONTROLS
export(Texture) var player_texture
export var player_enabled = false
enum {STATE_IDLE, STATE_WALK, STATE_FIGHT, STATE_STUN}

var drag_item = null
var state     = null
var stunTime  = 0

var move       = Vector3()
var walk_cycle = 0
var player_hit = false
var originPosition = Vector3()
var base_rotation = [Vector3(),Vector3()]
var timer = 5
var is_dying = false
var death_rotation = Vector3()
var origin_rotation = Vector3()
var drop_shroom_object = load("res://objects/Drop_shroom.tscn")

func _ready():
	PLAYER_CONTROLS  = PLAYER_NUM
	originPosition   = self.translation
	origin_rotation  = $Spatial.rotation
	self.state       = STATE_IDLE
	base_rotation[0] = $Spatial/eye_node.rotation
	base_rotation[1] = $Spatial/eye_node2.rotation
	$Spatial/MeshInstance.material_override = load("res://player/player.material").duplicate()
	$Spatial/MeshInstance.material_override.set("albedo_texture",player_texture)
	
func _physics_process(delta):
		
	if is_dying:
		timer -= delta
		move += Vector3(0,-0.5,0)
		$Spatial.rotation += death_rotation/20
		if timer < 0 || Input.is_action_just_pressed("action_p" + str(PLAYER_CONTROLS)):
			self.player_enabled = true
			self.translation    = originPosition
			self.is_dying       = false
			self.state          = STATE_IDLE
			$Spatial.rotation    = origin_rotation
			
	if timer > 0:
		timer -= delta
		if timer < 9:
			$talk.visible = false
	else:
		player_hit = false
#	# Fight 
	if self.state == STATE_STUN:
		stunTime += delta
		if stunTime >= STUN_TIME:
			stunTime = 0
			self.state = STATE_IDLE
	elif player_enabled && Input.is_action_just_pressed("action_p" + str(PLAYER_CONTROLS)):

		var pick_up = false
		for node in get_tree().get_nodes_in_group( "pickables"+str(PLAYER_NUM) ):
			node.queue_free()
			globals.add_score(PLAYER_NUM,1)
			pick_up = true
		if pick_up:
			get_node("pick_up/Pick_up_" + str( randi() % 4 + 1) ).play()
		else:
			get_node("stab/stab_" + str( randi() % 4 + 1) ).play()
			$AnimationPlayer.play("swing")
			for body in get_tree().get_nodes_in_group("players"):
				if body != self && body.translation.distance_to(self.translation) < 3:
					var direction = body.translation - self.translation
					body.push(direction.normalized() / 4, self)
					push(-direction.normalized() / 4, self)
					player_hit = true
			
			if !player_hit:
				player_hit = true
				get_node("teksty/tekst" + str( randi() % 13 + 1) ).play()
				timer = 20
				$talk.visible = true
			
			for body in get_tree().get_nodes_in_group("sage"):
				if body.translation.distance_to(self.translation) < 4:
					body.checkWin(self)

	elif player_enabled :
		var offset = MOVE_SPEED * delta
		var player_moved = false
		
		if Input.is_action_pressed("move_up_p" + str(PLAYER_CONTROLS)):
			move.z      -= offset
			player_moved = true
	
		if Input.is_action_pressed("move_down_p" + str(PLAYER_CONTROLS)):
			move.z      += offset
			player_moved = true
		
		if Input.is_action_pressed("move_left_p" + str(PLAYER_CONTROLS)):
			move.x      -= offset
			player_moved = true
	
		if Input.is_action_pressed("move_right_p" + str(PLAYER_CONTROLS)):
			move.x      += offset
			player_moved = true
	
		if player_moved:
			self.state = STATE_WALK
			walk_cycle += 0.2
			if walk_cycle >= PI:
				walk_cycle -= PI
				get_node("steps/Steps_" + str( randi() % 10 + 1 ) ).play()
		elif self.state != STATE_IDLE:

			if walk_cycle > PI * 0.5:
				walk_cycle += 0.2
			else:
				walk_cycle -= 0.2
				
			if walk_cycle < 0 or walk_cycle > PI:
				if !walk_cycle == 0:
					get_node("steps/Steps_"+str(randi()%10+1)).play()
				walk_cycle = 0
				self.state = STATE_IDLE
#		print (walk_cycle)

	$Spatial.translation.z =  -sin( walk_cycle ) * 0.2
	move                   = move_and_slide(move)
	if !is_dying:
		translation.y      = originPosition.y
		move               *= 0.90
	$Spatial.rotation.z    = atan2(move.x,-move.z)
	
	$Spatial/eye_node.rotation.x = base_rotation[0].x + sin( walk_cycle ) * 0.4 
	$Spatial/eye_node.rotation.y = base_rotation[0].y + sin( walk_cycle ) - PI/4
	$Spatial/eye_node2.rotation.x = base_rotation[1].x + sin( walk_cycle ) * 0.2 
	$Spatial/eye_node2.rotation.y = base_rotation[1].y + cos( walk_cycle ) * 0.6 - PI/5
#	$Spatial/eye_node2.rotation = base_rotation[1]

func enable_player(player_id):
	PLAYER_CONTROLS = player_id
	player_enabled = true
#	PLAYER_NUM = player_id
#	get_node("../../../Player"+str(player_id)).visible = true
	globals.add_score(self.PLAYER_NUM,0)
	
func push(direction, player):
	if self.state == STATE_STUN:
		var score = globals.get_score(self.PLAYER_NUM)
		
		if player:
			globals.add_score(player.PLAYER_NUM, score+7)
		
		self.popShrooms(score)
		is_dying       = true
		player_enabled = false
		timer          = 3
		move          += Vector3(0,20,0) + direction * 40
		death_rotation = Vector3(rand_range(-1,1),rand_range(-1,1),rand_range(-1,1))
		$Particles.emitting = true
	else:
		move += direction*50
		self.state = STATE_STUN
		$Particles.emitting = true
	
func popShrooms(amount):
#	var score = globals.player_score_label[PLAYER_NUM]
	var spawn = min(globals.get_score(PLAYER_NUM), amount)
	globals.add_score(PLAYER_NUM, -amount)
	for i in range(spawn):
		var new_pop = drop_shroom_object.instance()
		new_pop.translation = self.translation
		$"../../../Player1/Viewport/world/map".add_child(new_pop)
	