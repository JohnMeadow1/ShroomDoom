extends Node3D

var velocity = Vector3()
var rotation_velocity = Vector3()
var gravity  = Vector3(0,-64.0, 0)

func _ready():
	randomize()
	var angle = randf() * TAU 
	var force = randf_range(2.0, 4.0)
	velocity.x = sin(angle) * force
	velocity.z = cos(angle) * force
	velocity.y = randf_range(18.0,24.0)
	rotation_velocity.x = randf_range(-6.0,6.0)
	rotation_velocity.y = randf_range(-6.0,6.0)
	rotation_velocity.z = randf_range(-6.0,6.0)
	
	rotation.x = randf_range(0,TAU)
	rotation.y = randf_range(0,TAU)
	rotation.z = randf_range(0,TAU)

func _physics_process(delta):
#	velocity *= 0.98
	velocity += gravity * delta
	position += velocity * delta
	rotation += rotation_velocity * delta
	if position.y < -2:
		queue_free()
