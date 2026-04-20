extends CanvasLayer

@export_range(0, 3) var preview_stars: int = 3
@export var test_mode: bool = true
@export var is_final_level: bool = false

# Si quieres reiniciar todo el juego hacia una escena específica, pon aquí la ruta.
# Si la dejas vacía, recarga la escena actual.
@export_file("*.tscn") var reset_scene_path: String = ""

@onready var overlay: ColorRect = $Overlay
@onready var panel_root: Control = $PanelRoot
@onready var background: TextureRect = $PanelRoot/Background

@onready var win_label: Label = $PanelRoot/WinLabel
@onready var subtitle_label: Label = $PanelRoot/SubtitleLabel

@onready var star1: AnimatedSprite2D = $PanelRoot/Stars/Star1
@onready var star2: AnimatedSprite2D = $PanelRoot/Stars/Star2
@onready var star3: AnimatedSprite2D = $PanelRoot/Stars/Star3

@onready var label1: Label = $PanelRoot/Label1
@onready var label2: Label = $PanelRoot/Label2
@onready var label3: Label = $PanelRoot/Label3
@onready var metric_label: Label = $PanelRoot/MetricLabel

@onready var restart_button: Button = $PanelRoot/RestartButton
@onready var next_button: Button = $PanelRoot/NextButton
@onready var sonido: AudioStreamPlayer = $Sonido

var restart_button_default_position: Vector2
var next_button_default_position: Vector2


func _ready() -> void:
	restart_button.pressed.connect(_on_restart_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)

	restart_button_default_position = restart_button.position
	next_button_default_position = next_button.position

	restart_button.text = "RESET"
	update_next_button_text()

	if test_mode:
		visible = true
		show_results(preview_stars, "5:00", "7:00", "9:00", "Time: 0:00")
	else:
		visible = false


func show_results(stars_count: int, text1: String, text2: String, text3: String, metric_text: String = "") -> void:
	visible = true
	GameManager.is_dialogue_active = true

	if sonido:
		sonido.stop()
		sonido.play()

	label1.text = text3
	label2.text = text2
	label3.text = text1

	metric_label.text = metric_text
	metric_label.visible = metric_text != ""

	update_result_text(stars_count)
	update_stars(stars_count)
	update_buttons(stars_count)


func hide_results() -> void:
	visible = false
	GameManager.is_dialogue_active = false


func update_result_text(stars_count: int) -> void:
	if stars_count <= 0:
		win_label.text = "TRY AGAIN"
		subtitle_label.text = "PLEASE TRY AGAIN"
	else:
		win_label.text = "WIN!"
		subtitle_label.text = "STARS OBTAINED"


func update_stars(stars_count: int) -> void:
	var stars := [star1, star2, star3]

	for i in range(stars.size()):
		if i < stars_count:
			stars[i].play("full")
		else:
			stars[i].play("empty")


func update_next_button_text() -> void:
	if is_final_level:
		next_button.text = "FINISH"
	else:
		next_button.text = "CONTINUE"


func update_buttons(stars_count: int) -> void:
	restart_button.text = "RESET"

	if stars_count <= 0:
		next_button.visible = false

		var viewport_width: float = get_viewport().get_visible_rect().size.x
		restart_button.position.x = (viewport_width - restart_button.size.x) / 2.0
	else:
		next_button.visible = true
		restart_button.position = restart_button_default_position
		next_button.position = next_button_default_position
		update_next_button_text()


func _on_restart_button_pressed() -> void:
	GameManager.is_dialogue_active = false
	GameManager.reset_level1()
	GameManager.reset_nivel_2_completo()
	GameManager.next_spawn_point = ""

	if reset_scene_path != "":
		get_tree().change_scene_to_file(reset_scene_path)
	else:
		get_tree().reload_current_scene()


func _on_next_button_pressed() -> void:
	if is_final_level:
		print("Finish pressed")
	else:
		print("Continue pressed")

	hide_results()
