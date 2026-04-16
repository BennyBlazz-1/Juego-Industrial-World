extends Node

var is_dialogue_active = false

var next_spawn_point: String = ""

# =========================
# NIVEL 1
# =========================
var level1_steps = {
	"raw_material": false,
	"inventory": false,
	"packing_list": false,
	"work_instructions": false
}

var level1_score = 0
var level1_pass_score = 11

var level1_all_stations_done = false
var level1_exam_taken = false
var level1_passed = false
var level1_finished = false


# =========================
# NIVEL 2
# =========================
var nivel_2_botones = {
	"Boton1": false,
	"Boton2": false,
	"Boton3": false,
	"Boton4": false,
	"Boton5": false,
	"Boton6": false
}

var nivel_2_orden = [
	"Boton1",
	"Boton2",
	"Boton3",
	"Boton4",
	"Boton5",
	"Boton6"
]

var nivel_2_indice_actual = 0
var nivel_2_finished = false
var nivel_2_passed = false


# =========================
# SPAWN
# =========================
func set_next_spawn(spawn_name: String) -> void:
	next_spawn_point = spawn_name


func consume_next_spawn() -> String:
	var spawn_name := next_spawn_point
	next_spawn_point = ""
	return spawn_name


# =========================
# RESET NIVEL 1
# =========================
func reset_level1() -> void:
	level1_steps["raw_material"] = false
	level1_steps["inventory"] = false
	level1_steps["packing_list"] = false
	level1_steps["work_instructions"] = false

	level1_score = 0
	level1_all_stations_done = false
	level1_exam_taken = false
	level1_passed = false
	level1_finished = false


# =========================
# PROGRESO NIVEL 1
# =========================
func complete_step(step_name: String) -> void:
	if level1_steps.has(step_name):
		level1_steps[step_name] = true
	check_level1_progress()


func check_level1_progress() -> void:
	if level1_steps["raw_material"] \
	and level1_steps["inventory"] \
	and level1_steps["packing_list"] \
	and level1_steps["work_instructions"]:
		level1_all_stations_done = true


# =========================
# RESET NIVEL 2
# =========================
func reset_nivel_2() -> void:
	for key in nivel_2_botones.keys():
		nivel_2_botones[key] = false

	nivel_2_indice_actual = 0
	nivel_2_finished = false
	nivel_2_passed = false


func reiniciar_botones_nivel_2_en_escena() -> void:
	var escena_actual = get_tree().current_scene
	if escena_actual == null:
		return

	for hijo in escena_actual.get_children():
		if hijo is Area2D and hijo.name.begins_with("Boton"):
			if hijo.has_method("reiniciar_boton"):
				hijo.reiniciar_boton()


# =========================
# CONFIGURACIÓN NIVEL 2
# =========================
func set_nivel_2_orden(nuevo_orden: Array) -> void:
	nivel_2_orden = nuevo_orden
	reset_nivel_2()


func get_nivel_2_boton_esperado() -> String:
	if nivel_2_indice_actual < nivel_2_orden.size():
		return nivel_2_orden[nivel_2_indice_actual]
	return ""


func es_nivel_2_correcto(nombre_boton: String) -> bool:
	return nombre_boton == get_nivel_2_boton_esperado()


# =========================
# PROGRESO NIVEL 2
# =========================
func completar_boton_nivel_2(nombre_boton: String) -> bool:
	if nivel_2_finished:
		return false

	if not nivel_2_botones.has(nombre_boton):
		return false

	if nivel_2_botones[nombre_boton]:
		return false

	if es_nivel_2_correcto(nombre_boton):
		nivel_2_botones[nombre_boton] = true
		nivel_2_indice_actual += 1
		check_nivel_2_progreso()
		return true

	# Si se equivoca, reinicia toda la secuencia
	reset_nivel_2()
	reiniciar_botones_nivel_2_en_escena()
	return false


func check_nivel_2_progreso() -> void:
	var all_done := true

	for nombre in nivel_2_orden:
		if nivel_2_botones.has(nombre):
			if not nivel_2_botones[nombre]:
				all_done = false
				break
		else:
			all_done = false
			break

	if all_done:
		nivel_2_finished = true
		nivel_2_passed = true
