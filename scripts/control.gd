extends Control
 
@onready var buttons = [
	%Choice1,
	%Choice2,
	%Choice3,
	%Choice4
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
		
func _ready() -> void:
	
	update()
