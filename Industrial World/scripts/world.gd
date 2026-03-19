extends Node2D

@onready var building1_under_construction_map = $building1_under_construction_map
@onready var building1_completed_map = $building1_completed_map

func _ready():
	update_building_1_visual()

func update_building_1_visual():
	building1_under_construction_map.visible = not GameManager.level1_passed
	building1_completed_map.visible = GameManager.level1_passed
