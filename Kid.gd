extends RigidBody2D

var maxSpeed = 16000
var minSpeed = 8000
var maxTargetSpeed = 24000
var maxSpin = 5
var seen = false
var bobby

const Cam = preload("Camera.tscn")
const PlayerDeath = preload("PlayerDeath.tscn")

func _ready():
	maxTargetSpeed += (Globals.level - 1) * 25
	minSpeed += (Globals.level - 1) * 25
	randomize()
	$Sprite/Shirt.modulate = Color(randf(), randf(), randf())
	if !Globals.lighting: $LightOccluder2D.queue_free()

func _process(_delta):
	if !$VisibilityNotifier2D.is_on_screen(): mode = RigidBody2D.MODE_STATIC
	else: mode = RigidBody2D.MODE_RIGID
	
	if !seen:
		$Timer.wait_time = rand_range(1, 3) - (Globals.level - 1) * 0.05
	
	if seen:
		$Timer.wait_time = rand_range(0.5, 1) - (Globals.level - 1) * 0.05
	
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
		attack()

func idle():
	linear_velocity = Vector2(rand_range(-maxSpeed, maxSpeed), rand_range(-maxSpeed, maxSpeed)) * Globals.Delta
	angular_velocity = rand_range(-maxSpin, maxSpin)

func attack():
	if bobby.position.x > position.x:
		linear_velocity.x = rand_range(minSpeed, maxTargetSpeed) * Globals.Delta
	elif bobby.position.x < position.x:
		linear_velocity.x = rand_range(-minSpeed, -maxTargetSpeed) * Globals.Delta
	
	if bobby.position.y > position.y:
		linear_velocity.y = rand_range(minSpeed, maxTargetSpeed) * Globals.Delta
	elif bobby.position.y < position.y:
		linear_velocity.y = rand_range(-minSpeed, -maxTargetSpeed) * Globals.Delta
	
	angular_velocity = rand_range(-maxSpin, maxSpin)

func _on_Timer_timeout():
	if seen:
		attack()
	else:
		idle()

func _on_StartTimer_timeout():
	for body in $Area.get_overlapping_bodies():
		if body.name == "Player":
			queue_free()
