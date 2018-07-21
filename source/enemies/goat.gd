extends KinematicBody

export(int) var RANGE

const MOVE_BALANCE = 5

const MOVE_SPEED_WALK  = 10 * MOVE_BALANCE
const MOVE_SPEED_CHASE = 50 * MOVE_BALANCE
const MOVE_SPEED_RUN   = 10 * MOVE_BALANCE

const RUN_DISTANCE     = 5

enum {STATE_IDLE, STATE_BACK, STATE_CHASE}

const WAIT_TIME  = 1.5

var offset       = 0
var state        = null
var time         = 0
var player_moved = false
var walk_cycle   = 0

#var playerInArea = false
var originPosition = Vector3()
var target         = null
var targets        = []

func _ready():
	originPosition = self.translation
	state = STATE_BACK
	
	pass

func _physics_process(delta):
	if state == STATE_IDLE:
		idle(delta)
		player_moved = false
	elif state == STATE_CHASE:
		chase(delta)
		player_moved = true
	elif state == STATE_BACK:
		back(delta)
		player_moved = true
		
	bounce(player_moved)

func idle(delta):
	if time < WAIT_TIME:
		time += delta
	else:
		state = STATE_CHASE
		time = 0;

func chase(delta):
	var distance = self.translation.distance_to(target.translation)
		
	var direction = target.translation - self.translation
	direction = direction.normalized()
	direction.y = 0
	
	look_at(target.translation, Vector3(0,1,0))
	
	if distance > RUN_DISTANCE:
		offset = MOVE_SPEED_CHASE * delta
		move_and_slide(direction * offset)
		translation.y = originPosition.y
	else:
		offset = MOVE_SPEED_RUN * delta
		var collision = move_and_collide(direction * offset)
		if collision && collision.get_collider().get_name() == target.get_name():
			target.push(direction)
			target.popShrooms(4)
			state = STATE_IDLE
			time = 0;
			if targets.size() > 1:
				targets.push_back(target)
				targets.pop_front()
				target = targets.front()

func back(delta):
	var direction = originPosition - self.translation
	
	if direction.length_squared() >1:
		direction = direction.normalized()
		look_at(originPosition, Vector3(0,1,0))
		offset = MOVE_SPEED_WALK * delta
		direction.y = 0
		move_and_slide(direction * offset)
		translation.y = originPosition.y
		
func bounce(player_moved):
	if player_moved:
		walk_cycle += 0.2
		if walk_cycle >= PI:
			walk_cycle -= PI
	else:
		if walk_cycle > PI * 0.5:
			walk_cycle += 0.2
		else:
			walk_cycle -= 0.2
			
		if walk_cycle < 0 or walk_cycle > PI:
				walk_cycle = 0
	
	$Spatial.translation.y = -sin( walk_cycle ) * 0.2

func _on_SenseArea_body_entered(body):
	if body.is_in_group("players"):
		targets.push_back(body)
		target = targets.front()
		state = STATE_CHASE


func _on_SenseArea_body_exited(body):
	if body.is_in_group("players"):
		targets.erase(body)
		if targets.size() == 0:
			state = STATE_BACK
		else:
			target = targets.front()
			