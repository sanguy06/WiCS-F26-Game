extends CanvasLayer

@export var color_rect: ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
	color_rect.color.a = 0.0
	
func fade(target_alpha: float, duration: float = 1.0, delay: float = 0.0) -> Tween:
	var tween = create_tween()
	if delay > 0.0:
		tween.tween_interval(delay)
	tween.tween_property(color_rect, "color:a", target_alpha, duration)
	return tween
