extends Node3D

var velocity = Vector3()
var rotation_velocity = Vector3()
var gravity  = Vector3(0,-18.0, 0)

func _ready():
	randomize()
	velocity.x = randf_range(-18.0,18.0)
	velocity.y = randf_range(18.0,24.0)
	velocity.z = randf_range(-18.0,18.0)
	rotation_velocity.x = randf_range(-6.0,6.0)
	rotation_velocity.y = randf_range(-6.0,6.0)
	rotation_velocity.z = randf_range(-6.0,6.0)
	
	rotation.x = randf_range(0,TAU)
	rotation.y = randf_range(0,TAU)
	rotation.z = randf_range(0,TAU)

func _physics_process(delta):
	velocity *= 0.98
	velocity += gravity * delta
	position += velocity * delta
	rotation += rotation_velocity * delta
	if position.y < -3:
		queue_free()
