extends Node2D

@onready var timer: RichTextLabel = $Timer

var time

func _ready() -> void:
	await Timer(3.0)
	get_tree().change_scene_to_file("res://scenes/level_scene.tscn")

func _process(delta: float) -> void:
	timer.text = "0:0" + str(snapped(time, 0.01))

func Timer(start_time: float):
	
	time = start_time
	
	while time > 0.0:
		await wait(0.01)
		time -= 0.01
	return

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
