extends TextureButton


func _pressed():
	pass

func _on_mouse_entered():
	self.grab_focus()

func _on_mouse_exited():
	self.release_focus()

func _on_exit():
	get_tree().quit()

func _on_Start():
	get_tree().change_scene("res://viewports.tscn")
