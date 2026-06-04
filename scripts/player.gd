extends CharacterBody2D

var cursor_pos : Vector2

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag or TouchScreenButton:
		cursor_pos = event.position
		print(cursor_pos)
		
func _physics_process(delta: float) -> void:
	self.position = cursor_pos
