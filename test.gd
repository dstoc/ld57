extends Node2D

@onready var layer: TileMapLayer = $TileMapLayer
@onready var ball: RigidBody2D = $Ball
@onready var tee: Node2D= $Tee
@onready var flag: Node2D= $Flag
@onready var label: RichTextLabel = $CanvasLayer/RichTextLabel
@export var camera: Camera2D

var left_noise := FastNoiseLite.new()
var right_noise := FastNoiseLite.new()

var last_generated_row: int = 0
var tile_source_id: int = 0
var atlas_coords: Vector2i = Vector2i(1, 0)

var border_block := Vector2i(14, 0)
var flag_block := Vector2i(15, 0)
var inner_block: Vector2i = Vector2i(1, 0)

var left_center_x: int = 2
var max_offset: int = 20

const MIN_ZOOM: float = 0.1
const MAX_ZOOM: float = 10.0
const ZOOM_SPEED: float = 0.1

var is_panning: bool = false

func _ready() -> void:
  left_noise.noise_type = FastNoiseLite.NoiseType.TYPE_SIMPLEX
  left_noise.seed = randi()
  left_noise.frequency = 0.05

  right_noise.noise_type = FastNoiseLite.NoiseType.TYPE_SIMPLEX
  right_noise.seed = randi()
  right_noise.frequency = 0.05
  generate_level(State.level_lengths[State.level])
  

func _unhandled_input(event: InputEvent) -> void:
  if event is InputEventMouseButton:
    var mouse_event := event as InputEventMouseButton

    if mouse_event.button_index == MOUSE_BUTTON_RIGHT and mouse_event.pressed:
      State.start_game()

    if mouse_event.button_index == MOUSE_BUTTON_MIDDLE:
      is_panning = mouse_event.pressed

    elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
      _apply_zoom(-ZOOM_SPEED)

    elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
      _apply_zoom(ZOOM_SPEED)

  elif event is InputEventMouseMotion and is_panning:
    var motion := event as InputEventMouseMotion
    camera.position -= motion.relative / camera.zoom.x

  var key_event := event as InputEventKey
  if key_event:
    if key_event.keycode == KEY_ESCAPE:
      State.game_menu_modal()


func _apply_zoom(delta_zoom: float) -> void:
  var old_zoom_x: float = camera.zoom.x
  var new_zoom_x: float = clamp(
    old_zoom_x * (1.0 + delta_zoom),
    MIN_ZOOM,
    MAX_ZOOM
  )
  var new_zoom := Vector2(new_zoom_x, new_zoom_x)
  camera.zoom = new_zoom


func _process(_delta: float) -> void:
  camera.position = (camera.position + ball.position) / 2
  label.clear()
  label.append_text("Hole %d " % State.level)
  label.append_text("Par %d\n" % State.par)
  label.append_text("Strokes %d\n" % State.strokes)
  label.append_text("Distance %d\n" % int((ball.position - flag.position).length() / 10.0))
  label.append_text("Wallet %d %s\n" % [State.coins, State.bb_coin])
  label.append_text("Next hole charge %d %s\n" % [State.next_level_cost(), State.bb_coin])

func generate_level(rows: int) -> void:
  layer.clear()
  var start_offset := roundi(left_center_x + max_offset * 0.75)
  for x in range(start_offset - 1, start_offset + 2):
    layer.set_cell(Vector2i(x, -2), tile_source_id, inner_block)
    layer.set_cell(Vector2i(x, -1), tile_source_id, inner_block)

  fill_border_for_row(-3)
  fill_border_for_row(-2)

  tee.position = layer.map_to_local(Vector2i(start_offset, -1))
  ball.position = layer.map_to_local(Vector2i(start_offset, -2))
  generate_rows(0, rows + 1)
  fill_border_for_row(-1)

  var flag_x := randi_range(_find_first_cell(rows), _find_last_cell(rows))
  flag_x = _find_last_cell(rows)
  if flag_x == _find_first_cell(rows):
    layer.set_cell(Vector2i(flag_x - 1, rows), tile_source_id, inner_block)
  if flag_x == _find_last_cell(rows):
    layer.set_cell(Vector2i(flag_x + 1, rows), tile_source_id, inner_block)
  fill_border_for_row(rows - 1)
  fill_border_for_row(rows)
  fill_border_for_row(rows + 1)
  flag.position = layer.map_to_local(Vector2i(flag_x, rows))

  for y in range(1, rows - 1):
    if randf() < State.coin_row_probability:
      var item_scene: PackedScene = load("res://item.tscn")
      var item: Node2D = item_scene.instantiate()
      var item_x := randi_range(_find_first_cell(y), _find_last_cell(y))
      item.position = layer.map_to_local(Vector2i(item_x, y))
      add_child(item)

func _find_first_cell(y: int) -> int:
  for x in range(left_center_x + 0, left_center_x + max_offset + 1):
    var pos := Vector2i(x, y)
    if layer.get_cell_source_id(pos) >= 0 and layer.get_cell_atlas_coords(pos) < border_block:
      return x
  return -1

func _find_last_cell(y: int) -> int:
  for x in range(left_center_x + max_offset, left_center_x - 1, -1):
    var pos := Vector2i(x, y)
    if layer.get_cell_source_id(pos) >= 0 and layer.get_cell_atlas_coords(pos) < border_block:
      return x
  return -1


func generate_rows(start_y: int, end_y: int) -> void:
  for y in range(start_y, end_y):
    var left_factor: float = (left_noise.get_noise_1d(y) + 1.0) * 0.5
    var right_factor: float = (right_noise.get_noise_1d(y) + 1.0) * 0.5

    var left_x: int = left_center_x + int(left_factor * max_offset)
    var fill_width: int = ceili(right_factor * max_offset)

    for x in range(left_x, left_x + fill_width):
      layer.set_cell(Vector2i(x, y), tile_source_id, atlas_coords)

    # ensure that this row and prev have some overlap
    var first_cell := _find_first_cell(y)
    var last_cell := _find_last_cell(y)
    if first_cell == -1:
      continue
    var prev_first_cell := _find_first_cell(y - 1)
    var prev_last_cell := _find_last_cell(y - 1)
    if prev_first_cell == -1:
      continue
    if first_cell > prev_last_cell:
      for x in range(prev_last_cell, first_cell + 1):
        layer.set_cell(Vector2i(x, y), tile_source_id, atlas_coords)
    if last_cell < prev_first_cell:
      for x in range(last_cell, prev_first_cell + 1):
        layer.set_cell(Vector2i(x, y), tile_source_id, atlas_coords)

 
  for y in range(start_y, end_y - 1):
    fill_border_for_row(y)

func is_inner_tile(pos: Vector2i) -> bool:
  if layer.get_cell_source_id(pos) != 0: return false
  return layer.get_cell_atlas_coords(pos) < border_block

func fill_border_for_row(y: int) -> void:
  var start_x: int = _find_first_cell(y)
  if start_x < 0:
    start_x = left_center_x

  var x := start_x
  while true:
    var cell_pos: Vector2i = Vector2i(x, y)
    var neighbor_flags: Array[bool] = []
    if not is_inner_tile(cell_pos):
      break

    for offset_y in range(-1, 2):
      for offset_x in range(-1, 2):
        var neighbor_pos: Vector2i = cell_pos + Vector2i(offset_x, offset_y)
        var is_set := is_inner_tile(neighbor_pos)
        neighbor_flags.append(is_set)

    var result := match_border(neighbor_flags)
    layer.set_cell(cell_pos, 0, result)
  
    x += 1
  for fill_x in range(0, 40):
    var pos := Vector2i(fill_x, y)
    if not is_inner_tile(pos):
      layer.set_cell(pos, 0, border_block)

func check(state: Array[bool], constraint: Array[bool]) -> bool:
  for i in range(state.size()):
    if (not constraint[i]) and state[i]: return false
  return true

class BorderTile:
  var coord: Vector2i
  var constraints: Array[bool]

  func _init(_coord: Vector2i, _constraints: Array[bool]) -> void:
    coord = _coord
    constraints = _constraints

var borders: Array[BorderTile] = [
  BorderTile.new(Vector2i(2, 0), [
    true, false, true,
    false, true, true,
    true, false, true
  ]),
  BorderTile.new(Vector2i(4, 0), [
    true, false, true,
    true, true, false,
    true, false, true
  ]),
  BorderTile.new(Vector2i(5, 0), [
    true, true, true,
    false, true, false,
    true, true, true
  ]),
  BorderTile.new(Vector2i(10, 0), [
    true, true, true,
    true, true, false,
    true, false, true
  ]),
  BorderTile.new(Vector2i(9, 0), [
    true, false, true,
    true, true, false,
    true, true, true
  ]),
  BorderTile.new(Vector2i(8, 0), [
    true, true, true,
    false, true, true,
    true, false, true
  ]),
  BorderTile.new(Vector2i(7, 0), [
    true, false, true,
    false, true, true,
    true, true, true
  ]),
  BorderTile.new(Vector2i(13, 0), [
    true, false, true,
    true, true, true,
    true, false, true
  ]),
  BorderTile.new(Vector2i(12, 0), [
    true, true, true,
    false, true, true,
    true, true, true
  ]),
  BorderTile.new(Vector2i(11, 0), [
    true, true, true,
    true, true, false,
    true, true, true
  ]),
  BorderTile.new(Vector2i(6, 0), [
    true, false, true,
    true, true, true,
    true, true, true
  ]),
  BorderTile.new(Vector2i(3, 0), [
    true, true, true,
    true, true, true,
    true, false, true
  ]),
  # Default
  BorderTile.new(Vector2i(1, 0), [
    true, true, true,
    true, true, true,
    true, true, true
  ]),
]

func match_border(neighbors: Array[bool]) -> Vector2i:
  for border in borders:
    if check(neighbors, border.constraints):
      return border.coord
  return Vector2i(1, 0)

