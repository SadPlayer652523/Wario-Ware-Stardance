extends Node2D

@onready var clicker: TextureButton = $Clicker
@onready var counter: RichTextLabel = $Counter
@onready var themed_timer: Node2D = $ThemedTimer

var pressed = 0
var timer_end = false

func _ready() -> void:
	await themed_timer.Timer(15.0)
	timer_end = true

func _process(delta: float) -> void:
	counter.text = str(pressed)
	
	if pressed == 101:
		get_tree().change_scene_to_file("res://scenes/done_screen.tscn")
		
	if timer_end:
		get_tree().change_scene_to_file("res://scenes/level_scene.tscn")
	
func _on_clicker_pressed() -> void:
	pressed = pressed + 1
