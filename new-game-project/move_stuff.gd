extends Node3D

@onready var reference_root: Node3D = $"reference"
@onready var project_root: Node3D = $"project" 


func turn_project_into_colliders():
	for child in project_root.get_children():
		var rb = RigidBody3D.new()
		rb.name = child.name
		project_root.add_child(rb)
		child.reparent(rb)

		var cs = CollisionShape3D.new()
		cs.make_convex_from_siblings()
		rb.add_child(cs)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	turn_project_into_colliders()
	
	freeze_physics(true);
	
	var reference_children = reference_root.get_children() 
	var project_children = project_root.get_children()
	
	for i in range(len(reference_children)):
		var ref: Node3D = reference_children[i]
		var pr: Node3D = project_children[i]

		var offset = ref.position
		var rot = ref.rotation

		pr.position = project_root.global_position + offset
		pr.rotation = rot


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("start_physics"):
		freeze_physics(false);
	pass


func freeze_physics(frozen: bool) -> void:
	var meshes = project_root.get_children();
	for mesh: RigidBody3D in meshes:
		mesh.freeze = frozen;
	pass # Replace with function body.
