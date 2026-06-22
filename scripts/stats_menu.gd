extends Panel

func refresh() -> void:
	GameState._flush_playtime()
	%LossesValue.text       = str(GameState.stat_total_losses)
	%PlaytimeValue.text     = GameState.get_formatted_playtime()
	%NPCsServedValue.text   = str(GameState.stat_total_npcs_served)
	%GameOversValue.text    = str(GameState.stat_total_game_overs)

func _on_close_pressed() -> void:
	hide()
