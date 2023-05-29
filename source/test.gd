@tool
extends EditorScript

var aoi := {
	"Blue": 0,
	"Green": 0,
	"Red": 255,
#	"Tags": [],
	"Name": "",
	"KeyFrames": [
	]
}
func _run():
	aoi.Name = "1"
	var aoi_2 = aoi.duplicate()
	var aoi_3 = aoi.duplicate()
	var aoi_4 = aoi.duplicate()
	aoi_2.Name = "2"
	aoi_3.Name = "3"
	aoi_4.Name = "4"
	var aoi_array:= [aoi, aoi_2, aoi_3, aoi_4] 
	print(aoi_array)
