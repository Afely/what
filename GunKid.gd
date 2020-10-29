extends RigidBody2D

var maxSpeed = 16000
var maxSpin = 5
var seen = false
var bobby
var attacking

const Bullet = preload("Bullet.tscn")

const Cam = preload("Camera.tscn")
const PlayerDeath = preload("PlayerDeath.tscn")

func _ready():
	$AttackTimer.wait_time -= (Globals.level - 1) * 0.1
	randomize()
	$Sprite/Shirt.modulate = Color(randf(), randf(), randf())
	if !Globals.lighting: $LightOccluder2D.queue_free()

func _process(_delta):
	if !$VisibilityNotifier2D.is_on_screen(): mode = RigidBody2D.MODE_STATIC
	else: mode = RigidBody2D.MODE_RIGID
	
	if seen:
		$Arm.look_at(bobby.position)
	
	for body in $Area2D.get_overlapping_bodies():
		if body.name == "TileMap":
			queue_free()
		if body.name == "Player":
			for candy in get_parent().get_parent().get_node("Candy").get_children():
				candy.queue_free()
			if get_parent().get_parent().has_node("PlayerDeath"): return
			var particles = PlayerDeath.instance()
			get_parent().get_parent().add_child(particles)
			particles.position = body.position
			particles.emitting = true
			body.modulate.a = 0
			get_parent().get_parent().get_node("Tail").modulate.a = 0
			var pCam = body.get_node("Camera2D")
			var cam = Cam.instance()
			get_parent().get_parent().add_child(cam)
			cam.position = body.position
			cam.limit_right = pCam.limit_right
			cam.limit_left = pCam.limit_left
			cam.limit_top = pCam.limit_top
			cam.limit_bottom = pCam.limit_bottom
			
			body.die()

func _on_Area_body_exited(body):
	if body.name == "Player":
		seen = false
		idle()

func _on_Area_body_entered(body):
	if body.name == "Player":
		bobby = body
		seen = true
		$AttackTimer.start()

func idle():
	linear_velocity = Vector2(rand_range(-maxSpeed, maxSpeed), rand_range(-maxSpeed, maxSpeed)) * Globals.Delta
	angular_velocity = rand_range(-maxSpin, maxSpin)

func attack():
	var bullet = Bullet.instance()
	get_parent().get_parent().get_node("Bullets").add_child(bullet)
	bullet.shoot(bobby.position, $Arm/GunPos.global_position)

func _on_Timer_timeout():
	if seen && !attacking:
		$AttackTimer.start()
		attacking = true
	idle()

func _on_StartTimer_timeout():
	for body in $Area.get_overlapping_bodies():
		if body.name == "Player":
			queue_free()

func _on_AttackTimer_timeout():
	call_deferred("attack")
	attacking = false
