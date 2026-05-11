extends "res://scripts/drag_cont.gd"

# Assign all 4 screw nodes in the Inspector
@export var screw_1: RigidBody2D
@export var screw_2: RigidBody2D
@export var screw_3: RigidBody2D
@export var screw_4: RigidBody2D

# Emitted when all screws are back in and the panel locks
signal panel_locked
# Emitted when the panel is unlocked (first screw popped)
signal panel_unlocked

var _screws: Array = []
var _screws_in: int = 0

func _ready() -> void:
	super._ready() if super.has_method("_ready") else null

	_screws = [screw_1, screw_2, screw_3, screw_4]

	for screw in _screws:
		if screw == null:
			push_warning("panel.gd: A screw export is not assigned in the Inspector.")
			continue
		# Listen for screwed_in signal from each screw
		screw.screwed_in.connect(_on_screw_screwed_in)
		# Listen for when a screw pops off so we can unlock the panel
		screw.released.connect(_on_screw_released)

	# Count how many start already screwed in
	_screws_in = 0
	for screw in _screws:
		if screw != null and screw.is_screwed():
			_screws_in += 1

	_update_lock()

# ── Screw callbacks ───────────────────────────────────────────────────────────

func _on_screw_screwed_in() -> void:
	_screws_in += 1
	_update_lock()

func _on_screw_released(_component) -> void:
	# Only care if this reduces the screwed-in count
	# Re-count from source of truth to stay accurate
	var prev := _screws_in
	_screws_in = 0
	for screw in _screws:
		if screw != null and screw.is_screwed():
			_screws_in += 1

	if prev == _screws.size() and _screws_in < _screws.size():
		# Was fully locked, now isn't
		_set_locked(false)
		emit_signal("panel_unlocked")

# ── Lock logic ────────────────────────────────────────────────────────────────

func _update_lock() -> void:
	if _screws_in >= _screws.size():
		_set_locked(true)
		emit_signal("panel_locked")
	else:
		_set_locked(false)

func _set_locked(locked: bool) -> void:
	# Prevent drag_cont.gd from picking up the panel while locked
	snapped = locked
	if locked:
		freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
		freeze = true
		linear_velocity = Vector2.ZERO
	else:
		freeze = false
