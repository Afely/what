extends RigidBody2D

const TAIL = preload("Tail.tscn")
const OUTLINE = preload("Outline.tscn")
const TAILOUTLINE = preload("TailOutline.tscn")
const CANDY = preload("Candy.tscn")
const Cam = preload("Camera.tscn")

var mouse = {"global":Vector2(), "local":Vector2()}
var motion = Vector2()
var accel = 2000
var accelcel = 0.1
var maxSpeed = 50000
var margin = 112
var outline
var dead
var exited
var cam

func _ready():
	Globals.quota += (Globals.level * 4) + (Globals.levelKills / 8)
	Globals.levelKills = 0
	Globals.quota += Globals.overflow / 8
	Globals.quota = round(Globals.quota)
	if Globals.quota <= 0: Globals.quota = 5
	set_as_toplevel(true)
	outline = OUTLINE.instance()
	get_parent().get_node("Tail").add_child(outline)
	outline.position = position
	if !Globals.lighting: $Light2D.queue_free()

func _physics_process(delta):
	$Nav.look_at(get_parent().get_node("Exit").position)
	outline.position = position
	
	mouse.global = get_global_mouse_position()
	mouse.local = get_local_mouse_position()
	
	# shoot
	if Input.is_action_just_pressed("Click"):
		if dead: return
		var candy = CANDY.instance()
		get_parent().get_node("Candy").add_child(candy)
		candy.shoot(get_global_mouse_position(), global_position)
	
	# show exit
	if Globals.levelKills >= Globals.quota:
		$Nav/Sprite.visible = true
		var exit = get_parent().get_node("Exit")
		exit.get_node("Sprite").visible = true
		exit.get_node("CollisionShape2D").disabled = false
	
	if Input.is_action_pressed("ui_right"):
		motion.x += accel
		if motion.x > maxSpeed: motion.x = maxSpeed
	elif Input.is_action_pressed("ui_left"):
		motion.x -= accel
		if motion.x < -maxSpeed: motion.x = -maxSpeed
	else:
		motion.x = lerp(motion.x, 0, accelcel)
	
	if Input.is_action_pressed("ui_up"):
		motion.y -= accel
		if motion.y < -maxSpeed: motion.y = -maxSpeed
	elif Input.is_action_pressed("ui_down"):
		motion.y += accel
		if motion.y > maxSpeed: motion.y = maxSpeed
	else:
		motion.y = lerp(motion.y, 0, accelcel)
	
	for area in $Area2D.get_overlapping_areas():
		if !area: return
		if area.name == "Exit":
			Globals.can_pause = false
			$CollisionShape2D.disabled = true
			if exited: return
			exited = true
			Globals.level += 1
			if Globals.level > Globals.highscore: Globals.highscore = Globals.level
			
			MenuTransition.get_node("AnimationPlayer").play("Transition")
			yield(get_tree().create_timer(0.5), "timeout")
			Globals.overflow += Globals.levelKills - Globals.quota
			get_tree().change_scene("HaLOSER.tscn")
	
	
	linear_velocity = motion * delta
	
	var tail = TAIL.instance()
	get_parent().get_node("Tail").add_child(tail)
	tail.position = position
	var tailLine = TAILOUTLINE.instance()
	get_parent().get_node("Tail").add_child(tailLine)
	tailLine.position = position
	
	$Sprite.rotation = lerp_angle($Sprite.rotation, (mouse.global - position).normalized().angle(), 0.05)
	
	cam = Cam.instance()
	add_child(cam)
	cam.limit_left = Globals.topLeft.x
	cam.limit_right = Globals.bottomRight.x
	cam.limit_top = Globals.topLeft.y
	cam.limit_bottom = Globals.bottomRight.y

func die():
	$DeathTimer.start()

func _on_Timer_timeout():
	$Timer.wait_time = rand_range(0.05, 0.2)
	var lightness = rand_range(0.6, 0.8)
	$LightSprite.modulate.v = lightness
	if Globals.lighting: $Light2D.color.v = lightness - 0.2

func cameraShake(time, intensity):
	var i = 1
	while i < time:
		cam.offset.x = rand_range(-intensity / i, intensity / i)
		cam.offset.y = rand_range(-intensity / i, intensity / i)
		i += 1
		yield(get_tree().create_timer(rand_range(0.01, 0.005)), "timeout")
	cam.offset = Vector2(0, 0)

func _on_DeathTimer_timeout():
	dead = true
	
	MenuTransition.get_node("AnimationPlayer").play("Transition")
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("HaLOSER.tscn")
