extends Node

const DEFAULT_PERSONAJE_SELECCIONADO: int = 0

# 0 = hombre
# 1 = mujer
var personaje_seleccionado: int = DEFAULT_PERSONAJE_SELECCIONADO


func reset_state() -> void:
	personaje_seleccionado = DEFAULT_PERSONAJE_SELECCIONADO


func get_save_data() -> Dictionary:
	return {
		"personaje_seleccionado": personaje_seleccionado
	}


func apply_save_data(data: Dictionary) -> void:
	personaje_seleccionado = int(data.get("personaje_seleccionado", DEFAULT_PERSONAJE_SELECCIONADO))
