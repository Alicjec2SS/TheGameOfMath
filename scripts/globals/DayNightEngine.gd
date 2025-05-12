extends CanvasModulate


@export var gradient :GradientTexture1D


func _process(_delta) -> void:
	var value = (sin(global.playerData.time-PI/2)+1.0)/2.0
	self.color = gradient.gradient.sample(value)
