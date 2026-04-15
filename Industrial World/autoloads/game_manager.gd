extends Node

var is_dialogue_active = false

var next_spawn_point: String = ""

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

func set_next_spawn(spawn_name: String) -> void:
	next_spawn_point = spawn_name

func consume_next_spawn() -> String:
	var spawn_name := next_spawn_point
	next_spawn_point = ""
	return spawn_name

func reset_level1():
	level1_steps["raw_material"] = false
	level1_steps["inventory"] = false
	level1_steps["packing_list"] = false
	level1_steps["work_instructions"] = false

	level1_score = 0
	level1_all_stations_done = false
	level1_exam_taken = false
	level1_passed = false
	level1_finished = false

func complete_step(step_name: String):
	if level1_steps.has(step_name):
		level1_steps[step_name] = true
	check_level1_progress()

func check_level1_progress():
	if level1_steps["raw_material"] \
	and level1_steps["inventory"] \
	and level1_steps["packing_list"] \
	and level1_steps["work_instructions"]:
		level1_all_stations_done = true
