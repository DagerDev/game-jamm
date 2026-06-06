extends Control

@onready var master_slider = %Master
@onready var music_slider = %Music
@onready var sfx_slider = %SFX
@onready var menu = $VBoxContainer
@onready var settings = $Settings
@onready var background = $L1
@onready var credits = $V1
@onready var title = $Label

@onready var playBtn = %Play
@onready var creditBtn = %Credit
@onready var existBtn = %Exist
@onready var settingsBtn = %Settings

var menu_start_pos: Vector2
var background_start_pos: Vector2
var background_start_scale: Vector2
var title_start_pos: Vector2

var target_size := Vector2(1.3, 1.3)

var tween_menu: Tween
var tween_bg: Tween
var tween_credits: Tween
var tween_title: Tween
var tween_title_idle: Tween
var button_tweens := {}

var current_screen := "menu"
var transitioning := false
var hovered_button: Control = null

func _ready():
	menu_start_pos = menu.position
	background_start_pos = background.position
	background_start_scale = background.scale
	title_start_pos = title.position
	
	settings.position = menu_start_pos
	settings.visible = false
	settings.modulate.a = 0.0
	credits.visible = false
	credits.modulate.a = 0.0
	
	title.pivot_offset = title.size / 2
	
	# Init buttons - set margin_left to 0 first to avoid Nil error
	for btn in [playBtn, creditBtn, existBtn, settingsBtn]:
		btn.pivot_offset = btn.size / 2
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.add_theme_constant_override("margin_left", 0) # Fix: set initial value
		button_tweens[btn] = null
		btn.mouse_entered.connect(_on_btn_hover.bind(btn, true))
		btn.mouse_exited.connect(_on_btn_hover.bind(btn, false))
		btn.focus_entered.connect(_on_btn_hover.bind(btn, true))
		btn.focus_exited.connect(_on_btn_hover.bind(btn, false))
	
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	
	_play_title_intro()

func _input(event: InputEvent):
	if transitioning: return
	if event.is_action_pressed("ui_cancel"):
		if current_screen == "settings":
			_on_back_button_pressed()
		elif current_screen == "credits":
			_on_credits_back_pressed()
		get_viewport().set_input_as_handled()
	
	if event is InputEventMouseButton and not event.pressed:
		if hovered_button:
			_on_btn_hover(hovered_button, false)
	if event is InputEventScreenTouch and not event.pressed:
		if hovered_button:
			_on_btn_hover(hovered_button, false)

func _is_pressed(event: InputEvent) -> bool:
	return (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
		or (event is InputEventScreenTouch and event.pressed)

func _play_title_intro():
	if tween_title: tween_title.kill()
	title.modulate.a = 0.0
	title.position = title_start_pos + Vector2(-200, 0)
	title.rotation_degrees = -15
	
	tween_title = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween_title.tween_property(title, "position", title_start_pos, 0.6)
	tween_title.parallel().tween_property(title, "modulate:a", 1.0, 0.4)
	tween_title.parallel().tween_property(title, "rotation_degrees", 0.0, 0.6)
	tween_title.chain().tween_callback(_start_title_idle)

func _start_title_idle():
	if tween_title_idle: tween_title_idle.kill()
	tween_title_idle = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_title_idle.tween_property(title, "position:y", title_start_pos.y - 5, 1.5)
	tween_title_idle.parallel().tween_property(title, "rotation_degrees", -2, 1.5)
	tween_title_idle.tween_property(title, "position:y", title_start_pos.y + 5, 1.5)
	tween_title_idle.parallel().tween_property(title, "rotation_degrees", 2, 1.5)
	tween_title_idle.tween_property(title, "position:y", title_start_pos.y, 1.5)
	tween_title_idle.parallel().tween_property(title, "rotation_degrees", 0, 1.5)

func _stop_title_idle():
	if tween_title_idle: tween_title_idle.kill()

func _on_btn_hover(btn: Control, entered: bool):
	if transitioning: return
	
	if button_tweens[btn]: button_tweens[btn].kill()
	
	if entered:
		hovered_button = btn
		button_tweens[btn] = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		button_tweens[btn].set_parallel(true)
		button_tweens[btn].tween_property(btn, "scale", Vector2(1.15, 1.15), 0.3)
		button_tweens[btn].tween_property(btn, "rotation_degrees", randf_range(-4, 4), 0.3)
		button_tweens[btn].tween_property(btn, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.15)
		button_tweens[btn].tween_method(func(v): btn.add_theme_constant_override("margin_left", int(v)), btn.get_theme_constant("margin_left"), 12, 0.25)
	else:
		if hovered_button == btn:
			hovered_button = null
		button_tweens[btn] = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		button_tweens[btn].set_parallel(true)
		button_tweens[btn].tween_property(btn, "scale", Vector2.ONE, 0.25)
		button_tweens[btn].tween_property(btn, "rotation_degrees", 0.0, 0.25)
		button_tweens[btn].tween_property(btn, "modulate", Color.WHITE, 0.2)
		button_tweens[btn].tween_method(func(v): btn.add_theme_constant_override("margin_left", int(v)), btn.get_theme_constant("margin_left"), 0, 0.25)

func _button_click_fx(btn: Control):
	if transitioning: return
	if button_tweens[btn]: button_tweens[btn].kill()
	
	button_tweens[btn] = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	button_tweens[btn].tween_property(btn, "scale", Vector2(0.8, 1.2), 0.08)
	button_tweens[btn].parallel().tween_property(btn, "rotation_degrees", randf_range(-10, 10), 0.08)
	button_tweens[btn].chain().tween_property(btn, "scale", Vector2.ONE, 0.15)
	button_tweens[btn].parallel().tween_property(btn, "rotation_degrees", 0.0, 0.15)
	
	_stop_title_idle()
	if tween_title: tween_title.kill()
	tween_title = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween_title.tween_property(title, "scale", Vector2(1.15, 0.9), 0.1)
	tween_title.tween_property(title, "scale", Vector2.ONE, 0.2)
	tween_title.chain().tween_callback(_start_title_idle)

func _on_settings_button_pressed():
	_button_click_fx(settingsBtn)
	if current_screen!= "menu" or transitioning: return
	current_screen = "settings"
	
	if tween_menu: tween_menu.kill()
	settings.visible = true
	_stop_title_idle()
	
	if tween_title: tween_title.kill()
	tween_title = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween_title.tween_property(title, "position:x", title_start_pos.x - 600, 0.4) # further left
	tween_title.parallel().tween_property(title, "modulate:a", 0.0, 0.4) # fully hide
	
	tween_menu = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween_menu.tween_property(menu, "modulate:a", 0.0, 0.4)
	tween_menu.tween_property(menu, "position:x", menu_start_pos.x - 600, 0.4)
	settings.position.x = menu_start_pos.x + 600
	settings.modulate.a = 0.0
	tween_menu.tween_property(settings, "position", menu_start_pos, 0.4)
	tween_menu.tween_property(settings, "modulate:a", 1.0, 0.4)

func _on_back_button_pressed():
	if current_screen!= "settings" or transitioning: return
	current_screen = "menu"
	
	if tween_menu: tween_menu.kill()
	
	if tween_title: tween_title.kill()
	tween_title = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween_title.tween_property(title, "position", title_start_pos, 0.4)
	tween_title.parallel().tween_property(title, "modulate:a", 1.0, 0.4)
	tween_title.chain().tween_callback(_start_title_idle)
	
	tween_menu = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween_menu.tween_property(menu, "position", menu_start_pos, 0.4)
	tween_menu.tween_property(menu, "modulate:a", 1.0, 0.4)
	tween_menu.tween_property(settings, "position:x", menu_start_pos.x + 600, 0.4)
	tween_menu.tween_property(settings, "modulate:a", 0.0, 0.4)
	tween_menu.chain().tween_callback(func(): settings.visible = false)

func _on_credit_pressed() -> void:
	_button_click_fx(creditBtn)
	if current_screen!= "menu" or transitioning: return
	current_screen = "credits"
	
	if tween_bg: tween_bg.kill()
	if tween_credits: tween_credits.kill()
	credits.visible = true
	_stop_title_idle()
	
	if tween_title: tween_title.kill()
	tween_title = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween_title.tween_property(title, "position:x", title_start_pos.x - 800, 0.5) # way off screen
	tween_title.parallel().tween_property(title, "modulate:a", 0.0, 0.4)
	
	tween_menu = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween_menu.tween_property(menu, "position:x", menu_start_pos.x - 800, 0.5)
	tween_menu.tween_property(menu, "modulate:a", 0.0, 0.4)
	
	tween_bg = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween_bg.tween_property(background, "scale", target_size, 0.7)
	tween_bg.tween_property(background, "modulate", Color(0.4, 0.4, 0.4, 1.0), 0.5)
	
	tween_credits = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween_credits.tween_interval(0.3)
	tween_credits.tween_property(credits, "modulate:a", 1.0, 0.6)

func _on_credits_back_pressed():
	if current_screen!= "credits" or transitioning: return
	current_screen = "menu"
	
	if tween_bg: tween_bg.kill()
	if tween_credits: tween_credits.kill()
	
	tween_credits = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween_credits.tween_property(credits, "modulate:a", 0.0, 0.4)
	tween_credits.tween_callback(func(): credits.visible = false)
	
	tween_bg = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween_bg.tween_property(background, "scale", background_start_scale, 0.6)
	tween_bg.tween_property(background, "modulate", Color.WHITE, 0.5)
	
	if tween_title: tween_title.kill()
	tween_title = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween_title.tween_interval(0.2)
	tween_title.tween_property(title, "position", title_start_pos, 0.5)
	tween_title.parallel().tween_property(title, "modulate:a", 1.0, 0.4)
	tween_title.chain().tween_callback(_start_title_idle)
	
	tween_menu = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween_menu.tween_interval(0.1)
	tween_menu.tween_property(menu, "position", menu_start_pos, 0.5)
	tween_menu.tween_property(menu, "modulate:a", 1.0, 0.4)

func on_play() -> void:
	if transitioning: return
	transitioning = true
	_button_click_fx(playBtn)
	_stop_title_idle()
	
	var exit_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	exit_tween.tween_property(menu, "modulate:a", 0.0, 0.4)
	exit_tween.tween_property(menu, "position:y", menu_start_pos.y + 100, 0.4)
	exit_tween.tween_property(title, "modulate:a", 0.0, 0.4)
	exit_tween.tween_property(title, "position:y", title_start_pos.y - 100, 0.4)
	exit_tween.tween_property(background, "modulate:a", 0.0, 0.5)
	exit_tween.chain().tween_callback(func():
		get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")
	)

func on_exist() -> void:
	if transitioning: return
	_button_click_fx(existBtn)
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()

func _on_master_changed(value):
	set_bus_volume("Master", value)

func _on_music_changed(value):
	set_bus_volume("Music", value)

func _on_sfx_changed(value):
	set_bus_volume("SFX", value)

func set_bus_volume(bus_name, value):
	var bus_index = AudioServer.get_bus_index(bus_name)
	if value <= 0.001:
		AudioServer.set_bus_volume_db(bus_index, -80)
	else:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
