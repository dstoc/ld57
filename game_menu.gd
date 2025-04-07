extends Control

func _settings_pressed() -> void:
  State.close_modal()
  State.settings_modal()

func _quit_pressed() -> void:
  State.close_modal()
  State.main_menu()

func _continue_pressed() -> void:
  State.close_modal()
