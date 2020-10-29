extends Node2D

func _ready():
	$highscore.text = "highscore: " + str(Globals.highscore)
	$shots.text = "candy thrown: " + str(Globals.shots)
	$kills.text = "kids killed: " + str(Globals.kills)
	$deaths.text = "deaths: " + str(Globals.deaths)
	$LightingButton.pressed = Globals.lighting

func _process(_delta):
	Globals.lighting = $LightingButton.pressed

func _on_Back_pressed():
	MenuTransition.get_node("AnimationPlayer").play("Transition")
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("Menu.tscn")
