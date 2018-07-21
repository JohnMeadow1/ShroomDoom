extends KinematicBody


const MOVE_SPEED  = 50
const STUN_TIME   = 1

export(int) var PLAYER_NUM

enum {STATE_IDLE, STATE_WALK, STATE_FIGHT, STATE_STUN}

var drag_item = null
var state     = null
var stunTime  = 0

var move       = Vector3()
var walk_cycle = 0


func _ready():
	
	self.state = STATE_IDLE
	
func _physics_process(delta):

	if self.state == STATE_STUN:
		stunTime += delta
		if stunTime >= STUN_TIME:
			stunTime = 0
			self.state = STATE_IDLE
#	# Fight 
	elif Input.is_action_just_pressed("action_p" + str(PLAYER_NUM)):
		for node in get_tree().get_nodes_in_group( "pickables"+str(PLAYER_NUM) ):
			node.queue_free()
			globals.add_score(PLAYER_NUM,1)
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
		else:
			self.state = STATE_IDLE
			if walk_cycle > PI * 0.5:
				walk_cycle += 0.2
			else:
				walk_cycle -= 0.2
				
			if walk_cycle < 0 or walk_cycle > PI:
				walk_cycle = 0
#		print (walk_cycle)

	$Spatial.translation.z =  -sin( walk_cycle ) * 0.2
	move = move_and_slide(move)
	move *= 0.90
	$Spatial.rotation.z = atan2(move.x,-move.z)

func push(direction):
	move += direction*50
	self.state = STATE_STUN