extends Area2D

@export var orden: int = 0

@onready var sprite_signo = get_node_or_null("ExclamationMark")
@onready var sonido_boton = get_node_or_null("ExclamationMark/Boton")

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

func _process(_delta: float) -> void:
	if jugador_cerca and not completado and Input.is_action_just_pressed("interact"):
		interactuar()

func interactuar() -> void:
	if GameManager.is_dialogue_active:
		return

	var fue_correcto = GameManager.completar_boton_nivel_2(name)

	if fue_correcto:
		activar_correcto()

		if GameManager.nivel_2_finished:
			mostrar_dialogo_completado()
	else:
		activar_incorrecto()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		jugador_cerca = true
		mostrar_signo()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		jugador_cerca = false
		if not completado:
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

func activar_correcto() -> void:
	completado = true

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
	DialogueManager.show_dialogue_balloon(load(DIALOGO_ERROR))
	await DialogueManager.dialogue_ended
	GameManager.is_dialogue_active = false

func mostrar_dialogo_completado() -> void:
	GameManager.is_dialogue_active = true
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
