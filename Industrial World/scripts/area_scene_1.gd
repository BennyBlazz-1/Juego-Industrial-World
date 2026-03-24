extends Area2D

@export var next_scene_path: String
@export var require_level1_exam_taken: bool = false

func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.name == "man_player":
		if require_level1_exam_taken:
			if GameManager.level1_exam_taken:
				change_scene()
		else:
			change_scene()

func change_scene():
	get_tree().change_scene_to_file(next_scene_path)
