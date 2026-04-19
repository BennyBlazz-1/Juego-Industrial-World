extends CanvasLayer

@export_range(0, 3) var preview_stars: int = 3
@export var test_mode: bool = true

@onready var overlay: ColorRect = $Overlay
@onready var panel_root: Control = $PanelRoot
@onready var background: TextureRect = $PanelRoot/Background

@onready var star1: AnimatedSprite2D = $PanelRoot/Stars/Star1
@onready var star2: AnimatedSprite2D = $PanelRoot/Stars/Star2
@onready var star3: AnimatedSprite2D = $PanelRoot/Stars/Star3

@onready var label1: Label = $PanelRoot/Label1
@onready var label2: Label = $PanelRoot/Label2
@onready var label3: Label = $PanelRoot/Label3

@onready var restart_button: Button = $PanelRoot/RestartButton
@onready var next_button: Button = $PanelRoot/NextButton


func _ready() -> void:
	restart_button.pressed.connect(_on_restart_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)

	if test_mode:
		visible = true
		show_results(preview_stars, "Accuracy", "Speed", "Completion")
	else:
		visible = false


func show_results(stars_count: int, text1: String, text2: String, text3: String) -> void:
	visible = true

	label1.text = text1
	label2.text = text2
	label3.text = text3

	update_stars(stars_count)


func hide_results() -> void:
	visible = false


func update_stars(stars_count: int) -> void:
	var stars := [star1, star2, star3]

	for i in range(stars.size()):
		if i < stars_count:
			stars[i].play("full")
		else:
			stars[i].play("empty")


func _on_restart_button_pressed() -> void:
	print("Restart pressed")
	# Aquí luego pondremos la lógica real
	# Ejemplo futuro:
	# get_tree().reload_current_scene()


func _on_next_button_pressed() -> void:
	print("Next pressed")
	# Aquí luego pondremos la lógica real
	# Ejemplo futuro:
	# get_tree().change_scene_to_file("res://scenes/siguiente_nivel.tscn")
