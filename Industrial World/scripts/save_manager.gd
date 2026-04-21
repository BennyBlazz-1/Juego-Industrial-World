extends Node

const SAVE_PATH: String = "user://savegame.json"

var is_loading_game: bool = false

var _pending_scene_path: String = ""
var _pending_player_position: Vector2 = Vector2.ZERO
var _has_pending_player_position: bool = false
var _pending_scene_data: Dictionary = {}


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func prepare_new_game() -> void:
	_clear_pending_loaded_state()
	get_tree().paused = false
	Global.reset_state()
	GameManager.reset_all_progress()


func save_game() -> bool:
	var tree := get_tree()
	if tree == null:
		return false

	var current_scene := tree.current_scene
	if current_scene == null:
		return false

	var scene_path: String = current_scene.scene_file_path
	if scene_path == "":
		return false

	var player := tree.get_first_node_in_group("player") as Node2D
	if player == null:
		return false

	var save_data: Dictionary = {
		"saved_at_unix": Time.get_unix_time_from_system(),
		"saved_at_text": Time.get_datetime_string_from_system().replace("T", " "),
		"scene_path": scene_path,
		"player_position": _vector2_to_data(player.global_position),
		"global": Global.get_save_data(),
		"game_manager": GameManager.get_save_data(),
		"scene_data": _get_scene_save_data(current_scene)
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false

	file.store_string(JSON.stringify(save_data))
	return true


func load_game() -> bool:
	if not has_save():
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false

	var raw_text: String = file.get_as_text()
	if raw_text.strip_edges() == "":
		return false

	var json := JSON.new()
	var parse_result: int = json.parse(raw_text)
	if parse_result != OK:
		return false

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		return false

	var save_data: Dictionary = data

	var scene_path: String = String(save_data.get("scene_path", ""))
	if scene_path == "":
		return false

	var global_data: Dictionary = save_data.get("global", {})
	var game_manager_data: Dictionary = save_data.get("game_manager", {})
	var player_position_data: Dictionary = save_data.get("player_position", {})
	var scene_data: Dictionary = save_data.get("scene_data", {})

	get_tree().paused = false

	Global.reset_state()
	GameManager.reset_all_progress()

	Global.apply_save_data(global_data)
	GameManager.apply_save_data(game_manager_data)

	_pending_scene_path = scene_path
	_pending_player_position = _data_to_vector2(player_position_data)
	_has_pending_player_position = true
	_pending_scene_data = scene_data.duplicate(true)
	is_loading_game = true

	get_tree().change_scene_to_file(scene_path)
	return true


func apply_pending_loaded_state(current_scene: Node) -> void:
	if not is_loading_game:
		return

	if current_scene == null:
		return

	if current_scene.scene_file_path != _pending_scene_path:
		return

	if current_scene.has_method("apply_scene_save_data"):
		current_scene.call("apply_scene_save_data", _pending_scene_data)

	if _has_pending_player_position:
		var player := get_tree().get_first_node_in_group("player") as Node2D
		if player != null:
			player.global_position = _pending_player_position

			if player.has_method("update_current_camera"):
				player.call_deferred("update_current_camera")

	_clear_pending_loaded_state()


func _get_scene_save_data(current_scene: Node) -> Dictionary:
	if current_scene != null and current_scene.has_method("get_scene_save_data"):
		var scene_data = current_scene.call("get_scene_save_data")
		if typeof(scene_data) == TYPE_DICTIONARY:
			return (scene_data as Dictionary).duplicate(true)

	return {}


func _vector2_to_data(value: Vector2) -> Dictionary:
	return {
		"x": value.x,
		"y": value.y
	}


func _data_to_vector2(data: Dictionary) -> Vector2:
	return Vector2(
		float(data.get("x", 0.0)),
		float(data.get("y", 0.0))
	)


func _clear_pending_loaded_state() -> void:
	is_loading_game = false
	_pending_scene_path = ""
	_pending_player_position = Vector2.ZERO
	_has_pending_player_position = false
	_pending_scene_data = {}
