extends Button
class_name choiceButton

# =========================================================
# NODES
# =========================================================
@onready var icon_rect: TextureRect = $"TextureRect"
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
	var icon_rectt = get_node("TextureRect")
	if icon_rectt:
		icon_rectt.texture = texture
	else:
		push_error("TextureRect not found under " + name)
