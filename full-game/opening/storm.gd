extends CanvasLayer

@export var canvas_layer: CanvasLayer
@export var color_rect: ColorRect

@onready var rain: AudioStreamPlayer2D = $Rain

func _ready():
	fade_out(0.0, 1.0)
	$Rain.play()

func fade_out(target_alpha: float, duration: float = 1.0):
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", target_alpha, duration)
	return tween
