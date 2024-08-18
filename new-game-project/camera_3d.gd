extends Camera3D

@export var decay = 0.9  # How quickly the shaking stops [0, 1].
@export var max_offset = Vector2(0.01, 0.01)
@export var max_roll = 0.01  # Maximum rotation in radians (use sparingly).

var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].

var target_pos = self.position
var target_rot = self.quaternion
var offset = Vector3(0.0, 0.0, 0.0)

func _ready():
	randomize()

func add_trauma(amount):
	trauma = min(trauma + amount, 2.0)

func _process(delta: float):
	position = lerp(position, target_pos + offset, delta * 32.0)
	self.quaternion = lerp(self.quaternion, target_rot, 32.0 * delta)

	if trauma != 0.0:
		trauma = clamp(trauma, 0.0, 1.0)
		var it = 1.0 - exp(-delta)
		trauma = max(trauma - decay * it, 0)
		shake()

func shake():
	var amount = pow(trauma, trauma_power)
	var angle = max_roll * amount * randf_range(-1, 1)
	self.rotate_z(angle)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)
