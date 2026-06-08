extends Button
class_name choiceButton

# =========================================================
# NODES
# =========================================================
@onready var icon_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

# =========================================================
# DATA
# =========================================================
var button_text: String = ""

# =========================================================
# INIT
# =========================================================
func _ready():
	label.text = button_text


# =========================================================
# TEXT UPDATE
# =========================================================
func update_text(new_text: String):

	button_text = new_text

	if is_node_ready():
		label.text = new_text


# =========================================================
# ICON UPDATE
# =========================================================
func update_icon(texture: Texture2D):

	if is_node_ready():
		icon_rect.texture = texture


# =========================================================
# FULL UPDATE
# =========================================================
func update_button(new_text: String, texture: Texture2D):

	button_text = new_text

	if is_node_ready():
		label.text = new_text
		icon_rect.texture = texture
