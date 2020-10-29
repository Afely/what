extends Sprite

const pumpkin = preload("PumpkinPROP.tres")
const grave = preload("GravePROP.tres")

func _ready():
	randomize()
	if randf() > 0.5:
		texture = pumpkin
		$GraveOccluder.queue_free()
		if !Globals.lighting: $PumpkinOccluder.queue_free()
	else:
		texture = grave
		$Light.queue_free()
		$PumpkinOccluder.queue_free()
		if !Globals.lighting: $GraveOccluder.queue_free()

func _on_Timer_timeout():
	for body in $Area2D.get_overlapping_bodies():
		if body.name == "TileMap":
			queue_free()
	
	for area in $Area2D.get_overlapping_areas():
		if area.get_parent().name == "Prop":
			queue_free()
