extends StaticBody

var shroom_object  = load("res://objects/shroom.tscn")
var growing_timer  = 0
var growing_shroom = null
var growth_speed   = 10

func _ready():
	randomize()
	var shrooms = max(0, randi() % 30 - 25)
	if shrooms > 0 :
		for i in range( shrooms ):
			spawn_shroom(rand_range(3,7))

	
func _physics_process(delta):
	if growing_timer > 0:
		growing_timer-= delta
		grow_shroom()
		
	if $Shrooms.get_child_count() < 5:
		if randi() % 10000 < 2:
			growth_speed   = rand_range(8,10)
			growing_timer  = 1
			growing_shroom = spawn_shroom(0)
		
	
func spawn_shroom(size):
	var new_shroom            = shroom_object.instance()
	new_shroom.translation    = self.global_transform.origin
	new_shroom.translation.x += rand_range(1,5) * (( randi() % 2 ) * 2 - 1)
	new_shroom.translation.z += rand_range(1,5) * (( randi() % 2 ) * 2 - 1)
	new_shroom.size           = size
#	new_shroom.get_node("MeshInstance").material_override = SpatialMaterial.new()
	$Shrooms.add_child( new_shroom )
	return new_shroom

func grow_shroom():
	growing_shroom.size += (1 - growing_timer) / 10
	
