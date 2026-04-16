extends Area2D

@onready var exclamation_mark: AnimatedSprite2D = $ExclamationMark
@onready var interaction_label: Label = $PromptPoint/InteractionLabel

@export_file("*.dialogue") var dialogue_path: String
@export var step_name: String = ""
@export var station_display_name: String = "Station"

var is_player_close: bool = false
var opened_here: bool = false
var dialogue_resource: Resource = null

func _ready() -> void:
	exclamation_mark.visible = false
	exclamation_mark.play("exclamation")

	interaction_label.visible = false
	interaction_label.text = "Press E to start " + station_display_name

	if dialogue_path != "":
		dialogue_resource = load(dialogue_path)

	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _process(_delta: float) -> void:
	if is_player_close and Input.is_action_just_pressed("interact") and not GameManager.is_dialogue_active:
		if can_open_station():
			opened_here = true
			DialogueManager.show_dialogue_balloon(dialogue_resource, "start")

func can_open_station() -> bool:
	if dialogue_resource == null:
		return false

	if step_name == "":
		return true

	return not GameManager.level1_steps.get(step_name, false)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_close = true

		if can_open_station():
			exclamation_mark.visible = true
			interaction_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_close = false
		exclamation_mark.visible = false
		interaction_label.visible = false

func _on_dialogue_started(_dialogue) -> void:
	GameManager.is_dialogue_active = true
	exclamation_mark.visible = false
	interaction_label.visible = false

func _on_dialogue_ended(_dialogue) -> void:
	await get_tree().create_timer(0.2).timeout
	GameManager.is_dialogue_active = false

	if opened_here:
		opened_here = false
		if step_name != "":
			GameManager.complete_step(step_name)

	if is_player_close and can_open_station():
		exclamation_mark.visible = true
		interaction_label.visible = true
