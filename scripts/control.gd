extends Control
 
var storymanager

@onready var buttons = [
	%Choice1,
	%Choice2,
	%Choice3,
	%Choice4
]

var button_count = 4

func update_ui():
	var node = storymanager.get_current()

	$Label.text = node["text"]

	var choices = node.get("choices", [])

	for i in range(buttons.size()):

		if i < choices.size():
			buttons[i].visible = true
			buttons[i].button_text = choices[i]["text"]
		else:
			buttons[i].visible = false
		
func _ready():
	storymanager = preload("res://scenes/story.gd").new()
	add_child(storymanager)
	update_ui()
	setup_buttons()

func setup_buttons():
	for index in range(buttons.size()):
		buttons[index].pressed.connect(func(i=index):
			on_choice_pressed(i)
		)

func on_choice_pressed(index):

	#create_buttons(node["choices"])
	var node = storymanager.get_current()
	if index >= node["choices"].size():
		return
	
	var choice = node["choices"][index]
	
	storymanager.go_to(choice["next"])
	update_ui()
	
	
	
