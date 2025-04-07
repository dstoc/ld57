extends Node2D

@onready var area2d: Area2D = $Area2D 
@onready var sound: AudioStreamPlayer = $Sound

func _ready() -> void:
  area2d.body_entered.connect(_body_entered)

func _body_entered(body: Node) -> void:
  if body.name == "Ball":
    await get_tree().process_frame
    var ball: RigidBody2D = body
    ball.freeze = true
    # ball.collision_layer = 0
    # ball.collision_mask = 0
    State.round_finished_modal()
    sound.play()
