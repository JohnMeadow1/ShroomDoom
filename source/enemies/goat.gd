extends KinematicBody

export(int) var RANGE

const MOVE_BALANCE = 5

const MOVE_SPEED_WALK  = 10 * MOVE_BALANCE
const MOVE_SPEED_CHASE = 50 * MOVE_BALANCE
const MOVE_SPEED_RUN   = 10 * MOVE_BALANCE

const RUN_DISTANCE     = 5

enum {STATE_IDLE, STATE_BACK, STATE_CHASE}

var state = null

#var playerInArea = false
var originPosition = Vector3()
var target = null

func _ready():
	originPosition = self.translation
	state = STATE_IDLE
	
	pass

func _process(delta):
	
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
				state = STATE_BACK
				
				
				
#		print("Chase: " + target.get_name())
		
		
	pass


func _on_SenseArea_body_entered(body):
	if "player" in body.get_name():
		target = body
		state = STATE_CHASE


func _on_SenseArea_body_exited(body):
	target = null
	state = STATE_IDLE
