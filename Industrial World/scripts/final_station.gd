extends Area2D

@onready var exclamation_mark = $ExclamationMark

@export_file("*.dialogue") var dialogue_path: String

var is_player_close = false
var opened_here = false
var complete_dialogue = null

func _ready() -> void:
	exclamation_mark.visible = false
	exclamation_mark.play("exclamation")

	if dialogue_path != "":
		complete_dialogue = load(dialogue_path)

	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _process(delta: float) -> void:
	if is_player_close and Input.is_action_just_pressed("ui_accept") and not GameManager.is_dialogue_active:
		if GameManager.level1_all_stations_done and complete_dialogue != null and not GameManager.level1_exam_taken:
			opened_here = true
			DialogueManager.show_dialogue_balloon(complete_dialogue, "start")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_close = true
		exclamation_mark.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_close = false
		exclamation_mark.visible = false

func _on_dialogue_started(dialogue):
	GameManager.is_dialogue_active = true

func _on_dialogue_ended(dialogue):
	await get_tree().create_timer(0.2).timeout
	GameManager.is_dialogue_active = false
	opened_here = false
