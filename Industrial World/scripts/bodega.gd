extends Node2D

@onready var spawn_from_world: Marker2D = $spawn_from_world
@onready var score_label: Label = $ScoreUI/PanelRoot/ScoreLabel
@onready var result_panel = $ResultPanel

const PLAYER_SCENE = preload("res://scenes/man_player.tscn")

var player: Node2D


func _ready() -> void:
	if not GameManager.level1_passed and not SaveManager.is_loading_game:
		GameManager.reset_level1()

	crear_player()
	place_player_at_spawn()

	if result_panel != null and result_panel.has_method("hide_results"):
		result_panel.hide_results()

	update_score_label()

	if GameManager.level1_passed:
		call_deferred("show_saved_results_if_completed")


func _process(_delta: float) -> void:
	update_score_label()


func crear_player() -> void:
	player = PLAYER_SCENE.instantiate() as Node2D
	player.add_to_group("player")
	add_child(player)


func place_player_at_spawn() -> void:
	if player == null:
		print("No player en bodega")
		return

	var spawn_name: String = GameManager.consume_next_spawn()

	if spawn_name == "bodega_from_world":
		player.global_position = spawn_from_world.global_position
	else:
		player.global_position = spawn_from_world.global_position

	SaveManager.apply_pending_loaded_state(self)


func update_score_label() -> void:
	if score_label == null:
		return

	score_label.text = "Score: %d/%d" % [
		GameManager.level1_score,
		GameManager.level1_total_questions
	]


func calculate_level1_stars(score: int) -> int:
	if score >= 16:
		return 3
	elif score >= 11:
		return 2
	elif score >= 5:
		return 1
	else:
		return 0


func save_bodega_completed_state() -> void:
	GameManager.level1_final_score = clampi(GameManager.level1_score, 0, GameManager.level1_total_questions)
	GameManager.level1_stars = calculate_level1_stars(GameManager.level1_final_score)


func show_bodega_results() -> void:
	if result_panel == null:
		return

	var current_score: int = clampi(GameManager.level1_score, 0, GameManager.level1_total_questions)
	var current_stars: int = calculate_level1_stars(current_score)

	if GameManager.level1_passed:
		save_bodega_completed_state()

	result_panel.show_results(
		current_stars,
		"16/16",
		"11+",
		"5+",
		"Score: %d/%d" % [current_score, GameManager.level1_total_questions]
	)


func show_saved_results_if_completed() -> void:
	if not GameManager.level1_passed:
		return

	if result_panel == null:
		return

	result_panel.show_results(
		GameManager.level1_stars,
		"16/16",
		"11+",
		"5+",
		"Score: %d/%d" % [GameManager.level1_final_score, GameManager.level1_total_questions]
	)
