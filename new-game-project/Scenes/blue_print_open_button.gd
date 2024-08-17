extends Control

@export var xOffset : float = 0

var target : Control

var targetYSize = 0

var startOffset = Vector2(0,0)
var endOffset = Vector2(0,0)
var t = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = get_child(1)
	
	if (target):
		var size : Vector2 = target.get_parent_area_size()
		targetYSize = size[1]
		target.set_position(Vector2(0, size[1]))
		print(target.name)

	pass # Replace with function body.

# Dismiss the blueprint
func close_blueprint() -> void:
	
	if (target):
		t = 0
		startOffset = Vector2(0,0)
		endOffset = Vector2(0, targetYSize)
		
		target.set_position(Vector2(0, targetYSize))
	
	pass
	
# Dismiss the blueprint
func open_blueprint() -> void:
	
	if (target):
		t = 0
		endOffset = Vector2(0,0)
		startOffset = Vector2(0, targetYSize)
		
		target.set_position(Vector2(0, targetYSize))
	
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
	close_blueprint()
	pass # Replace with function body.


func _on_blueprint_ui_gui_input(event: InputEvent) -> void:
	if (event.is_pressed()):
		close_blueprint()
	if (event.is_action_pressed("")):
		close_blueprint()
	pass # Replace with function body.


func _on_close_pressed() -> void:
	close_blueprint()
	pass # Replace with function body.
