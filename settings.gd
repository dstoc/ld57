extends Control

const MIN_DB: float = -60.0
const MAX_DB: float = 6.0

const EFFECT_BUS: String = "Effects"
const MUSIC_BUS: String = "Music"

@onready var effect_slider: HSlider = find_child("EffectSlider")
@onready var music_slider: HSlider = find_child("MusicSlider")

func _ready() -> void:
  configure_slider(effect_slider)
  configure_slider(music_slider)
  effect_slider.value = db_to_linear(get_bus_volume(EFFECT_BUS))
  music_slider.value = db_to_linear(get_bus_volume(MUSIC_BUS))

func _on_done_pressed() -> void:
  State.close_modal()

func _on_effect_value_changed(value: float) -> void:
  var db := linear_to_db(value)
  set_bus_volume(EFFECT_BUS, db)

func _on_music_value_changed(value: float) -> void:
  var db := linear_to_db(value)
  set_bus_volume(MUSIC_BUS, db)

func set_bus_volume(bus_name: String, volume_db: float) -> void:
  var index: int = AudioServer.get_bus_index(bus_name)
  if index != -1:
    AudioServer.set_bus_volume_db(index, volume_db)
  else:
    push_error("Audio bus not found: %s" % bus_name)

func get_bus_volume(bus_name: String) -> float:
  var index: int = AudioServer.get_bus_index(bus_name)
  if index != -1:
    return AudioServer.get_bus_volume_db(index)
  else:
    push_error("Audio bus not found: %s" % bus_name)
    return 0.0

func configure_slider(slider: HSlider) -> void:
  slider.min_value = 0.0
  slider.max_value = 2.0
  slider.step = 0.01
  # slider.value = 1.0
