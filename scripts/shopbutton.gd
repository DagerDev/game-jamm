extends Button
class_name ShopButton

signal selected(id)

@onready var label = $RichLabel

@export var upgrade_id := ""

func update_display(level:int, price:int, description:String):

	label.bbcode_enabled = true

	label.text = \
		"[b]" + upgrade_id + "[/b]\n" + \
		"Lv." + str(level) + "\n" + \
		description + "\n" + \
		"$" + str(price)

func _pressed():
	selected.emit(upgrade_id)
