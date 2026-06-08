extends Control 

@onready var SfxClick = $"Click" 
@onready var SfxHover = $"Hover"

func Click() -> void: 
	SfxClick.pitch_scale = randf_range(0.9, 1.1) # ±10% pitch variation
	SfxClick.play() 

func Hover() -> void: 
	SfxHover.pitch_scale = randf_range(0.95, 1.05) # smaller variation for hover
	SfxHover.play()
