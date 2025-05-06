extends Control

var nodes_index = ["main", "inventory"] #,"settings"]
var current_index = 0
var is_transitioning = false

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("backpack") and not $"../BIG_anim".is_playing(): 
		handle_backpack_action()

	if not $Main.visible or $Inventory.visible:
		if not global.is_interacting and global.can_move:
			global.can_move = true
			global.is_interacting = false
		return
	
	global.can_move = false
	global.is_interacting = true

func handle_backpack_action() -> void:
	if is_transitioning:
		return

	is_transitioning = true

	if $Main.visible or $Inventory.visible:
		await _end()
	else:
		await _show()

	is_transitioning = false


func _on_right_pressed():
	if current_index + 1 <= len(nodes_index) - 1:
		var next_index = current_index + 1
		var anim_name = "switch_from_" + nodes_index[current_index] + "_to_" + nodes_index[next_index]
		if $"../BIG_anim".has_animation(anim_name):
			$"../BIG_anim".play(anim_name)
			current_index = next_index

func _on_left_pressed():
	if current_index - 1 >= 0:
		var prev_index = current_index - 1
		var anim_name = "switch_from_" + nodes_index[current_index] + "_to_" + nodes_index[prev_index]
		if $"../BIG_anim".has_animation(anim_name):
			$"../BIG_anim".play(anim_name)
			current_index = prev_index

func _show():
	if not $Main.visible and not $Inventory.visible:
		$"../BIG_anim".play("start")
		await $"../BIG_anim".animation_finished
		$Main.visible = true  # hoặc $Inventory.visible = true nếu muốn mở inventory trước
		current_index = 0

func _end():
	if $Main.visible or $Inventory.visible:
		$"../BIG_anim".play("end")
		await $"../BIG_anim".animation_finished
		$Main.visible = false
		$Inventory.visible = false
		current_index = 0

