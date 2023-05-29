extends Node
class_name AOI_handler
# aoi - Area Of Interest
enum {TYPE_SHROOM, TYPE_GOAT, TYPE_PLAYER}

var aoi_template := {
	"Blue": 255,
	"Green": 255,
	"Red": 255,
#	"Tags": [],
	"Name": "",
	"KeyFrames": [
#		{
#			"IsActive": false,
#			"Seconds": 0.0,
#			"Vertices": [
#				{"X": 0.0, "Y": 0.0},
#				{"X": 1.0, "Y": 0.0},
#				{"X": 1.0, "Y": 1.0},
#				{"X": 0.0, "Y": 1.0}
#			]
#		}
	]
}
var aois_set := [{},{},{},{}]

var aoi_type := 0


func _init(object_name:String):
	aois_set[0] = aoi_template.duplicate(true)
	aois_set[0].Name = "a_"+object_name
	aois_set[1] = aoi_template.duplicate(true)
	aois_set[1].Name = "b_"+object_name
	aois_set[2] = aoi_template.duplicate(true)
	aois_set[2].Name = "c_"+object_name
	aois_set[3] = aoi_template.duplicate(true)
	aois_set[3].Name = "d_"+object_name

func add_aoi(bbox:Rect2, camera_id:int, active:bool) -> void :
	bbox.position = bbox.position.round()
	bbox.size = bbox.size.round()
	var new_aoi = {
			"IsActive": active,
			"Seconds": logging.time_elapsed_sec,
			"Vertices": [
				{"X": bbox.position.x, "Y": bbox.position.y},
				{"X": bbox.position.x + bbox.size.x, "Y": bbox.position.y},
				{"X": bbox.position.x + bbox.size.x, "Y": bbox.position.y + bbox.size.y},
				{"X": bbox.position.x, "Y": bbox.position.y + bbox.size.y}
			]
		}
	if aois_set[camera_id].KeyFrames.size() > 0:
		aois_set[camera_id].KeyFrames[aois_set[camera_id].KeyFrames.size()-1].IsActive = true
	aois_set[camera_id].KeyFrames.append(new_aoi)

func set_aoi_color(color:Color):
	for i in 4:
		aois_set[i].Red   = int(color.r*255)
		aois_set[i].Green = int(color.g*255)
		aois_set[i].Blue  = int(color.b*255)

func __set_aoi_type(new_type:String):
	match new_type:
		"Shroom":
			set_aoi_color(Color.GREEN)
			aoi_type = 0
		"Goat":
			set_aoi_color(Color.RED)
			aoi_type = 1
		"Player":
			set_aoi_color(Color.BLUE)
			aoi_type = 2

func __push_log():
	match aoi_type:
		TYPE_SHROOM:
			for i in 4:
				if aois_set[i].KeyFrames.size() > 0:
					logging.add_shroom_aoi(aois_set[i])
		TYPE_GOAT:
			for i in 4:
				if aois_set[i].KeyFrames.size() > 0:
					logging.add_goat_aoi(aois_set[i])
		TYPE_PLAYER:
			for i in 4:
				if aois_set[i].KeyFrames.size() > 0:
					logging.add_player_aoi(aois_set[i])
