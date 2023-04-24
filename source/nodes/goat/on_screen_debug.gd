extends Node2D

var bounding_box: Rect2 = Rect2()
var update: bool = false

func _physics_process(delta):
	queue_redraw()

func _draw():
	if update:
		draw_rect(bounding_box, Color.GREEN, false)
		update = false
	else:
		set_physics_process(false)
		
func _update_rect_for_camera(new_bounding_box:Rect2):
	bounding_box = new_bounding_box
	update = true
	set_physics_process(true)
