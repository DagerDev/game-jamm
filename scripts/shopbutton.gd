extends PanelContainer
class_name shopButton

@onready var label  = $MarginContainer2/Text

var title := "bamwe"
var price : int

signal OnBuy

func getTitle(titleName:String):
	title = titleName
	update()
func getPrice(priceInt:int):
	price = priceInt
	update()

func update() -> void:
	label.text = title + \
	"\nprice: " + str(price)

func Pressed() -> void:
	OnBuy.emit()
