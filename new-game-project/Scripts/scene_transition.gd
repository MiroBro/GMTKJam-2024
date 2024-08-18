extends CanvasLayer

func change_scene2(target: String) -> void:
	$AnimationPlayer.play("dissolve")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target)
	$AnimationPlayer.play_backwards("dissolve")

func change_scene(target: String):
	$Dissolve_Rect/AnimationPlayer.play("dissolve")
	await $Dissolve_Rect/AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target)
	$Dissolve_Rect/AnimationPlayer.play_backwards("dissolve")
