extends CharacterBody3D

@export var RANGE: int

const MOVE_BALANCE = 0.0833333

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

var origin_position := Vector3()
var target   :Node3D= null
var targets        := []

var is_on_screen   := false
var is_on_specific_screen := [false,false,false,false]

var bbox_points := PackedVector3Array()
var last_bounding_box := Rect2()

@onready var aoi_handler := AOI_handler.new(name)
func _ready():
	origin_position = self.position
	state = STATE_BACK
	walk_cycle = randf_range(0,PI)
	
	var bounding_box: AABB = %MeshInstance3D.get_aabb()
	for i in 8:
		bbox_points.append( bounding_box.get_endpoint(i)  )
		
	aoi_handler.__set_aoi_type("Goat")
	%on_screen_debug.__set_bbox_color(Color.RED)
	
	%Label3D.text = name

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
		update_on_screen_bbox(true)

	%CanvasLayer.visible = globals.debug
	%Label3D.visible = globals.debug

func update_on_screen_bbox(active:bool) ->void:
	var bounding_box:Rect2 = Rect2()
	for camera_id in globals.cameras.size():
		bounding_box = Rect2() 
		bounding_box.position = globals.cameras[camera_id].unproject_position(%MeshInstance3D.global_position) 
		
		for i in bbox_points.size():
			if not globals.cameras[camera_id].is_position_in_frustum(%MeshInstance3D.to_global(bbox_points[i])):
				continue
			bounding_box = bounding_box.expand(globals.cameras[camera_id].unproject_position(%MeshInstance3D.to_global(bbox_points[i])))
		
		bounding_box = get_truncated_bbox_to_vieport_rect(bounding_box, camera_id)
		
		if bounding_box.size.x * bounding_box.size.y > 16:
			%on_screen_debug.__update_rect_for_camera(bounding_box)
			aoi_handler.add_aoi(bounding_box, camera_id, active)
			is_on_specific_screen[camera_id] = true
			last_bounding_box = bounding_box
		else:
			if is_on_specific_screen[camera_id]:
				aoi_handler.add_aoi(last_bounding_box, camera_id, false)
				is_on_specific_screen[camera_id] = false

func get_truncated_bbox_to_vieport_rect(bounding_box:Rect2, camera_id:int)->Rect2:
	var vieport_size = get_viewport().size * 0.5
	var vieport_rect = Rect2(Vector2.ZERO, vieport_size)
	bounding_box = bounding_box.intersection(vieport_rect)
#	var vieport_offset = Vector2( (floori(camera_id/2.0))%2, camera_id%2)
	bounding_box.position += globals.cameras_offeset[camera_id] * vieport_size
	return bounding_box

#func update_on_screen_rect_1():
#	var bounding_rect:Rect2 = Rect2()
#	for camera_id in globals.cameras.size():
#		bounding_rect = Rect2() 
#		bounding_rect.position = globals.cameras[camera_id].unproject_position(%MeshInstance3D.global_position)
#		for vertex_id in range(mesh_tool.get_vertex_count()):
#			bounding_rect = bounding_rect.expand(globals.cameras[camera_id].unproject_position(%MeshInstance3D.to_global(mesh_tool.get_vertex(vertex_id))))
#		on_screen_debug.update_rect_for_camera(bounding_rect, camera_id, Color.YELLOW)


func idle(delta)->void:
	if time < WAIT_TIME:
		time += delta
	else:
		state = STATE_CHASE
		time = 0;

func chase(_delta)->void:
	var distance = self.position.distance_to(target.position)
		
	var direction = target.position - self.position
	direction = direction.normalized()
	direction.y = 0
	
	look_at(target.position, Vector3(0,1,0))
	
	if distance > RUN_DISTANCE:
		offset = MOVE_SPEED_CHASE * globals.difficulty
		set_velocity(direction * offset)
		move_and_slide()
		position.y = origin_position.y
		%exclamation_mark.modulate = Color(1,1,1,  (RUN_DISTANCE - clamp(distance- (RUN_DISTANCE_2), 0, RUN_DISTANCE)) / RUN_DISTANCE ) 
	else:
		%exclamation_mark.modulate = Color(1,1,1,0)
		offset = MOVE_SPEED_RUN
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

func back(_delta)->void:
	var direction = origin_position - self.position
	
#	get_node("steps/Steps_" + str( randi() % 12 + 1 ) ).play()
	
	if direction.length_squared() >1:
		direction = direction.normalized()
		look_at(origin_position, Vector3(0,1,0))
		offset = MOVE_SPEED_WALK
		direction.y = 0
		set_velocity(direction * offset)
		move_and_slide()
		position.y = origin_position.y
		
func bounce()->void:
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

func _on_visible_on_screen_notifier_3d_screen_exited():
	is_on_screen = false
	update_on_screen_bbox(false)

func _exit_tree():
	aoi_handler.__push_log()

