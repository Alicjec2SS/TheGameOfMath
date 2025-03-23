extends Resource
class_name PlayerData

@export var position:Vector2
@export var current_map_path = "res://scenes/levels/level2.tscn" 
@export var money = 0 

#mảng lưu trữ những npc mà người chơi đã đánh bại
@export var defeated_ID_player = []

#số lượng tim của người chơi hiện có:
@export var HP = 3 #mới đầu sẽ là 0
@export var EXP = 0
@export var LVL = 1
@export var name = "Alice"
