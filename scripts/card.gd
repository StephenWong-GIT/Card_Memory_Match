extends Control

enum State {
	FACE_DOWN,
	FACE_UP,
	MATCHED,
}

signal card_clicked
signal state_changed(new_state: State)

@onready var _face: ColorRect = $Face

var pair_id: int = -1
var _state: State = State.FACE_DOWN

const COLOR_FACE_DOWN := Color(0.15, 0.18, 0.35)
const COLOR_MATCHED := Color(0.25, 0.65, 0.4)

# One distinct color per pair so the player can see which cards go together.
const PAIR_COLORS: Array = [
	Color(0.85, 0.25, 0.25),  # 0 red
	Color(0.90, 0.55, 0.15),  # 1 orange
	Color(0.85, 0.80, 0.15),  # 2 yellow
	Color(0.20, 0.75, 0.35),  # 3 green
	Color(0.20, 0.65, 0.85),  # 4 cyan
	Color(0.40, 0.30, 0.85),  # 5 purple
	Color(0.85, 0.35, 0.75),  # 6 pink
	Color(0.15, 0.55, 0.65),  # 7 teal
]

const _HOVER_SCALE := 1.05
const _PRESS_SCALE_MULT := 0.97
const _HOVER_MODULATE := Color(1.12, 1.12, 1.18, 1)
const _FLIP_HALF_SEC := 0.15
# Keeps idle UI readable while still giving matched pairs a gentle “settled” glow.
const _MATCH_PULSE_RANGE := Vector2(0.92, 1.08)

var _hovering: bool = false
var _pressing: bool = false
var _interact_tween: Tween
var _flip_tween: Tween
var _pulse_tween: Tween


func _face_up_color() -> Color:
	if pair_id >= 0 and pair_id < PAIR_COLORS.size():
		return PAIR_COLORS[pair_id]
	return Color(0.35, 0.55, 0.85)


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	_face.mouse_filter = MOUSE_FILTER_IGNORE
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_refresh_visual()
	var run_alone := get_parent() == get_tree().root or get_tree().current_scene == self
	if run_alone:
		card_clicked.connect(_demo_toggle_on_click)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		pivot_offset = size * 0.5
		_face.pivot_offset = _face.size * 0.5


func get_state() -> State:
	return _state


func flip_face_up() -> bool:
	if _state != State.FACE_DOWN:
		return false
	_state = State.FACE_UP
	state_changed.emit(_state)
	_start_flip_visual(true)
	return true


func flip_face_down() -> bool:
	if _state != State.FACE_UP:
		return false
	_state = State.FACE_DOWN
	state_changed.emit(_state)
	_start_flip_visual(false)
	return true


func mark_matched() -> bool:
	if _state != State.FACE_UP:
		return false
	_state = State.MATCHED
	state_changed.emit(_state)
	_kill_flip_tween()
	_face.scale.x = 1.0
	_refresh_visual()
	_start_match_pulse()
	scale = _interaction_scale_vector()
	modulate = Color.WHITE
	return true


func play_mismatch_feedback() -> void:
	_kill_flip_tween()
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var base_x := position.x
	for i in range(3):
		tw.tween_property(self, "position:x", base_x + 6.0, 0.04)
		tw.tween_property(self, "position:x", base_x - 6.0, 0.04)
	tw.tween_property(self, "position:x", base_x, 0.04)


func play_match_celebration() -> void:
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", scale * 1.08, 0.12)
	tw.tween_property(self, "scale", _interaction_scale_vector(), 0.18)


func _refresh_visual() -> void:
	match _state:
		State.FACE_DOWN:
			_face.color = COLOR_FACE_DOWN
		State.FACE_UP:
			_face.color = _face_up_color()
		State.MATCHED:
			_face.color = COLOR_MATCHED


func _demo_toggle_on_click() -> void:
	if _state == State.FACE_DOWN:
		flip_face_up()
	elif _state == State.FACE_UP:
		flip_face_down()


func _gui_input(event: InputEvent) -> void:
	if _state == State.MATCHED:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			_pressing = mb.pressed
			_apply_interaction_visual()
			if mb.pressed:
				card_clicked.emit()
				accept_event()


func _on_mouse_entered() -> void:
	if _state == State.MATCHED:
		return
	_hovering = true
	_apply_interaction_visual()


func _on_mouse_exited() -> void:
	_hovering = false
	_pressing = false
	_apply_interaction_visual()


func _interaction_scale_vector() -> Vector2:
	var s := 1.0
	if _hovering:
		s = _HOVER_SCALE
	if _pressing:
		s *= _PRESS_SCALE_MULT
	return Vector2(s, s)


func _apply_interaction_visual() -> void:
	if _state == State.MATCHED:
		return
	if _interact_tween != null and _interact_tween.is_valid():
		_interact_tween.kill()
	_interact_tween = create_tween()
	_interact_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var target_scale := _interaction_scale_vector()
	var target_mod := _HOVER_MODULATE if _hovering else Color.WHITE
	_interact_tween.parallel().tween_property(self, "scale", target_scale, 0.2)
	_interact_tween.parallel().tween_property(self, "modulate", target_mod, 0.2)


func _start_flip_visual(to_face_up: bool) -> void:
	_kill_flip_tween()
	var start_color := _face.color
	var mid_color: Color
	if to_face_up:
		mid_color = _face_up_color()
	else:
		mid_color = COLOR_FACE_DOWN
	_flip_tween = create_tween()
	_flip_tween.set_parallel(false)
	_flip_tween.tween_property(_face, "scale:x", 0.0, _FLIP_HALF_SEC).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_flip_tween.tween_callback(func():
		_face.color = mid_color
	)
	_flip_tween.tween_property(_face, "scale:x", 1.0, _FLIP_HALF_SEC).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# If the visible face color no longer matches logical state (e.g. rapid double-flip), sync once the flip finishes.
	_flip_tween.tween_callback(func():
		_refresh_visual()
		_apply_interaction_visual()
	)


func _kill_flip_tween() -> void:
	if _flip_tween != null and _flip_tween.is_valid():
		_flip_tween.kill()
	_flip_tween = null
	_face.scale.x = 1.0


func _start_match_pulse() -> void:
	if _pulse_tween != null and _pulse_tween.is_valid():
		_pulse_tween.kill()
	_pulse_tween = create_tween()
	_pulse_tween.set_loops()
	_pulse_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var base_mod := Color(1.0, 1.08, 1.05, 1)
	_pulse_tween.tween_property(_face, "modulate", base_mod * _MATCH_PULSE_RANGE.y, 0.55)
	_pulse_tween.tween_property(_face, "modulate", base_mod * _MATCH_PULSE_RANGE.x, 0.55)
