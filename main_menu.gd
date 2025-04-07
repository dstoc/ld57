extends Node2D


func _on_start_pressed() -> void:
  State.start_game()

func _on_settings_pressed() -> void:
  State.settings_modal()

func _on_how_play_pressed() -> void:
  State.howto_modal()
