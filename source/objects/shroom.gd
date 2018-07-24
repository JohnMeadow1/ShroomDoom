extends Spatial

var pickable        = false
var blink_value     = 1
var blink_iterattor = 1
var size            = 0
var max_size        = 20
var growth_rate     = 0.01
var grow_target     = 0
var growing_timer   = 1
var shroom_material = [preload("res://objects/Textures/shroom1.material"),preload("res://objects/Textures/shroom2.material") ]

func _ready():
	$MeshInstance.rotation.y        = rand_range(0,360)
	$MeshInstance.material_override = shroom_material[randi()%2]

func _physics_process(delta):
	if growing_timer > 0:
		growing_timer-= delta
		size += (1  - growing_timer) / 10
		
	elif size < max_size:
		size += growth_rate
		$MeshInstance.scale = Vector3(size,size,size)
		
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
func play_sound():
	get_node("Groan/Groan_"+str(randi()%4+1)).play()
	