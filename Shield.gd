extends RigidBody2D

var bobby
var accel = 0.02

func _ready():
	bobby = get_parent().get_parent().get_node("Player")
	accel += Globals.level * 0.001

func _physics_process(_delta):
	rotation = lerp_angle(rotation, (bobby.position - position).normalized().angle(), accel)
