extends Area2D

@export var next_scene_path: String
@export var require_level1_exam_taken: bool = false

var is_changing_scene: bool = false

func _on_body_entered(body: Node2D) -> void:
	if is_changing_scene:
		return

	if not body.is_in_group("player"):
		return

	if require_level1_exam_taken:
		if GameManager.level1_exam_taken:
			is_changing_scene = true
			call_deferred("change_scene")
	else:
		is_changing_scene = true
		call_deferred("change_scene")

func change_scene() -> void:
	get_tree().change_scene_to_file(next_scene_path)
