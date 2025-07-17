extends CharacterBody2D

@export var global_id: String
@export var item_id: int = 0
@export var size: Vector2

@export var sp: Sprite2D
@export var hitbox: Area2D
@onready var label: Label = $ClaimedLabel

func _ready():
	# Tự động sinh global_id nếu chưa có
	if global_id == "":
		global_id = generate_unique_id()
		print("Generated ID:", global_id)

	# Nếu item đã được nhặt rồi
	if global_id in global.playerData.picked_item_id:
		self.queue_free()
		return

	# Kiểm tra texture
	if sp.texture == null:
		push_error("Sprite2D chưa có texture!")
		return

	var tex_size = sp.texture.get_size()
	if tex_size.x == 0 or tex_size.y == 0:
		push_error("Texture không có kích thước hợp lệ!")
		return

	# Scale sprite
	sp.scale = size / tex_size
	print("Scale:", sp.scale)

	# Kết nối hitbox
	if hitbox:
		hitbox.connect("input_event", _on_hitbox_input_event)
	else:
		push_warning("Không tìm thấy Hitbox!")

func generate_unique_id() -> String:
	var scene_name = get_tree().current_scene.name
	var path_str = str(get_path()).replace("/", "_")
	return scene_name + path_str

func _on_hitbox_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Gotchu")
		sp.hide()
		global.playerData.inventory.append(item_id)
		global.playerData.picked_item_id.append(global_id)
		show_claimed_effect()

func show_claimed_effect():
	label.text = "Item Claimed"
	label.visible = true
	label.modulate.a = 1.0
	label.position = Vector2(0, -20)

	var tween = create_tween()
	tween.tween_property(label, "position", label.position + Vector2(0, -30), 1.2).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.2).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(Callable(label, "hide"))
	tween.tween_callback(Callable(self, "queue_free"))
