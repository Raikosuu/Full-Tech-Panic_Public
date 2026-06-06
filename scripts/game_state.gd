extends Node

var _game_scene_instance: Node = null
var interacted_npc: CharacterBody2D = null
var drag_active: bool = false

signal npcs_served_changed(count: int)
signal game_won

const LEVELS: Array = [
	{
		"day_number":         1,
		"day_label":          "Day 1",
		"npcs_to_win":        5,
		"npc_spawn_min_wait": 2.5,
		"npc_spawn_max_wait": 3.0,
		"npc_max_spawn":      22,
		"allowed_minigames":  [
			"res://scenes/minigame1_assembly.tscn",
			"res://scenes/minigame2_disassembly.tscn",
		],
		"intro_cutscene":     "res://cutscenes/prologue.tscn",
		"outro_cutscene":     "",
	},
	{
		"day_number":         2,
		"day_label":          "Day 2",
		"npcs_to_win":        5,
		"npc_spawn_min_wait": 2.0,
		"npc_spawn_max_wait": 2.5,
		"npc_max_spawn":      22,
		"allowed_minigames":  [
			"res://scenes/minigame3_rj45.tscn",
			"res://scenes/minigame4_rj45a.tscn",
		],
		"intro_cutscene":     "res://cutscenes/day2_intro.tscn",
		"outro_cutscene":     "",
	},
	{
		"day_number":         3,
		"day_label":          "Day 3",
		"npcs_to_win":        10,
		"npc_spawn_min_wait": 1.5,
		"npc_spawn_max_wait": 2.0,
		"npc_max_spawn":      22,
		"allowed_minigames":  [
			"res://scenes/minigame1_assembly.tscn",
			"res://scenes/minigame2_disassembly.tscn",
			"res://scenes/minigame3_rj45.tscn",
			"res://scenes/minigame4_rj45a.tscn",
		],
		"intro_cutscene":     "res://cutscenes/day3_intro.tscn",
		"outro_cutscene":     "res://cutscenes/epilogue.tscn",
	},
]

const GAME_SCENE: String = "res://scenes/game_scene.tscn"

var current_level_index: int        = 0
var current_level_scene: String     = GAME_SCENE
var current_level_data:  Dictionary = {}

# ── Tracks exactly which level and progress the player was on when they lost ──
var _checkpoint_level_index: int = 0
var _checkpoint_npcs_served: int = 0

var npcs_to_win: int = 5
var npcs_served: int = 0
var is_game_over: bool = false 

func _ready() -> void:
	load_level(0)

func load_level(index: int) -> void:
	if index >= LEVELS.size():
		game_won.emit()
		return
	current_level_index  = index
	current_level_data   = LEVELS[index]
	current_level_scene  = GAME_SCENE
	npcs_to_win          = current_level_data.get("npcs_to_win", 5)
	npcs_served          = 0

func get_current_day() -> int:
	return current_level_data.get("day_number", 1)

func get_current_day_label() -> String:
	return current_level_data.get("day_label", "Day 1")

func get_allowed_minigames() -> Array:
	var pool: Array = current_level_data.get("allowed_minigames", [])
	if pool.is_empty():
		return [
			"res://scenes/minigame1_assembly.tscn",
			"res://scenes/minigame2_disassembly.tscn",
			"res://scenes/minigame3_rj45.tscn",
			"res://scenes/minigame4_rj45a.tscn",
		]
	return pool

func get_intro_cutscene() -> String:
	return current_level_data.get("intro_cutscene", "")

func get_outro_cutscene() -> String:
	return current_level_data.get("outro_cutscene", "")

func get_npc_spawn_min() -> float:
	return current_level_data.get("npc_spawn_min_wait", 3.0)

func get_npc_spawn_max() -> float:
	return current_level_data.get("npc_spawn_max_wait", 8.0)

func get_npc_max_spawn() -> int:
	return current_level_data.get("npc_max_spawn", 22)

func advance_to_next_level() -> void:
	var next_index: int = current_level_index + 1
	if next_index >= LEVELS.size():
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return
	load_level(next_index)
	HealthState.reset()
	var intro := get_intro_cutscene()
	if intro != "":
		get_tree().change_scene_to_file(intro)
	else:
		get_tree().change_scene_to_file(GAME_SCENE)

func record_npc_served() -> void:
	if is_game_over:         
		return
	npcs_served += 1
	npcs_served_changed.emit(npcs_served)
	if npcs_served >= npcs_to_win:
		var outro := get_outro_cutscene()
		if outro != "":
			get_tree().change_scene_to_file(outro)
		else:
			advance_to_next_level()

# ── Call this right before HealthState.take_damage() ──────────────────────────
func _save_checkpoint() -> void:
	_checkpoint_level_index = current_level_index
	_checkpoint_npcs_served = npcs_served

# ── Restores state to exactly where the player lost ───────────────────────────
func reset_to_checkpoint() -> void:
	load_level(_checkpoint_level_index)
	npcs_served = _checkpoint_npcs_served
	npcs_served_changed.emit(npcs_served)
	drag_active          = false
	interacted_npc       = null
	_game_scene_instance = null

func reset_level() -> void:
	npcs_served          = 0
	drag_active          = false
	interacted_npc       = null
	_game_scene_instance = null
	npcs_to_win          = current_level_data.get("npcs_to_win", 5)
	is_game_over         = false   # ← ADD THIS
	
func enter_minigame() -> void:
	var pool: Array = get_allowed_minigames()
	var path: String = pool[randi() % pool.size()]
	_game_scene_instance = get_tree().current_scene
	get_tree().root.remove_child(_game_scene_instance)
	var minigame = load(path).instantiate()
	get_tree().root.add_child(minigame)
	get_tree().current_scene = minigame

func exit_minigame() -> void:
	if _game_scene_instance == null:
		get_tree().change_scene_to_file(current_level_scene)
		return
	var minigame = get_tree().current_scene
	get_tree().root.remove_child(minigame)
	minigame.queue_free()
	get_tree().root.add_child(_game_scene_instance)
	get_tree().current_scene = _game_scene_instance
	_game_scene_instance = null
	if interacted_npc != null and is_instance_valid(interacted_npc):
		interacted_npc.leave()
		interacted_npc = null

func fail_minigame() -> void:
	if _game_scene_instance == null:
		get_tree().change_scene_to_file(current_level_scene)
		return
	var minigame = get_tree().current_scene
	get_tree().root.remove_child(minigame)
	minigame.queue_free()
	get_tree().root.add_child(_game_scene_instance)
	get_tree().current_scene = _game_scene_instance
	_game_scene_instance = null
	if interacted_npc != null and is_instance_valid(interacted_npc):
		interacted_npc.fail_and_leave()
		interacted_npc = null
	
	HealthState.take_damage()
