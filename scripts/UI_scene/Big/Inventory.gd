extends Control

@onready var ItemSlot = preload("res://scenes/UI/ItemSlot.tscn")
@onready var slots = $"../../SemiInput/Items/VBoxContainer"

var merged_inventory: Dictionary

func _ready():
	if self.visible and slots.get_child_count() == 0:
		var raw_items: Array = []
		for item_id in global.playerData.inventory:
			var item = EffectManager.get_item(item_id)
			if item != null:
				raw_items.append(item)

		merged_inventory = merge_inventory(raw_items)
		
		
		for data in merged_inventory.values():
			
			var Sitem = data["item"]
			var Squantity = data["count"]

			var new_slot = ItemSlot.instantiate()
			new_slot.itemID = Sitem.ID

			# Scale icon nếu có
			var icon_node = new_slot.get_node("Icon")
			if icon_node.texture:
				var tex_size = icon_node.texture.get_size()
				var scale_factor = min(32.0 / tex_size.x, 32.0 / tex_size.y)
				icon_node.scale = Vector2(scale_factor, scale_factor)
				icon_node.position = Vector2(16, 16)

			slots.add_child(new_slot)

func merge_inventory(inventory_array: Array) -> Dictionary:
	var inventory_dict := {}
	var unstackable_index := 0

	for item in inventory_array:
		if not (item is InvItem):
			continue

		# Nếu item có ID == 0, xử lý đặc biệt (không stackable)
		#if item.ID == 0:
		#	continue

		# Nếu vật phẩm stackable, cộng dồn số lượng
		if item.stackable:
			if inventory_dict.has(item.ID):
				inventory_dict[item.ID]["count"] += 1
			else:
				inventory_dict[item.ID] = {
					"item": item,
					"count": 1
				}
		# Nếu vật phẩm không stackable (mỗi item là một mục riêng)
		else:
			var unique_key = str(item.ID) + "_" + str(unstackable_index)
			inventory_dict[unique_key] = {
				"item": item,
				"count": 1
			}
			unstackable_index += 1

	return inventory_dict


func get_data(itemID: int):
	var conv_item = EffectManager.get_item(itemID)
	if conv_item == null:
		return
	
	$Armor/Frame.show()
	$Armor/Support/Label.show()

	# Hiển thị tên và mô tả
	$Armor/Name.text = conv_item.name
	$Armor/des_.text = "DES.: " + conv_item.des
	$Armor/Support.show()
	$Armor/des_.show()
	$Armor/Name.show()
	
	
	var Squantity
	var Sitem
	
	if conv_item.stackable:
		Sitem = merged_inventory[itemID]["item"]
		Squantity= merged_inventory[itemID]["count"]
	else:
		Sitem = merged_inventory[str(itemID) + "_" + str(0)]["item"]
		Squantity = merged_inventory[str(itemID) + "_" + str(0)]["count"]
	
	
	var quantity_label = $Armor/quantity
	if quantity_label:
		quantity_label.text = str(Squantity)
		quantity_label.visible = Sitem.stackable and Squantity > 1
		quantity_label.show()
	
	# Cập nhật hình ảnh của vật phẩm
	var sprite = $Armor/Frame/Sprite2D
	sprite.texture = conv_item.texture

	if sprite.texture:
		var texture_size = sprite.texture.get_size()
		var target_size = Vector2(32 * 4.75, 32 * 5)
		sprite.scale.x = target_size.x / texture_size.x
		sprite.scale.y = target_size.y / texture_size.y

func _process(delta):
	
	if not self.visible:
		for child in slots.get_children():
			child.queue_free()
	if self.visible and slots.get_child_count() == 0:
		var raw_items: Array = []
		for item_id in global.playerData.inventory:
			var item = EffectManager.get_item(item_id)
			if item != null:
				raw_items.append(item)

		merged_inventory = merge_inventory(raw_items)
		
		
		for data in merged_inventory.values():
			var Sitem = data["item"]
			var Squantity = data["count"]

			var new_slot = ItemSlot.instantiate()
			new_slot.itemID = Sitem.ID

			# Scale icon nếu có
			var icon_node = new_slot.get_node("Icon")
			if icon_node.texture:
				var tex_size = icon_node.texture.get_size()
				var scale_factor = min(32.0 / tex_size.x, 32.0 / tex_size.y)
				icon_node.scale = Vector2(scale_factor, scale_factor)
				icon_node.position = Vector2(16, 16)

			slots.add_child(new_slot)

