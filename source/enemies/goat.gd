extends KinematicBody

export(int) var RANGE

const MOVE_BALANCE = 5

const MOVE_SPEED_WALK  = 10 * MOVE_BALANCE
const MOVE_SPEED_CHASE = 50 * MOVE_BALANCE
const MOVE_SPEED_RUN   = 10 * MOVE_BALANCE

const RUN_DISTANCE     = 5

enum {STATE_IDLE, STATE_BACK, STATE_CHASE}

const WAIT_TIME = 3

var state = null
var time = 0

#var playerInArea = false
var originPosition = Vector3()
var target = null

func _ready():
	originPosition = self.translation
	state = STATE_BACK
	
	pass

func _physics_process(delta):
	
	var offset = 0
#	var player_moved = false
	
	if target && state == STATE_CHASE:
		var distance = self.translation.distance_to(target.translation)
		
		var direction = target.translation - self.translation
		direction = direction.normalized()
		
		look_at(target.translation, Vector3(0,1,0))
		
		if distance > RUN_DISTANCE:
			offset = MOVE_SPEED_CHASE * delta
			move_and_slide(direction * offset)
		else:
			offset = MOVE_SPEED_RUN * delta
			var collision = move_and_collide(direction * offset)
			if collision && collision.get_collider().get_name() == target.get_name():
				target.push(direction)
				state = STATE_IDLE
				time = 0;
	elif target && state == STATE_IDLE && time < WAIT_TIME:
		time += delta;
	elif target && state == STATE_IDLE && time >= WAIT_TIME:
		state = STATE_CHASE
		time = 0;
	elif !target && state == STATE_IDLE:
		state = STATE_BACK
	elif state == STATE_BACK:
		var direction = originPosition - self.translation
		if direction.length_squared() >1:
			direction = direction.normalized()
			look_at(originPosition, Vector3(0,1,0))
			offset = MOVE_SPEED_WALK * delta
			move_and_slide(direction * offset)
		
func _on_SenseArea_body_entered(body):
	if body.is_in_group("players"):
		target = body
		state = STATE_CHASE


func _on_SenseArea_body_exited(body):
	target = null
	state = STATE_BACK
