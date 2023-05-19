extends Node3D

var pickable        := false
var max_size        := 20.0
var growth_rate     := 0.6
var shroom_material := [preload("res://nodes/pickable/model/points_shroom_3.material"),preload("res://nodes/pickable/model/points_shroom_4.material") ]
#var b_box_points  := PackedVector3Array([Vector3(1,2,-0.5), Vector3(-1,2,-0.5),Vector3(1,-0.5,0.6), Vector3(-1,-0.5, 0.6)])
#var b_box_points  := PackedVector3Array()
var is_on_screen := false

var aoi_count := 0
var aoi := {
	"Blue": 0,
	"Green": 255,
	"Red": 0,
#	"Tags": [],
	"Name": "Shroom",
	"KeyFrames": [
#		{
#			"IsActive": false,
#			"Seconds": 0.0,
#			"Vertices": [
#				{"X": 0.0, "Y": 0.0},
#				{"X": 1.0, "Y": 0.0},
#				{"X": 1.0, "Y": 1.0},
#				{"X": 0.0, "Y": 1.0}
#			]
#		}
	]
}
@onready var mesh = $MeshInstance3D

func _ready():
	mesh.rotation.y        = randf_range(0,360)
	mesh.material_override = shroom_material[randi()%2]
	%groans.play()
	aoi.Name += str(globals.spawned_shroom) 
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
		update_on_screen_rect(true)
		
	$CanvasLayer.visible = globals.debug

func update_on_screen_rect(active:bool):
	var bounding_rect:Rect2 = Rect2()
	for camera_id in globals.cameras.size():
		if not globals.cameras[camera_id].is_position_in_frustum(global_position):
			continue
		bounding_rect = Rect2() 
		bounding_rect.position = globals.cameras[camera_id].unproject_position(global_position) 
		for marker in mesh.get_children():
			bounding_rect = bounding_rect.expand(globals.cameras[camera_id].unproject_position(marker.global_position))
		var vieport_size = get_viewport().size * 0.5
		var vieport_rect = Rect2(Vector2.ZERO, vieport_size)
		bounding_rect = bounding_rect.intersection(vieport_rect)
		var vieport_offset = Vector2( (floori(camera_id/2.0))%2, camera_id%2)

		bounding_rect.position += vieport_offset * vieport_size
		if bounding_rect.size.length() > 4:
#			print(bounding_rect)
			%on_screen_debug._update_rect_for_camera(bounding_rect, camera_id, Color.GREEN)
			add_aoi(bounding_rect, active)

func add_aoi(bbox:Rect2, active:bool) ->void :
	bbox.position = bbox.position.round()
	bbox.size = bbox.size.round()
	var new_aoi = {
			"IsActive": active,
			"Seconds": logging.time_elapsed_sec,
			"Vertices": [
				{"X": bbox.position.x, "Y": bbox.position.y},
				{"X": bbox.position.x + bbox.size.x, "Y": bbox.position.y},
				{"X": bbox.position.x + bbox.size.x, "Y": bbox.position.y + bbox.size.y},
				{"X": bbox.position.x, "Y": bbox.position.y + bbox.size.y}
			]
		}
	aoi.KeyFrames.append(new_aoi)
	aoi_count += 1

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
	update_on_screen_rect(false)

func _exit_tree():
	if aoi_count > 0:
		logging.add_aoi(aoi)
	

