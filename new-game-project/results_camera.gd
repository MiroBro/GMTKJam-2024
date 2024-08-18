extends Camera3D

@export var look_thing: Node3D
@export var distance = 10.0
@export var count_down = 0.3;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.look_at(look_thing.global_position)
	count_down -= delta
	if count_down < 0.0:
		self.global_position = lerp(self.global_position, look_thing.global_position + self.global_transform.basis.z * distance, delta * 0.5)
