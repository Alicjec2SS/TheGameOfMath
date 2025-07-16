extends CanvasLayer

@export var direction := Vector2(1, 1).normalized()
@export var leaf_count := 20
@export var leaf_scene: PackedScene
@export var leaf_animation : String = "1"  # Chọn animation lá

var leaves := []

func _ready():
	randomize()
	for i in range(leaf_count):
		spawn_leaf()

func _process(delta):
	if leaves.size() < leaf_count:
		spawn_leaf()
	leaves = leaves.filter(func(l): return is_instance_valid(l))

func spawn_leaf():
	if leaf_scene == null:
		print("Chưa gán leaf_scene!")
		return

	var leaf = leaf_scene.instantiate() as AnimatedSprite2D
	add_child(leaf)

	leaf.animation = leaf_animation  # Dùng anim chọn

	var screen_size = get_viewport().get_visible_rect().size

	var spawn_pos = Vector2()
	if randi() % 2 == 0:
		spawn_pos.x = -50
		spawn_pos.y = randf() * screen_size.y
	else:
		spawn_pos.x = randf() * screen_size.x
		spawn_pos.y = -50

	leaf.global_position = spawn_pos

	var angle_variation = deg_to_rad(randf_range(-15, 15))
	var velocity = direction.rotated(angle_variation) * randf_range(30, 100)
	leaf.set_meta("velocity", velocity)

	leaves.append(leaf)
