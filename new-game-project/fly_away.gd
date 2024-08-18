extends RigidBody3D


# Called when the node enters the scene tree for the first time.
var dir = Vector3(1.0, 0.0, 0.0)
func _ready() -> void:
	randomize()
	dir.x = randf_range(-1.0, 1.0)
	dir.z = randf_range(-1.0, 1.0)
	dir = dir.normalized()


# Called every frame. 'delta' is the elapsed time since the previous frame.
var prev_freeze = self.freeze
var count_down = 10.0
var start_count = false
func _process(delta: float) -> void:
	if prev_freeze != self.freeze:
		self.add_constant_central_force(Vector3(0.0, 18.0, 0.0))
		start_count = true

	if start_count:
		count_down -= delta
		if count_down < 0.0:
			self.queue_free()
	
	if !self.freeze:
		var force = dir
		force.y = 0.0
		force=  force.normalized() * 10.0
		self.add_constant_central_force(force * 15.0 * delta)
	prev_freeze = self.freeze
