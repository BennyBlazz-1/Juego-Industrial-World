extends Node

var botones: Array = []
var indice_actual: int = 0

func _ready() -> void:
	var nivel = get_parent()

	for hijo in nivel.get_children():
		if hijo is Area2D and hijo.name.begins_with("Boton"):
			botones.append(hijo)

	botones.sort_custom(func(a, b): return a.orden < b.orden)

	for boton in botones:
		boton.manager = self
		boton.ocultar_signo()

	print("Botones encontrados: ", botones.size())
	for boton in botones:
		print("Asignado manager a: ", boton.name, " | orden: ", boton.orden)

func es_boton_actual(boton) -> bool:
	if indice_actual >= botones.size():
		return false
	return botones[indice_actual] == boton

func intentar_activar(boton) -> void:
	if indice_actual >= botones.size():
		return

	if boton.completado:
		return

	print("Intentando activar: ", boton.name)
	print("Botón esperado: ", botones[indice_actual].name)

	if botones[indice_actual] == boton:
		boton.activar_correcto()
		indice_actual += 1

		if indice_actual >= botones.size():
			_secuencia_completada()
	else:
		boton.activar_incorrecto()
		_boton_incorrecto()

func _boton_incorrecto() -> void:
	print("Botón incorrecto")
	# Si quieres que reinicie toda la secuencia al equivocarse,
	# descomenta la siguiente línea:
	# reiniciar_secuencia()

func reiniciar_secuencia() -> void:
	indice_actual = 0

	for boton in botones:
		boton.reiniciar_boton()

func _secuencia_completada() -> void:
	print("Secuencia completada")
	# Aquí pones lo que pasará al terminar
	# Ejemplo:
	# get_tree().change_scene_to_file("res://Nivel3.tscn")
