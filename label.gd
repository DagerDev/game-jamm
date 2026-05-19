extends Node2D

@export var L : Label 

var hasPicked : bool = false
var choice := 0

#results
var rChoice1 := "you now have 10k"
var rChoice2 := "you rejected bru why?"

#if trys to change choice
var r2Choice1 := "you already said yes you still have 10k!!"
var r2Choice2 := "you already choosed you cant change it"

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
