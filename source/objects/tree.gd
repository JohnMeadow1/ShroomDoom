extends StaticBody

var shroom_object = load("res://objects/shroom.tscn")

func _ready():
	randomize()

	for i in range( max(0, randi() % 10 - 5) ):
		spawn_shroom()

	
func _physics_process(delta):
	
	pass
	
func spawn_shroom():
	var new_shroom = shroom_object.instance()
	new_shroom.translation = translation 
	new_shroom.translation.x += rand_range(1,5) * (( randi() % 2 ) * 2 - 1)
	new_shroom.translation.z += rand_range(1,5) * (( randi() % 2 ) * 2 - 1)

	$Shrooms.add_child( new_shroom )

func grow_shroom():
	pass
	
