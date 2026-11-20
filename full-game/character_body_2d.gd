extends CharacterBody2D

@export var speed = 250
@export var min_y := 235.0
@export var max_y := 285.0
@export var min_x := 20.0
@onready var anim = $AnimatedSprite2D

func _ready():
	add_to_group("player")

func _physics_process(delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1

	velocity = direction.normalized() * speed
	move_and_slide()

	# Keep the player on the grass strip and off the left edge
	global_position.y = clampf(global_position.y, min_y, max_y)
	global_position.x = maxf(global_position.x, min_x)

	if direction == Vector2.ZERO:
		anim.play("idle")
	else:
		anim.play("run")

	# Only change facing when moving horizontally
	if direction.x < 0:
		anim.flip_h = true
	elif direction.x > 0:
		anim.flip_h = false
