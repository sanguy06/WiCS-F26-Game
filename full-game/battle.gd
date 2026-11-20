extends Control
# Root of battle.tscn = a plain Control node with this script. Nothing else needed.
# Add your own enemy sprite later by dropping a TextureRect/Sprite2D into the scene.

var questions: Array = []
var q_index := 0
var hearts := 3

var title_label: Label
var hearts_label: Label
var progress_label: Label
var question_label: Label
var feedback_label: Label
var buttons: Array[Button] = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	questions = GameState.battle_questions
	q_index = GameState.battle_question_index
	hearts = GameState.battle_hearts
	
	_build_ui()
	_show_question()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.z_index = -1
	bg.color = Color(0.10, 0.12, 0.18)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 40)
	add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)

	title_label = Label.new()
	title_label.text = "A wild %s appears!" % GameState.current_enemy_name
	title_label.add_theme_font_size_override("font_size", 30)
	box.add_child(title_label)

	hearts_label = Label.new()
	hearts_label.add_theme_font_size_override("font_size", 22)
	box.add_child(hearts_label)

	progress_label = Label.new()
	box.add_child(progress_label)

	question_label = Label.new()
	question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	question_label.custom_minimum_size = Vector2(0, 90)
	question_label.add_theme_font_size_override("font_size", 22)
	box.add_child(question_label)

	for i in 4:
		var b := Button.new()
		b.custom_minimum_size = Vector2(0, 44)
		b.pressed.connect(_on_answer.bind(i))
		box.add_child(b)
		buttons.append(b)

	feedback_label = Label.new()
	feedback_label.add_theme_font_size_override("font_size", 20)
	box.add_child(feedback_label)

func _show_question() -> void:
	var q: Dictionary = questions[q_index]
	question_label.text = q["q"]
	progress_label.text = "Question %d / %d" % [q_index + 1, questions.size()]
	hearts_label.text = "Your hearts: " + "♥ ".repeat(hearts)
	for i in buttons.size():
		buttons[i].text = q["options"][i]
		buttons[i].disabled = false

func _set_buttons_disabled(d: bool) -> void:
	for b in buttons:
		b.disabled = d
		
		
func _on_answer(i: int) -> void:
	var q: Dictionary = questions[q_index]
	
	if i == q["answer"]:
		feedback_label.text = "Correct! You hit the slime!"
		_set_buttons_disabled(true)

		# Save progress before leaving battle
		GameState.battle_question_index += 1
		GameState.battle_hearts = hearts
		GameState.pending_hurt = true

		# Return to overworld
		get_tree().change_scene_to_file("res://main.tscn")
		
	else:
		hearts -= 1
		
		GameState.battle_hearts = hearts
		
		hearts_label.text = "Your hearts: " + "♥ ".repeat(hearts)
		
		buttons[i].disabled = true
		
		if hearts <= 0:
			feedback_label.text = "You ran out of hearts... retreat!"
			
			_set_buttons_disabled(true)
			
			await get_tree().create_timer(1.5).timeout
			
			GameState.lose_battle()
			
		else:
			feedback_label.text = "Wrong! Try again."
