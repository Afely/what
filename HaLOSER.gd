extends Node2D

func _ready():
	
	$"Box/died on".text = "died on stage " + str(Globals.level)
	$Box/highscore.text = "highscore: " + str(Globals.highscore)
	$Box/kills.text = "kids killed\n" + str(Globals.localKills)
	$Box/shots.text = "candy thrown\n" + str(Globals.localShots)
	
	Globals.deaths += 1
	Globals.localShots = 0
	Globals.localKills = 0
	Globals.levelKills = 0
	Globals.level = 1
	Globals.overflow = 0
	Globals.quota = 0

func _on_restart_pressed():
	LoadingScreen.get_node("AnimationPlayer").play("Start")
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("Workspace.tscn")

func _on_menu_pressed():
	MenuTransition.get_node("AnimationPlayer").play("Transition")
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("Menu.tscn")
