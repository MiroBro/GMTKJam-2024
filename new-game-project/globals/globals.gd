extends Node


var level = 0
var mesh_to_cut: MeshInstance3D
var mesh = ImmediateMesh.new()
var cut_meshes: Array[ImmediateMesh]
var number_of_pieces = [3, 5, 5, 5]

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
