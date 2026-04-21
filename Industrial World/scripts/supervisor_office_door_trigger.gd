extends Area2D

@export_file("*.dialogue") var dialogue_path: String = "res://dialogues/supervisor_office_maintenance.dialogue"
@export var trigger_cooldown: float = 0.4

var dialogue_resource: Resource = null
var can_trigger: bool = true


func _ready() -> void:
	if dialogue_path != "":
		dialogue_resource = load(dialogue_path)

	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not can_trigger:
		return

	if not body.is_in_group("player"):
		return

	if GameManager.is_dialogue_active:
		return

	if dialogue_resource == null:
		return

	can_trigger = false
	GameManager.is_dialogue_active = true

	if body is CharacterBody2D:
		var player_body: CharacterBody2D = body as CharacterBody2D
		player_body.velocity = Vector2.ZERO

	DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
	await DialogueManager.dialogue_ended

	GameManager.is_dialogue_active = false

	await get_tree().create_timer(trigger_cooldown).timeout
	can_trigger = true
