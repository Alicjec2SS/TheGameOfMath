extends Control

@onready var anim = $anim
var current_anim = "idle"  # Lưu trạng thái animation hiện tại


func _process(delta):
	if not self.visible:
		$"../anim".play("show")
	if $"../..".velocity != Vector2(0,0):
		set_animation("walking")
	else:
		set_animation("idle")
	$Name.text = global.playerData.name
	$LVL.text = str(global.playerData.LVL)
	$Coin.text = str(global.playerData.money) + "G"

func set_animation(name):
	if current_anim != name:
		current_anim = name
		anim.play(name)
