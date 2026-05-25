extends Control

@onready var master_slider = %Master
@onready var music_slider = %Music
@onready var sfx_slider = %SFX
@onready var menu = $VBoxContainer
@onready var settings = $Settings

var menu_start_pos

func _ready():
	menu_start_pos = menu.position
	settings.visible = false
	settings.modulate.a = 0
	
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)


func _on_settings_button_pressed():
	settings.visible = true
	var tween = create_tween()

	# menu slides left + fades
	tween.parallel().tween_property(
		menu,
		"position:x",
		menu.position.x - 300,
		0.4
		)
	tween.parallel().tween_property(
		menu,
		"modulate:a",
		0.0,
		0.4
		)

	# settings fades in
	tween.parallel().tween_property(
		settings,
		"modulate:a",
		1.0,
		0.4
		)


func _on_back_button_pressed():
	var tween = create_tween()

	# menu returns
	tween.parallel().tween_property(
		menu,
		"position",
		menu_start_pos,
		0.4
		)
		
	tween.parallel().tween_property(
		menu,
		"modulate:a",
		1.0,
		0.4
	)

	# settings fades out
	tween.parallel().tween_property(
		settings,
		"modulate:a",
		0.0,
		0.4
	)
	
	tween.finished.connect(_hide_settings)


func _hide_settings():
	settings.visible = false



func on_play() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")


func on_exist() -> void:
	get_tree().quit()


func _on_credit_pressed() -> void:
<<<<<<< HEAD
	get_tree().change_scene_to_file("res://scenes/The_Team.tscn")
=======
	pass


func _on_master_changed(value):
	set_bus_volume("Master", value)

func _on_music_changed(value):
	set_bus_volume("Music", value)

func _on_sfx_changed(value):
	set_bus_volume("SFX", value)

func set_bus_volume(bus_name, value):
	var bus_index = AudioServer.get_bus_index(bus_name)

	# Prevent log(0)
	if value <= 0.001:
		AudioServer.set_bus_volume_db(bus_index, -80)
	else:
		AudioServer.set_bus_volume_db(
			bus_index,
			linear_to_db(value)
			)
>>>>>>> 8e273ad (main menu settings)
