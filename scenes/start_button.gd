extends Button

func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	var underline = find_child("Underline") as Panel  # Find the underline panel
	if underline:  # Make sure it exists
		underline.visible = true

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	var underline = find_child("Underline") as Panel
	if underline:
		underline.visible = false

func _on_pressed():
	if name == "StartButton":
		print("The start button was clicked")
		get_tree().change_scene_to_file("res://scenes/world.tscn")
	elif name == "ExitButton":
		print("The exit button was clicked")
		get_tree().quit()
	# ... more buttons if needed
