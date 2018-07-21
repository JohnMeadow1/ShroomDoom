extends StaticBody

var shroom_object = load("res://objects/shroom.tscn")

func _ready():
	randomize()
	var shrooms = max(0, randi() % 30 - 25)
	if shrooms >0 :
		for i in range( shrooms ):
			spawn_shroom()

	
func _physics_process(delta):
	
	pass
	
func spawn_shroom():
	var new_shroom = shroom_object.instance()
	new_shroom.translation = self.global_transform.origin
	new_shroom.translation.x += rand_range(1,5) * (( randi() % 2 ) * 2 - 1)
	new_shroom.translation.z += rand_range(1,5) * (( randi() % 2 ) * 2 - 1)
	new_shroom.get_node("MeshInstance").material_override = SpatialMaterial.new()
	$Shrooms.add_child( new_shroom )

func grow_shroom():
	pass
	
