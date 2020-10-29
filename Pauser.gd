extends CanvasLayer

var bee = 0

func _ready():
	$H/Quota.get_font("font").outline_color = Color(0, 0, 0)
	$H/Quota.set("custom_colors/font_color", Color(1, 1, 1))

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") && Globals.can_pause:
		pause()
	
	$H/Quota.text = str(Globals.levelKills) + "/" + str(Globals.quota) + " kids killed"
	if Globals.levelKills >= Globals.quota:
		$H/Quota.get_font("font").outline_color = Color("0d7f3f")
		$H/Quota.set("custom_colors/font_color", Color("18b722"))
	else:
		$H/Quota.get_font("font").outline_color = Color(0, 0, 0)
		if $H/Quota.get("custom_colors/font_color") == Color("18b722"):
			$H/Quota.set("custom_colors/font_color", Color(1, 1, 1))
	
	if Globals.levelKills > bee:
		$PauseUI/AnimationPlayer.play("kill")
		bee = Globals.levelKills
	if Globals.levelKills == 0:
		bee = Globals.levelKills

func pause():
	if !get_tree().paused:
		$PauseUI/AnimationPlayer.play("pauseStart")
		yield(get_tree().create_timer(0.1), "timeout")
		get_tree().paused = true
	else:
		$PauseUI/AnimationPlayer.play_backwards("pauseStart")
		yield(get_tree().create_timer(0.1), "timeout")
		get_tree().paused = false

func _on_menu_pressed():
	MenuTransition.get_node("AnimationPlayer").play("Transition")
	yield(get_tree().create_timer(1), "timeout")
	get_tree().paused = false
	get_tree().change_scene("Menu.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_resume_pressed():
	pause()

func _on_Pause_pressed():
	pause()
