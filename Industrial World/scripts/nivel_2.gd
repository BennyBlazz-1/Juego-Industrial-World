extends Node2D

@onready var spawn_from_world: Marker2D = get_node_or_null("spawn_from_world")
@onready var timer_label: Label = $TimerUI/PanelRoot/TimerLabel
@onready var result_panel = $ResultPanel

const THREE_STAR_LIMIT: int = 300 # 5:00
const TWO_STAR_LIMIT: int = 420   # 7:00
const ONE_STAR_LIMIT: int = 540   # 9:00

var elapsed_time: float = 0.0
var timer_running: bool = false
var timer_started: bool = false
var final_time_seconds: int = 0


func _ready() -> void:
	call_deferred("place_player_at_spawn")

	if result_panel != null and result_panel.has_method("hide_results"):
		result_panel.hide_results()

	if GameManager.nivel_2_passed:
		load_completed_state()
		call_deferred("show_saved_results_if_completed")
	else:
		reset_timer_state()


func _process(delta: float) -> void:
	if timer_running:
		elapsed_time += delta
		update_timer_label()


func place_player_at_spawn() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	if spawn_from_world == null:
		push_error("No existe el nodo 'spawn_from_world' en nivel_2.tscn")
		return

	var spawn_name := GameManager.consume_next_spawn()

	if spawn_name == "spawn_from_world":
		player.global_position = spawn_from_world.global_position


func start_nivel_2_timer_if_needed() -> void:
	if timer_started:
		return

	if GameManager.nivel_2_finished:
		return

	timer_started = true
	timer_running = true


func stop_nivel_2_timer() -> void:
	if not timer_started:
		return

	timer_running = false

	if elapsed_time <= 0.0:
		final_time_seconds = 0
	else:
		final_time_seconds = int(ceil(elapsed_time))

	timer_label.text = format_time(final_time_seconds)
	save_completed_state()


func show_nivel_2_results() -> void:
	if result_panel == null:
		return

	var stars := calculate_stars(final_time_seconds)

	result_panel.show_results(
		stars,
		"5:00",
		"7:00",
		"9:00",
		"Time: " + format_time(final_time_seconds)
	)


func show_saved_results_if_completed() -> void:
	if not GameManager.nivel_2_passed:
		return

	if result_panel == null:
		return

	result_panel.show_results(
		GameManager.nivel_2_stars,
		"5:00",
		"7:00",
		"9:00",
		"Time: " + format_time(GameManager.nivel_2_final_time_seconds)
	)


func save_completed_state() -> void:
	GameManager.nivel_2_final_time_seconds = final_time_seconds
	GameManager.nivel_2_stars = calculate_stars(final_time_seconds)


func load_completed_state() -> void:
	timer_running = false
	timer_started = false
	final_time_seconds = GameManager.nivel_2_final_time_seconds
	elapsed_time = float(final_time_seconds)

	if timer_label != null:
		timer_label.text = format_time(final_time_seconds)


func reset_timer_state() -> void:
	elapsed_time = 0.0
	timer_running = false
	timer_started = false
	final_time_seconds = 0
	update_timer_label()


func update_timer_label() -> void:
	if timer_label == null:
		return

	timer_label.text = format_time(int(floor(elapsed_time)))


func calculate_stars(total_seconds: int) -> int:
	if total_seconds <= THREE_STAR_LIMIT:
		return 3
	elif total_seconds <= TWO_STAR_LIMIT:
		return 2
	elif total_seconds <= ONE_STAR_LIMIT:
		return 1
	else:
		return 0


func format_time(total_seconds: int) -> String:
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	return "%d:%02d" % [minutes, seconds]
