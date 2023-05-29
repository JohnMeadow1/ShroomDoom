extends Node2D

var bounding_box := [Rect2(), Rect2(), Rect2(), Rect2()]
var bounding_box_color := PackedColorArray([Color.GHOST_WHITE,Color.GHOST_WHITE,Color.GHOST_WHITE,Color.GHOST_WHITE])
var bounding_box_count := 0
var update := false
var color := Color.WHITE

func _physics_process(_delta):
	queue_redraw()

func _draw():
	if update:
		for i in bounding_box_count:
			draw_rect(bounding_box[i], bounding_box_color[i], false)
			bounding_box_color[i].a = 0.2
			draw_rect(bounding_box[i], bounding_box_color[i], true)
		bounding_box_count = 0
		update = false
	else:
		set_physics_process(false)
		
func __set_bbox_color(new_color) -> void:
	color = new_color
	
func __update_rect_for_camera(new_bounding_box:Rect2):
	if globals.debug and bounding_box_count < 4:
		bounding_box[bounding_box_count] = new_bounding_box
		bounding_box_color[bounding_box_count] = color
#		match cam_id:
#			0: bounding_box_color[bounding_box_count] = Color.WHITE
#			1: bounding_box_color[bounding_box_count] = Color.RED
#			2: bounding_box_color[bounding_box_count] = Color.GREEN
#			3: bounding_box_color[bounding_box_count] = Color.BLUE
			
		bounding_box_count += 1
		update = true
		set_physics_process(true)

