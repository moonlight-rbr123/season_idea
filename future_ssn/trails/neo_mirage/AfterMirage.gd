extends Trail

# Aftermirage: while the tank moves, leave faint tinted copies of it behind that fade out.
# On the skins screen there is no tank to copy, so the particle fallback (ghost silhouettes) is used instead.

export var spawn_interval: = 0.09
export var ghost_life: = 0.5
export var ghost_alpha: = 0.38

var _skin = null
var _moving: = false
var _acc: = 0.0
var _c1: = Color(0.6, 0.9, 1.0, 1.0)

func _ready() -> void :
	._ready()
	var n = get_parent()
	while n != null and not (n is TankSkin):
		n = n.get_parent()
	_skin = n
	set_process(true)

func play_or_stop_particles(play: bool):
	if _skin == null:
		.play_or_stop_particles(play)
	else:
		_moving = play
		for p in particle_systems:
			p.emitting = false

func set_tint_one(one: Color):
	_c1 = one
	.set_tint_one(one)

func _process(delta: float) -> void :
	if _skin == null or not _moving or not is_instance_valid(_skin):
		_acc = 0.0
		return
	if not _skin.is_visible_in_tree():
		return
	_acc += delta
	if _acc >= spawn_interval:
		_acc = 0.0
		_spawn_ghost()

func _spawn_ghost() -> void :
	var host = get_tree().current_scene
	if host == null:
		return
	var g = _skin.duplicate(0)
	for nm in ["TankBodyCommon", "AnimationPlayer", "DriveAnim"]:
		var c = g.get_node_or_null(nm)
		if c != null:
			g.remove_child(c)
			c.free()
	host.add_child(g)
	g.global_transform = _skin.global_transform
	g.z_as_relative = false
	g.z_index = 90
	g.modulate = Color(0.55 + _c1.r * 0.45, 0.55 + _c1.g * 0.45, 0.55 + _c1.b * 0.45, ghost_alpha)
	var tw: = Tween.new()
	g.add_child(tw)
	tw.interpolate_property(g, "modulate:a", ghost_alpha, 0.0, ghost_life, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tw.interpolate_property(g, "scale", g.scale, g.scale * 0.45, ghost_life, Tween.TRANS_QUAD, Tween.EASE_OUT)   # shrinks as it drifts away
	tw.interpolate_callback(g, ghost_life, "queue_free")
	tw.start()
