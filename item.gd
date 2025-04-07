extends Node2D

@onready var area2d: Area2D = $Area2D 
@onready var sound: AudioStreamPlayer = $Sound

func _ready() -> void:
  area2d.body_entered.connect(_body_entered)

func _exit_tree() -> void:
  area2d.body_entered.disconnect(_body_entered)

func _body_entered(body: Node) -> void:
  if body.name == "Ball":
    State.coins += State.coin_value
    State.coins_collected += State.coin_value
    sound.play()
    area2d.monitoring = false
    visible = false
    await sound.finished
    var parent := get_parent()
    if parent:
      parent.remove_child(self)
