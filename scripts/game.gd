extends Control

const PAIR_COUNT := 8
const CARD_COUNT := 16

@onready var _grid: GridContainer = $CenterContainer/GridContainer
@onready var _move_label: Label = $UI/MoveLabel
@onready var _win_panel: Control = $WinPanel
@onready var _restart_button: Button = $WinPanel/VBox/RestartButton

var _card_scene: PackedScene = preload("res://scenes/Card.tscn")
var _rng := RandomNumberGenerator.new()

var _flipped: Array = []
var _locked: bool = false
var _moves: int = 0
var _matches: int = 0


func _ready() -> void:
	_rng.randomize()
	_win_panel.visible = false
	_restart_button.pressed.connect(_on_restart_pressed)
	setup_board()


func setup_board() -> void:
	clear_board()
	_flipped.clear()
	_locked = false
	_moves = 0
	_matches = 0
	_update_move_label()
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
	_update_move_label()
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
			_win_panel.visible = true
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


func _update_move_label() -> void:
	_move_label.text = "Moves: %d" % _moves


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
