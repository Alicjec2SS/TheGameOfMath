extends Control

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



func _process(delta):
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


	
	
