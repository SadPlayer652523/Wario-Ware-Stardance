extends Node2D

@onready var garlic_container: HBoxContainer = $GarlicContainer
@onready var garlic: TextureRect = $GarlicContainer/Garlic
@onready var garlic_2: TextureRect = $GarlicContainer/Garlic2
@onready var garlic_3: TextureRect = $GarlicContainer/Garlic3
@onready var garlic_4: TextureRect = $GarlicContainer/Garlic4
@onready var garlic_5: TextureRect = $GarlicContainer/Garlic5
@onready var level: RichTextLabel = $Level
@onready var timer: RichTextLabel = $Timer

var time

func _ready() -> void:
	if !Global.sonic_dead and Global.minigames_done > 3:
		await Timer(0.1)
	else:
		await Timer(3.0)
	if Global.minigames_done < 4:
		Global.minigames_done = Global.minigames_done + 1
		get_tree().change_scene_to_file("res://scenes/minigames/minigame_" + str(Global.minigames_done) + ".tscn")
	else:
		if !Global.sonic_dead:
			get_tree().change_scene_to_file("res://scenes/done_screen.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/minigames/minigame_4.tscn")
	Global.timer_ticking = true

func _process(delta: float) -> void:
	match Global.lives:
		4:
			garlic.hide()
		3:
			garlic.hide()
			garlic_2.hide()
		2:
			garlic.hide()
			garlic_2.hide()
			garlic_3.hide()
		1:
			garlic.hide()
			garlic_2.hide()
			garlic_3.hide()
			garlic_4.hide()
		0:
			garlic_container.hide() # just hides everything
	
	timer.text = "0:0" + "%0.2f" % time
	if Global.minigames_done < 4:
		level.text = "Level " + str(Global.minigames_done + 1)
	else:
		level.text = "Level 4"

func Timer(start_time: float):
	
	time = start_time # make the timer, which is reflected through the timer text, start at your desired number
	
	while time > 0.0: # run if timer hasnt reached 0
		await wait(0.01) 
		time -= 0.01 # remove 0.1
		# progressively get the value smaller and smaller
	
	#when timer reaches 0
	return

func wait(seconds: float) -> void: # write this simple function out for wait!
	await get_tree().create_timer(seconds).timeout # makes u wait, dw abt this being complex '''
