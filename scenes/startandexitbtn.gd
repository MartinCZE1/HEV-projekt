extends Button

func _ready():
	match name:
		"StartButton":
			connect("pressed", Callable(self, "_on_start_pressed"))
			
		"ExitButton":
			connect("pressed", Callable(self, "_on_exit_pressed"))
	
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))


func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	var underline = find_child("Underline") as Panel
	if underline != null:
		underline.visible = true

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	var underline = find_child("Underline") as Panel
	if underline != null:
		underline.visible = false

func _on_start_pressed():
	print("The start button was clicked")
	if get_tree() != null:
		get_tree().change_scene_to_file("res://scenes/world.tscn")
	else:
		printerr("Error: SceneTree is null when trying to change scene.")

func _on_exit_pressed():
	print("The exit button was clicked")
	if get_tree() != null:
		get_tree().quit()
	else:
		printerr("Error: SceneTree is null when trying to quit.")


func _on_pressed() -> void:
	pass
