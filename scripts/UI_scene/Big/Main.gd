extends Control

var showing_item = ""

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

func _ready():
	$"../../BIG_anim".play("RESET")


func _process(delta):
	if not self.visible:return
	
	$PlayerInfo/HP_Bar.min_value = 0
	$PlayerInfo/HP_Bar.max_value = global.playerData.MAX_HP
	$PlayerInfo/HP_Bar.value = global.playerData.HP
	$PlayerInfo/HP_Bar/HP.text = str(global.playerData.HP) +"/"+str(global.playerData.MAX_HP)
	
	$PlayerInfo/Mana_Bar.min_value = 0
	$PlayerInfo/Mana_Bar.max_value = global.playerData.MAX_MANA
	$PlayerInfo/Mana_Bar.value = global.playerData.mana
	$PlayerInfo/Mana_Bar/MP.text = str(global.playerData.mana) +"/"+str(global.playerData.MAX_MANA)
	
	$PlayerInfo/LVL.text = str(global.playerData.LVL) 
	$PlayerInfo/SPD.text = str(global.playerData.speed)
	$PlayerInfo/DMG.text = str(global.playerData.DMG)
	$PlayerInfo/DEF.text = str(global.playerData.DEF)
	
	$PlayerInfo/Gold.text = str("GOLD:") + format_short_number(global.playerData.money)
	
	var exp_cap = int(pow(global.playerData.LVL, 2) * 100)
	
	var temp
	if global.playerData.using_equips[0] != null:
		temp = [EffectManager.get_item(global.playerData.using_equips[0])]
	else:
		temp = [null]
	if global.playerData.using_equips[1] != null:
		temp.append(EffectManager.get_item(global.playerData.using_equips[1]))
	else:
		temp.append(null)
		
	if $"../../BigInput/ArmorSlot" and $"../../BigInput/WeaponSlot":
		$"../../BigInput/ArmorSlot".icon = temp[0].texture if temp[0] else null
		$"../../BigInput/WeaponSlot".icon = temp[1].texture if temp[1] else null
	
	if global.playerData.LVL < 80:
		$PlayerInfo/EXP_Bar.min_value = 0
		$PlayerInfo/EXP_Bar.max_value = exp_cap
		$PlayerInfo/EXP_Bar.value = global.playerData.EXP
		$PlayerInfo/EXP_Bar/EXP.text = str(global.playerData.EXP) + " / " + str(exp_cap)
	else:
		$PlayerInfo/EXP_Bar.min_value = 0
		$PlayerInfo/EXP_Bar.max_value = 100
		$PlayerInfo/EXP_Bar.value = 100
		$PlayerInfo/EXP_Bar/EXP.text = "MAX"

func _on_armor_slot_pressed():
	var temp = EffectManager.get_item(global.playerData.using_equips[0]) if global.playerData.using_equips[0] else null
	if not temp:
		return

	if showing_item == "armor":
		# Nếu đang xem Armor rồi, bấm lại thì tắt đi -> hiện PlayerInfo
		showing_item = ""
		$Armor.hide()
		$Armor/unequip.hide()
		$PlayerInfo.show()
	else:
		# Đang xem cái khác (Weapon hoặc PlayerInfo) -> chuyển sang Armor
		showing_item = "armor"
		$PlayerInfo.hide()
		$Armor.show()
		$Armor/unequip.show()
		$Armor/Name.text = temp.name
		$Armor/des_.text = "des. : " + temp.des
		$Armor/Frame/Sprite2D.texture = temp.texture


func _on_weapon_slot_pressed():
	var temp = EffectManager.get_item(global.playerData.using_equips[1]) if global.playerData.using_equips[1] else null
	if not temp:
		return

	if showing_item == "weapon":
		# Nếu đang xem Weapon rồi, bấm lại thì tắt đi -> hiện PlayerInfo
		showing_item = ""
		$Armor.hide()
		$Armor/unequip.hide()
		$PlayerInfo.show()
	else:
		# Đang xem cái khác (Armor hoặc PlayerInfo) -> chuyển sang Weapon
		showing_item = "weapon"
		$PlayerInfo.hide()
		$Armor.show()
		$Armor/unequip.show()
		$Armor/Name.text = temp.name
		$Armor/des_.text = "des. : " + temp.des
		$Armor/Frame/Sprite2D.texture = temp.texture




