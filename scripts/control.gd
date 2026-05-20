extends Control

@onready var buttons = [
	$CenterContainer/Container/Choice1,
	$CenterContainer/Container/Choice2,
	$CenterContainer/Container/Choice3,
	$CenterContainer/Container/Choice4
]

@export var text = [
	"A",
	"B",
	"C",
	"D"
]

var button_count = 4

func update():
	for i in range(buttons.size()):
		buttons[i].button_text = text[i]
		
	for i in range(buttons.size()):
		buttons[i].visible = i < button_count
		
