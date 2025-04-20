extends Resource
class_name PlayerData

@export var position:Vector2
@export var current_map_path = "res://scenes/levels/level2.tscn" 
@export var money = 0 

#mảng lưu trữ những npc mà người chơi đã đánh bại
@export var defeated_ID_player = []

#số lượng tim của người chơi hiện có:
@export var HP = 3 #mới đầu sẽ là 0
@export var DMG = 1
@export var EXP = 0
@export var LVL = 1
@export var name = "Alice"
@export var MAX_HP = 3
@export var mana = 100
@export var MAX_MANA = 100
@export var DEF:int = 0

@export var enabled_skills = [0]
@export var current_skill = 0
@export var waiting_items_effect: Array[int] = []#lưu ID các vật phẩm sửa soạn dùng
@export var add_speed = 0
@export var speed = 75

@export var using_equips = [201,202]
#item[0] là armor , item[1] là weapon
#lưu ID giống waiting_items_effect


func recovery(a_HP=0,a_MP=0):
	if HP + a_HP <= MAX_HP:
		HP += a_HP
	else:
		HP = MAX_HP 
	if mana + a_MP <= MAX_MANA:
		mana += a_MP
	else:
		mana = MAX_MANA

func adding_speed(amount:float,duration,percentage:bool=false):
	if percentage:
		add_speed = int(speed * amount)
	else:
		add_speed = amount
	await TimeManager.get_tree().create_timer(duration).timeout
	add_speed = 0
