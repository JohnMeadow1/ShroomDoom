extends Decal

func _ready():
	get_child(0).queue_free()
