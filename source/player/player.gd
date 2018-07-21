extends KinematicBody


const MOVE_SPEED  = 50
const STUN_TIME   = 1

export(int) var PLAYER_NUM
export(Texture) var player_texture
enum {STATE_IDLE, STATE_WALK, STATE_FIGHT, STATE_STUN}

var drag_item = null
var state     = null
var stunTime  = 0

var move       = Vector3()
var walk_cycle = 0
var originPosition = Vector3()
var base_rotation = [Vector3(),Vector3()]

func _ready():
	originPosition   = self.translation
	self.state       = STATE_IDLE
	base_rotation[0] = $Spatial/eye_node.rotation
	base_rotation[1] = $Spatial/eye_node2.rotation
	$Spatial/MeshInstance.material_override = load("res://player/player.material").duplicate()
	$Spatial/MeshInstance.material_override.set("albedo_texture",player_texture)
	
func _physics_process(delta):

	
#	# Fight 
	if self.state == STATE_STUN:
		stunTime += delta
		if stunTime >= STUN_TIME:
			stunTime = 0
			self.state = STATE_IDLE
			
	elif Input.is_action_just_pressed("action_p" + str(PLAYER_NUM)):
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
					body.push(direction.normalized() / 4)
					push(-direction.normalized() / 4)
			for body in get_tree().get_nodes_in_group("sage"):
				if body.translation.distance_to(self.translation) < 4:
					body.checkWin(self)
	else:
		var offset = MOVE_SPEED * delta
		var player_moved = false
		
		if Input.is_action_pressed("move_up_p" + str(PLAYER_NUM)):
			move.z      -= offset
			player_moved = true
	
		if Input.is_action_pressed("move_down_p" + str(PLAYER_NUM)):
			move.z      += offset
			player_moved = true
		
		if Input.is_action_pressed("move_left_p" + str(PLAYER_NUM)):
			move.x      -= offset
			player_moved = true
	
		if Input.is_action_pressed("move_right_p" + str(PLAYER_NUM)):
			move.x      += offset
			player_moved = true
	
		if player_moved:
			self.state = STATE_WALK
			walk_cycle += 0.2
			if walk_cycle >= PI:
				walk_cycle -= PI
				get_node("steps/Steps_" + str( randi() % 10 + 1 ) ).play()
				$dust.emitting = true
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
	move = move_and_slide(move)
	translation.y = originPosition.y
	move *= 0.90
	$Spatial.rotation.z = atan2(move.x,-move.z)
	$Spatial/eye_node.rotation.x = base_rotation[0].x + sin( walk_cycle ) * 0.4 
	$Spatial/eye_node.rotation.y = base_rotation[0].y + sin( walk_cycle ) - PI/4
	$Spatial/eye_node2.rotation.x = base_rotation[1].x + sin( walk_cycle ) * 0.2 
	$Spatial/eye_node2.rotation.y = base_rotation[1].y + cos( walk_cycle ) * 0.6 - PI/5
#	$Spatial/eye_node2.rotation = base_rotation[1]


func push(direction):
	move += direction*50
	self.state = STATE_STUN
	$Particles.emitting = true
	
func popShrooms(amount):
#	var score = globals.player_score_label[PLAYER_NUM]
	globals.add_score(PLAYER_NUM, -amount)
	