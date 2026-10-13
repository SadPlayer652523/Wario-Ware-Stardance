extends Node2D

@onready var themed_timer: Node2D = $ThemedTimer 
# ^^^ You dragged this in the scene by the way 

var garlic_collected = 0 # just keeping track of garlic collected
var timer_end = false # boolean (true or false) stating whether the timer ended

func _ready() -> void:
	await themed_timer.Timer(10.0) #accessing a function from this node
	timer_end = true

func _process(delta: float) -> void: # running every frame brochacho
	if garlic_collected == 3:
		Global.lives += 1
		if Global.minigames_done > 3: # we access a global script and see how many minigames have been compeleted
			get_tree().change_scene_to_file("res://scenes/done_screen.tscn") # change current play scene into another, but you make your own finish screen in a later challenge, dont worry abt this rn
		else:
			get_tree().change_scene_to_file("res://scenes/level_scene.tscn") # go back to the intermission scene
	
	if timer_end: # if the timer does end...
		get_tree().change_scene_to_file("res://scenes/level_screen.tscn") # back to intermission
		

func garlic_collect() -> void: # cool function that you connect to those garlics
	garlic_collected = garlic_collected + 1
	return
