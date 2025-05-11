extends Button

@export var itemID:int = 0

# Called when the node enters the scene tree for the first time.
func _ready():pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if itemID != 0:
		self.show()
		if itemID >= 200 :
			self.text = "Equip"
			if itemID in global.playerData.using_equips:
				self.text = "Unequip"
				self.theme = load("res://settings/unequip.tres") 
			else:
				self.theme = load("res://settings/equip.tres")
		else:
			self.text = "Use"
			self.theme = load("res://settings/equip.tres")
	else:
		self.hide()
	


func _on_pressed():
	var conv_item = EffectManager.get_item(itemID)
	if conv_item.type == "Consumable item":#normal item:
		global.playerData.waiting_items_effect.append(itemID)
		global.playerData.inventory.erase(itemID)
	else:
		if conv_item.type == "Armor":
			if itemID == global.playerData.using_equips[0]:
				global.playerData.using_equips[0] = null
			else:
				global.playerData.using_equips[0] = itemID
		if conv_item.type == "Weapon":
			if itemID == global.playerData.using_equips[1]:
				global.playerData.using_equips[1] = null
			else:
				global.playerData.using_equips[1] = itemID
	$"../.."._update_inventory()
	if not itemID in global.playerData.inventory:
		$"../..".get_data(itemID)
		self.hide()
		$"../des_".text = ""
		$"../Name".text = ""
		$"../Frame/Sprite2D".texture = null
		$"../quantity".text = ""
	else:
		$"../..".get_data(itemID)
		
