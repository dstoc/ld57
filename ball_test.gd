extends RigidBody2D

@export var max_force: float = 1500.0
@export var line_color: Color = Color.RED
@export var line_width: float = 2.0
@onready var shoot: AudioStreamPlayer = $Shoot
@onready var hit: AudioStreamPlayer = $Hit

var is_dragging: bool = false
var drag_start: Vector2 = Vector2.ZERO
var drag_current: Vector2 = Vector2.ZERO

var line: Line2D

func _ready() -> void:
  line = Line2D.new()
  line.width = line_width
  line.default_color = line_color
  add_child(line)


func _input(event: InputEvent) -> void:
  if event is InputEventMouseButton:
    var mouse_event := event as InputEventMouseButton
    if mouse_event.button_index == MOUSE_BUTTON_LEFT:
      if mouse_event.pressed:
        is_dragging = true
        drag_start = mouse_event.position
        drag_current = drag_start
      else:
        if is_dragging:
          is_dragging = false
          apply_shot()
          line.clear_points()

  elif event is InputEventMouseMotion and is_dragging:
    var motion := event as InputEventMouseMotion
    drag_current = motion.position
    update_line()

func _process(_delta: float) -> void:
  if is_dragging: update_line()

func update_line() -> void:
  line.clear_points()
  line.rotation = -rotation
  line.add_point(Vector2.ZERO)
  line.add_point(drag_start - drag_current)


func apply_shot() -> void:
  var force_vec: Vector2 = (drag_start - drag_current) * 5.0
  if force_vec.length() > max_force:
    force_vec = force_vec.normalized() * max_force
  apply_impulse(force_vec)
  State.strokes += 1
  shoot.pitch_scale = 0.6 + (force_vec.length() / max_force) * 0.4
  shoot.play()

# var has_collided: bool = false

# func _physics_process(_delta: float) -> void:
#   if get_contact_count() > 0 and not has_collided:
#     has_collided = true
#     hit.play()
#   elif get_contact_count() == 0:
#     has_collided = false  # Reset for next collision

const IMPULSE_THRESHOLD: float = 50.0  # Tune this for your game
var has_played: bool = false

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
  var contact_count: int = state.get_contact_count()

  var strong_hit: bool = false

  for i in range(contact_count):
    var impulse: float = state.get_contact_impulse(i).length()
    if impulse >= IMPULSE_THRESHOLD:
      strong_hit = true
      break

  if strong_hit and not has_played:
    hit.play()
    has_played = true
  elif contact_count == 0:
    has_played = false
