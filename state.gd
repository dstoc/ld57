extends Node

var level := 0
var strokes := 0
var par := 0
var coins := 0
var coins_collected := 0
var level_lengths: Array[int] = [0, 50, 68, 61, 85, 96, 91, 110, 123, 118, 140, 157, 150, 169, 188, 179, 207, 231, 300, 0]

const bogey_penalty := 1
const coin_value := 1
const under_par_bonus := 10
const hole_in_one_bonus := 2 * under_par_bonus
const coin_row_probability = 0.5
const bb_coin = "[img]res://coin.png[/img]"

var music_player: AudioStreamPlayer

func _ready() -> void:
  reset()
  music_player = AudioStreamPlayer.new()
  add_child(music_player)
  music_player.stream = preload("res://track.mp3")
  music_player.bus = "Music"
  music_player.play()
  music_player.finished.connect(func () -> void: music_player.play())

func reset() -> void:
  level = 1
  coins = 5

func next_level_cost() -> int:
  return int(level_lengths[level] * coin_row_probability * (coin_value) * ((2 + level) / 60.0))
  
func main_menu() -> void:
  reset()
  var scene: PackedScene = load("res://main_menu.tscn")
  get_tree().change_scene_to_packed(scene)

func start_game() -> void:
  strokes = 0
  coins_collected = 0
  par = int(level_lengths[level] / 50.0) * 3
  var scene: PackedScene = load("res://game.tscn")
  get_tree().change_scene_to_packed(scene)

func round_finished_modal() -> void:
  State.show_modal("res://round_finished.tscn")

func settings_modal() -> void:
  State.show_modal("res://settings.tscn")

func game_menu_modal() -> void:
  State.show_modal("res://game_menu.tscn")

func howto_modal() -> void:
  State.show_modal("res://howto.tscn")

# func _unhandled_input(event: InputEvent) -> void:
#   var key_event := event as InputEventKey
#   if key_event:
#     if key_event.keycode == KEY_ESCAPE:
#       if get_tree().current_scene.scene_file_path == "res://test.tscn": 
#         game_menu_modal()

func show_modal(scene_path: String) -> void:
  var inner_scene: PackedScene = load(scene_path)
  var content_instance: Node = inner_scene.instantiate()

  var modal_window: Window = Window.new()
  modal_window.name = "LevelCompleteWindow"
  modal_window.exclusive = true
  modal_window.unresizable = true
  modal_window.size = Vector2(400, 300)
  modal_window.title = "Level Complete"
  modal_window.transparent = true
  modal_window.unresizable = true
  modal_window.borderless = true
  modal_window.size = DisplayServer.window_get_size()
  modal_window.position = Vector2.ZERO
  modal_window.popup_centered()

  modal_window.add_child(content_instance)

  get_tree().current_scene.add_child(modal_window)

  modal_window.popup_centered()

func close_modal() -> void:
  var scene_root: Node = get_tree().current_scene
  for child: Node in scene_root.get_children():
    var window := child as Window
    if window:
      scene_root.remove_child(window)
      child.queue_free()
