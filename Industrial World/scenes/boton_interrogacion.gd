extends Area2D

@export var orden: int = 0

@onready var sprite_signo = $ExclamationMark
@onready var sonido_boton = $ExclamationMark/Boton

var jugador_cerca: bool = false
var completado: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if sprite_signo:
		sprite_signo.visible = false

func _process(_delta: float) -> void:
	if jugador_cerca and not completado and Input.is_action_just_pressed("interact"):
		interactuar()

func interactuar() -> void:
	var fue_correcto = GameManager.completar_boton_nivel_2(name)

	if fue_correcto:
		activar_correcto()
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

func ocultar_signo() -> void:
	if sprite_signo and not completado:
		sprite_signo.visible = false

func activar_correcto() -> void:
	completado = true

	if sprite_signo:
		sprite_signo.visible = true

	if sonido_boton:
		sonido_boton.stop()
		sonido_boton.play()

	print("Correcto:", name)

	if GameManager.nivel_2_finished:
		print("Nivel 2 completado")
		# aquí puedes cambiar de nivel o abrir puerta

func activar_incorrecto() -> void:
	print("Incorrecto:", name)
