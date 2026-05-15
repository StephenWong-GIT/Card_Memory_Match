extends Control

const PAIR_COUNT := 8
const CARD_COUNT := 16

@onready var _grid: GridContainer = $CenterContainer/GridContainer

var _card_scene: PackedScene = preload("res://scenes/Card.tscn")
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	setup_board()


func setup_board() -> void:
	clear_board()
	var deck := make_deck()
	shuffle_deck(deck, _rng)
	for pid in deck:
		var card: Control = _card_scene.instantiate()
		card.pair_id = pid
		_grid.add_child(card)


func clear_board() -> void:
	for child in _grid.get_children():
		child.queue_free()


## Build [0,0,1,1,...,7,7] for unit tests and gameplay.
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
	for i in PAIR_COUNT:
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
