extends CharacterBody2D

@onready var SellEngine:CanvasLayer = $"../../Player/SellDialog"

@export var artID = 0
@onready var Anim = $AnimatedSprite2D
@export var dialog_tree='gaylordchatting'

@export_group("Seller settings")
@export var buy_greeting:String
@export var sell_greeting:String
@export_range(0.0,1.0) var resale_value_percentage: float # 0.0 to 1.0
@export var items:Array[Array] = [[1,-1,1],[202,2,10000]]


#items look like this:
# [[itemID,amount = -1,price]]
#amount = -1 is infinity


func _ready():
	Anim.play(str(artID))

func exit_dialog(arg:String):
	if arg=='quit':
		global.can_move=true
		global.is_interacting=false
		SellEngine._start_sell_dialog(buy_greeting,sell_greeting,resale_value_percentage,items)

func interact():
	global.can_move=false
	global.is_interacting=true
	if dialog_tree:
		Dialogic.start(dialog_tree)

		if not Dialogic.signal_event.is_connected(exit_dialog):
			Dialogic.signal_event.connect(exit_dialog)
		
	else:
		#để sell vào đây 
		SellEngine._start_sell_dialog(buy_greeting,sell_greeting,resale_value_percentage,items)
