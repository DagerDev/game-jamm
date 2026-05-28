extends Control

@onready var master_slider = %Master
@onready var music_slider = %Music
@onready var sfx_slider = %SFX
@onready var menu = $VBoxContainer
@onready var settings = $Settings
@onready var background= $L1
@onready var credits = $V1

var menu_start_pos
var start_size
var targetS
var target_size := Vector2(2, 2)

func _ready():
	menu_start_pos = menu.position
	start_size = background.size
	settings.position = menu_start_pos
	settings.visible = false
	credits.visible = false
	credits.modulate.a = 0
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
		"position",
		menu_start_pos,
		0.4
		)
		
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
		"position:x",
		menu.position.x - 300,
		0.4
		)
	tween.parallel().tween_property(
		settings,
		"modulate:a",
		0.0,
		0.4
		)

func on_play() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")


func on_exist() -> void:
	get_tree().quit()


func _on_credit_pressed() -> void:
	credits.visible = true
	var tween = create_tween()
	
	tween.parallel().tween_property(
		background,
		"scale",
		 target_size,
		0.5
	)
	
	tween.parallel().tween_property(
		background,
		"modulate",
		Color(),
		0.4
	)
	
	tween.parallel().tween_property(
		credits,
		"modulate:a",
		1.0,
		0.7
	)
	


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
