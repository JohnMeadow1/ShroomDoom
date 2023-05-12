extends Node

var thread

var is_initialized: bool = false
var frame: int = 0
var time_stamp: float = 0.0
var time_stamp_start: float = 0.0
var shroom_log: = {}

var frame_player_log: = {}

var frame_shroom_log: = {}
var frame_shroom_idx: = 0

var frame_goat_log: = {}
var frame_goat_idx: = 0

var bbox_to_draw: = []
var bbox_count: = 0

# {
#   1: {"time_stamp": 0.0, "shrooms": ["shroom1"]}, 
#   2: {"time_stamp": 0.0, "shrooms": []}
# }
# TODO -------------------------
# initial time
# key logging
# -------------------------
#28.04.2023	11:43:05.364	09:43:05.364
	
func start_log():
	if !is_initialized:
		is_initialized = true
		for i in 1000:
			bbox_to_draw.append( Rect2() )
	frame = 0
	time_stamp = 0.0
	frame_shroom_idx = 0
	time_stamp_start = Time.get_ticks_msec()
	shroom_log.clear()
	frame_shroom_log.clear()


func add_frame():
	shroom_log[Time.get_unix_time_from_system()] = {"p" : frame_player_log.duplicate(), "g" : frame_goat_log.duplicate(), "s" : frame_shroom_log.duplicate()}
	frame_shroom_log.clear()
	frame_player_log.clear()
	frame_goat_log.clear()
	frame_goat_idx = 0
	frame_shroom_idx = 0
	frame += 1
	bbox_count = 0

func add_player_position_velocity(player: int, position:Vector2, velocity:Vector2 ):
	frame_player_log[player] = {"p":position, "v":velocity}

func add_player_input(player: int, input:String):
	if not frame_player_log.has(player):
		frame_player_log[player] = {"p":"", "v":""}
	if not frame_player_log[player].has("s"):
		frame_player_log[player]["s"] = []
	frame_player_log[player]["s"].append(input)

func add_goat_position_velocity(position:Vector2, velocity:Vector2):
	frame_goat_log[frame_goat_idx] = Rect2(position, velocity)
	frame_goat_idx += 1
	
func add_shroom_position(position: Vector2):
	frame_shroom_log[frame_shroom_idx] = position
	frame_shroom_idx += 1


func add_bbox(new_rect:Rect2, camera_id:int):
	bbox_to_draw[bbox_count] = new_rect
	bbox_count += 1

func save_logs():
#	var store_data_callable = Callable(self, "_store_data")
	thread = Thread.new()
	thread.start(_store_data)
	_store_data()
	
func _store_data():
	var save_log = FileAccess.open("user://shroom_log_%s_%s.json" % [Time.get_date_string_from_system(), (Time.get_time_string_from_system()).replace(":","-")], FileAccess.WRITE)
	save_log.store_string(JSON.stringify(shroom_log))
	save_log.close()

func _exit_tree():
	if thread:
		thread.wait_to_finish()
