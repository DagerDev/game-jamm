extends Control

@onready var shopmenu = $"../ShopMenu"

func _on_shop_button_pressed() -> void:
	shopmenu.visible = 1


func _on_exit_pressed() -> void:
	shopmenu.visible = 0
