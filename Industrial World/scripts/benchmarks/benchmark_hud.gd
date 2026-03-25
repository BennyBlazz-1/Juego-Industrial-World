extends CanvasLayer

var panel: PanelContainer
var title_label: Label
var time_label: Label
var fps_label: Label
var npc_label: Label
var prop_label: Label
var area_label: Label
var event_label: Label

func _ready() -> void:
	_build_hud()

func _build_hud() -> void:
	# Limpia hijos si había algo previo
	for child in get_children():
		child.queue_free()

	panel = PanelContainer.new()
	panel.name = "PanelContainer"
	panel.position = Vector2(16, 16)
	panel.size = Vector2(260, 170)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.name = "MarginContainer"
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.name = "VBoxContainer"
	margin.add_child(vbox)

	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "Prueba: -"
	vbox.add_child(title_label)

	time_label = Label.new()
	time_label.name = "TimeLabel"
	time_label.text = "Tiempo: 0.0 s"
	vbox.add_child(time_label)

	fps_label = Label.new()
	fps_label.name = "FPSLabel"
	fps_label.text = "FPS: 0"
	vbox.add_child(fps_label)

	npc_label = Label.new()
	npc_label.name = "NPCLabel"
	npc_label.text = "NPC activos: 0"
	vbox.add_child(npc_label)

	prop_label = Label.new()
	prop_label.name = "PropLabel"
	prop_label.text = "Objetos activos: 0"
	vbox.add_child(prop_label)

	area_label = Label.new()
	area_label.name = "AreaLabel"
	area_label.text = "Áreas activas: 0"
	vbox.add_child(area_label)

	event_label = Label.new()
	event_label.name = "EventLabel"
	event_label.text = "Eventos acumulados: 0"
	vbox.add_child(event_label)

func set_values(test_name: String, elapsed: float, npc_count: int, prop_count: int, area_count: int, event_count: int) -> void:
	if title_label == null:
		return

	title_label.text = "Prueba: %s" % test_name
	time_label.text = "Tiempo: %.1f s" % elapsed
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	npc_label.text = "NPC activos: %d" % npc_count
	prop_label.text = "Objetos activos: %d" % prop_count
	area_label.text = "Áreas activas: %d" % area_count
	event_label.text = "Eventos acumulados: %d" % event_count
