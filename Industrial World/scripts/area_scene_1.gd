extends Area2D

@export var next_scene_path: String
@export var require_level1_exam_taken: bool = false
@export var require_level1_passed: bool = false
@export var require_nivel_2_passed: bool = false
@export var target_spawn_name: String = ""
@export_file("*.dialogue") var blocked_dialogue_path: String = ""
@export var triggers_final_supervisor_sequence: bool = false
@export_file("*.tscn") var final_cutscene_scene_path: String = "res://scenes/final_supervisor_cutscene.tscn"

var is_changing_scene: bool = false
var blocked_dialogue: Resource = null


func _ready() -> void:
	if blocked_dialogue_path != "":
		blocked_dialogue = load(blocked_dialogue_path)


func _on_body_entered(body: Node2D) -> void:
	if is_changing_scene:
		return

	if not body.is_in_group("player"):
		return

	if require_level1_exam_taken and not GameManager.level1_exam_taken:
		show_blocked_dialogue()
		return

	if require_level1_passed and not GameManager.level1_passed:
		show_blocked_dialogue()
		return

	if require_nivel_2_passed and not GameManager.nivel_2_passed:
		show_blocked_dialogue()
		return

	if triggers_final_supervisor_sequence \
	and GameManager.level1_passed \
	and not GameManager.final_supervisor_dialogue_enabled:
		GameManager.set_next_spawn(target_spawn_name)
		GameManager.return_to_world_after_final_cutscene = true
		is_changing_scene = true
		call_deferred("change_to_final_cutscene")
		return

	GameManager.set_next_spawn(target_spawn_name)
	is_changing_scene = true
	call_deferred("change_scene")


func change_scene() -> void:
	get_tree().change_scene_to_file(next_scene_path)


func change_to_final_cutscene() -> void:
	get_tree().change_scene_to_file(final_cutscene_scene_path)


func show_blocked_dialogue() -> void:
	if GameManager.is_dialogue_active:
		return

	if blocked_dialogue == null:
		return

	GameManager.is_dialogue_active = true
	DialogueManager.show_dialogue_balloon(blocked_dialogue, "start")
	await DialogueManager.dialogue_ended
	GameManager.is_dialogue_active = false
