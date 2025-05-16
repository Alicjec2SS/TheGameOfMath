extends Control

@export var slot_size: Vector2 = Vector2(90, 90)
@export var itemID:int
@export var quantity:int = -1
@export var price:int = 0

@onready var Icon = $Icon
@onready var Name = $Name

var converted_item
# Called when the node enters the scene tree for the first time.
func _ready():
	if not converted_item:
		converted_item = EffectManager.get_item(itemID)
	if converted_item:
		Icon.texture = converted_item.texture
		
		if Icon.texture:
			var tex_size = Icon.texture.get_size()
			var scale_factor = min(slot_size.x / tex_size.x, slot_size.y / tex_size.y)
			Icon.scale = Vector2(scale_factor, scale_factor)
			Icon.position = slot_size / 2  # Canh giữa
			Icon.position.x += 25
		Name.text = converted_item.name
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	converted_item = EffectManager.get_item(itemID)
	if converted_item:
		Icon.texture = converted_item.texture
		Name.text = converted_item.name
		$Quantity.text = "x" + str(quantity) if quantity > 0 else ""
		

func _on_button_pressed():
	print(str(itemID) + "pressed")
	$"../../.."._get_data(itemID,quantity,price)
		
