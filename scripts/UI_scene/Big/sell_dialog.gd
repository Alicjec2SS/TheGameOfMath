extends CanvasLayer

@export var greeting:String
@export var items:Array[Array]


var cur_item
var cur_price

#items look like this:
# [[itemID,amount = -1,price]]
#amount = -1 is infinity

@onready var slots = $ScrollContainer/VBoxContainer
@onready var ItemSlot = preload("res://scenes/UI/sell_dialog_item_slot.tscn")
@onready var UI = $"../UI"
@onready var anim = $anim

#save-load
@export var sellerID:int


func _update_inventory():
	for data in items:
		var new_slot = ItemSlot.instantiate()
		new_slot.itemID = data[0]
		new_slot.quantity = data[1]
		new_slot.price = data[2]

		var icon_node = new_slot.get_node("Icon")
		if icon_node.texture:
			var tex_size = icon_node.texture.get_size()
			var scale_factor = min(32.0 / tex_size.x, 32.0 / tex_size.y)
			icon_node.scale = Vector2(scale_factor, scale_factor)
			icon_node.position = Vector2(16, 16)

		slots.add_child(new_slot)
	#slots.add_child(ItemSlot.instantiate())

	await get_tree().process_frame

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_inventory()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mini_UI = UI.get_node("Mini")
	var mini_UI_anim = UI.get_node("anim")
	if self.visible and mini_UI.visible:
		mini_UI_anim.play("end")
		anim.play("start")
		await get_tree().create_timer(1).timeout
		$RichTextLabel.text = greeting


func _get_data(itemID,amount,price):
	var conv_item = EffectManager.get_item(itemID)
	cur_item = itemID
	cur_price = price
	var text = "Huh? " + conv_item.name + "?"
	text += "we only have " + str(amount) + " of them." if amount > 0 else ""
	text += " How many do you want to buy?"
	$RichTextLabel.text = text
	$Accept.show()
	$Cancel.show()
	


func _on_cancel_pressed():
	$RichTextLabel.text = greeting
	$Accept.hide()
	$Cancel.hide()	


func _on_accept_pressed():
	global.playerData.inventory.append(cur_item)
	global.playerData.money -= cur_price
	print("purchased")
	$Accept.hide()
	$Cancel.hide()
	$RichTextLabel.text = "It costs all " + str(cur_price) +"G . Anything else?"
