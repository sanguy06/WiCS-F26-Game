extends CanvasLayer

@export_file("*.json") var d_file
@onready var opening_canvas_layer: CanvasLayer = $"../../openingCanvasLayer"
@onready var color_rect: ColorRect = $"../../openingCanvasLayer/ColorRect"
@onready var thunder: AudioStreamPlayer2D = $"../../thunder"

var dialogue = []
var current_dialogue_id = 0
var d_active = false

func _ready():
	print("dialogue ready")
	start()

func start():
	if d_active: 
		return
	d_active = true
	$NinePatchRect.visible = true
	$"Old lady/oldLadySprite".visible = false
	$"Player/Idle".visible = false
	dialogue = load_dialogue()
	current_dialogue_id = -1
	next_script()
	
func fade_out(target_alpha: float, duration: float = 1.0):
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", target_alpha, duration)
	return tween
	
func fade_in(target_alpha: float = 1.0, duration: float = 1.0):
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", target_alpha, duration)
	return tween
	
func fade_to_black_and_back():
	var out_tween = fade_out(1.0, 0.25)
	await out_tween.finished

	var in_tween = fade_in(0.0, 0.25)
	await in_tween.finished
	
func load_dialogue():
	var file = FileAccess.open("res://opening/json/StoryOpening.json.txt", FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	return content
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		next_script()
		
func next_script():
	current_dialogue_id += 1
	if current_dialogue_id >= len(dialogue):
		d_active = false
		$NinePatchRect.visible = false
		await get_tree().create_timer(1.6).timeout
		get_tree().change_scene_to_file("res://main.tscn")
		return
		return
		
	$NinePatchRect/Name.text = dialogue[current_dialogue_id]['name']
	$NinePatchRect/Chat.text = dialogue[current_dialogue_id]['text']
	
	if $NinePatchRect/Name.text == "Grandma":
		$"Old lady/oldLadySprite".visible = true
	else:
		$"Old lady/oldLadySprite".visible = false
		
	if $NinePatchRect/Name.text == "Player":
		$"Player/Idle".visible = true
		
	else:
		$"Player/Idle".visible = false
		
	if $NinePatchRect/Chat.text == "A peaceful farm filled with crops. Dark clouds suddenly gather overhead.":
		$NinePatchRect.visible = false
	else:
		$NinePatchRect.visible = true
		
	if $NinePatchRect/Chat.text == "[THUNDER CRASHES]":
		$NinePatchRect.visible = true
		$"../../thunder".play(0.3)
		fade_to_black_and_back()
	
	if $NinePatchRect/Chat.text == "hello":
		$NinePatchRect.visible = false
		fade_out(1.0, 1.0)
		

		
		
		

	
	
		
	
		
	
	
