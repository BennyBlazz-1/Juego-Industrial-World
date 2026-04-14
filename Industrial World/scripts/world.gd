extends Node2D

@onready var building1_under_construction_map = $building1_under_construction_map
@onready var building1_completed_map = $building1_completed_map

var personajes = [
	preload("res://scenes/man_player.tscn"),
	#preload("res://player_woman.tscn"),
]

func _ready():
	update_building_1_visual()
	spawn_personaje() # 👈 NUEVO

func update_building_1_visual():
	building1_under_construction_map.visible = not GameManager.level1_passed
	building1_completed_map.visible = GameManager.level1_passed

func spawn_personaje():
	var personaje = personajes[Global.personaje_seleccionado].instantiate()
	personaje.position = Vector2(100, 100) # 👈 donde aparece
	add_child(personaje)
