extends Control

@onready var ItemSlot = preload("res://scenes/UI/ItemSlot.tscn")
@onready var slots = $"../../SemiInput/Items/VBoxContainer"

# Called when the node enters the scene tree for the first time.
func _ready():
	if self.visible:
		for i in global.playerData.inventory:
			var new_slot = ItemSlot.instantiate()
			new_slot.itemID = i	
			
			var image = new_slot.get_node("Icon")
			  # Gán ảnh trước

			if image.texture:
				var tex_size = image.texture.get_size()
				var scale_factor = min(32.0 / tex_size.x, 32.0 / tex_size.y)
				image.scale = Vector2(scale_factor, scale_factor)
				image.position = Vector2(16, 16)  # Canh giữa slot 32x32 nếu 'centered' = true

			slots.add_child(new_slot)
			

func get_data(call_from: int):
	var conv_item = EffectManager.get_item(call_from)
	if conv_item == null:
		return

	$Armor/Name.text = conv_item.name
	$Armor/des_.text = conv_item.des

	var sprite := $Armor/Frame/Sprite2D
	sprite.texture = conv_item.texture

	if sprite.texture:
		var texture_size = sprite.texture.get_size()
		var target_size = Vector2(32*4.75, 32*5)
		sprite.scale.x = target_size.x / texture_size.x
		sprite.scale.y = target_size.y / texture_size.y



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
