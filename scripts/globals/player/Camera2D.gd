extends Camera2D

"""
	Usage : self as this node(Camera2D)
			self.add_trauma(0.5) # can replace 0.5 with any in range 0.0 to 0.5
"""


@export var decay := 0.8 # How quickly the shake decays
@export var max_offset := Vector2(10, 10) # Maximum displacement in pixels
@export var max_rotation := 0.05 # Maximum rotation in radians
@export var trauma_pwr := 2.0 # Exponent for trauma calculation

var trauma := 0.0 # Current shake strength
var random := RandomNumberGenerator.new() # Random number generator

func _ready():
	random.randomize() # Initialize RNG

# Adds trauma to the shake
func add_trauma(amount: float):
	trauma = clamp(trauma + amount, 0.0, 1.0)

# Updates shake effect
func _process(delta):
	if trauma > 0:
		var shake_intensity = pow(trauma, trauma_pwr)
		offset = Vector2(
			random.randf_range(-1, 1) * max_offset.x * shake_intensity,
			random.randf_range(-1, 1) * max_offset.y * shake_intensity
		)
		rotation = random.randf_range(-1, 1) * max_rotation * shake_intensity
		trauma = max(trauma - decay * delta, 0.0)
	else:
		offset = lerp(offset, Vector2.ZERO, 0.1)
		rotation = lerp(rotation, 0.0, 0.1)
	
	
	
