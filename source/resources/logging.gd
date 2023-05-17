extends Node

var thread

var is_initialized: bool = false
var frame: int = 0
var time_stamp: float = 0.0
var time_stamp_start_msec: float = 0.0
var time_stamp_start_usec: float = 0.0
var time_elapsed_sec: float = 0.0
var shroom_log: = {}
var frame_time_sec := 0.0 
var frame_time_last_tic := 0.0 

var frame_player_log: = {
	"1": {
		"p": "(position_x, position_y)",
		"s": ["states (up, down, left, right, swing, score, check_victory, hits_player, gets_stunned, stunned, flying, died, flying, respawn)"
		],
		"v": "(velocity_x, velocity_y)" 
		}
	}

var frame_shroom_log: = {
	"0": "(position_x, position_y)",
	"1": "(position_x, position_y)"
	}

var frame_shroom_idx: = 0

var frame_goat_log: = {
	"0": {
		"p": "(position_x, position_y)",
		"v": "(velocity_x, velocity_y)"
	},
	"1": {
		"p": "(position_x, position_y)",
		"v": "(velocity_x, velocity_y)"
	}}
var frame_goat_idx: = 0

var aoi_log: = {
	"Aois": [],
	"Tags": [],
	"Media": {
		"MediaType": 1,
		"Height": 1080.0,
		"Width": 1920.0,
		"MediaCount": 1,
		"DurationMicroseconds": 0.0
	},
	"Version": 2
}
#		{
#			"Blue": 255,
#			"Green": 255,
#			"Red": 255,
#			"Tags": [],
#			"Name": "KOZA1",
#			"KeyFrames": [
#				{
#					"IsActive": false,
#					"Seconds": 0.0,
#					"Vertices": [
#						{
#							"X": 0,
#							"Y": 0
#						},{
#							"X": 1,
#							"Y": 0
#						},{
#							"X": 1,
#							"Y": 1
#						},{
#							"X": 0,
#							"Y": 1
#						}
#					]
#				}
#			]
#		},
#		{
#			"Blue": 255,
#			"Green": 255,
#			"Red": 255,
#			"Tags": [],
#			"Name": "Player1",
#			"KeyFrames": [
#				{
#					"IsActive": true,
#					"Seconds": 1.0,
#					"Vertices": [
#						{
#							"X": 0,
#							"Y": 0
#						},{
#							"X": 1,
#							"Y": 0
#						},{
#							"X": 1,
#							"Y": 1
#						},{
#							"X": 0,
#							"Y": 1
#						}
#					]
#				}
#			]
#		}
#	]
#}

var input_log := {}

func start_log():
	if !is_initialized:
		is_initialized = true
#		for i in 1000:
#			bbox_to_draw.append( Rect2() )
	frame = 0
	time_stamp = 0.0
	frame_shroom_idx = 0
	time_stamp_start_msec = Time.get_ticks_msec()
	time_stamp_start_usec = Time.get_ticks_usec()
	frame_time_last_tic = Time.get_ticks_msec()
	frame_time_sec = 0.0
	time_elapsed_sec = 0.0
	print("logging_started ", time_stamp_start_msec)

func add_frame():
	frame_time_sec = (Time.get_ticks_msec() - frame_time_last_tic) / 1000.0
	frame_time_last_tic = Time.get_ticks_msec()
	time_elapsed_sec = (Time.get_ticks_msec() - time_stamp_start_msec) / 1000.0
	shroom_log[Time.get_unix_time_from_system()] = {"player" : frame_player_log.duplicate(), "goat" : frame_goat_log.duplicate(), "shroom" : frame_shroom_log.duplicate()}
	frame_shroom_log.clear()
	frame_player_log.clear()
	frame_goat_log.clear()
	frame_goat_idx = 0
	frame_shroom_idx = 0
	frame += 1

func add_player_position_velocity(player: int, position:Vector2, velocity:Vector2 ):
#	if not frame_player_log.has(player):
	frame_player_log[player] = {"p":position, "v":velocity}
#	frame_player_log[player]["p"] = position
#	frame_player_log[player]["v"] = velocity

func add_player_input(player: int, input:String):
	if not frame_player_log.has(player):
		frame_player_log[player] = {"p":"", "v":""}
	if not frame_player_log[player].has("s"):
		frame_player_log[player]["s"] = []
	frame_player_log[player]["s"].append(input)

func add_goat_position_velocity(position:Vector2, velocity:Vector2):
	frame_goat_log[frame_goat_idx] = {"p":position, "v":velocity}
	frame_goat_idx += 1
	
func add_shroom_position(position: Vector2):
	frame_shroom_log[frame_shroom_idx] = position
	frame_shroom_idx += 1


#func add_bbox(new_rect:Rect2, color:Color):
#	frame_bbox_log[frame_bbox_count] = new_rect
#	frame_bbox_count += 1
func add_aoi(new_aoi:Dictionary):
	aoi_log["Aois"].append(new_aoi)

func add_input(input:String):
	var key = str(Time.get_unix_time_from_system())
	if not input_log.has(key):
		input_log[key] = []
	input_log[key].append( input )

func save_logs():
#	var store_data_callable = Callable(self, "_store_data")
	aoi_log.Media.DurationMicroseconds = Time.get_ticks_usec() - time_stamp_start_usec

	thread = Thread.new()
	thread.start(_store_data)
	print("save_logs start")
#	_store_data()
	
func get_test_name() -> String:
	var test_name = "missing_id_file"
	var id_file = FileAccess.open("user://id.txt", FileAccess.READ)
	var error = FileAccess.get_open_error()
	if error != OK:
		printerr("open file error: ", error)
	else:
		test_name = id_file.get_line()
		id_file.close()
	return test_name
	
func _store_data():
	print("save_logs thread started")
	var test_name = get_test_name()
	var date := Time.get_date_string_from_system()
	var time := (Time.get_time_string_from_system()).replace(":","-")
	var save_log = FileAccess.open("user://%s_%s_%s.json" % [test_name, date, time], FileAccess.WRITE)
	save_log.store_string(JSON.stringify(shroom_log))
	save_log.close()
	
	save_log = FileAccess.open("user://%s_aois_%s_%s.json" % [test_name, date, time], FileAccess.WRITE)
	save_log.store_string(JSON.stringify(aoi_log))
	save_log.close()

	save_log = FileAccess.open("user://%s_inputs_%s_%s.json" % [test_name, date, time], FileAccess.WRITE)
	save_log.store_string(JSON.stringify(input_log))
	save_log.close()

	shroom_log.clear()
	frame_shroom_log.clear()
	print("save_logs done")

func _exit_tree():
	if thread:
		thread.wait_to_finish()
