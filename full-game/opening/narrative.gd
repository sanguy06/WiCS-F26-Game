extends CanvasLayer

@export_file("*.json") var d_file
@export var fade: CanvasLayer

var dialogue = []
var current_dialogue_id = 0
var d_active = false

func _ready():
	start()

func start():
	if d_active: 
		return
	d_active = true
	$RichTextLabel.visible = true
	dialogue = load_dialogue()
	current_dialogue_id = -1
	next_script()
	
func load_dialogue():
	var file = FileAccess.open("res://opening/json/narrativeDialogue.json.txt", FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	return content
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		next_script()
		
func next_script():
	current_dialogue_id += 1
	if current_dialogue_id >= len(dialogue):
		d_active = false
		$RichTextLabel.visible = false
		return
		
	$RichTextLabel.text = dialogue[current_dialogue_id]['text']
	
	if $RichTextLabel.text == "A peaceful farm filled with crops. Dark clouds suddenly gather overhead.":
		set_process_input(false)
		await fade.fade(1.0, 1.5, 3.0).finished
		get_tree().change_scene_to_file("res://opening/opening.tscn")
		
