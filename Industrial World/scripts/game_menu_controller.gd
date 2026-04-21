extends Node

@export_file("*.tscn") var menu_scene_path: String = "res://scenes/menu.tscn"

@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var exit_confirmation_panel: CanvasLayer = $ExitConfirmationPanel
@onready var save_game_panel: CanvasLayer = $SaveGamePanel
@onready var save_notification_panel: CanvasLayer = $SaveNotificationPanel

@onready var resume_button: Button = $PauseMenu/PanelRoot/MainPanel/ResumeButton
@onready var pause_save_button: Button = $PauseMenu/PanelRoot/MainPanel/SaveGameButton
@onready var pause_exit_button: Button = $PauseMenu/PanelRoot/MainPanel/ExitButton

@onready var save_and_exit_button: Button = $ExitConfirmationPanel/PanelRoot/MainPanel/SaveAndExitButton
@onready var exit_without_saving_button: Button = $ExitConfirmationPanel/PanelRoot/MainPanel/ExitWithoutSavingButton
@onready var cancel_exit_button: Button = $ExitConfirmationPanel/PanelRoot/MainPanel/CancelButton

@onready var save_button: Button = $SaveGamePanel/PanelRoot/MainPanel/SaveButton
@onready var cancel_save_button: Button = $SaveGamePanel/PanelRoot/MainPanel/CancelButton

var is_menu_open: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_prepare_panel(pause_menu)
	_prepare_panel(exit_confirmation_panel)
	_prepare_panel(save_game_panel)
	_prepare_panel(save_notification_panel)

	_hide_all_panels()

	resume_button.pressed.connect(_on_resume_button_pressed)
	pause_save_button.pressed.connect(_on_pause_save_button_pressed)
	pause_exit_button.pressed.connect(_on_pause_exit_button_pressed)

	save_and_exit_button.pressed.connect(_on_save_and_exit_button_pressed)
	exit_without_saving_button.pressed.connect(_on_exit_without_saving_button_pressed)
	cancel_exit_button.pressed.connect(_on_cancel_exit_button_pressed)

	save_button.pressed.connect(_on_save_button_pressed)
	cancel_save_button.pressed.connect(_on_cancel_save_button_pressed)


func _prepare_panel(panel: CanvasLayer) -> void:
	panel.visible = false
	panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if GameManager.is_dialogue_active and not is_menu_open:
			return

		if exit_confirmation_panel.visible:
			_show_pause_menu()
			get_viewport().set_input_as_handled()
			return

		if save_game_panel.visible:
			_show_pause_menu()
			get_viewport().set_input_as_handled()
			return

		if pause_menu.visible:
			_resume_game()
			get_viewport().set_input_as_handled()
			return

		_open_pause_menu()
		get_viewport().set_input_as_handled()


func _open_pause_menu() -> void:
	is_menu_open = true
	GameManager.is_dialogue_active = true
	get_tree().paused = true
	_show_pause_menu()


func _resume_game() -> void:
	is_menu_open = false
	_hide_all_panels()
	get_tree().paused = false
	GameManager.is_dialogue_active = false


func _hide_all_panels() -> void:
	pause_menu.visible = false
	exit_confirmation_panel.visible = false
	save_game_panel.visible = false

	if save_notification_panel.has_method("hide_message"):
		save_notification_panel.call("hide_message")
	else:
		save_notification_panel.visible = false


func _show_pause_menu() -> void:
	_hide_all_panels()
	pause_menu.visible = true


func _show_exit_confirmation() -> void:
	_hide_all_panels()
	exit_confirmation_panel.visible = true


func _show_save_game_panel() -> void:
	_hide_all_panels()
	save_game_panel.visible = true


func _show_save_notification(text: String) -> void:
	if save_notification_panel.has_method("show_message"):
		save_notification_panel.call("show_message", text)
	else:
		save_notification_panel.visible = true


func _return_to_menu() -> void:
	get_tree().paused = false
	GameManager.is_dialogue_active = false
	is_menu_open = false
	_hide_all_panels()
	get_tree().change_scene_to_file(menu_scene_path)


func _on_resume_button_pressed() -> void:
	_resume_game()


func _on_pause_save_button_pressed() -> void:
	_show_save_game_panel()


func _on_pause_exit_button_pressed() -> void:
	_show_exit_confirmation()


func _on_cancel_save_button_pressed() -> void:
	_show_pause_menu()


func _on_cancel_exit_button_pressed() -> void:
	_show_pause_menu()


func _on_save_button_pressed() -> void:
	var save_ok: bool = SaveManager.save_game()

	_resume_game()
	_show_save_notification("Game Saved" if save_ok else "Save Failed")
	await get_tree().create_timer(1.2).timeout

	if save_notification_panel.has_method("hide_message"):
		save_notification_panel.call("hide_message")


func _on_save_and_exit_button_pressed() -> void:
	var save_ok: bool = SaveManager.save_game()

	if not save_ok:
		_show_pause_menu()
		_show_save_notification("Save Failed")
		await get_tree().create_timer(1.2).timeout

		if save_notification_panel.has_method("hide_message"):
			save_notification_panel.call("hide_message")
		return

	_return_to_menu()


func _on_exit_without_saving_button_pressed() -> void:
	_return_to_menu()
