extends Node2D



func _on_play_pressed() -> void:
	
	$ClickSFX.play()
	
	SceneTransition.change_scene("res://Scenes/IntroScene.tscn")
	
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	$ClickSFX.play()
	get_tree().quit()
	
	pass # Replace with function body.


func _on_play_mouse_entered() -> void:
	$HoverSFX.play()
	pass

func _on_quit_mouse_entered() -> void:
	$HoverSFX.play()
	pass
