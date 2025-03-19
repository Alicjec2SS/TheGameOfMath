extends CharacterBody2D

#khai báo đây là player
func player():pass



#varible setups
#các biến động
var direction = null
var anchor = ""
var last_state = "down"#đặt last state quyết định anchor cho engine 8 hướng

#biến thiết lập(bán tĩnh)
@export var speed = 75

#biến tĩnh(các obj)
@onready var Anim = $AnimatedSprite2D

func ready():
	self.global_position.x = Transporter.next_pos.x
	self.global_position.y = Transporter.next_pos.y

func move(delta):
	#thiết lập biến direction thành Vector2 (x,y)
	direction = Vector2()
	
	#kiểm tra event:
	if Input.is_action_pressed("up"):
		direction.y = -1
		last_state = "up"
	if Input.is_action_pressed("down"):
		direction.y = 1
		last_state = "down"
	if Input.is_action_pressed("left"):
		direction.x = -1
	if Input.is_action_pressed("right"):
		direction.x = 1
	

	#biến dữ liệu của direction thành velocity
	if global.can_move:
		direction = direction.normalized()
		velocity = direction*speed*delta*100
	else:
		velocity = Vector2()

#save engine support function
func update_data_to_global():
	global.playerData.position = self.global_position

func _physics_process(delta):
	if global.can_move:
		move(delta)
		move_and_slide()
	#print(global.can_move)
	update_data_to_global()
	process_animation_by_direction(direction)
	
func process_animation_by_direction(_direction):
	var anim
	if global.can_move:
		if _direction.y == 1:#đi xuống
			anchor = "down"
		if _direction.y == -1:#đi lên
			anchor = "up"
		if _direction.x == 1:#tức là qua phải
			anchor = "right"
		if _direction.x == -1:#tức là qua trái
			anchor = "left"
		if _direction.x == 0 and direction.y == 0:
			anchor = ""#không di chuyển
	
		if anchor == "":
			anim = Anim.animation
			anim = anim.replace("walk","idle")
		else:
			anim = ""
			if anchor == "down" or anchor == "up":
				anim = "walk_" + anchor
			else:
				anim = "walk_" + last_state + "_" + anchor
		Anim.play(anim)
	else:
		anim = Anim.animation
		anim = anim.replace("walk","idle")
		Anim.play(anim)
		

