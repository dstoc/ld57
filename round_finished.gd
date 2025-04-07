extends Control

@onready var label: RichTextLabel = find_child("RichTextLabel")

func _ready() -> void:
  label.clear()
  label.append_text("[b]Hole %d clear![/b]\n\n" % [State.level])
  var new_total := State.coins
  if State.coins_collected > 0:
    label.append_text("Collected %d %s\n" % [State.coins_collected, State.bb_coin])
  if State.strokes == 1:
    var stroke_bonus := State.hole_in_one_bonus * (State.par - State.strokes)
    label.append_text("Hole in one bonus %d %s\n" % [stroke_bonus, State.bb_coin])
    new_total += stroke_bonus
  elif State.strokes < State.par:
    var stroke_bonus := State.under_par_bonus * (State.par - State.strokes)
    label.append_text("Under par bonus %d %s\n" % [stroke_bonus, State.bb_coin])
    new_total += stroke_bonus

  if State.strokes > State.par:
    var stroke_charge := State.bogey_penalty * (State.strokes - State.par)
    label.append_text("Bogey penalty %d %s\n" % [stroke_charge, State.bb_coin])
    new_total -= stroke_charge

  label.append_text("New total %d %s\n" % [new_total, State.bb_coin])
  label.append_text("\n")

  if State.level == 18:
    label.append_text("Solid game. That was impressive.")
    label.append_text("\n[url=finished]Main Menu[/url]\n")
  elif new_total >= State.next_level_cost():
    label.append_text("Hole %d charge %d %s paid!\n" % [State.level + 1, State.next_level_cost(), State.bb_coin])
    label.append_text("%s\n" % continue_string())
    State.coins = new_total - State.next_level_cost()
    label.append_text("\n[url=next]Next hole[/url]\n")
  else:
    label.append_text("Unable to pay hole %d charge %d %s\n" % [State.level + 1, State.next_level_cost(), State.bb_coin])
    label.append_text("%s\n" % roast_string())
    label.append_text("\n[url=finished]Main Menu[/url]\n")

func _url_click(option_id: String) -> void:
  if option_id == "next":
    State.level += 1
    State.start_game()
  if option_id == "finished":
    State.main_menu()

func continue_string() -> String:
  var phrases: Array[String] = [
    "On to the next.",
    "Let’s keep it moving.",
    "Next hole.",
    "Let’s go.",
    "Moving on.",
    "What’s next?",
    "Shake it off, next hole.",
    "New hole, new opportunity."
  ]

  return phrases[randi() % phrases.size()]

func roast_string() -> String:
  var roasts: Array[String] = [
    "You sure you brought enough balls for this round?",
    "Might be time to just enjoy the walk.",
    "Hey, the clubhouse has cold drinks and no hazards.",
    "Scorecard’s looking more like a phone number.",
    "You playing golf or conducting a search party?",
    "That one might be a practice round.",
    "You’re making the course look longer than it is.",
    "Retirement’s always an option.",
    "That swing’s a crime in some states.",
    "We’d get through faster if you just rode in the cart."
  ]

  return roasts[randi() % roasts.size()]
