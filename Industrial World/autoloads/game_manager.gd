extends Node

const DEFAULT_LEVEL1_STEPS: Dictionary = {
	"raw_material": false,
	"inventory": false,
	"packing_list": false,
	"work_instructions": false
}

const DEFAULT_NIVEL_2_BOTONES: Dictionary = {
	"Boton1": false,
	"Boton2": false,
	"Boton3": false,
	"Boton4": false,
	"Boton5": false,
	"Boton6": false
}

const DEFAULT_NIVEL_2_ORDEN: Array = [
	"Boton1",
	"Boton3",
	"Boton6",
	"Boton4",
	"Boton2",
	"Boton5"
]

const DEFAULT_LEVEL1_PASS_SCORE: int = 5
const DEFAULT_LEVEL1_TOTAL_QUESTIONS: int = 16

var is_dialogue_active = false
var next_spawn_point: String = ""
var final_supervisor_dialogue_enabled: bool = false
var return_to_world_after_final_cutscene: bool = false
var postgame_supervisor_dialogue_enabled: bool = false
var credits_played: bool = false

# =========================
# NIVEL 1
# =========================
var level1_steps = DEFAULT_LEVEL1_STEPS.duplicate(true)

var level1_score = 0
var level1_pass_score = DEFAULT_LEVEL1_PASS_SCORE
var level1_total_questions = DEFAULT_LEVEL1_TOTAL_QUESTIONS

var level1_all_stations_done = false
var level1_exam_taken = false
var level1_passed = false
var level1_finished = false
var level1_stars: int = 0
var level1_final_score: int = 0


# =========================
# NIVEL 2
# =========================
var nivel_2_botones = DEFAULT_NIVEL_2_BOTONES.duplicate(true)

var nivel_2_orden = DEFAULT_NIVEL_2_ORDEN.duplicate()

var nivel_2_indice_actual = 0
var nivel_2_finished = false
var nivel_2_passed = false
var nivel_2_stars: int = 0
var nivel_2_final_time_seconds: int = 0


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
# RESET TOTAL
# =========================
func reset_all_progress() -> void:
	is_dialogue_active = false
	next_spawn_point = ""
	final_supervisor_dialogue_enabled = false
	return_to_world_after_final_cutscene = false
	postgame_supervisor_dialogue_enabled = false
	credits_played = false

	level1_steps = DEFAULT_LEVEL1_STEPS.duplicate(true)
	level1_score = 0
	level1_pass_score = DEFAULT_LEVEL1_PASS_SCORE
	level1_total_questions = DEFAULT_LEVEL1_TOTAL_QUESTIONS
	level1_all_stations_done = false
	level1_exam_taken = false
	level1_passed = false
	level1_finished = false
	level1_stars = 0
	level1_final_score = 0

	nivel_2_botones = DEFAULT_NIVEL_2_BOTONES.duplicate(true)
	nivel_2_orden = DEFAULT_NIVEL_2_ORDEN.duplicate()
	nivel_2_indice_actual = 0
	nivel_2_finished = false
	nivel_2_passed = false
	nivel_2_stars = 0
	nivel_2_final_time_seconds = 0


# =========================
# RESET NIVEL 1
# =========================
func reset_level1() -> void:
	level1_steps = DEFAULT_LEVEL1_STEPS.duplicate(true)

	level1_score = 0
	level1_pass_score = DEFAULT_LEVEL1_PASS_SCORE
	level1_total_questions = DEFAULT_LEVEL1_TOTAL_QUESTIONS
	level1_all_stations_done = false
	level1_exam_taken = false
	level1_passed = false
	level1_finished = false
	level1_stars = 0
	level1_final_score = 0


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
func reset_nivel_2_intento() -> void:
	for key in nivel_2_botones.keys():
		nivel_2_botones[key] = false

	nivel_2_indice_actual = 0
	nivel_2_finished = false


func reset_nivel_2_completo() -> void:
	reset_nivel_2_intento()
	nivel_2_passed = false
	nivel_2_stars = 0
	nivel_2_final_time_seconds = 0


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
	nivel_2_orden = nuevo_orden.duplicate()
	reset_nivel_2_intento()


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

	reset_nivel_2_intento()
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


# =========================
# SAVE / LOAD
# =========================
func get_save_data() -> Dictionary:
	return {
		"next_spawn_point": next_spawn_point,
		"final_supervisor_dialogue_enabled": final_supervisor_dialogue_enabled,
		"return_to_world_after_final_cutscene": return_to_world_after_final_cutscene,
		"postgame_supervisor_dialogue_enabled": postgame_supervisor_dialogue_enabled,
		"credits_played": credits_played,

		"level1_steps": level1_steps.duplicate(true),
		"level1_score": level1_score,
		"level1_pass_score": level1_pass_score,
		"level1_total_questions": level1_total_questions,
		"level1_all_stations_done": level1_all_stations_done,
		"level1_exam_taken": level1_exam_taken,
		"level1_passed": level1_passed,
		"level1_finished": level1_finished,
		"level1_stars": level1_stars,
		"level1_final_score": level1_final_score,

		"nivel_2_botones": nivel_2_botones.duplicate(true),
		"nivel_2_orden": nivel_2_orden.duplicate(),
		"nivel_2_indice_actual": nivel_2_indice_actual,
		"nivel_2_finished": nivel_2_finished,
		"nivel_2_passed": nivel_2_passed,
		"nivel_2_stars": nivel_2_stars,
		"nivel_2_final_time_seconds": nivel_2_final_time_seconds
	}


func apply_save_data(data: Dictionary) -> void:
	next_spawn_point = String(data.get("next_spawn_point", ""))
	final_supervisor_dialogue_enabled = bool(data.get("final_supervisor_dialogue_enabled", false))
	return_to_world_after_final_cutscene = bool(data.get("return_to_world_after_final_cutscene", false))
	postgame_supervisor_dialogue_enabled = bool(data.get("postgame_supervisor_dialogue_enabled", false))
	credits_played = bool(data.get("credits_played", false))

	var loaded_level1_steps: Dictionary = data.get("level1_steps", {})
	level1_steps = DEFAULT_LEVEL1_STEPS.duplicate(true)
	for key in level1_steps.keys():
		if loaded_level1_steps.has(key):
			level1_steps[key] = bool(loaded_level1_steps[key])

	level1_score = int(data.get("level1_score", 0))
	level1_pass_score = int(data.get("level1_pass_score", DEFAULT_LEVEL1_PASS_SCORE))
	level1_total_questions = int(data.get("level1_total_questions", DEFAULT_LEVEL1_TOTAL_QUESTIONS))
	level1_all_stations_done = bool(data.get("level1_all_stations_done", false))
	level1_exam_taken = bool(data.get("level1_exam_taken", false))
	level1_passed = bool(data.get("level1_passed", false))
	level1_finished = bool(data.get("level1_finished", false))
	level1_stars = int(data.get("level1_stars", 0))
	level1_final_score = int(data.get("level1_final_score", 0))

	var loaded_nivel_2_botones: Dictionary = data.get("nivel_2_botones", {})
	nivel_2_botones = DEFAULT_NIVEL_2_BOTONES.duplicate(true)
	for key in nivel_2_botones.keys():
		if loaded_nivel_2_botones.has(key):
			nivel_2_botones[key] = bool(loaded_nivel_2_botones[key])

	var loaded_nivel_2_orden = data.get("nivel_2_orden", DEFAULT_NIVEL_2_ORDEN)
	if typeof(loaded_nivel_2_orden) == TYPE_ARRAY:
		nivel_2_orden = (loaded_nivel_2_orden as Array).duplicate()
	else:
		nivel_2_orden = DEFAULT_NIVEL_2_ORDEN.duplicate()

	nivel_2_indice_actual = int(data.get("nivel_2_indice_actual", 0))
	nivel_2_finished = bool(data.get("nivel_2_finished", false))
	nivel_2_passed = bool(data.get("nivel_2_passed", false))
	nivel_2_stars = int(data.get("nivel_2_stars", 0))
	nivel_2_final_time_seconds = int(data.get("nivel_2_final_time_seconds", 0))

	is_dialogue_active = false
