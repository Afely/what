extends Sprite

var scaleSpeed = 0.2

func _process(_delta):
	if scale.x <= 0:
		queue_free()
	scale -= Vector2(scaleSpeed, scaleSpeed) * Globals.Delta
