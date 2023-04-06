extends CharacterBody3D

@export var RANGE: int

const MOVE_BALANCE = 5

const MOVE_SPEED_WALK  = 10 * MOVE_BALANCE
const MOVE_SPEED_CHASE = 50 * MOVE_BALANCE
const MOVE_SPEED_RUN   = 10 * MOVE_BALANCE

const RUN_DISTANCE     = 5.0
const RUN_DISTANCE_2   = RUN_DISTANCE * 0.5

enum {STATE_IDLE, STATE_BACK, STATE_CHASE}

const WAIT_TIME  = 1.5

var offset       := 0.0
var state        := 0
var time         := 0.0
var player_moved := false
var walk_cycle   := 0.0

#var playerInArea = false
var originPosition := Vector3()
var target   :Node3D= null
var targets        := []

var is_on_screen   := false

func _ready():
	originPosition = self.position
	state = STATE_BACK
	walk_cycle = randf_range(0,PI)
#	if not is_visible_in_tree():
#		queue_free()

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
		
	bounce()
	
	if is_on_screen:
		for i in globals.cameras.size():
			var on_screen_postion = globals.cameras[i].unproject_position(global_position).round()
			if on_screen_postion.x > 0 and on_screen_postion.x < get_viewport().size.x:
				if on_screen_postion.y > 0 and on_screen_postion.y < get_viewport().size.y:
					prints(name, "jest na ekranie: player ", i+1, " w pozycji:",  on_screen_postion)

func idle(delta):
	if time < WAIT_TIME:
		time += delta
	else:
		state = STATE_CHASE
		time = 0;

func chase(delta):
	var distance = self.position.distance_to(target.position)
		
	var direction = target.position - self.position
	direction = direction.normalized()
	direction.y = 0
	
	look_at(target.position, Vector3(0,1,0))
	
#	get_node("steps/Steps_" + str( randi() % 12 + 1 ) ).play()
	
	if distance > RUN_DISTANCE:
		offset = MOVE_SPEED_CHASE * delta
		set_velocity(direction * offset)
		move_and_slide()
		position.y = originPosition.y
		%exclamation_mark.modulate = Color(1,1,1,  (RUN_DISTANCE - clamp(distance- (RUN_DISTANCE_2), 0, RUN_DISTANCE)) / RUN_DISTANCE ) 
	else:
		%exclamation_mark.modulate = Color(1,1,1,0)
		offset = MOVE_SPEED_RUN * delta
		var collision = move_and_collide(direction * offset)
		if collision && collision.get_collider().get_name() == target.get_name():
			target.push(direction, null)
			%bump.play()
			target.popShrooms(4)
			state = STATE_IDLE
			time = 0;
			if targets.size() > 1:
				targets.push_back(target)
				targets.pop_front()
				target = targets.front()

func back(delta):
	var direction = originPosition - self.position
	
#	get_node("steps/Steps_" + str( randi() % 12 + 1 ) ).play()
	
	if direction.length_squared() >1:
		direction = direction.normalized()
		look_at(originPosition, Vector3(0,1,0))
		offset = MOVE_SPEED_WALK * delta
		direction.y = 0
		set_velocity(direction * offset)
		move_and_slide()
		position.y = originPosition.y
		
func bounce():
	if player_moved:
		walk_cycle += 0.2
		if walk_cycle >= PI:
			walk_cycle -= PI
			%step.play()
#			get_node("steps/Step_"+str(randi()%12+1)).play()
	else:
		if walk_cycle > PI * 0.5:
			walk_cycle += 0.2
		else:
			walk_cycle -= 0.2
			
		if walk_cycle < 0 or walk_cycle > PI:
				walk_cycle = 0
	
	$Node3D.position.y = -sin( walk_cycle ) * 0.2

func _on_SenseArea_body_entered(body):
	if body.is_in_group("players"):
		targets.push_back(body)
		target = targets.front()
		state = STATE_CHASE
		%meeh.play()
#		get_node("meeeh/Meeeh_" + str( randi() % 8 + 1 ) ).play()


func _on_SenseArea_body_exited(body):
	if body.is_in_group("players"):
		targets.erase(body)
		if targets.size() == 0:
			state = STATE_BACK
		else:
			target = targets.front()
			


func _on_visible_on_screen_notifier_3d_screen_entered():
	is_on_screen = true
#	prints(name, "na ekranie")


func _on_visible_on_screen_notifier_3d_screen_exited():
	is_on_screen = false
#	prints(name, "na poza ekranem")
