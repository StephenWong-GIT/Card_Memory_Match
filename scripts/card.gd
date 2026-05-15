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
const COLOR_FACE_UP := Color(0.35, 0.55, 0.85)
const COLOR_MATCHED := Color(0.25, 0.65, 0.4)


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	_face.mouse_filter = MOUSE_FILTER_IGNORE
	_refresh_visual()
	var run_alone := get_parent() == get_tree().root or get_tree().current_scene == self
	if run_alone:
		card_clicked.connect(_demo_toggle_on_click)


func get_state() -> State:
	return _state


func flip_face_up() -> bool:
	if _state != State.FACE_DOWN:
		return false
	_state = State.FACE_UP
	state_changed.emit(_state)
	_refresh_visual()
	return true


func flip_face_down() -> bool:
	if _state != State.FACE_UP:
		return false
	_state = State.FACE_DOWN
	state_changed.emit(_state)
	_refresh_visual()
	return true


func mark_matched() -> bool:
	if _state != State.FACE_UP:
		return false
	_state = State.MATCHED
	state_changed.emit(_state)
	_refresh_visual()
	return true


func _refresh_visual() -> void:
	match _state:
		State.FACE_DOWN:
			_face.color = COLOR_FACE_DOWN
		State.FACE_UP:
			_face.color = COLOR_FACE_UP
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
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			card_clicked.emit()
			accept_event()
