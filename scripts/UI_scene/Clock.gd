extends Control

@onready var animsprite = $AnimatedSprite2D
@onready var time = $Label
@onready var day = $Label2

const min_in_day = 1440
const min_in_hour = 60
const ingame1day = (2*PI)/min_in_day

func _ready():
	recalc()

func _process(_delta):
	recalc()
		
func recalc() -> void:
	var total_min = int(global.playerData.time / ingame1day)
	global.playerData.day = int(total_min/min_in_day)+1
	var cur_day_min = total_min % min_in_day
	var hour = int(cur_day_min / min_in_hour)
	var min = cur_day_min - hour*min_in_hour
	if hour <= 6:
		animsprite.play("dawn")
	elif hour <= 12:
		animsprite.play("day")
	elif hour <= 18:
		animsprite.play("noon")
	else:
		animsprite.play("night")
	time.text = str(hour)+':'+str(min)
	day.text = str(global.playerData.day)
	
	
		

		
	
