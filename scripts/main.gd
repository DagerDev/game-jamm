extends Node2D

@onready var ani = $Animated
@onready var buttons = $CanvasLayer/Control/CenterContainer/buttons
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ani.play("cs1")


func animation_finished() -> void:
	buttons.visible = 1
