extends Spatial

var velocity = Vector3()
var rotation_velocity = Vector3()
var gravity  = Vector3(0,-0.04, 0)

func _ready():
	randomize()
	velocity.x = rand_range(-0.5,0.5)
	velocity.y = rand_range(0.5,0.7)
	velocity.z = rand_range(-0.5,0.5)
	rotation_velocity.x = rand_range(-0.1,0.1)
	rotation_velocity.y = rand_range(-0.1,0.1)
	rotation_velocity.z = rand_range(-0.1,0.1)
	
	rotation.x = rand_range(0,360)
	rotation.y = rand_range(0,360)
	rotation.z = rand_range(0,360)


func _physics_process(delta):
	velocity += gravity
	translation += velocity
	rotation +=rotation_velocity
	if translation.y < -3:
		queue_free()
	pass
