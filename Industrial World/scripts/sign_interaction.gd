extends Area2D

@onready var interaction_label: Label = get_node_or_null("PromptPoint/InteractionLabel")

@export_file("*.dialogue") var dialogue_path: String
@export var prompt_text: String = "Press E to read"

var is_player_close: bool = false
var sign_dialogue: Resource = null

func _ready() -> void:
	if dialogue_path != "":
		sign_dialogue = load(dialogue_path)

	if interaction_label != null:
		interaction_label.visible = false
		interaction_label.text = prompt_text

	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _process(_delta: float) -> void:
	if is_player_close and Input.is_action_just_pressed("interact") and not GameManager.is_dialogue_active:
		if sign_dialogue != null:
			DialogueManager.show_dialogue_balloon(sign_dialogue, "start")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_close = true
		if interaction_label != null:
			interaction_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_close = false
		if interaction_label != null:
			interaction_label.visible = false

func _on_dialogue_started(_dialogue) -> void:
	GameManager.is_dialogue_active = true
	if interaction_label != null:
		interaction_label.visible = false

func _on_dialogue_ended(_dialogue) -> void:
	await get_tree().create_timer(0.2).timeout
	GameManager.is_dialogue_active = false

	if is_player_close and interaction_label != null:
		interaction_label.visible = true
