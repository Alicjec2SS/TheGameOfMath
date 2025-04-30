extends Control

@export var slot_size: Vector2 = Vector2(80, 80)
@export var itemID:int
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
		Name.text = converted_item.name
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	converted_item = EffectManager.get_item(itemID)
	if converted_item:
		Icon.texture = converted_item.texture
		Name.text = converted_item.name
		

func _on_button_pressed():
	$"../../../../Big/Inventory".get_data(itemID)
