extends Node3D

#@onready var reference_root: Node3D = $"reference"
#@onready var project_root: Node3D = $"project" 

var reference_root: Node3D
var project_root: Node3D


func instantiate_piece(instance, counter):
	
	
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.mesh = Globals.cut_meshes[counter]
	mesh_instance.material_override = load("res://Materials/material_Wood.tres")
	mesh_instance.global_transform.origin = reference_root.get_child(counter).global_transform.origin 
	
	
	mesh_instance.rotation = reference_root.get_child(counter).rotation
	var collision_shape = CollisionShape3D.new()
	
	collision_shape.shape = mesh_instance.mesh.create_convex_shape()
	collision_shape.global_transform.origin = reference_root.get_child(counter).global_transform.origin 
	collision_shape.rotation = reference_root.get_child(counter).rotation
	


	instance.add_child(mesh_instance)
	instance.add_child(collision_shape)
			
				

func turn_project_into_colliders():
	var counter = 0
	print(reference_root)
	if reference_root:
		for root_child: Node3D in reference_root.get_children():
			var instance = RigidBody3D.new()	
			instance.mass = 100;
			instance.axis_lock_angular_x = true
			
			instance.axis_lock_angular_y = true
			instance.axis_lock_angular_z = true
			instance.axis_lock_linear_x = true
			instance.axis_lock_linear_y = false
			instance.axis_lock_linear_z = true
			
			instantiate_piece(instance, counter)			
					#child_mesh.scale = reference_root.get_child(counter).scale 
			if project_root:
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

	reference_root = load("res://building_blocks/projects/reference.tscn").instantiate()
	add_child(reference_root)
	project_root = load("res://building_blocks/projects/project.tscn").instantiate()
	add_child(project_root)
	#reference_root.global_transform.origin = Vector3(0,0,0)
	#project_root.global_transform.origin = Vector3(0,0,0)
	
	turn_project_into_colliders()

	freeze_physics(true);
	
	#var reference_children = reference_root.get_children() 
	#var project_children = project_root.get_children()
	#
	#for i in range(len(reference_children)):
		#var ref: MeshInstance3D = reference_children[i]
		#var pr: Node3D = project_children[i]

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
	if Input.is_key_pressed(KEY_ENTER):
		Globals.level += 1
		Globals.cut_meshes.clear()

		if Globals.level >= Globals.number_of_levels:
			SceneTransition.change_scene("res://Scenes/Ending.tscn")
		else:
			get_tree().change_scene_to_file("res://splitting_algorithm_scene.tscn")
		
	if Input.is_key_pressed(KEY_SPACE):
	#if Input.is_action_just_pressed("start_physics"):
		freeze_physics(false);
	pass


	pass # Replace with function body.



func freeze_physics(frozen: bool) -> void:
	if project_root:
		var nodes: Array[Node] = project_root.get_children();
		for node in nodes:
			
			for child in node.get_children():
				if child is RigidBody3D:
					child.freeze = frozen;
			pass # Replace with function body.
