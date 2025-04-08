extends CanvasLayer

@onready var infoTextBox = $PlayerContainer/QuestionBox
@onready var answerBox = $AnswerBox
@onready var chatBox = $Chatbox/ChatBox
@onready var playerCamera = $"../Camera2D"
@onready var timer = $Timer

var answer = ""
var turn = 1
@export var chat_tree = ["Hello Bro", "Let's have a fight", "Ansia challanged you!!!"]
@export var tran_troi = "Diss me may"
@export var opponentID = 0 
var index_of_text = 0
var question_obj
@export var heart_left = 1
@export var opponent_health = 3
@export var EXP = 0
@export var money = 0
@export var UI: CanvasLayer
@export var delay_time: int = 5
@export var oponent_damage = 1

var effect_id = global.playerData.current_skill
@export var level_question = 1
var levelQuest

var game_ended = false
var bf_game_dialog_doned = false 
var is_totem_available = false
var x2damage = false

func _ready():
	match level_question:
		1: levelQuest = QuestGenerator.Level1
		2: levelQuest = QuestGenerator.Level2
		3: levelQuest = QuestGenerator.Level3
		4: levelQuest = QuestGenerator.Level4
		5: levelQuest = QuestGenerator.Level5
		6: levelQuest = QuestGenerator.Level6
	
	reset_game()  # Reset trạng thái ban đầu
	global.can_move = false
	global.is_interacting = true
	if self.visible:
		start_initial_dialog()

func reset_game():
	game_ended = false
	bf_game_dialog_doned = false
	index_of_text = 0
	turn = 1
	heart_left = global.playerData.HP
	opponent_health = 3
	answerBox.clear()
	chatBox.hide()
	infoTextBox.text = ""
	$Button.disabled = false
	timer.stop()
	$OpponentContainer/OpponentHealth.show()
	$PlayerContainer/Health.show()
	$OpponentContainer/OpponentHearts2.play("alive")  # Reset animation
	$PlayerContainer/PlayerHeart.play("alive")  # Reset animation

func start_initial_dialog():
	$Animation.play("start_text_box")
	await get_tree().create_timer(1).timeout
	if index_of_text < len(chat_tree):
		chatBox.show()
		chatBox.text = "[center]" + chat_tree[index_of_text] + "[/center]"
		index_of_text += 1
	else:
		chatBox.hide()
		bf_game_dialog_doned = true
		start_new_turn()

func _process(delta):
	if game_ended:
		return  # Thoát sớm nếu game đã kết thúc
	timer.wait_time = delay_time
	UI.get_node("Mini/HP_Bar").value = heart_left
	if effect_id == 3 and heart_left > 0:
		heart_left = 1
		x2damage = true
	if not self.visible:
		global.can_move = true
		global.is_interacting = false
		apply_effects()
		return
	else:
		$OpponentContainer/OpponentHealth.text = "x" + str(opponent_health)
		$PlayerContainer/Health.text = "x" + str(heart_left)

	if Input.is_action_just_pressed("ui_accept") and not game_ended and not bf_game_dialog_doned:
		if index_of_text < len(chat_tree):
			$Animation.play("end_text_box")
			await get_tree().create_timer(1).timeout
			chatBox.text = "[center]" + chat_tree[index_of_text] + "[/center]"
			index_of_text += 1
			$Animation.play("start_text_box")
			await get_tree().create_timer(1).timeout
		else:
			chatBox.hide()
			bf_game_dialog_doned = true
			start_new_turn()

func apply_effects():
	if effect_id == 4:
		is_totem_available = true
	elif effect_id == 3:
		heart_left = 1
		x2damage = true
	elif effect_id == 2:
		heart_left = int(global.playerData.HP / 2)
		EXP *= 1.5
	elif effect_id == 5:
		heart_left = int(global.playerData.HP * 0.65)
		global.playerData.DMG *= 1.5
	elif effect_id == 6:
		heart_left *= 2
	else:
		is_totem_available = false
		x2damage = false

func start_new_turn():
	apply_effects()
	if not levelQuest:
		print("Error: levelQuest is not defined!")
		return
	question_obj = levelQuest.new()
	if not question_obj or not question_obj.expression:
		print("Error: Failed to create question_obj or expression is invalid!")
		return
	answer = question_obj.expression[1]
	infoTextBox.text = "[center]" + question_obj.expression[0] + "[/center]"
	chatBox.hide()
	$Animation.play("start")
	await get_tree().create_timer(1).timeout
	timer.stop()
	timer.start()
	$Button.disabled = false

func _on_button_pressed():
	$Button.disabled = true
	timer.stop()
	var userAnswer = answerBox.get_text().strip_edges()
	answerBox.clear()

	var formattedAns = []
	for i in answer:
		if i == floor(i):
			formattedAns.append(str(i))
		else:
			formattedAns.append(str(round(i * 100) / 100).pad_decimals(2))
	answer = formattedAns

	$Animation.play("end")
	await get_tree().create_timer(1).timeout
	if userAnswer in answer:
		handle_correct_answer()
	else:
		handle_incorrect_answer()

func handle_correct_answer():
	print("You did correct")
	if x2damage:
		opponent_health -= 2 * global.playerData.DMG
	elif effect_id == 5:
		opponent_health -= 1.5 * global.playerData.DMG
	else:
		opponent_health -= global.playerData.DMG

	if opponent_health <= 0:
		$OpponentContainer/OpponentHearts2.play("died")
		$OpponentContainer/OpponentHealth.hide()
		handle_victory()
	else:
		if opponent_health == 1:
			$OpponentContainer/OpponentHealth.hide()
		else:
			$OpponentContainer/OpponentHealth.text = "x" + str(opponent_health)
		turn += 1
		start_new_turn()

func handle_incorrect_answer():
	print("Incorrect")
	playerCamera.add_trauma(0.5)
	if is_totem_available:
		is_totem_available = false
		print("totem")
		$Animation.play("end")
		await get_tree().create_timer(1).timeout
		$Animation.play("start_text_box")
		chatBox.show()
		chatBox.text = "[center]Totem saved you[/center]"
		await get_tree().create_timer(3).timeout
		$Animation.play("end_text_box")
		await get_tree().create_timer(1).timeout
		chatBox.hide()
		start_new_turn()
	else:
		heart_left -= oponent_damage * (100 / (100 + global.playerData.DEF))
		if heart_left <= 0:
			$PlayerContainer/PlayerHeart.play("died")
			handle_defeat()
		else:
			if heart_left == 1:
				$PlayerContainer/Health.hide()
			else:
				$PlayerContainer/Health.text = "x" + str(heart_left)
			await show_correct_answer()
			turn += 1
			start_new_turn()

func show_correct_answer():
	await get_tree().create_timer(1).timeout
	$Animation.play("end")
	await get_tree().create_timer(1).timeout
	$Animation.play("start_text_box")
	chatBox.show()
	if len(answer) >= 2:
		chatBox.text = "[center]The correct answer were " + str(answer[0]) + " or " + str(answer[1]) + "[/center]"
	else:
		chatBox.text = "[center]The correct answer was " + str(answer[0]) + "[/center]"
	await get_tree().create_timer(3).timeout
	$Animation.play("end_text_box")
	await get_tree().create_timer(1).timeout
	chatBox.hide()

func handle_victory():
	print("YOU WIN. Great, buddy :))))")
	await get_tree().create_timer(1).timeout
	$Animation.play("end")
	await get_tree().create_timer(1).timeout
	$Animation.play("start_text_box")
	game_ended = true
	chatBox.show()
	chatBox.text = "[center]You Win!!![/center]"
	await get_tree().create_timer(3).timeout
	$Animation.play("end_text_box")
	await get_tree().create_timer(1).timeout
	chatBox.hide()
	heart_left = global.playerData.HP
	opponent_health = 999
	$Animation.play("start_text_box")
	chatBox.show()
	chatBox.text = "[center] Your opponent said: \" " + tran_troi + " \" [/center]"
	await get_tree().create_timer(3).timeout
	$Animation.play("end_text_box")
	await get_tree().create_timer(1).timeout
	$Animation.play("start_text_box")
	chatBox.show()
	chatBox.text = "[center] Your opponent gave you  " + str(money) + "G! [/center]"
	await get_tree().create_timer(3).timeout
	$Animation.play("end_text_box")
	await get_tree().create_timer(1).timeout
	$Animation.play("start_text_box")
	chatBox.show()
	chatBox.text = "[center]You earned " + str(EXP) + " EXP! [/center]"
	await get_tree().create_timer(3).timeout
	$"../Transition".play("fade_out")
	$Animation.play("end_text_box")
	await get_tree().create_timer(1.1).timeout
	global.playerData.defeated_ID_player.append(opponentID)
	global.playerData.EXP += self.EXP
	global.playerData.money += self.money
	$"../Transition".play("fade_in")
	await get_tree().create_timer(1).timeout
	reset_game()  # Reset trước khi thoát
	global.can_move = true
	global.is_interacting = false
	global.playerData.HP = heart_left
	self.hide()

func handle_defeat():
	print("You lose. Stupid")
	UI.get_node("Mini/anim").play("death")
	await get_tree().create_timer(1).timeout
	UI.get_node("Mini/anim").play("die")
	heart_left = global.playerData.HP
	opponent_health = 999
	$Animation.play("start_text_box")
	game_ended = true
	chatBox.show()
	chatBox.text = "[center]You lost[/center]"
	await get_tree().create_timer(3).timeout
	$Animation.play("end_text_box")
	await get_tree().create_timer(1).timeout
	chatBox.show()
	chatBox.text = "[center]You said: .. .. .. ... . . .... [/center]"
	await get_tree().create_timer(3).timeout
	$Animation.play("end_text_box")
	await get_tree().create_timer(1).timeout
	var random = RandomNumberGenerator.new()
	random.randomize()
	var payout = random.randi_range(0, global.playerData.money)
	$Animation.play("start_text_box")
	chatBox.show()
	chatBox.text = "[center]You gave " + str(payout) + " G for your opponent! [/center]"
	await get_tree().create_timer(3).timeout
	$"../Transition".play("fade_out")
	$Animation.play("end_text_box")
	await get_tree().create_timer(1.1).timeout
	global.playerData.money -= payout
	$"../Transition".play("fade_in")
	UI.get_node("anim").play("end")
	await get_tree().create_timer(1).timeout
	reset_game()  # Reset trước khi thoát
	global.playerData.HP = global.playerData.MAX_HP
	global.can_move = true
	global.is_interacting = false
	self.hide()

func _on_timer_timeout():
	if not self.visible or not bf_game_dialog_doned:
		return
	$Button.disabled = true
	handle_incorrect_answer()
