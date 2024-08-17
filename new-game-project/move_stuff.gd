extends Node3D

@onready var testmesh2 = $"testmesh2"

@onready var g = $"project_1" 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	freeze_physics(true);
	var meshes = g.get_children();
	for mesh: RigidBody3D in meshes:
		pass
		#mesh.position.z += 10;
		
	#turn_test_mesh_into_rigid_body();
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if Input.is_action_just_pressed("start_physics"):
		freeze_physics(false);

	pass

	
func turn_test_mesh_into_rigid_body():
	
	var mesh = Mesh.new()
	#testmesh2.create_trime
	##testmesh2.
	#var rb = RigidBody3D.new();
	#
	#var cs = CollisionShape3D.new();
	#add_child(cs);
	#cs.create	
	#rb.add_child(testmesh2);
	
	#rb.add_constant_force(Vector3.ONE * 10);

	
	
	#testmesh2.colli;
	#testmesh.global_position = Vector3.ONE;
	#
	#get_tree().root.add_child(rb);
	#print("hello")
	#testmesh.create_convex_collision(false, false);
	
	


func freeze_physics(frozen: bool) -> void:
	
	var meshes = g.get_children();
	for mesh: RigidBody3D in meshes:
		mesh.freeze = frozen;
	pass # Replace with function body.
