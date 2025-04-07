extends Control

@onready var label: RichTextLabel = $RichTextLabel

func _ready() -> void:
  label.clear()
  label.append_text("[b]How to Play[/b]\n")
  label.append_text("\n")
  label.append_text("The target is at the bottom of the hole.\nYour goal is to sink the ball.\n")
  label.append_text("Click, drag, and release to shoot.\n")
  label.append_text("\n")
  label.append_text("There are 18 holes.\n")
  label.append_text("Each hole costs %s\n" % State.bb_coin)
  label.append_text("Earn %s by scoring under par or collecting them during play.\n" % State.bb_coin)
  label.append_text("\n")
  label.append_text("Bogeys cost 1 %s\n" % State.bb_coin)
  label.append_text("Gain 10 %s for every stroke under par.\nDouble for a hole-in-one.\n" % State.bb_coin)

func _on_done_pressed() -> void:
  State.close_modal()
