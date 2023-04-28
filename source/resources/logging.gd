extends Node

var frame: int = 0
var time_stamp: float = 0.0
var time_stamp_start: float = 0.0
var shroom_position_log: = {}

var frame_player_log: = {}
var frame_shroom_log: = {}
var frame_shroom_idx: = 0
var frame_goat_log: = {}
var frame_goat_idx: = 0
# {
#   1: {"time_stamp": 0.0, "shrooms": ["shroom1"]}, 
#   2: {"time_stamp": 0.0, "shrooms": []}
# }

func start_log():
	frame = 0
	time_stamp = 0.0
	frame_shroom_idx = 0
	time_stamp_start = Time.get_ticks_msec()
	shroom_position_log.clear()
	frame_shroom_log.clear()

func add_frame():
	shroom_position_log[frame] = {"t": (Time.get_ticks_msec() - time_stamp_start), "p" : frame_player_log.duplicate(), "g" : frame_goat_log.duplicate(), "s" : frame_shroom_log.duplicate()}
	frame_shroom_log.clear()
	frame_player_log.clear()
	frame_goat_log.clear()
	frame_goat_idx = 0
	frame_shroom_idx = 0
	frame += 1

func add_player(player: Node3D):
	frame_player_log[player.PLAYER_NUM] = player.global_position
	
func add_goat(goat: Node3D):
	frame_goat_log[frame_goat_idx] = goat.global_position
	frame_goat_idx += 1
	
func add_shroom(shroom: Node3D):
	frame_shroom_log[frame_shroom_idx] = shroom.global_position
	frame_shroom_idx += 1

func save_logs():
	var save_log = FileAccess.open("user://shroom_log%d.json" % time_stamp_start, FileAccess.WRITE)
	save_log.store_string(JSON.stringify(shroom_position_log))
	save_log.close()
