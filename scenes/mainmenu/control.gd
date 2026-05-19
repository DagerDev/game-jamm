extends Control


func on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func on_exist() -> void:
	get_tree().quit()
