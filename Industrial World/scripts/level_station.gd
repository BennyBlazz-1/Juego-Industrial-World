extends Area2D

@onready var exclamation_mark = $ExclamationMark

@export_file("*.dialogue") var dialogue_path: String
@export var step_name: String = ""

var is_player_close = false
var opened_here = false
var dialogue_resource = null

func _ready() -> void:
	exclamation_mark.visible = false
	exclamation_mark.play("exclamation")

	if dialogue_path != "":
		dialogue_resource = load(dialogue_path)

	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _process(delta: float) -> void:
	if is_player_close and Input.is_action_just_pressed("ui_accept") and not GameManager.is_dialogue_active:
		if dialogue_resource != null:
			if step_name == "" or not GameManager.level1_steps.get(step_name, false):
				opened_here = true
				DialogueManager.show_dialogue_balloon(dialogue_resource, "start")

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

	if opened_here:
		opened_here = false
		if step_name != "":
			GameManager.complete_step(step_name)
