extends Control

const PAIR_COUNT := 8
const CARD_COUNT := 16

const _TWEEN_TRANS_UI := Tween.TRANS_CUBIC
const _TWEEN_EASE_UI := Tween.EASE_OUT
const _MOVE_PUNCH_SCALE := 1.12
const _RESTART_HOVER_SCALE := 1.06
const _RESTART_PRESS_MULT := 0.96

@onready var _grid: GridContainer = $CenterContainer/GridContainer
@onready var _move_label: Label = $UI/MoveLabel
@onready var _background: TextureRect = $Background
@onready var _win_panel: Control = $WinPanel
@onready var _win_vbox: VBoxContainer = $WinPanel/VBox
@onready var _final_moves_label: Label = $WinPanel/VBox/FinalMovesLabel
@onready var _personal_best_label: Label = $WinPanel/VBox/PersonalBestLabel
@onready var _restart_button: Button = $WinPanel/VBox/RestartButton

var _card_scene: PackedScene = preload("res://scenes/Card.tscn")
var _rng := RandomNumberGenerator.new()

var _flipped: Array = []
var _locked: bool = false
var _moves: int = 0
var _matches: int = 0

var _move_label_tween: Tween
var _win_reveal_tween: Tween
var _ambient_tween: Tween
var _restart_tween: Tween
var _restart_hovering: bool = false


func _ready() -> void:
	_rng.randomize()
	_win_panel.visible = false
	_restart_button.pressed.connect(_on_restart_pressed)
	_restart_button.mouse_entered.connect(_on_restart_mouse_entered)
	_restart_button.mouse_exited.connect(_on_restart_mouse_exited)
	_restart_button.gui_input.connect(_on_restart_gui_input)
	_restart_button.resized.connect(_on_restart_resized)
	_on_restart_resized()
	setup_board()
	_start_background_ambience()


func setup_board() -> void:
	clear_board()
	_flipped.clear()
	_locked = false
	_moves = 0
	_matches = 0
	_update_move_label(false)
	_reset_win_panel_for_hide()
	_win_panel.visible = false
	var deck := make_deck()
	shuffle_deck(deck, _rng)
	for pid in deck:
		var card: Control = _card_scene.instantiate()
		card.pair_id = pid
		card.card_clicked.connect(_on_card_clicked.bind(card))
		_grid.add_child(card)


func clear_board() -> void:
	for child in _grid.get_children():
		child.queue_free()


func _on_card_clicked(card: Control) -> void:
	if _locked:
		return
	if card.get_state() != card.State.FACE_DOWN:
		return
	if _flipped.has(card):
		return

	card.flip_face_up()
	_flipped.append(card)

	if _flipped.size() < 2:
		return

	_moves += 1
	_update_move_label(true)
	_locked = true

	var a: Control = _flipped[0]
	var b: Control = _flipped[1]

	if a.pair_id == b.pair_id:
		a.mark_matched()
		b.mark_matched()
		a.play_match_celebration()
		b.play_match_celebration()
		_matches += 1
		_flipped.clear()
		_locked = false
		if _matches == PAIR_COUNT:
			await _present_win_screen()
	else:
		a.play_mismatch_feedback()
		b.play_mismatch_feedback()
		await get_tree().create_timer(1.0).timeout
		# Cards may have been freed by a restart; guard before flipping back.
		if is_instance_valid(a):
			a.flip_face_down()
		if is_instance_valid(b):
			b.flip_face_down()
		_flipped.clear()
		_locked = false


func _on_restart_pressed() -> void:
	setup_board()


func _on_restart_resized() -> void:
	_restart_button.pivot_offset = _restart_button.size * 0.5


func _on_restart_mouse_entered() -> void:
	_restart_hovering = true
	_tween_restart_to(_restart_target_scale())


func _on_restart_mouse_exited() -> void:
	_restart_hovering = false
	_tween_restart_to(_restart_target_scale())


func _on_restart_gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return
	var mb := event as InputEventMouseButton
	if mb.button_index != MOUSE_BUTTON_LEFT:
		return
	if mb.pressed:
		_tween_restart_to(_restart_target_scale() * _RESTART_PRESS_MULT)
	else:
		_tween_restart_to(_restart_target_scale())


func _restart_target_scale() -> float:
	return _RESTART_HOVER_SCALE if _restart_hovering else 1.0


func _tween_restart_to(factor: float) -> void:
	if _restart_tween != null:
		_restart_tween.kill()
	_restart_tween = create_tween()
	_restart_tween.set_trans(_TWEEN_TRANS_UI).set_ease(_TWEEN_EASE_UI)
	_restart_tween.tween_property(_restart_button, "scale", Vector2(factor, factor), 0.14)


func _present_win_screen() -> void:
	_final_moves_label.text = "Final moves: %d" % _moves
	_personal_best_label.text = "PERSONAL BEST!"
	_win_panel.visible = true
	await get_tree().process_frame
	_win_vbox.pivot_offset = _win_vbox.size * 0.5
	_win_panel.modulate = Color(1, 1, 1, 0)
	_win_vbox.scale = Vector2(0.35, 0.35)
	if _win_reveal_tween != null:
		_win_reveal_tween.kill()
	_win_reveal_tween = create_tween()
	_win_reveal_tween.set_parallel(true)
	_win_reveal_tween.set_trans(_TWEEN_TRANS_UI).set_ease(_TWEEN_EASE_UI)
	_win_reveal_tween.tween_property(_win_panel, "modulate:a", 1.0, 0.38)
	_win_reveal_tween.tween_property(_win_vbox, "scale", Vector2.ONE, 0.42)


func _reset_win_panel_for_hide() -> void:
	_win_panel.modulate = Color.WHITE
	_win_vbox.scale = Vector2.ONE
	_restart_button.scale = Vector2.ONE
	_restart_hovering = false
	if _win_reveal_tween != null:
		_win_reveal_tween.kill()
	if _restart_tween != null:
		_restart_tween.kill()


func _update_move_label(with_punch: bool = true) -> void:
	_move_label.text = "Moves: %d" % _moves
	if not with_punch:
		if _move_label_tween != null:
			_move_label_tween.kill()
		_move_label.scale = Vector2.ONE
		return
	_move_label.pivot_offset = _move_label.size * 0.5
	if _move_label_tween != null:
		_move_label_tween.kill()
	_move_label.scale = Vector2(_MOVE_PUNCH_SCALE, _MOVE_PUNCH_SCALE)
	_move_label_tween = create_tween()
	_move_label_tween.set_trans(_TWEEN_TRANS_UI).set_ease(_TWEEN_EASE_UI)
	_move_label_tween.tween_property(_move_label, "scale", Vector2.ONE, 0.24)


func _start_background_ambience() -> void:
	if _ambient_tween != null:
		_ambient_tween.kill()
	_background.modulate = Color.WHITE
	_ambient_tween = create_tween()
	_ambient_tween.set_loops()
	_ambient_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_ambient_tween.tween_property(_background, "modulate", Color(0.92, 0.95, 1.04, 1), 4.0)
	_ambient_tween.tween_property(_background, "modulate", Color(1.04, 0.96, 0.93, 1), 4.0)


func get_moves() -> int:
	return _moves


func get_matches() -> int:
	return _matches


# ---------------------------------------------------------------------------
# Static helpers (pure logic — used by tests without a live scene)
# ---------------------------------------------------------------------------

## Build [0,0,1,1,...,7,7].
static func make_deck() -> Array:
	var deck: Array = []
	for i in range(PAIR_COUNT):
		deck.append(i)
		deck.append(i)
	return deck


static func deck_is_valid(deck: Array) -> bool:
	if deck.size() != CARD_COUNT:
		return false
	var counts := {}
	for id in deck:
		if typeof(id) != TYPE_INT:
			return false
		counts[id] = counts.get(id, 0) + 1
	for i in range(PAIR_COUNT):
		if counts.get(i, 0) != 2:
			return false
	return true


static func shuffle_deck(deck: Array, rng: RandomNumberGenerator) -> void:
	for i in range(deck.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t = deck[i]
		deck[i] = deck[j]
		deck[j] = t


func get_grid_pair_ids() -> Array:
	var ids: Array = []
	for child in _grid.get_children():
		ids.append(child.pair_id)
	return ids
