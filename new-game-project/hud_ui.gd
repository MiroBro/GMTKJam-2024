extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Planks Left".text = "Planks left: " + str(Globals.cut_meshes.size()) + " / " + str(Globals.number_of_pieces[Globals.level])
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
