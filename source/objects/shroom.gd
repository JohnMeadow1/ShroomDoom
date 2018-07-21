extends MeshInstance

var pickable = false
var blink_value = 1
var blink_iterattor = 1

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _physics_process(delta):
	if pickable:
		blink_value -= delta * blink_iterattor
		if blink_value <= 0.5 || blink_value >= 1:
			blink_iterattor *=-1
			blink_value -= delta * blink_iterattor
		self.material_override.set("albedo_color", Color(blink_value,blink_value,blink_value))
#		set("albedo_color", Color(blink_value,blink_value,blink_value) )
#		print(Color(blink_value,blink_value,blink_value))


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
			self.material_override.set("albedo_color", Color(1,1,1) )
			pickable = false
