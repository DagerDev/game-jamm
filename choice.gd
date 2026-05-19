extends TextureButton

@export var button_text: String = "Play":
	set(value):
		button_text = value
		if has_node("Label"):
			$Label.text = value
func _ready():
	$Label.text = button_text
