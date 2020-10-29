extends RigidBody2D

var maxSpeed = 16000
var minSpeed = 6000
var maxTargetSpeed = 8000
var minSpin = 1
var maxSpin = 2
var seen = false
var bobby
var col
var shield

const Cam = preload("Camera.tscn")
const PlayerDeath = preload("PlayerDeath.tscn")
const Juice = preload("DeathParticles.tscn")
const Shield = preload("Shield.tscn")

func _ready():
	bobby = get_parent().get_parent().get_node("Player")
	
	randomize()
	col = Color(randf(), randf(), randf())
	$Sprite/Shirt.modulate = col
	if !Globals.lighting: $LightOccluder2D.queue_free()
	
	shield = Shield.instance()
	get_parent().add_child(shield)
	shield.get_node("Sprite").modulate = col
	
func _process(_delta):
	if !$VisibilityNotifier2D.is_on_screen(): mode = RigidBody2D.MODE_STATIC
	else: mode = RigidBody2D.MODE_RIGID
	
	shield.global_position = global_position
	
	if !seen:
		$Timer.wait_time = rand_range(1, 3)
	
	if seen:
		$Timer.wait_time = rand_range(1, 1.5)
	
	for body in $Area2D.get_overlapping_bodies():
		if body.name == "TileMap":
			queue_free()
			shield.queue_free()
		if body.name == "Player":
			Globals.kills += 1
			Globals.localKills += 1
			Globals.levelKills += 1
			shield.queue_free()
			
			body.cameraShake(50, rand_range(200, 300))
			
			var particles = Juice.instance()
			var mat = ParticlesMaterial.new()
			get_parent().get_parent().add_child(particles)
			mat = particles.process_material
			particles.position = global_position
			mat.color = col
			mat.direction = Vector3(body.motion.x, body.motion.y, 0)
			particles.process_material = mat
			particles.emitting = true
			queue_free()

func _on_Area_body_exited(body):
	if body.name == "Player":
		seen = false
		idle()

func _on_Area_body_entered(body):
	if body.name == "Player":
		seen = true
		attack()

func idle():
	linear_velocity = Vector2(rand_range(-maxSpeed, maxSpeed), rand_range(-maxSpeed, maxSpeed)) * Globals.Delta
	angular_velocity = rand_range(-maxSpin, maxSpin)

func attack():
	if bobby.position.x > position.x:
		linear_velocity.x = rand_range(-minSpeed, -maxTargetSpeed) * Globals.Delta
	elif bobby.position.x < position.x:
		linear_velocity.x = rand_range(minSpeed, maxTargetSpeed) * Globals.Delta
	
	if bobby.position.y > position.y:
		linear_velocity.y = rand_range(-minSpeed, -maxTargetSpeed) * Globals.Delta
	elif bobby.position.y < position.y:
		linear_velocity.y = rand_range(minSpeed, maxTargetSpeed) * Globals.Delta

func _on_Timer_timeout():
	if seen:
		attack()
	else:
		idle()

func _on_StartTimer_timeout():
	for body in $Area.get_overlapping_bodies():
		if body.name == "Player":
			queue_free()
			shield.queue_free()
