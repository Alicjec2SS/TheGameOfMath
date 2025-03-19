extends CanvasLayer

@onready var anim = $AnimationPlayer
@onready var input = $AnswerBox
@onready var enter = $Submit
@onready var chatbox = $ChatBox

@export var level_question: int = 1
@export var machine_name: String = "Gold Machine"
@export var exp: int = 999

var messes = [
	"You turned on the " + machine_name,
	"Answer the question to gain " + str(exp) + " EXP"
]
var index = 0
var ended_text = false
var sins
var squestion
var sanswer

signal doned
# Engine setup
var levelQuest

func _ready():
	match level_question:
		1: levelQuest = QuestGenerator.Level1
		2: levelQuest = QuestGenerator.Level2
		3: levelQuest = QuestGenerator.Level3
		4: levelQuest = QuestGenerator.Level4
		5: levelQuest = QuestGenerator.Level5
		6: levelQuest = QuestGenerator.Level6
	messes = [
	"You turned on the " + machine_name,
	"Answer the question to gain " + str(exp) + " EXP"
	]
	global.can_move = false
	global.is_interacting = true
	self.hide()  # Ẩn hộp thoại ngay từ đầu để không hiện lên khi game bắt đầu

func show_dialog():
	self.show()
	self.visible = true
	index = 0
	ended_text = false
	did = false
	counter = 0
	is_animating = false

	chatbox.text = "[center]" + messes[index] + "[/center]"
	index += 1
	anim.play("start_text_box")

func close_dialog():
	self.hide()
	global.can_move = true
	global.is_interacting = false

var counter = 0
var did = false
var is_animating = false  # Chặn spam input

func _process(delta):
	match level_question:
		1: levelQuest = QuestGenerator.Level1
		2: levelQuest = QuestGenerator.Level2
		3: levelQuest = QuestGenerator.Level3
		4: levelQuest = QuestGenerator.Level4
		5: levelQuest = QuestGenerator.Level5
		6: levelQuest = QuestGenerator.Level6
	if not self.visible:
		return

	if self.visible and not did and chatbox.text.strip_edges() == "":
		anim.play("start_text_box")
		await get_tree().create_timer(1).timeout
		if index < len(messes):
			chatbox.text = "[center]" + messes[index] + "[/center]"
			index += 1
		did = true

	if Input.is_action_just_released("ui_accept") and not ended_text and not is_animating:
		is_animating = true  # Chặn input khi hiệu ứng đang chạy
		if index < len(messes):
			anim.play("end_text_box")
			await get_tree().create_timer(1).timeout
			chatbox.text = "[center]" + messes[index] + "[/center]"
			index += 1
			anim.play("start_text_box")
			await get_tree().create_timer(1).timeout
		else:
			if counter == 0:
				counter += 1
				anim.play("end_text_box")
				await get_tree().create_timer(1).timeout
				sins = levelQuest.new()
				sanswer = sins.expression[1]
				squestion =sins.expression[0]
				chatbox.text = "[center]" + squestion + "[/center]"
				anim.play("start")
				await get_tree().create_timer(1).timeout
		is_animating = false  # Cho phép nhấn lại sau khi hiệu ứng kết thúc

func _on_submit_pressed():
	enter.disabled = true
	var userAnswer = input.get_text().strip_edges()
	var formattedAns = []
	
	for i in sanswer:
		if i == floor(i):  # Nếu là số nguyên
			formattedAns.append(str(i))
		else:
			formattedAns.append(str(round(i * 100) / 100).pad_decimals(2))

	sanswer = formattedAns  # Định dạng lại
	input.clear()
	if userAnswer in sanswer:
		anim.play("end")
		await get_tree().create_timer(1).timeout
		anim.play("start_text_box")
		chatbox.text = "[center]You did correct[/center]"
		await get_tree().create_timer(3).timeout
		anim.play("end_text_box")
		await get_tree().create_timer(1).timeout
		anim.play("start_text_box")
		chatbox.text = "[center]You earned " + str(exp) + " EXP[/center]"
		global.playerData.EXP += int(exp)
		await get_tree().create_timer(3).timeout
		anim.play("end_text_box")
		await get_tree().create_timer(1).timeout
	else:
		anim.play("end")
		await get_tree().create_timer(1).timeout
		anim.play("start_text_box")
		chatbox.text = "[center]You did wrong[/center]"
		await get_tree().create_timer(3).timeout
		anim.play("end_text_box")
		await get_tree().create_timer(1).timeout
		anim.play("start_text_box")
		if len(sanswer) > 1:
			chatbox.text = "[center]The correct answer was " + sanswer[0] + " or " + sanswer[1] + "[/center]"
		else:
			chatbox.text = "[center]The correct answer was " + sanswer[0] + "[/center]"
		await get_tree().create_timer(3).timeout
		anim.play("end_text_box")
		await get_tree().create_timer(1).timeout
	
	enter.disabled = false
	doned.emit()
	close_dialog()  # Đóng hộp thoại sau khi hoàn thành trả lời
