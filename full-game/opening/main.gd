extends Node
@export var fade: CanvasLayer

func _ready():
	$Main/IntroMusic.play()

func _on_start_game_pressed():
	await fade.fade(1.0, 1.5, 0.0).finished
	get_tree().change_scene_to_file("res://opening/storm.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
