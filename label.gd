extends Node2D

@onready var changingLabel = $Scene_Text
@onready var changingbutton = $Choice
@onready var changingbutton1 = $Choice2
@export var L : Label 
var hasPicked : bool = false
var choice := 0

#introduction
var So_text_changing: = "So..."
var intro_text: = "a mysterious guy asked you want 10k would you take it or pass it?"

#results
var rChoice1 := "you now have 10k"
var rChoice2 := "you rejected bru why?"

#if trys to change choice
var r2Choice1 := "you already said yes you still have 10k!!"
var r2Choice2 := "you already choosed you cant change it"

#The scene for the text
func Scene1():
	changingbutton.hide()
	changingbutton1.hide()
	await get_tree().create_timer(2).timeout
	changingLabel.text = So_text_changing
	await get_tree().create_timer(2).timeout
	changingLabel.text = intro_text
	changingbutton.show()
	changingbutton1.show()

#when the game opens... it directs this cutscene
func _ready():
	Scene1()

#the update Function
func update():
	if hasPicked:
		if choice == 1:
			L.text = r2Choice1
		elif choice == 2:
			L.text = r2Choice2
	else:
		if choice == 1:
			L.text = rChoice1
		elif choice == 2:
			L.text = rChoice2
			
	hasPicked = true 

func choice1() -> void:
	if !hasPicked:
		choice = 1
	update()


func choice2() -> void:
	if !hasPicked:
		choice = 2
	update()
