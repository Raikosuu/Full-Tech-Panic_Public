class_name BaseMinigame
extends Node2D

# ─────────────────────────────────────────────────────────────
#  BaseMinigame
#  Extend this for every minigame you make:
#
#      extends BaseMinigame
#
#      func _check_completion() -> bool:
#          return <your win condition>
#
#  Optional overrides:
#      func _on_minigame_ready() -> void   — setup logic (replaces _ready)
#      func _on_complete() -> void         — runs before returning to game
# ─────────────────────────────────────────────────────────────

# Seconds to wait after completion before returning to the game.
@export var completion_delay: float = 1.0

var _completed: bool = false

func _ready() -> void:
	# Must keep running while the tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_on_minigame_ready()

# Override in child scripts for setup logic.
func _on_minigame_ready() -> void:
	pass

# Call this whenever something happens that might finish the minigame.
func try_complete() -> void:
	if _completed:
		return
	if _check_completion():
		_completed = true
		_on_complete()
		_finish()

# Override this — return true when the player has won.
func _check_completion() -> bool:
	return false

# Override for final effects (sound, animation, UI) before returning.
func _on_complete() -> void:
	pass

func _finish() -> void:
	if completion_delay > 0.0:
		await get_tree().create_timer(completion_delay, true, false, true).timeout
	GameState.exit_minigame()
