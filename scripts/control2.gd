extends Control

@onready var shopkeeper =$"../ShopMenu/ShopPanel/ShopOwner"

@onready var shopMenu = %ShopMenu
@onready var shopPanel = %ShopPanel
@onready var bank = %Bank
@onready var health = %HealthBank
@onready var hack = %Hack
@onready var bomb = %Bomb
@onready var sabotage = %Sabotage
@onready var loan = %Loan
@onready var shopBtn = %ShopButton
@onready var exitButton = %Exit
@onready var statusLabel = %Info

var tween_shop : Tween
var tween_bank : Tween
var tween_health : Tween
var tween_hack : Tween
var tween_bomb : Tween
var tween_sabotage : Tween
var tween_loan : Tween
var tween_label : Tween

var panel_start_pos: Vector2
var panel_hidden_y: float
var shop_open := false

var tween_keeper : Tween
var keeper_start_pos : Vector2

func _ready():
	keeper_start_pos = shopkeeper.position
	
	shopMenu.visible = false
	shopMenu.modulate.a = 0.0
	statusLabel.modulate.a = 0.0
	statusLabel.visible = false
	
	bank.pivot_offset = bank.size / 2
	hack.pivot_offset = hack.size / 2
	bomb.pivot_offset = bomb.size / 2
	sabotage.pivot_offset = sabotage.size / 2
	loan.pivot_offset = loan.size / 2
	
	panel_start_pos = shopPanel.position
	panel_hidden_y = get_viewport_rect().size.y + 50
	shopPanel.position.y = panel_hidden_y

func _input(event: InputEvent):
	if shop_open and event.is_action_pressed("ui_cancel"): # ESC = ui_cancel
		_on_exit_pressed()
		get_viewport().set_input_as_handled()

func _is_pressed(event: InputEvent) -> bool:
	return (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
		or (event is InputEventScreenTouch and event.pressed)

func push_message(text: String, wait_time := 2.0, fade_time := 0.5):
	if text == "":
		return
	if tween_label: tween_label.kill()
	statusLabel.text = text
	statusLabel.modulate.a = 1.0 # instant show
	statusLabel.visible = true
	tween_label = create_tween()
	tween_label.tween_interval(wait_time) # wait
	tween_label.tween_property(statusLabel, "modulate:a", 0.0, fade_time) # fade
	tween_label.tween_callback(func(): statusLabel.visible = false)

func _on_bank_gui_input(event: InputEvent):
	if _is_pressed(event):
		if tween_bank: tween_bank.kill()
		tween_bank = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		tween_bank.tween_property(bank, "scale", Vector2(1.15, 1.15), 0.15)
		tween_bank.parallel().tween_property(bank, "rotation_degrees", randf_range(-8, 8), 0.15)
		tween_bank.chain().tween_property(bank, "scale", Vector2.ONE, 0.15)
		tween_bank.parallel().tween_property(bank, "rotation_degrees", 0.0, 0.15)

func _on_hack_gui_input(event: InputEvent) -> void:
	if _is_pressed(event):
		if tween_hack: tween_hack.kill()
		# No position tweens - HBoxContainer safe
		tween_hack = create_tween().set_trans(Tween.TRANS_SINE)
		tween_hack.tween_property(hack, "rotation_degrees", -4, 0.04)
		tween_hack.tween_property(hack, "rotation_degrees", 4, 0.04)
		tween_hack.tween_property(hack, "rotation_degrees", 0, 0.04)
		tween_hack.parallel().tween_property(hack, "modulate", Color(0.2, 1, 0.8), 0.06)
		tween_hack.chain().tween_property(hack, "modulate", Color.WHITE, 0.1)

func _on_bomb_gui_input(event: InputEvent) -> void:
	if _is_pressed(event):
		if tween_bomb: tween_bomb.kill()
		tween_bomb = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween_bomb.tween_property(bomb, "scale", Vector2(0.7, 1.3), 0.1)
		tween_bomb.chain().tween_property(bomb, "scale", Vector2(1.25, 1.25), 0.15).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tween_bomb.chain().tween_property(bomb, "scale", Vector2.ONE, 0.2)
		tween_bomb.parallel().tween_property(bomb, "modulate", Color(1, 0.3, 0.1), 0.1)
		tween_bomb.chain().tween_property(bomb, "modulate", Color.WHITE, 0.2)

func _on_sabotage_gui_input(event: InputEvent) -> void:
	if _is_pressed(event):
		if tween_sabotage: tween_sabotage.kill()
		tween_sabotage = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		tween_sabotage.tween_property(sabotage, "rotation_degrees", -15, 0.12)
		tween_sabotage.parallel().tween_property(sabotage, "scale", Vector2(0.9, 0.9), 0.12)
		tween_sabotage.chain().tween_property(sabotage, "rotation_degrees", 0.0, 0.15)
		tween_sabotage.parallel().tween_property(sabotage, "scale", Vector2.ONE, 0.15)

func _on_loan_gui_input(event: InputEvent) -> void:
	if _is_pressed(event):
		if tween_loan: tween_loan.kill()
		tween_loan = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween_loan.tween_property(loan, "scale", Vector2(1.1, 0.8), 0.15)
		tween_loan.chain().tween_property(loan, "scale", Vector2.ONE, 0.25)
		tween_loan.parallel().tween_property(loan, "modulate", Color(1, 0.9, 0.2), 0.1)
		tween_loan.chain().tween_property(loan, "modulate", Color.WHITE, 0.2)

func _on_health_bank_value_changed(_value: float) -> void:
	if tween_health: tween_health.kill()
	tween_health = create_tween()
	tween_health.tween_property(health, "scale", Vector2(1.05, 1.05), 0.06)
	tween_health.tween_property(health, "scale", Vector2.ONE, 0.06)

func _on_shop_button_pressed() -> void:
	shopMenu.mouse_filter = Control.MOUSE_FILTER_STOP
	shopPanel.mouse_filter = Control.MOUSE_FILTER_STOP
	
	start_shopkeeper_idle()
	if tween_shop: tween_shop.kill()
	shop_open = true
	shopBtn.visible = false # hide shop button when open
	shopMenu.visible = true
	
	shopPanel.position = Vector2(panel_start_pos.x, panel_hidden_y)
	tween_shop = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween_shop.tween_property(shopMenu, "modulate:a", 1.0, 0.5)
	tween_shop.tween_property(shopPanel, "position", panel_start_pos, 0.5)

func _on_exit_pressed() -> void:
	shopMenu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shopPanel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if tween_shop: tween_shop.kill()
	shop_open = false
	tween_shop = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween_shop.tween_property(shopMenu, "modulate:a", 0.0, 0.5)
	tween_shop.tween_property(shopPanel, "position:y", panel_hidden_y, 0.5)
	tween_shop.chain().tween_callback(func(): 
		shopMenu.visible = false
		shopBtn.visible = true # show shop button again
	)
	stop_shopkeeper_idle()
	
func start_shopkeeper_idle():
	if tween_keeper:
		tween_keeper.kill()

	shopkeeper.position = keeper_start_pos

	tween_keeper = create_tween()
	tween_keeper.set_loops()

	tween_keeper.tween_property(
		shopkeeper,
		"position:y",
		keeper_start_pos.y - 8,
		1.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween_keeper.tween_property(
		shopkeeper,
		"position:y",
		keeper_start_pos.y,
		1.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
func stop_shopkeeper_idle():
	if tween_keeper:
		tween_keeper.kill()

	var t = create_tween()
	t.tween_property(
		shopkeeper,
		"position",
		keeper_start_pos,
		0.2
	)
