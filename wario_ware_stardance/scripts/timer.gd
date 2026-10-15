extends Node2D

@onready var timer: RichTextLabel = $Timer

var time : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if time < 10.0:
		timer.text = "0:0" + str(snapped(time, 0.01))
	else:
		timer.text = "0:" + str(snapped(time, 0.01))

func Timer(start_time: float):
	if Global.timer_ticking:
		time = start_time

		while time > 0.0 and Global.timer_ticking: # run if timer hasnt reached 0
			await wait(0.01)
			time = time - 0.01
		if !Global.minigames_done == 4:
			Global.minigames_done -= 1
		if Global.minigames_done == 4:
			if Global.sonic_dead:
				Global.lives -= 1
			else:
				Global.minigames_done = 5
		if Global.timer_ticking:
			if Global.minigames_done == 4 and !Global.sonic_dead:
				get_tree().change_scene_to_file("res://scenes/done_screen.tscn")
			else:
				get_tree().change_scene_to_file("res://scenes/level_scene.tscn")

func wait(seconds: float) -> void:
	if Global.timer_ticking:
		await get_tree().create_timer(seconds).timeout # makes u wait
