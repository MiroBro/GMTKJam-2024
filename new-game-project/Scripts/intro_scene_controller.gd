extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	$"../Cutscene2".play("Intro_Cutscene_2")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func showText1() -> void:
	pass
	
func play2() -> void:
	pass
	$"../Cutscene2".play("Intro_Cutscene_3")
	
func showText2() -> void:
	pass
	
func play3() -> void:
	pass
	$"../Cutscene2".play("Intro_Cutscene_4")
	
func showText3() -> void:
	pass

func play4() -> void:
	pass
	$"../Cutscene2".play("Intro_Cutscene_5")

func showText4() -> void:
	pass


func _on_button1_pressed() -> void:
	pass
	$"../Cutscene2".play("Intro_Cutscene_3")


func _on_button2_pressed() -> void:
	pass
	$"../Cutscene2".play("Intro_Cutscene_4")


func _on_button3_pressed() -> void:
	pass
	$"../Cutscene2".play("Intro_Cutscene_5")


func _on_button4_pressed() -> void:
	pass # Replace with function body.
	SceneTransition.change_scene("res://splitting_algorithm_scene.tscn")
