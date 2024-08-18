extends Control

@export var xOffset : float = 0
@export var polygon: CanvasItem

var target : Control

var targetYSize = 0

var startOffset = Vector2(0,0)
var endOffset = Vector2(0,0)
var t = 2

func set_banana_relative_pos(pos: Vector3):
	polygon.set_banana_relative_pos(pos)

func make_blueprint_from_mesh(mesh: MeshInstance3D):
	polygon.make_thing(mesh.duplicate())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = get_child(1)

	if (target):
		var sizeVec : Vector2 = target.get_parent_area_size()
		targetYSize = sizeVec[1]
		target.set_position(Vector2(0, 0))
		print(target.name)

	pass # Replace with function body.

# Dismiss the blueprint
func close_blueprint() -> void:
	if (target):
		t = 0
		startOffset = Vector2(0,0)
		endOffset = Vector2(0, targetYSize)
		
		#target.set_position(Vector2(0, targetYSize))
	pass

# Dismiss the blueprint
func open_blueprint() -> void:
	if (target):
		t = 0
		endOffset = Vector2(0,0)
		startOffset = Vector2(0, targetYSize)
		
		#target.set_position(Vector2(0, targetYSize))
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (t <= 1):
		target.set_position(startOffset.lerp(endOffset, t))
		t += delta * 2
	pass


func _on_open_blueprint_pressed() -> void:
	if (target):
		open_blueprint()
	pass # Replace with function body.


func _on_blueprint_ui_mouse_exited() -> void:
	#close_blueprint()
	pass # Replace with function body.


func _on_close_pressed() -> void:
	close_blueprint()
	pass # Replace with function body.
