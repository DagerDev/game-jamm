extends Control


func on_play() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")


func on_exist() -> void:
	get_tree().quit()


func _on_credit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/The_Team.tscn")
