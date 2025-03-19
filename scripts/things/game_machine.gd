extends CharacterBody2D

@export var level_question:int = 1
@export var machine_name:String = "Gold Machine"
@export var exp:int = 999


func interact():
	$Image.play("on_red")
	global.can_move = false
	global.is_interacting = true
	var training_scene = get_node("/root/"+get_tree().current_scene.name+"/Player/Training")
	training_scene.level_question = level_question
	training_scene.machine_name = machine_name
	training_scene.exp = exp
	training_scene.show_dialog()
	await training_scene.doned
	$Image.play("off_red")
func _on_interact_idea_body_entered(body):
	$Label.show()

func _on_interact_idea_body_exited(body):
	if body.has_method("player"):
		$Label.hide()
	

func _ready():
	$Label.hide()
	$Image.play("off_red")
	
var checky = 0

func _process(delta):
	if checky < 1:
		$Label.hide()
		checky += 1

