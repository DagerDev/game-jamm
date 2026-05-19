extends Node2D

var num := 0;

func update():
	$Label.text = str(num)

func button1() -> void:
	num += 1
	update()


func button2() -> void:
	num -= 1
	update()
