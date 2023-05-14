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

var originPosition := Vector3()
var target   :Node3D= null
var targets        := []

var is_on_screen   := false

var b_box_points: PackedVector3Array = PackedVector3Array()

func _ready():
	originPosition = self.position
	state = STATE_BACK
	walk_cycle = randf_range(0,PI)
	
	var bounding_box: AABB = %MeshInstance3D.get_aabb()
	for i in 8:
		b_box_points.append( bounding_box.get_endpoint(i)  )
	
	$Label3D.text = name
#	if not is_visible_in_tree():
#		queue_free()

func _physics_process(delta):
	logging.add_goat_position_velocity(Vector2(global_position.x, global_position.z), Vector2(velocity.x, velocity.z) )
	match state:
		STATE_IDLE:
			idle(delta)
			player_moved = false
		STATE_CHASE:
			chase(delta)
			player_moved = true
		STATE_BACK:
			back(delta)
			player_moved = true
	bounce()
	
	if is_on_screen:
		update_on_screen_rect()

func update_on_screen_rect():
	var bounding_rect:Rect2 = Rect2()
	for camera_id in globals.cameras.size():

		bounding_rect = Rect2() 
		bounding_rect.position = globals.cameras[camera_id].unproject_position(%MeshInstance3D.global_position) 
		# BBOX na Viewport coords
		for i in b_box_points.size():
			bounding_rect = bounding_rect.expand(globals.cameras[camera_id].unproject_position(%MeshInstance3D.to_global(b_box_points[i])))
		var vieport_size = get_viewport().size * 0.5
		var vieport_rect = Rect2(Vector2.ZERO, vieport_size)
		bounding_rect = bounding_rect.intersection(vieport_rect)
		var vieport_offset = Vector2( (floori(camera_id/2.0))%2, camera_id%2)

		bounding_rect.position += vieport_offset * vieport_size
#		bounding_rect = bounding_rect.intersection(vieport_rect)
		if bounding_rect.size.length():
#			prints(name, "cam_id:", camera_id,"bbox", bounding_rect)
			%on_screen_debug._update_rect_for_camera(bounding_rect, camera_id)
		
#		globals.add_bbox(bounding_rect, camera_id)

#func update_on_screen_rect_1():
#	var bounding_rect:Rect2 = Rect2()
#	for camera_id in globals.cameras.size():
#		bounding_rect = Rect2() 
#		bounding_rect.position = globals.cameras[camera_id].unproject_position(%MeshInstance3D.global_position)
#		for vertex_id in range(mesh_tool.get_vertex_count()):
#			bounding_rect = bounding_rect.expand(globals.cameras[camera_id].unproject_position(%MeshInstance3D.to_global(mesh_tool.get_vertex(vertex_id))))
#		on_screen_debug.update_rect_for_camera(bounding_rect, camera_id, Color.YELLOW)

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
			target.pop_shrooms(4)
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
	
	%MeshInstance3D.position.y = -sin( walk_cycle ) * 0.2

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
