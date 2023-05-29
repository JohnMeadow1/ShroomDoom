@tool
extends EditorScript

var path := "Final_aois_player_2023-05-29_18-41-31"
var event_enter_pressed := 8956022
var event_recording_start := 6056022

var start_offset_usec := event_enter_pressed - event_recording_start
var start_offset_sec := 0.0

var shroom_a := {
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
var shroom_b := shroom_a.duplicate(true)
var shroom_c := shroom_a.duplicate(true)
var shroom_d := shroom_a.duplicate(true)
var is_shroom:= false

func _run():
	start_offset_sec = start_offset_usec / 1000000.0
	is_shroom = path.contains("shroom")
#	print(start_offset_sec)

	var data := {}
	var file = FileAccess.open("user://"+path+".aois", FileAccess.READ)
	var error = FileAccess.get_open_error()
	if error != OK:
		printerr("open file error: ", error)
	else:
		data = JSON.parse_string(file.get_as_text())
	data.Media.DurationMicroseconds += start_offset_usec
	
	for i in data.Aois.size():
		for j in data.Aois[i].KeyFrames.size():
			data.Aois[i].KeyFrames[j].Seconds = data.Aois[i].KeyFrames[j].Seconds + start_offset_sec
			
		if is_shroom:
			match data.Aois[i].Name[0]:
				"a":
					shroom_a.Aois.append(data.Aois[i].duplicate(true))
				"b":
					shroom_b.Aois.append(data.Aois[i].duplicate(true))
				"c":
					shroom_c.Aois.append(data.Aois[i].duplicate(true))
				"d":
					shroom_d.Aois.append(data.Aois[i].duplicate(true))
				
	var save_log = FileAccess.open("user://"+path+"_fixed.aois", FileAccess.WRITE)
	save_log.store_string(JSON.stringify(data))
	save_log.close()

	if is_shroom:
		shroom_a.Media.DurationMicroseconds = data.Media.DurationMicroseconds
		shroom_b.Media.DurationMicroseconds = data.Media.DurationMicroseconds
		shroom_c.Media.DurationMicroseconds = data.Media.DurationMicroseconds
		shroom_d.Media.DurationMicroseconds = data.Media.DurationMicroseconds
		
		save_log = FileAccess.open("user://"+path+"_fixed_a.aois", FileAccess.WRITE)
		save_log.store_string(JSON.stringify(shroom_a))
		save_log.close()

		save_log = FileAccess.open("user://"+path+"_fixed_b.aois", FileAccess.WRITE)
		save_log.store_string(JSON.stringify(shroom_b))
		save_log.close()

		save_log = FileAccess.open("user://"+path+"_fixed_c.aois", FileAccess.WRITE)
		save_log.store_string(JSON.stringify(shroom_c))
		save_log.close()
		
		save_log = FileAccess.open("user://"+path+"_fixed_d.aois", FileAccess.WRITE)
		save_log.store_string(JSON.stringify(shroom_d))
		save_log.close()
