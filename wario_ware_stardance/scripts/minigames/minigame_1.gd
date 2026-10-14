extends Node2D

@onready var themed_timer: Node2D = $ThemedTimer 

var garlic_collected = 0 # just keeping track of garlic collected
var timer_end = false

func _ready() -> void:
	await themed_timer.Timer(10.0) #accessing a function from this node
	timer_end = true

func _process(delta: float) -> void: # running every frame brochacho
	if garlic_collected > 2:
		get_tree().change_scene_to_file("res://scenes/done_screen.tscn")
	
	if timer_end: # if the timer does end...
		get_tree().change_scene_to_file("res://scenes/level_screen.tscn")
		

func garlic_collect() -> void: # cool function that you connect to those garlics
	garlic_collected = garlic_collected + 1
	return
