extends Area2D

@export var orden: int = 0

@onready var sprite_signo = get_node_or_null("ExclamationMark")
@onready var sonido_boton = get_node_or_null("ExclamationMark/Boton")
@onready var interaction_label = get_node_or_null("PromptPoint/InteractionLabel")

var jugador_cerca: bool = false
var completado: bool = false

const DIALOGO_ERROR = "res://dialogues/nivel2_wrong.dialogue"
const DIALOGO_COMPLETE = "res://dialogues/nivel2_complete.dialogue"


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if sprite_signo:
		sprite_signo.visible = false
		if sprite_signo.has_method("stop"):
			sprite_signo.stop()

	if interaction_label:
		interaction_label.visible = false
		interaction_label.text = "Press E"

	if GameManager.nivel_2_passed:
		marcar_como_nivel_ya_superado()


func _process(_delta: float) -> void:
	if GameManager.nivel_2_passed:
		return

	if jugador_cerca and not completado and Input.is_action_just_pressed("interact"):
		interactuar()


func interactuar() -> void:
	if GameManager.is_dialogue_active:
		return

	if interaction_label:
		interaction_label.visible = false

	var escena_actual := get_tree().current_scene

	if escena_actual != null and escena_actual.has_method("start_nivel_2_timer_if_needed"):
		escena_actual.start_nivel_2_timer_if_needed()

	var fue_correcto := GameManager.completar_boton_nivel_2(name)

	if fue_correcto:
		activar_correcto()

		if GameManager.nivel_2_finished:
			if escena_actual != null and escena_actual.has_method("stop_nivel_2_timer"):
				escena_actual.stop_nivel_2_timer()

			await mostrar_dialogo_completado()

			if escena_actual != null and escena_actual.has_method("show_nivel_2_results"):
				escena_actual.show_nivel_2_results()
	else:
		activar_incorrecto()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		jugador_cerca = true

		if GameManager.nivel_2_passed:
			mostrar_signo()
			ocultar_label()
		elif not completado:
			mostrar_signo()
			mostrar_label()


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		jugador_cerca = false
		ocultar_label()

		if GameManager.nivel_2_passed:
			mostrar_signo()
		elif not completado:
			ocultar_signo()


func mostrar_signo() -> void:
	if sprite_signo:
		sprite_signo.visible = true
		if sprite_signo.has_method("play"):
			sprite_signo.play()


func ocultar_signo() -> void:
	if sprite_signo and not completado:
		sprite_signo.visible = false
		if sprite_signo.has_method("stop"):
			sprite_signo.stop()


func mostrar_label() -> void:
	if interaction_label and not completado and not GameManager.nivel_2_passed:
		interaction_label.visible = true


func ocultar_label() -> void:
	if interaction_label:
		interaction_label.visible = false


func activar_correcto() -> void:
	completado = true
	ocultar_label()

	if sprite_signo:
		sprite_signo.visible = true
		if sprite_signo.has_method("play"):
			sprite_signo.play()

	if sonido_boton:
		sonido_boton.stop()
		sonido_boton.play()


func activar_incorrecto() -> void:
	mostrar_dialogo_error()


func mostrar_dialogo_error() -> void:
	GameManager.is_dialogue_active = true
	ocultar_label()
	DialogueManager.show_dialogue_balloon(load(DIALOGO_ERROR))
	await DialogueManager.dialogue_ended
	GameManager.is_dialogue_active = false

	if jugador_cerca and not completado and not GameManager.nivel_2_passed:
		mostrar_label()


func mostrar_dialogo_completado() -> void:
	GameManager.is_dialogue_active = true
	ocultar_label()
	DialogueManager.show_dialogue_balloon(load(DIALOGO_COMPLETE))
	await DialogueManager.dialogue_ended
	GameManager.is_dialogue_active = false


func reiniciar_boton() -> void:
	completado = false
	jugador_cerca = false

	if sprite_signo:
		sprite_signo.visible = false
		if sprite_signo.has_method("stop"):
			sprite_signo.stop()

	ocultar_label()


func marcar_como_nivel_ya_superado() -> void:
	completado = true
	jugador_cerca = false
	ocultar_label()

	if sprite_signo:
		sprite_signo.visible = true
		if sprite_signo.has_method("play"):
			sprite_signo.play()
