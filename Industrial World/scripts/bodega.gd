extends Node2D

func _ready():
	if not GameManager.level1_passed:
		GameManager.reset_level1()
