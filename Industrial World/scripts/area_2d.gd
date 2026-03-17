extends Area2D

@onready var exclamation_mark = $ExclamationMark

const FIRST_DIALOGUE = preload("res://dialogues/first_dialogue.dialogue")
var is_player_close = false

func _ready() -> void:
	exclamation_mark.visible = false
	exclamation_mark.play("exclamation")
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _process(delta: float) -> void:
	if is_player_close and Input.is_action_just_pressed("ui_accept") and not GameManager.is_dialogue_active:
		DialogueManager.show_dialogue_balloon(FIRST_DIALOGUE, "start")

func _on_area_entered(area: Area2D) -> void:
	exclamation_mark.visible = true
	is_player_close = true


func _on_area_exited(area: Area2D) -> void:
	exclamation_mark.visible = false
	is_player_close = false

func _on_dialogue_started(dialogue):
	GameManager.is_dialogue_active = true

func _on_dialogue_ended(dialgue):
	await get_tree().create_timer(0.2).timeout
	GameManager.is_dialogue_active = false
