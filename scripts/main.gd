extends Node2D

@onready var ani = %animation
@onready var buttons = $CanvasLayer/Control/CenterContainer/buttons
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ani.play("Intro")


func animation_finished() -> void:
	pass


func _on_choice_3_pressed() -> void:
	pass # Replace with function body.
