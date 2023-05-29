extends Node3D

var pickable        := false
var max_size        := 20.0
var growth_rate     := 0.6
var shroom_material := [preload("res://nodes/pickable/model/points_shroom_3.material"),preload("res://nodes/pickable/model/points_shroom_4.material") ]

var is_on_screen    := false
var is_on_specific_screen := [false,false,false,false]

var bbox_points := PackedVector3Array()
var last_bounding_box := Rect2()

@onready var mesh = $MeshInstance3D
@onready var aoi_handler := AOI_handler.new("shroom"+str(globals.spawned_shroom))

func _ready():
	mesh.rotation.y        = randf_range(0,360)
	mesh.material_override = shroom_material[randi()%2]
	%groans.play()
	aoi_handler.__set_aoi_type("Shroom")
	%on_screen_debug.__set_bbox_color(Color.GREEN)
	%Label3D.text = str("Shroom_", globals.spawned_shroom)
	
#	mesh.scale = Vector3.ONE * 20
#	var bounding_box: AABB = mesh.get_aabb()
#	bounding_box = bounding_box.grow(1)
#	for i in 8:
#		b_box_points.append( bounding_box.get_endpoint(i)  )
	
func _physics_process(delta):
	logging.add_shroom_position( Vector2(global_position.x,global_position.z) )
	if mesh.scale.x < max_size:
		mesh.scale += Vector3.ONE * growth_rate * delta
		
	if is_on_screen:
		update_on_screen_bbox(true)
		
	%CanvasLayer.visible = globals.debug
	%Label3D.visible = globals.debug

func update_on_screen_bbox(active:bool):
	var bounding_box:Rect2 = Rect2()
	for camera_id in globals.cameras.size():
		bounding_box = Rect2() 
		bounding_box.position = globals.cameras[camera_id].unproject_position(global_position) 
		for marker in mesh.get_children():
			if not globals.cameras[camera_id].is_position_in_frustum(marker.global_position):
				continue
			bounding_box = bounding_box.expand(globals.cameras[camera_id].unproject_position(marker.global_position))

		bounding_box = get_truncated_bbox_to_vieport_rect(bounding_box, camera_id)

		if bounding_box.size.x * bounding_box.size.y > 16:
			%on_screen_debug.__update_rect_for_camera(bounding_box)
			aoi_handler.add_aoi(bounding_box, camera_id, active)
			is_on_specific_screen[camera_id] = true
			last_bounding_box = bounding_box
		else:
			if is_on_specific_screen[camera_id]:
				is_on_specific_screen[camera_id] = false
				aoi_handler.add_aoi(last_bounding_box, camera_id, false)

func get_truncated_bbox_to_vieport_rect(bounding_box:Rect2, camera_id:int):
	var vieport_size = get_viewport().size * 0.5
	var vieport_rect = Rect2(Vector2.ZERO, vieport_size)
	bounding_box = bounding_box.intersection(vieport_rect)
#	var vieport_offset = Vector2( (floori(camera_id/2.0))%2, camera_id%2)
	bounding_box.position += globals.cameras_offeset[camera_id] * vieport_size
	return bounding_box

func _on_Area_body_entered(body):
	if body.is_in_group("players"):
		pickable = true
		add_to_group("pickables"+str(body.PLAYER_NUM))

func _on_Area_body_exited(body):
	if body.is_in_group("players"):
		remove_from_group("pickables"+str(body.PLAYER_NUM))
		if is_in_group("pickables1") || is_in_group("pickables2") || is_in_group("pickables3") || is_in_group("pickables4"):
			pass
		else: 
			pickable = false

func _on_visible_on_screen_notifier_3d_screen_entered():
	is_on_screen = true

func _on_visible_on_screen_notifier_3d_screen_exited():
	is_on_screen = false
	update_on_screen_bbox(false)

func _exit_tree():
	aoi_handler.__push_log()
	

