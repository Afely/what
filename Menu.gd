extends Node2D

func _ready():
	$AnimationPlayer.play("MenuLoop")

func _on_Play_pressed():
	LoadingScreen.get_node("AnimationPlayer").play("Start")
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("Workspace.tscn")

func _on_Settings_pressed():
	MenuTransition.get_node("AnimationPlayer").play("Transition")
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("Stats.tscn")

func _on_Exit_pressed():
	$Adios.visible = true
	get_tree().quit()
