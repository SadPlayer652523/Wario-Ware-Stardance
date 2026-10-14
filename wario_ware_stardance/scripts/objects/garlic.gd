
# the onreadys below run immediately at the start of the game, preventing 
# errors related to variable that haven't been defined yet in later scripts 

extends Node2D
@onready var player: CharacterBody2D = $"../Sonic" # grabs the parent node
@onready var self_area = $Area2D
@onready var player_area = $"../Sonic/Area2D"
@onready var minigame_1: Node2D = $".."

func _process(delta: float) -> void: # this runs EVERY FRAME! 
	
	if player_area.overlaps_area(self_area): # checks if overlapping
		if self.visible:
			minigame_1.garlic_collect()
			self.hide() #removed from player sight; collected
