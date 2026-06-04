extends Node

const MINIGAMES: Array[String] = [
	"res://scenes/minigame1_assembly.tscn",
	"res://scenes/minigame2_disassembly.tscn",
	"res://scenes/minigame3_rj45.tscn",
	"res://scenes/minigame4_rj45a.tscn",
]

var _game_scene_instance: Node = null
var interacted_npc: CharacterBody2D = null
var drag_active: bool = false

# ── Win condition ──────────────────────────────────────────────────────────────
signal npcs_served_changed(count: int)
signal game_won

var npcs_to_win: int = 10        # override in GameState inspector or via code
var npcs_served: int = 0

func record_npc_served() -> void:
	npcs_served += 1
	npcs_served_changed.emit(npcs_served)
	if npcs_served >= npcs_to_win:
		game_won.emit()

func enter_minigame() -> void:
	var path: String = MINIGAMES[randi() % MINIGAMES.size()]
	_game_scene_instance = get_tree().current_scene
	get_tree().root.remove_child(_game_scene_instance)
	var minigame = load(path).instantiate()
	get_tree().root.add_child(minigame)
	get_tree().current_scene = minigame

func exit_minigame() -> void:
	if _game_scene_instance == null:
		get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
		return
	var minigame = get_tree().current_scene
	get_tree().root.remove_child(minigame)
	minigame.queue_free()
	get_tree().root.add_child(_game_scene_instance)
	get_tree().current_scene = _game_scene_instance
	_game_scene_instance = null
	if interacted_npc != null and is_instance_valid(interacted_npc):
		interacted_npc.leave()          # ← NPC is now "served", leave() should call record_npc_served()
		interacted_npc = null

func fail_minigame() -> void:
	if _game_scene_instance == null:
		get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
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
