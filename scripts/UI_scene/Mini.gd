extends Control


@onready var mana = $Mana_Bar
@onready var HP = $HP_Bar
@onready var anim = $anim
var current_anim = "idle"  # Lưu trạng thái animation hiện tại

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
	mana.min_value = 0
	mana.max_value = global.playerData.MAX_MANA
	mana.value = global.playerData.mana
	
	HP.min_value = 0
	HP.max_value = global.playerData.MAX_HP
	HP.value = global.playerData.HP
	if not self.visible:
		$"../anim".play("show")
	if $"../..".velocity != Vector2(0,0):
		set_animation("walking")
	else:
		set_animation("idle")
	$Name.text = global.playerData.name
	$LVL.text = str(global.playerData.LVL)
	$Coin.text = str(format_short_number(global.playerData.money)) + "G"
	$HP.text = str(global.playerData.HP)+"/"+str(global.playerData.MAX_HP)
	$MP.text = str(global.playerData.mana)+"/"+str(global.playerData.MAX_MANA)

func set_animation(name):
	if current_anim != name:
		current_anim = name
		anim.play(name)
