extends Node2D

var Room = preload("Room.tscn")
var Exit = preload("Exit.tscn")
var Kid = preload("Kid.tscn")
var GunKid = preload("GunKid.tscn")
var ShieldKid = preload("ShieldKid.tscn")
var Prop = preload("Prop.tscn")
onready var Map = $TileMap

var tile_size = 128
var num_rooms = 25
var min_size = 6
var max_size = 10
var cull = 0.75
var exit_min_dist = 5
var numSpawns = 200
var numProps = 300
var path
var fullRect = Rect2()

func _ready():
	numSpawns += (Globals.level * 25) + (Globals.localKills * 4) + Globals.overflow
	LoadingScreen.get_node("AnimationPlayer").play("Load")
	randomize()
	make_rooms()
	yield(get_tree().create_timer(1.2), "timeout")
	update()
	make_map()
	yield(get_tree().create_timer(0.1), "timeout")
	remove_rooms()
	$Timer.start()

func make_rooms():
	for _i in range(num_rooms):
		var pos = Vector2(0, 0)
		var r = Room.instance()
		var w = floor(rand_range(min_size, max_size + 1))
		var h = floor(rand_range(min_size, max_size + 1))
		r.make_room(pos, Vector2(w, h) * tile_size)
		$Rooms.add_child(r)
	
	yield(get_tree().create_timer(1.1), "timeout")
	
	var roomPos = []
	for room in $Rooms.get_children():
		if randf() > cull:
			room.queue_free()
		else:
			room.mode = RigidBody2D.MODE_STATIC
			roomPos.append(room.position)
	
	yield(get_tree(), "idle_frame")
	
	path = find_mst(roomPos)

func find_mst(nodes):
	
	path = AStar2D.new()
	
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	
	while nodes:
		var min_dist = INF
		var min_p = null
		var p = null
		
		for p1 in path.get_points():
			p1 = path.get_point_position(p1)
			
			for p2 in nodes:
				if p1.distance_to(p2) < min_dist:
					min_dist = p1.distance_to(p2)
					min_p = p2
					p = p1
		var n = path.get_available_point_id()
		path.add_point(n, min_p)
		path.connect_points(path.get_closest_point(p), n)
		nodes.erase(min_p)
	return path

func make_map():
	Map.clear()
	
	for room in $Rooms.get_children():
		var r = Rect2(room.position - room.size, room.get_node("CollisionShape2D").shape.extents * 2)
		fullRect = fullRect.merge(r)
	var topLeft = Map.world_to_map(fullRect.position)
	var bottomRight = Map.world_to_map(fullRect.end)
	
	Globals.topLeft = Map.map_to_world(topLeft)
	Globals.bottomRight = Map.map_to_world(bottomRight)
	
	for x in range(topLeft.x, bottomRight.x):
		for y in range(topLeft.y, bottomRight.y):
			Map.set_cell(x, y, 0)
	
	var corridors = []
	for room in $Rooms.get_children():
		var s = (room.size / tile_size).floor()
		var _pos = Map.world_to_map(room.position)
		var ul = (room.position / tile_size).floor() - s
		
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				Map.set_cell(ul.x + x, ul.y + y, -1)
		
		var p = path.get_closest_point(room.position)
		for conn in path.get_point_connections(p):
			if !conn in corridors:
				var start = Map.world_to_map(path.get_point_position(p))
				var end = Map.world_to_map(path.get_point_position(conn))
				carve_path(start, end)
		corridors.append(p)

func carve_path(pos1, pos2):
	var xDiff = sign(pos2.x - pos1.x)
	var yDiff = sign(pos2.y - pos1.y)
	if xDiff == 0: xDiff = pow(-1, randi() % 2)
	if yDiff == 0: yDiff = pow(-1, randi() % 2)
	
	var x_y = pos1
	var y_x = pos2
	if (randi() % 2) > 0:
		x_y = pos2
		y_x = pos1
	
	for x in range(pos1.x, pos2.x, xDiff):
		Map.set_cell(x, x_y.y, -1)
		Map.set_cell(x, x_y.y + yDiff, -1)
	for y in range(pos1.y, pos2.y, yDiff):
		Map.set_cell(y_x.x, y, -1)
		Map.set_cell(y_x.x + xDiff, y, -1)

func remove_rooms():
	# place exit
	if !has_node("Exit"):
		var exitRoom = $Rooms.get_children()[rand_range(exit_min_dist, $Rooms.get_children().size())]
		var exit = Exit.instance()
		add_child(exit)
		exit.position = exitRoom.position
	
	# spawn player
	for room in $Rooms.get_children():
		if !has_node("Player"):
			var player = preload("Player.tscn").instance()
			add_child(player)
			player.position = room.position
		room.queue_free()

func _draw():
	return
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2), Color(1, 0, 0), false)
	if path:
		for p in path.get_points():
			for c in path.get_point_connections(p):
				var pp = path.get_point_position(p)
				var cp = path.get_point_position(c)
				draw_line(pp, cp, Color(0, 1, 0), 15, true)

func spawnProp():
	var x = rand_range(fullRect.position.x, fullRect.end.x)
	var y = rand_range(fullRect.position.y, fullRect.end.y)
	var prop = Prop.instance()
	$Props.add_child(prop)
	prop.global_position = Vector2(x, y)
	var size = rand_range(0.078, 0.125)
	prop.scale = Vector2(size, size)
	if randf() > 0.5:
		prop.scale.x = -prop.scale.x

func spawnEnemy():
	var x = rand_range(fullRect.position.x, fullRect.end.x)
	var y = rand_range(fullRect.position.y, fullRect.end.y)
	var kid
	var kidSelect = rand_range(0, 20)
	if kidSelect > 10:
		kid = Kid.instance()
		$Enemies.add_child(kid)
	elif kidSelect > 5:
		kid = GunKid.instance()
		$Enemies.add_child(kid)
	else:
		kid = ShieldKid.instance()
		$Shields.add_child(kid)
	kid.global_position = Vector2(x, y)

func _on_Timer_timeout():
	if numSpawns > 0:
		spawnEnemy()
		numSpawns -= 1
	
	if numProps > 0:
		spawnProp()
		numProps -= 1
	
	if numSpawns == 0 && numProps == 0:
		finish()

func finish():
	LoadingScreen.get_node("Floor").text = "Level " + str(Globals.level)
	LoadingScreen.get_node("AnimationPlayer").play("End")
	Globals.can_pause = true
	$Timer.stop()
