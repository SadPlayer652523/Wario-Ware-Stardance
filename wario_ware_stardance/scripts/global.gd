extends Node

var minigames_done = 0
var lives = 5
var buttons_pressed = 0
var timer_ticking = true

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	#print(str(minigames_done) + " " + str(lives))
	if lives < 1:
		get_tree().change_scene_to_file("res://scenes/death_screen.tscn")
		lives = 5
		minigames_done = 0
		buttons_pressed = 0
		timer_ticking = true
