extends TextureRect

var vectors : PackedVector2Array = []

@export var reference_mesh: MeshInstance3D
@export var reference_banana: Node3D
@export var plank_mesh: MeshInstance3D

@export var camera: Camera3D

var poly : Polygon2D = Polygon2D.new()

func set_banana_relative_pos(pos: Vector3):
	if reference_banana:
		var new_pos = camera.global_position + pos
		reference_banana.global_position.x = new_pos.x
		reference_banana.global_position.z = new_pos.z

func make_thing_ref(mesh: MeshInstance3D, ref: MeshInstance3D, diff: float = 50.0):
	ref.mesh = mesh.mesh
	ref.rotation = mesh.rotation
	ref.scale = mesh.scale

	var aabb = ref.mesh.get_aabb()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL

	var w = max(aabb.size.x, aabb.size.z)
	camera.size = max(w, max(3.0, w * 1.4))
	mesh.global_position = camera.global_position + Vector3(0.0, -diff, 0.0)

func make_thing_plank(mesh: MeshInstance3D):
	make_thing_ref(mesh, plank_mesh, 60.0)

func make_thing(mesh: MeshInstance3D):
	make_thing_ref(mesh, reference_mesh)
 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
