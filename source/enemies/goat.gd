extends KinematicBody

export(int) var RANGE

const MOVE_SPEED_WALK  = 10
const MOVE_SPEED_CHASE = 50 * 2.5
const MOVE_SPEED_RUN   = 70

enum {STATE_IDLE, STATE_WALK, STATE_CHASE}

var move       = Vector3()
var walk_cycle = 0

#var playerInArea = false
var originPosition = Vector3()
var target = null

func _ready():
	originPosition = self.translation
	
	pass

func _process(delta):
	
	var offset = 0
#	var player_moved = false
	
	if (target != null && self.translation.distance_to(target.translation) > 0.5):
		offset = MOVE_SPEED_CHASE * delta
#		print("Chase: " + target.get_name())
		
		var direction = target.translation - self.translation
		direction = direction.normalized()
		
		look_at(target.translation, Vector3(0,1,0))
		move_and_slide(direction * offset)
	pass


func _on_SenseArea_body_entered(body):
	if("player" in body.get_name()):
		target = body


func _on_SenseArea_body_exited(body):
	target = null
