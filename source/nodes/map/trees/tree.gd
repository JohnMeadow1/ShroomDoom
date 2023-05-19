extends StaticBody3D

var shroom_object  = load("res://nodes/pickable/points_shroom.tscn")
var growing_timer  = 0.0
var growing_shroom = null
var growth_speed   = 10.0
@onready var timer := Timer.new()

func _ready():
	add_child(timer)
	timer.connect("timeout", spawn_shroom)
	randomize()
	var shrooms = max(0.0, int(float(randi() % 30) / 10.0 -1.0))
	if shrooms > 0 :
		for i in range( shrooms ):
			spawn_shroom()
	timer.start(randf_range(0, 68))
	
#func _physics_process(_delta):
#	if $Shrooms.get_child_count() < 3:
#		if randi() % 10000 < 2:
#			spawn_shroom()

func spawn_shroom():
	if $Shrooms.get_child_count() < 3 and randi()%2:
		var new_shroom         = shroom_object.instantiate()
		new_shroom.position    = self.global_transform.origin
		new_shroom.position.x += randf_range(1,5) * (( randi() % 2 ) * 2 - 1)
		new_shroom.position.z += randf_range(1,5) * (( randi() % 2 ) * 2 - 1)

		$Shrooms.add_child( new_shroom )
		globals.spawned_shroom += 1
	timer.start(randf_range(0, 68*globals.difficulty))

	
