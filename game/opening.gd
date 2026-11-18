extends CanvasLayer

@onready var canvas_layer: CanvasLayer = $"."
@export var color_rect: ColorRect

@onready var player: Node = $Player
@onready var old_lady: Node = $"Old lady"

@onready var rain: AudioStreamPlayer2D = $rain
@onready var thunder: AudioStreamPlayer2D = $thunder

func _ready():
	fade_out(0.0, 1.0)
	$rain.play(3.2)

func fade_out(target_alpha: float, duration: float = 1.0):
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", target_alpha, duration)
	return tween
