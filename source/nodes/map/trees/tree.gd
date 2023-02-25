extends StaticBody3D

var shroom_object  = load("res://nodes/pickable/points_shroom.tscn")
var growing_timer  = 0.0
var growing_shroom = null
var growth_speed   = 10.0

func _ready():
	randomize()
	var shrooms = max(0.0, int(float(randi() % 30) / 10.0 -10.0))
	if shrooms > 0 :
		for i in range( shrooms ):
			spawn_shroom()

func _physics_process(_delta):
	if $Shrooms.get_child_count() < 3:
		if randi() % 10000 < 2:
			spawn_shroom()

func spawn_shroom():
	var new_shroom         = shroom_object.instantiate()
	new_shroom.position    = self.global_transform.origin
	new_shroom.position.x += randf_range(1,5) * (( randi() % 2 ) * 2 - 1)
	new_shroom.position.z += randf_range(1,5) * (( randi() % 2 ) * 2 - 1)
#	new_shroom.get_node("MeshInstance3D").material_override = StandardMaterial3D.new()
	$Shrooms.add_child( new_shroom )

func grow_shroom():
	growing_shroom.size += (1.0  - growing_timer) / 10.0
	
