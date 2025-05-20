extends CanvasLayer

@export var buy_greeting:String
@export var sell_greeting:String
@export_range(0.0,1.0) var resale_value_percentage: float # 0.0 to 1.0
@export var items:Array[Array]

#items look like this:
# [[itemID,amount = -1,price]]
#amount = -1 is infinity

var cur_item_info:Array = [null,null,null]
var cur_will_buy_quantity = 1
var merged_inv
#	cur_item_info[0] = itemID
#cur_item_info[2] = price
#cur_item_info[1] = amount



@onready var buy_slots = $Buy/ScrollContainer/VBoxContainer
@onready var sell_slots = $Sell/ScrollContainer/VBoxContainer
@onready var ItemSlot = preload("res://scenes/UI/sell_dialog_item_slot.tscn")
@onready var UI = $"../UI"
@onready var anim = $Buy/anim

#save-load
@export var sellerID:int


##
##
##
## Buy dialog
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

		buy_slots.add_child(new_slot)
	#slots.add_child(ItemSlot.instantiate())

	await get_tree().process_frame

# Called when the node enters the scene tree for the first time.
	
func start_buy():
	var mini_UI = UI.get_node("Mini")
	var mini_UI_anim = UI.get_node("anim")
	if self.get_node("Buy").visible and mini_UI.visible:
		mini_UI_anim.play("end")
		anim.play("start")
		await get_tree().create_timer(1).timeout
		$Buy/RichTextLabel.text = buy_greeting
	$Buy/Money.text = "Money: " + str(global.playerData.money) + " G"

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
		$Buy/QuantityBox/Quantity.text = "X" + str(cur_will_buy_quantity) 
		$Buy/QuantityBox/Cost.text = format_short_number(cur_will_buy_quantity * cur_item_info[2]) + " G"
		$Buy/Accept.show()
		$Buy/Cancel.show()
		$Buy/QuantityBox.show()
		$Buy/Background/Quantity.show()
		cur_will_buy_quantity = 1#reset
	$Buy/RichTextLabel.text = text
	$Buy/Background/InBag.show()
	$Buy/Inbag.show()
	$Buy/Inbag.text = "In Bag: " + str(global.playerData.inventory.count(itemID))
	
func _on_cancel_pressed():
	$RichTextLabel.text = buy_greeting
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
	_update_inventory()

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

##
##
##end buy dialog

##Manager
func _on_buy_pressed():
	$Case.hide()
	$Buy.show()
	start_buy()

func _on_sell_pressed():
	$Case.hide()
	$Sell.show()
	start_sell()

func _ready():
	_update_inventory()
	_get_player_inventory()

func _process(delta):
	start_buy()
	start_sell()
##end Manager

##sell dialog

func merge_inventory(inventory_array: Array) -> Dictionary:
	'''Nhận vào một array chứa các vật phẩm đã được chuyển đổi thành resource file và thu gọn nó 
		Theo dạng {<ID của vật phẩm đó> : {"item":<Item đã đc chuyển đổi>, "count" : <số lượng>}}'''
	var inventory_dict := {}
	var unstackable_index := 0

	for i in range(inventory_array.size()):
		var item = inventory_array[i]

		
		if not (item is InvItem):

			continue

		if item.stackable:
			if inventory_dict.has(item.ID):
				inventory_dict[item.ID]["count"] += 1
			else:
				inventory_dict[item.ID] = {
					"item": item,
					"count": 1
				}
		else:
			var unique_key = str(item.ID) + "_" + str(unstackable_index)
			inventory_dict[unique_key] = {
				"item": item,
				"count": 1
			}
			unstackable_index += 1

	
	return inventory_dict


func _get_player_inventory():
	var temp = []
	for i in global.playerData.inventory:
		temp.append(EffectManager.get_item(i))
		
	merged_inv = merge_inventory(temp)
	for data in merged_inv.values():
		var new_slot = ItemSlot.instantiate()
		new_slot.itemID = data["item"].ID
		new_slot.quantity = data["count"]
		new_slot.price = resale_value_percentage * data["item"].sell

		var icon_node = new_slot.get_node("Icon")
		if icon_node.texture:
			var tex_size = icon_node.texture.get_size()
			var scale_factor = min(32.0 / tex_size.x, 32.0 / tex_size.y)
			icon_node.scale = Vector2(scale_factor, scale_factor)
			icon_node.position = Vector2(16, 16)

		sell_slots.add_child(new_slot)
	#slots.add_child(ItemSlot.instantiate())

	await get_tree().process_frame

func _get_data_selling(itemID,amount,price):
	var conv = EffectManager.get_item(itemID)
	$Sell/RichTextLabel.text = "Huh?" + conv.name + "?, Kinda great. How many do you want to sell?"
	$Sell/Background/Quantity.show()
	$Sell/QuantityBox.show()

func start_sell():
	var mini_UI = UI.get_node("Mini")
	var mini_UI_anim = UI.get_node("anim")
	if self.get_node("Sell").visible and mini_UI.visible:
		mini_UI_anim.play("end")
		#anim.play("start")
		await get_tree().create_timer(1).timeout
		$Sell/RichTextLabel.text = sell_greeting
	$Sell/Money.text = "Money: " + str(global.playerData.money) + " G"
	



