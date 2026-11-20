extends Node
# AUTOLOAD this as "GameState" (Project > Project Settings > Globals > Autoload)

const OVERWORLD_SCENE := "res://main.tscn"
const BATTLE_SCENE := "res://battle.tscn"
const TOTAL_SLIMES := 3

var defeated: Array[String] = []   # names of mob nodes already beaten
var slimes_defeated := 0
var seeds := 0
var boss_defeated := false

var player_pos := Vector2.ZERO
var has_pos := false

var current_mob_id := ""
var current_enemy_name := "Slime"
var current_is_boss := false

var battle_questions: Array = []
var battle_question_index := 0
var battle_hearts := 3
var pending_hurt := false

# Edit / add questions here. "answer" is the index of the correct option.
var slime_questions: Array = [
	{"q": "What does print(2 + 3 * 2) output in Python?", "options": ["10", "8", "12", "7"], "answer": 1},
	{"q": "Which data structure is LIFO (last in, first out)?", "options": ["Queue", "Stack", "Array", "Heap"], "answer": 1},
	{"q": "Which loop is guaranteed to run at least once?", "options": ["for", "while", "do-while", "foreach"], "answer": 2},
	{"q": "What does len(\"farm\") return in Python?", "options": ["3", "4", "5", "Error"], "answer": 1},
	{"q": "Which keyword defines a function in Python?", "options": ["func", "function", "def", "fn"], "answer": 2},
	{"q": "What is the index of the first element of an array in C, Java, or Python?", "options": ["1", "0", "-1", "Depends on the size"], "answer": 1},
]

var boss_questions: Array = [
	{"q": "What is the time complexity of binary search on a sorted array?", "options": ["O(n)", "O(log n)", "O(n log n)", "O(1)"], "answer": 1},
	{"q": "x = [1, 2, 3]\ny = x\ny.append(4)\nprint(x)  # What prints?", "options": ["[1, 2, 3]", "[1, 2, 3, 4]", "Error", "[4]"], "answer": 1},
	{"q": "What is the purpose of a base case in recursion?", "options": ["Make it faster", "Stop the recursion", "Declare variables", "Loop forever"], "answer": 1},
]

func get_questions() -> Array:
	var pool: Array = boss_questions.duplicate(true) if current_is_boss else slime_questions.duplicate(true)
	pool.shuffle()
	var picked: Array = pool.slice(0, 3)
	for q in picked:
		var correct = q["options"][q["answer"]]
		q["options"].shuffle()
		q["answer"] = q["options"].find(correct)
	return picked

func start_battle(mob_id: String, enemy_name: String, is_boss: bool, return_pos: Vector2) -> void:
	current_mob_id = mob_id
	current_enemy_name = enemy_name
	current_is_boss = is_boss
	
	player_pos = return_pos
	has_pos = true

	# Initialize battle progress
	battle_questions = get_questions()
	battle_question_index = 0
	battle_hearts = 3
	pending_hurt = false
	
	get_tree().change_scene_to_file.call_deferred(BATTLE_SCENE)

func win_battle() -> void:
	defeated.append(current_mob_id)
	if current_is_boss:
		boss_defeated = true
		seeds += 5
	else:
		slimes_defeated += 1
		seeds += 1
	if get_tree().current_scene.has_method("_update_hud"):
		get_tree().current_scene._update_hud()

func lose_battle() -> void:
	# Mob stays alive; player returns to overworld and can retry
	get_tree().change_scene_to_file(OVERWORLD_SCENE)

func reset() -> void:
	defeated.clear()
	slimes_defeated = 0
	seeds = 0
	boss_defeated = false
	has_pos = false
