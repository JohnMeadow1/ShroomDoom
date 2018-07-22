extends TextureButton


var buttons = null
var current_button = 0

func _ready():
	self.buttons = [self, $TextureButton2, $TextureButton]

func _physics_process(delta):
	if Input.is_action_just_pressed("move_up_p1"):
		self.current_button = (self.current_button - 1) % 3
		self.buttons[self.current_button].grab_focus()
		
	if Input.is_action_just_pressed("move_down_p1"):
		self.current_button = (self.current_button + 1) % 3
		self.buttons[self.current_button].grab_focus()
	
	if Input.is_action_just_pressed("use_p1"):
		self.buttons[self.current_button]._pressed()

func _pressed():
	pass

func _on_mouse_entered():
	self.grab_focus()

func _on_mouse_exited():
	self.release_focus()

func _on_exit():
	get_tree().quit()

func _on_Start():
	get_tree().change_scene("res://viewports/viewports.tscn")
