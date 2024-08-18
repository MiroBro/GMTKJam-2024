extends Camera3D

@export var decay = 0.9  # How quickly the shaking stops [0, 1].
@export var max_offset = Vector2(0.03, 0.03)
@export var max_roll = 0.01  # Maximum rotation in radians (use sparingly).

var impulse = false;

var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].

var original_pos = self.position
var target_rot = self.quaternion
var offset = Vector3(0.0, 0.0, 0.0)

func _ready():
	randomize()

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)
	
func add_impulse():
		impulse = true

func _process(delta: float):
	var target_pos = original_pos + offset
	position = lerp(position, target_pos, 1 - exp(-delta * 32) )
	quaternion = lerp(quaternion, target_rot, 1 - exp(-delta * 32))

	if trauma != 0.0:
		var it = 1.0 - exp(-delta)
		trauma = lerp(trauma, 0.0, it)
		shake()

func shake():
	var amount = pow(trauma, trauma_power)
	var angle = max_roll * amount * randf_range(-1, 1)
	var T = 1
	#if impulse:
	angle = clamp(angle,-T,T)
	#self.rotate_z(angle)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)
	
	var X = 0.03
	
	offset.x = clamp(offset.x, -X, X)
	offset.y = clamp(offset.y, -X, X)

	
