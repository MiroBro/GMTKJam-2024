extends Node2D



func _on_play_pressed() -> void:
	
	print("hi")
	
	SceneTransition.change_scene("res://Scenes/IntroScene.tscn")
	
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	
	get_tree().quit()
	
	pass # Replace with function body.
