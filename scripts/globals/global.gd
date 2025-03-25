extends Node

signal complete_save_game
signal complete_load_game

var can_move = true
var is_interacting
var game_data
var is_changed_map_via_json = false
var is_game_data_modified = false  # Cờ theo dõi nếu dữ liệu bị thay đổi


#test paths
var save_folder_path = "res://user/"
var save_file = "testsave.tres"
var playerData = PlayerData.new()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game_data()
		get_tree().quit() # default behavior

func save_game_data():
	ResourceSaver.save(playerData, save_folder_path + save_file)
	print("Data saved!")

func load_game_data():
	playerData = ResourceLoader.load(save_folder_path + save_file).duplicate(true)
	print("Data loaded complete!")

func _ready():
	get_tree().set_auto_accept_quit(false)
	
	load_game_data()
	Transporter.change_scene(playerData.current_map_path,playerData.position)
	
func _process(delta):	
	playerData.LVL = int(floor(pow(float(playerData.EXP) / 100, 1.0 / 2)))
	if playerData.LVL > 80:
		playerData.LVL = 80
	#mỗi 10 LVL sẽ nhận được 1 skill
	playerData.enabled_skills = []
	for i in range(int(playerData.LVL / 10)):
		if i <= 6:
			playerData.enabled_skills.append(i)
	if not playerData.current_skill in playerData.enabled_skills:
		playerData.current_skill = 0
	playerData.HP = 3 + playerData.LVL
	playerData.DMG = int(playerData.HP * 0.325)
	
