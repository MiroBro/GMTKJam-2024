extends Node3D

@onready var reference_root: Node3D = $"reference"
@onready var project_root: Node3D = $"project" 

func instantiate_piece(instance, counter):
	
	
	var child_mesh: MeshInstance3D = MeshInstance3D.new()
	child_mesh.mesh = Globals.mesh
	
	child_mesh.global_transform.origin = reference_root.get_child(counter).global_transform.origin
	print("positon",child_mesh.global_transform.origin)

	#child_mesh.scale = Vector3(5,5,5)
	#child_mesh.rotation = reference_root.get_child(counter).rotation
	
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = child_mesh.mesh.create_convex_shape()
	#collision_shape.scale = reference_root.get_child(counter).scale
	instance.add_child(child_mesh)
	instance.add_child(collision_shape)
			
				#var box_shape: BoxShape3D = child.shape
				#box_shape.size = reference_root.get_child(counter).scale
			
				

func turn_project_into_colliders():
	var counter = 0
	for root_child: Node3D in reference_root.get_children():
		var scene = null
	
		scene = load("res://building_blocks/wall.tscn")
				
		var instance = scene.instantiate()
		instantiate_piece(instance, counter)		
		
				#child_mesh.scale = reference_root.get_child(counter).scale 
		project_root.get_child(counter).add_child(instance)
		counter += 1	
		#var rb = RigidBody3D.new()
		#rb.name = child.name
		#child.add_child(rb)
		##child.reparent(rb)
#
		#var cs = CollisionShape3D.new()
		#var shape = BoxShape3D.new()
		#shape.size = Vector3(1,1,1)
		#cs.shape = shape 
			#
		#
		##cs.make_convex_from_siblings()
		#child.add_child(cs)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	turn_project_into_colliders()

	freeze_physics(true);
	
	var reference_children = reference_root.get_children() 
	var project_children = project_root.get_children()
	
	for i in range(len(reference_children)):
		var ref: MeshInstance3D = reference_children[i]
		var pr: Node3D = project_children[i]

		#var offset = reference_root.global_position - ref.global_position
		#var rot = ref.quaternion
		
	   
		#pr.global_transform.origin = ref.global_transform.origin
		#pr.position = ref.position
		#pr.scale = ref.scale
		#pr.rotation = ref.rotation
		
		#pr.global_position = project_root.global_position + offset
		#pr.quaternion = rot


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#var project_children = project_root.get_children()
	#for project_child in project_children:
		#print(project_child)	
	
	if Input.is_key_pressed(KEY_SPACE):
	#if Input.is_action_just_pressed("start_physics"):
		freeze_physics(false);
	pass


	pass # Replace with function body.



func freeze_physics(frozen: bool) -> void:
	var nodes: Array[Node] = project_root.get_children();
	for node in nodes:
		
		for child in node.get_children():
			if child is RigidBody3D:
				child.freeze = frozen;
		pass # Replace with function body.
