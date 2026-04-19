extends Sprite2D

@onready var label: Label = $Label
@onready var timer_escritura: Timer = $TimerEscritura
@onready var timer_ocultar: Timer = $TimerOcultar

@export_range(0.02, 1.0, 0.01) var velocidad_letra: float = 0.05
@export var tiempo_visible: float = 3.0

var _texto_actual: String = ""
var index: int = 0

@export_multiline var texto: String = "":
	set(value):
		_texto_actual = value

		if not is_node_ready():
			return

		if _texto_actual.strip_edges() == "":
			ocultar_texto()
			return

		mostrar_texto()
	get:
		return _texto_actual


func _ready() -> void:
	# El Sprite2D NO se oculta aquí. Lo controlará AnimationPlayer.
	label.visible = false
	label.text = ""

	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = true
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP

	timer_escritura.one_shot = false
	timer_ocultar.one_shot = true
	timer_escritura.wait_time = velocidad_letra


func mostrar_texto() -> void:
	label.visible = true
	label.text = ""
	index = 0

	timer_escritura.stop()
	timer_ocultar.stop()
	timer_escritura.wait_time = velocidad_letra

	_escribir_siguiente_letra()

	if index >= _texto_actual.length():
		timer_ocultar.start(tiempo_visible)
	else:
		timer_escritura.start()


func _on_timer_escritura_timeout() -> void:
	if index >= _texto_actual.length():
		timer_escritura.stop()
		timer_ocultar.start(tiempo_visible)
		return

	_escribir_siguiente_letra()

	if index >= _texto_actual.length():
		timer_escritura.stop()
		timer_ocultar.start(tiempo_visible)


func _escribir_siguiente_letra() -> void:
	if index < _texto_actual.length():
		index += 1
		label.text = _texto_actual.substr(0, index)


func _on_timer_ocultar_timeout() -> void:
	ocultar_texto()


func ocultar_texto() -> void:
	timer_escritura.stop()
	timer_ocultar.stop()
	label.text = ""
	label.visible = false
	index = 0
