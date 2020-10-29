extends Area2D

var Juice = preload("DeathParticles.tscn")

var direction = Vector2()
var rot = 0.1
var shrink = 5
var startShrink
export var speed = 1500

func _ready():
	randomize()
	$Sprite.modulate = Color(randf(), randf(), randf())
	if !Globals.lighting: $LightOccluder2D.queue_free()

func shoot(aim_position, gun_position):
	Globals.shots += 1
	Globals.localShots += 1
	global_position = gun_position
	direction = (aim_position - gun_position).normalized()
	rotation = direction.angle()

func _process(delta):
	position += direction * speed * delta
	rotation += rot
	if startShrink:
		scale.x -= shrink * delta
		scale.y -= shrink * delta
	if scale.x <= 0:
		queue_free()

func _on_Candy_body_entered(body):
	if body.name == "TileMap" or body.get_parent().name == "Shields":
		queue_free()
	elif body.get_parent().name == "Enemies":
		Globals.kills += 1
		Globals.localKills += 1
		Globals.levelKills += 1
		
		get_parent().get_parent().get_node("Player").cameraShake(50, rand_range(100, 200))
		
		var particles = Juice.instance()
		var mat = ParticlesMaterial.new()
		get_parent().get_parent().add_child(particles)
		mat = particles.process_material
		particles.position = global_position
		mat.color = body.get_node("Sprite").get_node("Shirt").modulate
		mat.direction = Vector3(direction.x, direction.y, 0)
		particles.process_material = mat
		particles.emitting = true
		body.queue_free()
		queue_free()

func _on_Timer_timeout():
	startShrink = true
