extends CanvasLayer

@export var greeting:String
@export var items:Array[Array]

#items look like this:
# [[itemID,amount = -1,price]]
#amount = -1 is infinity

var cur_item_info:Array = [null,null,null]
var cur_will_buy_quantity = 1

#	cur_item_info[0] = itemID
#cur_item_info[2] = price
#cur_item_info[1] = amount



@onready var slots = $ScrollContainer/VBoxContainer
@onready var ItemSlot = preload("res://scenes/UI/sell_dialog_item_slot.tscn")
@onready var UI = $"../UI"
@onready var anim = $anim

#save-load
@export var sellerID:int

func format_short_number(num: float) -> String:
	var abs_num = abs(num)
	var suffix := ""
	var value := num

	if abs_num >= 1_000_000_000:
		suffix = "B"
		value = num / 1_000_000_000.0
	elif abs_num >= 1_000_000:
		suffix = "M"
		value = num / 1_000_000.0
	elif abs_num >= 1_000:
		suffix = "K"
		value = num / 1_000.0
	else:
		return str(int(num))  # hoặc dùng "%.1f" % num nếu bạn vẫn muốn có số thập phân nhỏ

	return "%.1f%s" % [value, suffix]

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
	cur_item_info[0] = itemID
	cur_item_info[2] = price
	cur_item_info[1] = amount
	var text
	if global.playerData.money < price:
		text = "You don't have enough money to buy that. Anything else?"
	else:
		text = "Huh? " + conv_item.name + "?"
		text += "we only have " + str(amount) + " of them." if amount > 0 else ""
		text += " How many do you want to buy?"
		$QuantityBox/Quantity.text = "X" + str(cur_will_buy_quantity) 
		$QuantityBox/Cost.text = format_short_number(cur_will_buy_quantity * cur_item_info[2]) + " G"
		$Accept.show()
		$Cancel.show()
		$QuantityBox.show()
		$Background/Quantity.show()
		cur_will_buy_quantity = 1#reset
	$RichTextLabel.text = text

func _on_cancel_pressed():
	$RichTextLabel.text = greeting
	$Accept.hide()
	$Cancel.hide()
	$QuantityBox.hide()

func _on_accept_pressed():
	global.playerData.inventory.append(cur_item_info[0])
	var cost = cur_item_info[2] * int(cur_will_buy_quantity)
	global.playerData.money -= cost
	print("purchased")
	$Accept.hide()
	$Cancel.hide()
	$QuantityBox.hide()
	$Background/Quantity.hide()
	$RichTextLabel.text = "It costs all " + str(cost) +"G . Anything else?"

func _on_down_pressed():
	cur_will_buy_quantity = max(1,cur_will_buy_quantity-1)
	$QuantityBox/Quantity.text = "X" + str(cur_will_buy_quantity)
	$QuantityBox/Cost.text = format_short_number(cur_will_buy_quantity * cur_item_info[2]) + " G"

func _on_up_pressed():
	if cur_item_info[1] >= 0:
		cur_will_buy_quantity = min(floor(global.playerData.money / cur_item_info[2]), 
								cur_item_info[1],
								cur_will_buy_quantity + 1)
	else:
		cur_will_buy_quantity = min(floor(global.playerData.money / abs(cur_item_info[2])), 
								cur_will_buy_quantity + 1)
	$QuantityBox/Quantity.text = "X" + str(cur_will_buy_quantity)
	$QuantityBox/Cost.text = format_short_number(cur_will_buy_quantity * cur_item_info[2]) + " G"
