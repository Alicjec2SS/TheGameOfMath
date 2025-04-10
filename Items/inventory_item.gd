extends Resource 

#form
class_name InvItem

@export_group("Item Info")
@export var ID:int = 0
@export var des:String = "This is an item"
@export var name:String = "This is the name of the item"
@export var texture:Texture2D
@export var type:String = "Consumable item"
@export var sell:int = 10
@export var rank:String = "Common"
#thông số hiệu ứng

#recently effect

@export_group("Recently Effects") 
@export var time_effect:bool = false
@export var duration = -1
@export var effect_time_space = 1#sô lần chững 

@export_group("Recently Effects/Time Pulse Included")
@export var add_HP_by_number = 0
@export var add_HP_by_percentage = -1
@export var add_MP_by_number = 0
@export var add_MP_by_percentage = -1

#hai nhân tố không cần pulse như các cái ở trên
@export_group("Recently Effects/Time Pulse Not Included")
@export var add_speed_by_number = 0
@export var add_speed_by_percentage = -1


func recently_effect():
	#nếu second mà lớn hơn 0 thì hiệu ứng sẽ chạy đến hết thời gian thì thôi, 
	#nếu không thì cộng thẳng vào máu hoặc năng lượng gì đó hiện tại
	EffectManager.apply_item_effect(self)
	
func during_battle(turn:int):
	pass#node battle sẽ truyền vào từng item đang dược kích hoạt turn để từ đó nó chạy, hiệu ứng trong hàm này sẽ tồn tại cho đến khi kết thúc trận đấu

func after_battle(result):
	pass#result cũng sec được truyền vào y chang như turn của hàm during battle

func on_question_answered(corection:bool):
	pass#y chang với correction là kết quả đúng sai của cái câu hỏi vừa được trả lời
