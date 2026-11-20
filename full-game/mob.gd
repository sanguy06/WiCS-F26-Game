extends Area2D
# Root = Area2D with children: Sprite2D/AnimatedSprite2D, CollisionShape2D
# Give every mob a UNIQUE node name (Slime1, Slime2, Slime3, Boss)

@export var is_boss := false
@export var enemy_name := "Slime"
var battle_started := false

@onready var idle_sound := get_node_or_null("IdleSound") as AudioStreamPlayer2D
@onready var hurt_sound := get_node_or_null("HurtSound") as AudioStreamPlayer2D

func _process(_delta: float) -> void:
	# Play idle sound only when idle and not already playing
	if not is_boss and not battle_started and $AnimatedSprite2D.animation == "idle":
		if idle_sound and not idle_sound.playing:
			idle_sound.play()
	elif idle_sound and idle_sound.playing and $AnimatedSprite2D.animation != "idle":
		idle_sound.stop()

func _ready() -> void:
	add_to_group("boss" if is_boss else "mobs")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or battle_started:
		return
		
	battle_started = true
	set_deferred("monitoring", false)
	
	var away: Vector2 = (body.global_position - global_position).normalized() * 80.0
	GameState.player_pos = body.global_position + away
	GameState.has_pos = true
	
	$AnimatedSprite2D.play("attack")
	await $AnimatedSprite2D.animation_finished
	
	GameState.start_battle(name, enemy_name, is_boss, GameState.player_pos)
	
func play_hurt_animation() -> void:
	var sprite: AnimatedSprite2D = $AnimatedSprite2D
	var idle_sound := get_node_or_null("IdleSound") as AudioStreamPlayer2D
	var hurt_sound := get_node_or_null("HurtSound") as AudioStreamPlayer2D
	
	set_deferred("monitoring", false)
	if idle_sound:
		idle_sound.stop()
	if hurt_sound:
		hurt_sound.play()

	# Play the hurt animation
	sprite.play("hurt")
	await sprite.animation_finished

	# Check whether all three questions have been answered
	if GameState.battle_question_index >= GameState.battle_questions.size():
		if hurt_sound and not hurt_sound.playing:
			hurt_sound.play()
		$AnimatedSprite2D.play("death")
		await $AnimatedSprite2D.animation_finished
		
		# Keep the dead slime visible, but prevent another encounter.
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
		$CollisionShape2D.set_deferred("disabled", true)
		GameState.win_battle()
		
	else:
		# Return to idle
		sprite.play("idle")
		
		GameState.pending_hurt = false

		# Return to questions
		get_tree().change_scene_to_file("res://battle.tscn")
