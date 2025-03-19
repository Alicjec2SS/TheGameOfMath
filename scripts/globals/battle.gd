extends CanvasLayer

@onready var infoTextBox = $PlayerContainer/QuestionBox
@onready var answerBox = $AnswerBox
@onready var chatBox = $Chatbox/ChatBox
#@onready var playerHearts = $PlayerContainer/Hearts
@onready var playerCamera = $"../Camera2D" # camera để shake

var answer = ""
var turn = 1
@export var chat_tree = ["Hello Bro",
				"Let's have a fight",
				"Ansia challanged you!!!"]
@export var tran_troi = "Diss me may"
@export var opponentID = 0 
var index_of_text = 0
var question_obj
var heart_left = global.playerData.HP #= 3 -  số câu hỏi mà thằng user đần độn đã làm sai  = số mạng mà thằng user ngu dốt còn lại
@export var opponent_health = 3 # mặc định là 3. Đây là máu của thằng đối thủ
@export var EXP = 0
@export var money = 0


@export var level_question = 1
var levelQuest


var game_ended = false
var bf_game_dialog_doned = false 

signal skip_emitted 
				



func hide_all():
	$PlayerContainer.hide()
	$OpponentContainer.hide()

var counter = 0# biến đếm cho hàm process
# Called when the node enters the scene tree for the first time.
func _ready():
	match level_question:
		1:
			levelQuest = QuestGenerator.Level1
		2:
			levelQuest = QuestGenerator.Level2
		3:
			levelQuest = QuestGenerator.Level3
		4:
			levelQuest = QuestGenerator.Level4
		5:
			levelQuest = QuestGenerator.Level5
		6:
			levelQuest = QuestGenerator.Level6
	game_ended = false
	bf_game_dialog_doned = false 
	global.can_move = false
	global.is_interacting = true
	if self.visible:
		hide_all()
		$Animation.play("start_text_box")
		await get_tree().create_timer(1).timeout
		if index_of_text < len(chat_tree):
			chatBox.show()
			chatBox.text = "[center]" + chat_tree[index_of_text] + "[/center]"
			index_of_text += 1
		else:
			chatBox.hide()
	#await skip_emitted

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if not self.visible:
		global.can_move = true
		global.is_interacting = false
		return
	else:
		$OpponentContainer/OpponentHealth.text = "x" + str(opponent_health)
		$PlayerContainer/Health.text = "x" + str(heart_left)
	if Input.is_action_just_pressed("ui_accept") and not game_ended and not bf_game_dialog_doned:
		if index_of_text < len(chat_tree) and not game_ended:
			$Animation.play("end_text_box")
			await get_tree().create_timer(1).timeout
			chatBox.text = "[center]" + chat_tree[index_of_text] + "[/center]"
			index_of_text += 1
			$Animation.play("start_text_box")
			await get_tree().create_timer(1).timeout
			
		else:
			chatBox.hide()
			
			#start battle 
			#generate question 
			if counter == 0:
				bf_game_dialog_doned = true
				question_obj = levelQuest.new()
				answer = question_obj.expression[1]
				infoTextBox.text = question_obj.expression[0]
				$Animation.play("end_text_box")
				await get_tree().create_timer(1).timeout
				$Animation.play("start")
				await get_tree().create_timer(1).timeout
				counter += 1
			return


func _on_button_pressed():
	#không cho bẫm lại nuts khi đã bấm:
	$Button.disabled = true

	
	var userAnswer = answerBox.get_text()
	userAnswer = userAnswer.strip_edges()
	
	var formattedAns = []

	for i in answer:
		if i == floor(i): #int
			formattedAns.append(str(i))
		else:
			formattedAns.append(str(round(i * 100) / 100).pad_decimals(2))  # Định dạng từng phần tử


	answer = formattedAns#định dạng lại 
	#xóa nội dung của cái answerBox
	answerBox.clear()
	if userAnswer in answer:
		print("You did correct")
		opponent_health -= 1
		#await get_tree().create_timer(1).timeout #đợi một giây để thằng user ngu dốt hiểu được chuyện j vừa xảy ra
		if opponent_health == 1:
			$OpponentContainer/OpponentHealth.hide()
		elif opponent_health == 0:
			$OpponentContainer/OpponentHearts2.play("died")
		else:
			$OpponentContainer/OpponentHealth.text = "x" + str(opponent_health)
		if opponent_health <= 0:
			print("YOU WIN. Great, buddy :))))")
			await get_tree().create_timer(1).timeout #đợi một giây để thằng user ngu dốt hiểu được chuyện j vừa xảy ra
			$Animation.play("end")
			await get_tree().create_timer(1).timeout
			$Animation.play("start_text_box")
			game_ended = true
			chatBox.show()
			chatBox.text = "[center]You Win!!![/center]"
			await get_tree().create_timer(3).timeout
			chatBox.hide()
			$Animation.play("end_text_box")
			await get_tree().create_timer(1).timeout
			heart_left = global.playerData.HP
			opponent_health = 999
			$Animation.play("start_text_box")
			chatBox.show()
			game_ended = true
			chatBox.text = "[center] Your opponent said: \" " + tran_troi + " \" [/center]"
			await get_tree().create_timer(3).timeout
			$Animation.play("end_text_box")
			await get_tree().create_timer(1).timeout
			$Animation.play("start_text_box")
			chatBox.show()
			game_ended = true
			chatBox.text = "[center] Your opponent gave you  " + str(money) + "G! [/center]"
			await get_tree().create_timer(3).timeout
			$Animation.play("end_text_box")
			await get_tree().create_timer(1).timeout
			$Animation.play("start_text_box")
			chatBox.show()
			game_ended = true
			chatBox.text = "[center]You earned " + str(EXP) + " EXP! [/center]"
			await get_tree().create_timer(3).timeout
			$"../Transition".play("fade_out")
			$Animation.play("end_text_box")
			await get_tree().create_timer(1.1).timeout
			#thêm ID của opponent vào mảng để bữa sau khỏi đánh lại:
			global.playerData.defeated_ID_player.append(opponentID)
			global.playerData.EXP += self.EXP
			global.playerData.money += self.money
			
			$"../Transition".play("fade_in")
			await get_tree().create_timer(1).timeout
			
			global.can_move = true
			global.is_interacting = false
			
			self.hide()
			# setup lại cho lần sau:

	else:
		print("Incorrect")
		# bắt đầu quy trình trừ điểm:
		playerCamera.add_trauma(0.5)
		heart_left -= 1
		#await get_tree().create_timer(1).timeout #đợi một giây để thằng user ngu dốt hiểu được chuyện j vừa xảy ra
		if opponent_health == 1:
			$PlayerContainer/Health.hide()
		elif opponent_health == 0:
			$PlayerContainer/PlayerHeart.play("died")
		else:
			$PlayerContainer/Health.text = "x" + str(heart_left)
		await get_tree().create_timer(1).timeout #đợi một giây để thằng user ngu dốt hiểu được chuyện j vừa xảy ra
		$Animation.play("end")
		await get_tree().create_timer(1).timeout
		$Animation.play("start_text_box")
		chatBox.show()
		if len(answer) >= 2 :#cụ thể là 2
			chatBox.text = "[center]The correct answer were " + str(answer[0]) + " or " + str(answer[1])
		else:
			chatBox.text = "[center]The correct answer was " + str(answer) + "[/center]"
		await get_tree().create_timer(3).timeout
		chatBox.hide()
		$Animation.play("end_text_box")
		await get_tree().create_timer(1).timeout
		if heart_left <= 0:
			print("You lose. Stupid")
			# setup lại cho lần sau:
			heart_left = global.playerData.HP
			opponent_health = 999
			$Animation.play("start_text_box")
			game_ended = true
			chatBox.show()
			chatBox.text = "[center]You lost[/center]"
			await get_tree().create_timer(3).timeout
			await get_tree().create_timer(3).timeout
			chatBox.hide()
			$Animation.play("end_text_box")
			chatBox.text = "[center]You said: .. .. .. ... . . .... [/center]"
			await get_tree().create_timer(3).timeout
			$Animation.play("end_text_box")
			
			var random = RandomNumberGenerator.new()
			random.randomize()
			var payout = random.randi_range(0,global.playerData.money)
			await get_tree().create_timer(1).timeout
			$Animation.play("start_text_box")
			chatBox.show()
			game_ended = true
			chatBox.text = "[center]You gave " + str(payout) + " G for your opponent! [/center]"
			await get_tree().create_timer(3).timeout
			$"../Transition".play("fade_out")
			$Animation.play("end_text_box")
			await get_tree().create_timer(1.1).timeout
			
			global.playerData.money -= payout
			
			$"../Transition".play("fade_in")
			await get_tree().create_timer(1).timeout

			global.can_move = true
			global.is_interacting = false
			
			
			#tắt cái battle đi 
			self.hide()
		else:
			$Animation.play("start")
			await get_tree().create_timer(1).timeout
				
			
				
			
			
	
	question_obj = levelQuest.new()
	answer = question_obj.expression[1]
	infoTextBox.text = question_obj.expression[0]
	turn += 1
	
	$Button.disabled = false

