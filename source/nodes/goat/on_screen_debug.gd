extends Node2D

var bounding_box: = [Rect2(), Rect2(), Rect2(), Rect2()]
var bounding_box_count := 0
var update: bool = false

func _physics_process(delta):
#	prints(get_parent().get_parent().name, "queue_redraw")
	queue_redraw()

func _draw():
	if update:
		for i in bounding_box_count:
			draw_rect(bounding_box[i], Color.GREEN, false)
		bounding_box_count = 0
		update = false
	else:
#		bounding_box_count = 0
		set_physics_process(false)
		
func _update_rect_for_camera(new_bounding_box:Rect2):
	if bounding_box_count >= 4:
		return
	bounding_box[bounding_box_count] = new_bounding_box
	bounding_box_count += 1
	update = true
	set_physics_process(true)

