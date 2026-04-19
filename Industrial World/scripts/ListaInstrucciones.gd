extends Area2D

@onready var signo = get_node_or_null("ExclamationMark")
@onready var sonido = get_node_or_null("ExclamationMark/Boton")
@onready var interaction_label = get_node_or_null("PromptPoint/InteractionLabel")

var jugador_cerca := false

const DIALOGO_INSTRUCCIONES = "res://dialogues/nivel2_instructions.dialogue"

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if signo:
		signo.visible = true
		if signo.has_method("play"):
			signo.play()

	if interaction_label:
		interaction_label.visible = false
		interaction_label.text = "Press E to read instructions"

func _process(_delta: float) -> void:
	if jugador_cerca and Input.is_action_just_pressed("interact"):
		interactuar()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		jugador_cerca = true
		mostrar_signo()
		mostrar_label()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		jugador_cerca = false
		ocultar_label()

func mostrar_signo() -> void:
	if signo:
		signo.visible = true
		if signo.has_method("play"):
			signo.play()

func ocultar_signo() -> void:
	if signo:
		signo.visible = false
		if signo.has_method("stop"):
			signo.stop()

func mostrar_label() -> void:
	if interaction_label:
		interaction_label.visible = true

func ocultar_label() -> void:
	if interaction_label:
		interaction_label.visible = false

func interactuar() -> void:
	if GameManager.is_dialogue_active:
		return

	if sonido:
		sonido.stop()
		sonido.play()

	mostrar_dialogo_instrucciones()

func mostrar_dialogo_instrucciones() -> void:
	GameManager.is_dialogue_active = true
	ocultar_signo()
	ocultar_label()
	DialogueManager.show_dialogue_balloon(load(DIALOGO_INSTRUCCIONES))
	await DialogueManager.dialogue_ended
	GameManager.is_dialogue_active = false

	var escena_actual := get_tree().current_scene
	if escena_actual != null:
		var tutorial_panel = escena_actual.get_node_or_null("TutorialPanel")
		if tutorial_panel != null and tutorial_panel.has_method("show_panel"):
			tutorial_panel.show_panel()

	mostrar_signo()
	if jugador_cerca:
		mostrar_label()
