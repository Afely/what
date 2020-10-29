extends Area2D

const PlayerDeath = preload("PlayerDeath.tscn")
const Cam = preload("Camera.tscn")

var direction = Vector2()
var speed = 250

func _ready():
	speed += Globals.level * 5

func shoot(aim_position, gun_position):
	global_position = gun_position
	direction = (aim_position - gun_position).normalized()
	rotation = direction.angle()

func _process(delta):
	position += direction * speed * delta
	
	for body in get_overlapping_bodies():
		if body.name == "Player":
			speed = 0
			modulate.a = 0
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
		
		if body.name == "TileMap"or body.get_parent().name == "Shields":
			queue_free()
