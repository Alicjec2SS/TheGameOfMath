extends CanvasLayer


@export var buy_greeting:String
@export var sell_greeting:String
@export_range(0.0,1.0) var resale_value_percentage: float # 0.0 to 1.0
@export var items:Array[Array]

#items look like this:
# [[itemID,amount = -1,price]]
#amount = -1 is infinity

var cur_item_info:Array = [null,null,null]
var will_sell_item:Array  = [null,null]
var cur_will_buy_quantity = 1
var cur_will_sell_quantity = 1
var merged_inv


#	cur_item_info[0] = itemID
#cur_item_info[2] = price
#cur_item_info[1] = amount
#will_sell_item[0] = itemID
#will_sell_item[1] = price



@onready var buy_slots = $Buy/ScrollContainer/VBoxContainer
@onready var sell_slots = $Sell/ScrollContainer/VBoxContainer
@onready var ItemSlot = preload("res://scenes/UI/sell_dialog_item_slot.tscn")
@onready var UI = $"../UI"
@onready var anim = $Buy/anim
@onready var sell_anim = $Sell/anim

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
	if not self.get_node("Buy").visible and not $Sell.visible:
		if mini_UI.visible:
			mini_UI_anim.play("end")
		anim.play("start")
		$Buy.show()
		$Buy/Background.show()
		$Buy/ScrollContainer.show()
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
	$Buy/RichTextLabel.text = buy_greeting
	$Buy/Accept.hide()
	$Buy/Cancel.hide()
	$Buy/QuantityBox.hide()
	$Buy/Background/Quantity.hide()
	$Buy/Inbag.hide()
	$Buy/Background/InBag.hide()

func _on_accept_pressed():
	global.playerData.inventory.append(cur_item_info[0])
	var cost = cur_item_info[2] * int(cur_will_buy_quantity)
	global.playerData.money -= cost
	print("purchased")
	$Buy/Accept.hide()
	$Buy/Cancel.hide()
	$Buy/QuantityBox.hide()
	$Buy/Background/Quantity.hide()
	$Buy/RichTextLabel.text = "It costs all " + str(cost) +"G . Anything else?"
	_update_inventory()

func _on_down_pressed():
	cur_will_buy_quantity = max(1,cur_will_buy_quantity-1)
	$Buy/QuantityBox/Quantity.text = "X" + str(cur_will_buy_quantity)
	$Buy/QuantityBox/Cost.text = format_short_number(cur_will_buy_quantity * cur_item_info[2]) + " G"

func _on_up_pressed():
	if cur_item_info[1] >= 0:
		cur_will_buy_quantity = min(floor(global.playerData.money / cur_item_info[2]), 
								cur_item_info[1],
								cur_will_buy_quantity + 1)
	else:
		cur_will_buy_quantity = min(floor(global.playerData.money / abs(cur_item_info[2])), 
								cur_will_buy_quantity + 1)
	$Buy/QuantityBox/Quantity.text = "X" + str(cur_will_buy_quantity)
	$Buy/QuantityBox/Cost.text = format_short_number(cur_will_buy_quantity * cur_item_info[2]) + " G"

##
##
##end buy dialog

##Manager

#the function is used to active the sell engine
func _start_sell_dialog(p_buy_greeting,p_sell_greeting,p_resale_value_percentage,p_items):
	#reset
	
	buy_greeting = p_buy_greeting
	sell_greeting = p_sell_greeting
	resale_value_percentage = p_resale_value_percentage
	items = p_items
	
	_update_inventory()
	_get_player_inventory()
	
	
	self.show()
	$Case/anim.play("start")
	$"../UI/anim".play("end")

func _on_buy_pressed():
	$Case/anim.play("end")
	await get_tree().create_timer(1).timeout
	start_buy()
	$Quit_Box/anim.play("start")

func _on_sell_pressed():
	$Case/anim.play("end")
	await get_tree().create_timer(1).timeout
	start_sell()
	$Quit_Box/anim.play("start")

func _ready():
	_update_inventory()
	_get_player_inventory()

func _process(delta):
	if self.visible:
		global.can_move = false
		global.is_interacting = true 
	else:
		global.can_move = true
		global.is_interacting = false 


func _on_quit_pressed():
	$Buy/anim.play("end")
	$Sell/anim.play("end")
	$Quit_Box/anim.play("end")
	await get_tree().create_timer(1).timeout
	$Buy.hide()
	$Sell.hide()
	self.hide()
	

##end Manager



##sell dialog
func remove_k_items(inventory: Array, item_to_remove: Variant, k: int) -> void:
	var removed := 0
	for i in range(inventory.size() - 1, -1, -1):  # Duyệt ngược để tránh lệch index khi remove
		if inventory[i] == item_to_remove:
			inventory.remove_at(i)
			removed += 1
			if removed >= k:
				break


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
	
	for i in sell_slots.get_children():
		i.queue_free()
	
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
	sell_slots.add_child(ItemSlot.instantiate())

	await get_tree().process_frame

func _get_data_selling(itemID,amount,price):
	var conv = EffectManager.get_item(itemID)
	$Sell/RichTextLabel.text = "Huh?" + conv.name + "?, Kinda great. How many do you want to sell?"
	$Sell/Background/Quantity.show()
	$Sell/QuantityBox.show()
	$Sell/OK.show()
	$Sell/Nope.show()
	cur_will_sell_quantity = 1
	will_sell_item[0] = itemID
	will_sell_item[1] = price
	$Sell/QuantityBox/Quantity.text = "X" + str(cur_will_sell_quantity) 
	$Sell/QuantityBox/Cost.text = format_short_number(cur_will_sell_quantity * will_sell_item[1]) + " G"

func start_sell():
	var mini_UI = UI.get_node("Mini")
	var mini_UI_anim = UI.get_node("anim")
	if not $Sell.visible and not $Buy.visible:
		if mini_UI.visible:
			mini_UI_anim.play("end")
		sell_anim.play("start")
		$Sell.show()
		$Sell/Background.show()
		await get_tree().create_timer(1).timeout
		$Sell/RichTextLabel.text = sell_greeting
	$Sell/Money.text = "Money: " + str(global.playerData.money) + " G"

func _on_up_s_pressed():
	var max_quantity = global.playerData.inventory.count(will_sell_item[0])
	cur_will_sell_quantity = min(max_quantity, cur_will_sell_quantity + 1)
	
	$Sell/QuantityBox/Quantity.text = "X" + str(cur_will_sell_quantity)
	$Sell/QuantityBox/Cost.text = format_short_number(cur_will_sell_quantity * will_sell_item[1]) + " G"


func _on_down_s_pressed():
	cur_will_sell_quantity = max(1,cur_will_sell_quantity-1)
	$Sell/QuantityBox/Quantity.text = "X" + str(cur_will_sell_quantity)
	$Sell/QuantityBox/Cost.text = format_short_number(cur_will_sell_quantity * will_sell_item[1]) + " G"


func _on_ok_pressed():
	if will_sell_item[0] in global.playerData.using_equips:
		var Index = global.playerData.using_equips.find(will_sell_item[0])
		if Index != -1:
			global.playerData.using_equips[Index] = null
	else:
		remove_k_items(global.playerData.inventory,will_sell_item[0],cur_will_sell_quantity)
		global.playerData.money += cur_will_sell_quantity * will_sell_item[1]
		$Sell/OK.hide()
		$Sell/Nope.hide()
		$Sell/Background/Quantity.hide()
		$Sell/QuantityBox.hide()
		$Sell/RichTextLabel.text = "Okay, i will pay " +  str(cur_will_sell_quantity * will_sell_item[1]) 
		$Sell/RichTextLabel.text += "them" if cur_will_sell_quantity > 0 else "it"
		$Sell/RichTextLabel.text += ". Anything else?"
	will_sell_item = [null,null]
	cur_will_sell_quantity=1
	_get_player_inventory()

func _on_nope_pressed():
	$Sell/RichTextLabel.text = sell_greeting
	$Sell/OK.hide()
	$Sell/Nope.hide()
	$Sell/QuantityBox.hide()
	$Sell/Background/Quantity.hide()
##End sell_dialog



