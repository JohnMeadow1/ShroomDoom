extends Node

var frame: int = 0
var time_stamp: float = 0.0
var time_stamp_start: float = 0.0
var shroom_position_log: = {}
var frame_log: = {}

# {
#   1: {"time_stamp": 0.0, "shrooms": ["shroom1"]}, 
#   2: {"time_stamp": 0.0, "shrooms": []}
# }

func start_log():
	frame = 0
	time_stamp = 0.0
	time_stamp_start = Time.get_ticks_msec()
	shroom_position_log.clear()
	frame_log.clear()

func add_frame():
	frame += 1
	shroom_position_log[frame] = {"time_stamp": (Time.get_ticks_msec() - time_stamp_start), "shrooms" : frame_log.duplicate()}
	frame_log.clear()


func add_shroom(shroom: Node3D):
	print(shroom.name)
	frame_log[shroom.name] = shroom.global_position

func save_logs():
	var save_log = FileAccess.open("user://shroom_log%d.json" % time_stamp_start, FileAccess.WRITE)
	save_log.store_string(JSON.stringify(shroom_position_log))
	save_log.close()
