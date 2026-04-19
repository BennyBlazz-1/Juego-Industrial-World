extends Area2D

@onready var exclamation_mark: AnimatedSprite2D = $ExclamationMark
@onready var interaction_label: Label = $PromptPoint/InteractionLabel

const FIRST_DIALOGUE = preload("res://dialogues/first_dialogue.dialogue")

@export var prompt_text: String = "Presiona E para hablar"

var is_player_close: bool = false
var last_dialogue_index: int = -1
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

	exclamation_mark.visible = false
	exclamation_mark.play("exclamation")

	interaction_label.visible = false
	interaction_label.text = prompt_text

	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _process(_delta: float) -> void:
	if is_player_close and Input.is_action_just_pressed("interact") and not GameManager.is_dialogue_active:
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

	if is_player_close:
		interaction_label.visible = true
		exclamation_mark.visible = true
