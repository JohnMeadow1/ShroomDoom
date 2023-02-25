extends Node3D

var pickable        = false
var size            = 5.0
var max_size        = 20
var growth_rate     = 0.6
var shroom_material = [preload("res://nodes/pickable/model/points_shroom_3.material"),preload("res://nodes/pickable/model/points_shroom_4.material") ]

func _ready():
	$MeshInstance3D.rotation.y        = randf_range(0,360)
	$MeshInstance3D.set_surface_override_material(0, shroom_material[randi()%2])
	%groans.play()
	set_physics_process(false)
	
func _physics_process(delta):
	if size < max_size:
		size += growth_rate * delta
		$MeshInstance3D.scale = Vector3(size,size,size)
	else:
		set_physics_process(false)
		
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
