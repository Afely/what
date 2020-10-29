extends Node

var highscore = 0
var level = 1
var shots = 0
var localShots = 0
var kills = 0
var localKills = 0
var levelKills = 0
var quota = 0
var overflow = 0
var deaths = 0
var lighting = true
var topLeft
var bottomRight
var Delta
var can_pause = false

func _process(delta):
	Delta = delta
	if Input.is_action_just_pressed("ui_select"):
		OS.window_fullscreen = not OS.window_fullscreen
