extends CanvasLayer

func change_scene(target: String) -> void:
	$Dissolve_Rect/AnimationPlayer.play("dissolve")
	if $Dissolve_Rect/AnimationPlayer.is_playing(): return  
	#await ($Dissolve_Rect/AnimationPlayer,'animation_finished')
	get_tree().change_scene_to_file(target)
	$Dissolve_Rect/AnimationPlayer.play_backwards("dissolve")
