extends CanvasLayer


@export var items:Array[int]
@export var quantity_of_items:Array[int]

@onready var slots = $ScrollContainer/VBoxContainer
@onready var ItemSlot = preload("res://scenes/UI/ItemSlot.tscn")

#save-load
@export var sellerID:int


func _update_inventory():
	for data in items:
		var new_slot = ItemSlot.instantiate()
		new_slot.itemID = data

		var icon_node = new_slot.get_node("Icon")
		if icon_node.texture:
			var tex_size = icon_node.texture.get_size()
			var scale_factor = min(32.0 / tex_size.x, 32.0 / tex_size.y)
			icon_node.scale = Vector2(scale_factor, scale_factor)
			icon_node.position = Vector2(16, 16)

		slots.add_child(new_slot)
	slots.add_child(ItemSlot.instantiate())

	await get_tree().process_frame

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_inventory()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
