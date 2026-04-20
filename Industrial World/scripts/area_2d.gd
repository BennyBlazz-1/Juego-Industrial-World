extends Area2D

@onready var exclamation_mark: AnimatedSprite2D = $ExclamationMark
@onready var interaction_label: Label = $PromptPoint/InteractionLabel

const FIRST_DIALOGUE = preload("res://dialogues/first_dialogue.dialogue")
const FINAL_DIALOGUE = preload("res://dialogues/supervisor_final.dialogue")
const POSTGAME_DIALOGUE = preload("res://dialogues/supervisor_postgame.dialogue")

@export var prompt_text: String = "Presiona E para hablar"

var is_player_close: bool = false
var last_dialogue_index: int = -1
var rng := RandomNumberGenerator.new()

var opened_final_dialogue: bool = false


func _ready() -> void:
	rng.randomize()

	exclamation_mark.visible = false
	exclamation_mark.play("exclamation")

	interaction_label.visible = false
	interaction_label.text = prompt_text

	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _process(_delta: float) -> void:
	if not is_player_close:
		return

	if GameManager.is_dialogue_active:
		return

	if Input.is_action_just_pressed("interact"):
		opened_final_dialogue = false

		if GameManager.postgame_supervisor_dialogue_enabled:
			DialogueManager.show_dialogue_balloon(POSTGAME_DIALOGUE, "start")
		elif GameManager.final_supervisor_dialogue_enabled:
			opened_final_dialogue = true
			DialogueManager.show_dialogue_balloon(FINAL_DIALOGUE, "start")
		else:
			var random_index := get_random_dialogue_index()
			var dialogue_start := "start_" + str(random_index)
			DialogueManager.show_dialogue_balloon(FIRST_DIALOGUE, dialogue_start)


func get_random_dialogue_index() -> int:
	var new_index := rng.randi_range(1, 5)

	while new_index == last_dialogue_index:
		new_index = rng.randi_range(1, 5)

	last_dialogue_index = new_index
	return new_index


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_close = true
		exclamation_mark.visible = true
		interaction_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_close = false
		exclamation_mark.visible = false
		interaction_label.visible = false


func _on_dialogue_started(_dialogue) -> void:
	GameManager.is_dialogue_active = true
	interaction_label.visible = false
	exclamation_mark.visible = false


func _on_dialogue_ended(_dialogue) -> void:
	await get_tree().create_timer(0.2).timeout
	GameManager.is_dialogue_active = false

	if opened_final_dialogue:
		opened_final_dialogue = false
		var current_scene := get_tree().current_scene
		if current_scene != null and current_scene.has_method("start_endgame_credits"):
			current_scene.call_deferred("start_endgame_credits")
		return

	if is_player_close:
		interaction_label.visible = true
		exclamation_mark.visible = true
