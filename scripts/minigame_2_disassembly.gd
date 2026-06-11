extends BaseMinigame

const REQUIRED_REMOVALS: Array[String] = ["PANEL", "CPU", "CFAN", "RAM", "HDD", "BATTERY", "MOBO"]
const REQUIRED_SCREWS: int = 4

var _removed_parts:  Array[String] = []
var _removed_screws: int = 0
var _hotbar: Node = null                     

func _on_minigame_ready() -> void:
	_hotbar = get_node_or_null("DisassemblyHotbar")   
	if _hotbar and _hotbar.has_method("set_screw_total"):
		_hotbar.set_screw_total(REQUIRED_SCREWS)     
	_pre_fill_all()
	_connect_snap_zones(self)
	child_entered_tree.connect(_on_child_entered_tree)
func _pre_fill_all() -> void:
	# ── Panel + screws ──────────────────────────────────────────────────────
	var panel    := get_node_or_null("SU_panel")
	var panel_sz := get_node_or_null("SU_main/Panel_snapzone")
	if panel_sz and panel:
		panel_sz.pre_fill(panel)

	for i in range(1, 5):
		var screw    := get_node_or_null("Screws%d" % i)
		var screw_sz := get_node_or_null("SU_panel/snapzone%s" % ("" if i == 1 else str(i)))
		if screw_sz and screw:
			screw_sz.pre_fill(screw)

	# ── Battery ─────────────────────────────────────────────────────────────
	var battery    := get_node_or_null("SU_Battery")
	var battery_sz := get_node_or_null("SU_main/Battery_snapzone")
	if battery_sz and battery:
		battery_sz.pre_fill(battery)

	# ── MoBo ────────────────────────────────────────────────────────────────
	var mobo    := get_node_or_null("MoBo")
	var mobo_sz := get_node_or_null("SU_main/MoBo_snapzone")
	if mobo_sz and mobo:
		mobo_sz.pre_fill(mobo)

	# ── CPU — hidden inside mobo, eject_on_click restores it ────────────────
	var cpu    := get_node_or_null("CPU")
	var cpu_sz := get_node_or_null("MoBo/CPU_snapzone")
	if cpu_sz and cpu:
		cpu_sz.remove_component = true
		cpu_sz.eject_on_click   = true
		cpu_sz.pre_fill(cpu)
		# Hide sprite — it's represented by the mobo texture
		var cpu_sprite := _find_sprite(cpu)
		if cpu_sprite:
			cpu_sprite.visible = false
		var cpu_col := cpu.get_node_or_null("CollisionShape2D")
		if cpu_col:
			cpu_col.disabled = true

	# ── RAM — hidden inside mobo ─────────────────────────────────────────────
	var ram    := get_node_or_null("RAM_Module")
	var ram_sz := get_node_or_null("MoBo/RAM_snapzone")
	if ram_sz and ram:
		ram_sz.remove_component = true
		ram_sz.eject_on_click   = true
		ram_sz.pre_fill(ram)
		var ram_sprite := _find_sprite(ram)
		if ram_sprite:
			ram_sprite.visible = false
		var ram_col := ram.get_node_or_null("CollisionShape2D")
		if ram_col:
			ram_col.disabled = true

	# ── CFAN — sits on top of mobo, stays visible ───────────────────────────
	var cfan    := get_node_or_null("Cooling Fan")
	var cfan_sz := get_node_or_null("MoBo/CFAN_snapzone")
	if cfan_sz and cfan:
		cfan_sz.pre_fill(cfan)
		# CFAN is visible — do NOT hide it

	# ── HDD — hidden inside rack ─────────────────────────────────────────────
	var hdd    := get_node_or_null("HDD")
	var hdd_sz := get_node_or_null("SuRack/HDD_snapzone")
	if hdd_sz and hdd:
		hdd_sz.remove_component = true
		hdd_sz.eject_on_click   = true
		hdd_sz.pre_fill(hdd)
		var hdd_sprite := _find_sprite(hdd)
		if hdd_sprite:
			hdd_sprite.visible = false
		var hdd_col := hdd.get_node_or_null("CollisionShape2D")
		if hdd_col:
			hdd_col.disabled = true

func _on_child_entered_tree(node: Node) -> void:
	call_deferred("_connect_snap_zones", node)

func _connect_snap_zones(node: Node) -> void:
	for child in node.get_children():
		if child.has_signal("part_snapped") and not child.part_snapped.is_connected(_on_part_snapped):
			child.part_snapped.connect(_on_part_snapped)
		if child.has_signal("part_removed") and not child.part_removed.is_connected(_on_part_removed):
			child.part_removed.connect(_on_part_removed)
		_connect_snap_zones(child)

func _on_part_snapped(_slot_type: String) -> void:
	pass

func _on_part_removed(slot_type: String) -> void:
	if slot_type == "SCREW":
		return  # ← don't count screws here; wait for hotbar deposit
	if slot_type not in _removed_parts:
		_removed_parts.append(slot_type)
		print("Removed: %s  (%d / %d)" % [slot_type, _removed_parts.size(), REQUIRED_REMOVALS.size()])

# Called by the hotbar after a part is physically deposited
func _on_part_deposited(slot_type: String) -> void:
	if slot_type == "SCREW":
		_removed_screws += 1
		print("Screw deposited: %d / %d" % [_removed_screws, REQUIRED_SCREWS])
	else:
		_on_part_removed(slot_type)
	try_complete()

func _check_completion() -> bool:
	if _removed_screws < REQUIRED_SCREWS:
		return false
	for part in REQUIRED_REMOVALS:
		if part not in _removed_parts:
			return false
	return true

func _on_complete() -> void:
	print("PC disassembly complete!")

func _find_sprite(node: Node) -> Sprite2D:
	for child in node.get_children():
		if child is Sprite2D:
			return child
	return null
