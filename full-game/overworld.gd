extends Node2D
# Root of overworld.tscn. Needs children: Player (instance of player scene),
# Slime1, Slime2, Slime3, Boss (instances of mob scene). HUD is built in code.

var info_label: Label
var end_panel: Control

func _ready() -> void:
	# Remove regular slimes that have already been defeated
	for mob in get_tree().get_nodes_in_group("mobs"):
		if mob.name in GameState.defeated:
			mob.queue_free()

	# Handle the boss separately
	var boss := get_tree().get_first_node_in_group("boss")
	
	_refresh_boss_state()
	
	# Restore the player's previous position
	if GameState.has_pos and has_node("Player"):
		$Player.global_position = GameState.player_pos

	# Build and update the HUD
	_build_hud()
	_update_hud()
	
	if GameState.pending_hurt:
		call_deferred("_play_pending_hurt")

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	info_label = Label.new()
	info_label.position = Vector2(16, 12)
	info_label.add_theme_font_size_override("font_size", 20)
	layer.add_child(info_label)

	end_panel = ColorRect.new()
	(end_panel as ColorRect).color = Color(0, 0, 0, 0.75)
	end_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	end_panel.visible = false
	layer.add_child(end_panel)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	end_panel.add_child(box)
	var msg := Label.new()
	msg.text = "You collected the seeds!\nGrandma's garden will bloom again."
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.add_theme_font_size_override("font_size", 28)
	box.add_child(msg)
	var btn := Button.new()
	btn.text = "Play again"
	btn.pressed.connect(func():
		GameState.reset()
		get_tree().reload_current_scene())
	box.add_child(btn)

func _update_hud() -> void:
	var goal := ""
	if GameState.slimes_defeated < GameState.TOTAL_SLIMES:
		goal = "Defeat the slimes: %d/%d" % [GameState.slimes_defeated, GameState.TOTAL_SLIMES]
	elif not GameState.boss_defeated:
		goal = "A big monster appeared! Find it!"
	else:
		goal = "Garden saved!"
	info_label.text = "Seeds: %d    |    %s" % [GameState.seeds, goal]
	end_panel.visible = GameState.boss_defeated
	_refresh_boss_state()

func _play_pending_hurt() -> void:
	var mob = get_node_or_null(GameState.current_mob_id)
	
	if mob:
		await mob.play_hurt_animation()
		
func _refresh_boss_state() -> void:
	var boss := get_tree().get_first_node_in_group("boss")
	if not boss:
		return

	if GameState.boss_defeated:
		boss.queue_free()
		return

	var boss_ready := GameState.slimes_defeated >= GameState.TOTAL_SLIMES
	boss.visible = boss_ready
	boss.set_deferred("monitoring", boss_ready)
