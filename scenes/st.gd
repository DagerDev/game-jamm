extends CanvasLayer



func _on_button_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/mainmenu/mainmenu.tscn")
