extends Node2D

@onready var themed_timer: Node2D = $ThemedTimer 
@onready var sonic: CharacterBody2D = $Sonic

var timer_end = false
var already_dead = false

func _ready() -> void:
	await themed_timer.Timer(4.0)
	timer_end = true

func _process(delta: float) -> void:
	if sonic.dead and !already_dead:
		already_dead = true
		Global.minigames_done += 1
		Global.lives += 1
