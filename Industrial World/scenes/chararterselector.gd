extends CanvasLayer

@onready var sprite = $Sprite2D

@export_file("*.tscn") var escena_destino: String = "res://scenes/intro.tscn"

var personajes = [
	preload("res://art/characters/man front.png"),
	preload("res://art/characters/woman front(1).png"),
]

var indice := 0

func _ready() -> void:
	indice = Global.personaje_seleccionado
	mostrar_personaje()

func mostrar_personaje() -> void:
	sprite.texture = personajes[indice]

func _on_button_left_pressed() -> void:
	if indice > 0:
		indice -= 1
		mostrar_personaje()

func _on_button_2_rigth_pressed() -> void:
	if indice < personajes.size() - 1:
		indice += 1
		mostrar_personaje()

func _on_button_3_ok_pressed() -> void:
	Global.personaje_seleccionado = indice
	get_tree().change_scene_to_file(escena_destino)
