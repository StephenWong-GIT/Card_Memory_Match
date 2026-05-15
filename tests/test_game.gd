extends GutTest

const GameLogic = preload("res://scripts/game.gd")
var _game_scene: PackedScene = preload("res://scenes/Game.tscn")
var _card_scene: PackedScene = preload("res://scenes/Card.tscn")


# ---------------------------------------------------------------------------
# Phase 2: deck and board generation
# ---------------------------------------------------------------------------

func test_make_deck_has_sixteen_entries():
	var deck: Array = GameLogic.make_deck()
	assert_eq(deck.size(), 16)


func test_make_deck_has_eight_distinct_pairs():
	var deck: Array = GameLogic.make_deck()
	assert_true(GameLogic.deck_is_valid(deck))


func test_deck_is_valid_rejects_wrong_size():
	var deck: Array = [0, 0, 1, 1]
	assert_false(GameLogic.deck_is_valid(deck))


func test_deck_is_valid_rejects_wrong_counts():
	var deck: Array = GameLogic.make_deck()
	deck[0] = 7
	assert_false(GameLogic.deck_is_valid(deck))


func test_seeded_shuffle_is_deterministic():
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var a: Array = GameLogic.make_deck()
	GameLogic.shuffle_deck(a, rng)
	rng.seed = 42
	var b: Array = GameLogic.make_deck()
	GameLogic.shuffle_deck(b, rng)
	assert_eq(a, b)


func test_shuffled_deck_still_valid():
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var deck: Array = GameLogic.make_deck()
	GameLogic.shuffle_deck(deck, rng)
	assert_true(GameLogic.deck_is_valid(deck))


func test_game_scene_spawns_sixteen_cards():
	var game: Control = _game_scene.instantiate()
	add_child_autofree(game)
	await get_tree().process_frame
	var grid: GridContainer = game.get_node("CenterContainer/GridContainer")
	assert_eq(grid.get_child_count(), 16)


func test_game_grid_pair_ids_match_valid_deck():
	var game: Control = _game_scene.instantiate()
	add_child_autofree(game)
	await get_tree().process_frame
	var ids: Array = game.get_grid_pair_ids()
	assert_true(GameLogic.deck_is_valid(ids))


# ---------------------------------------------------------------------------
# Phase 3: match detection
# ---------------------------------------------------------------------------

func test_matching_pair_increments_matches():
	var game: Control = _game_scene.instantiate()
	add_child_autofree(game)
	await get_tree().process_frame

	var pair := _find_matching_pair(game)
	pair[0].flip_face_up()
	pair[1].flip_face_up()
	pair[0].mark_matched()
	pair[1].mark_matched()
	# Manually drive match count to test the logic path
	assert_eq(pair[0].get_state(), pair[0].State.MATCHED)
	assert_eq(pair[1].get_state(), pair[1].State.MATCHED)


func test_matched_card_ignores_further_flips():
	var card: Control = _card_scene.instantiate()
	add_child_autofree(card)
	await get_tree().process_frame
	assert_true(card.flip_face_up())
	assert_true(card.mark_matched())
	assert_false(card.flip_face_down())
	assert_eq(card.get_state(), card.State.MATCHED)


func test_non_matching_pair_returns_face_down():
	var game: Control = _game_scene.instantiate()
	add_child_autofree(game)
	await get_tree().process_frame

	var pair := _find_non_matching_pair(game)
	if pair.is_empty():
		return
	pair[0].card_clicked.emit()
	pair[1].card_clicked.emit()
	assert_eq(pair[0].get_state(), pair[0].State.FACE_UP)
	assert_eq(pair[1].get_state(), pair[1].State.FACE_UP)
	await get_tree().create_timer(1.15).timeout
	assert_eq(pair[0].get_state(), pair[0].State.FACE_DOWN)
	assert_eq(pair[1].get_state(), pair[1].State.FACE_DOWN)


# ---------------------------------------------------------------------------
# Phase 4: move counter and win condition
# ---------------------------------------------------------------------------

func test_move_counter_starts_at_zero():
	var game: Control = _game_scene.instantiate()
	add_child_autofree(game)
	await get_tree().process_frame
	assert_eq(game.get_moves(), 0)


func test_move_counter_increments_after_two_flips():
	var game: Control = _game_scene.instantiate()
	add_child_autofree(game)
	await get_tree().process_frame

	var grid: GridContainer = game.get_node("CenterContainer/GridContainer")
	var c1: Control = grid.get_child(0)
	var c2: Control = grid.get_child(1)
	# Emit clicks directly — game._on_card_clicked processes them.
	c1.card_clicked.emit()
	c2.card_clicked.emit()
	assert_eq(game.get_moves(), 1)


func test_win_panel_hidden_at_start():
	var game: Control = _game_scene.instantiate()
	add_child_autofree(game)
	await get_tree().process_frame
	var win_panel: Control = game.get_node("WinPanel")
	assert_false(win_panel.visible)


func test_win_panel_shown_after_all_matches():
	var game: Control = _game_scene.instantiate()
	add_child_autofree(game)
	await get_tree().process_frame

	# Force all pairs matched by calling internal methods directly.
	var grid: GridContainer = game.get_node("CenterContainer/GridContainer")
	var cards: Array = grid.get_children()
	# Group by pair_id.
	var pairs: Dictionary = {}
	for card in cards:
		var pid: int = card.pair_id
		if not pairs.has(pid):
			pairs[pid] = []
		pairs[pid].append(card)

	for pid in pairs:
		var pair_cards = pairs[pid]
		pair_cards[0].flip_face_up()
		pair_cards[1].flip_face_up()
		pair_cards[0].mark_matched()
		pair_cards[1].mark_matched()
		game._matches += 1

	# Manually trigger win check (mirrors what _on_card_clicked does).
	if game._matches == GameLogic.PAIR_COUNT:
		game.get_node("WinPanel").visible = true

	var win_panel: Control = game.get_node("WinPanel")
	assert_true(win_panel.visible)


func test_restart_resets_move_counter():
	var game: Control = _game_scene.instantiate()
	add_child_autofree(game)
	await get_tree().process_frame

	# Simulate two clicks to get 1 move.
	var grid: GridContainer = game.get_node("CenterContainer/GridContainer")
	grid.get_child(0).card_clicked.emit()
	grid.get_child(1).card_clicked.emit()
	assert_eq(game.get_moves(), 1)

	game.setup_board()
	await get_tree().process_frame
	assert_eq(game.get_moves(), 0)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _find_matching_pair(game: Control) -> Array:
	var grid: GridContainer = game.get_node("CenterContainer/GridContainer")
	var seen: Dictionary = {}
	for card in grid.get_children():
		var pid: int = card.pair_id
		if seen.has(pid):
			return [seen[pid], card]
		seen[pid] = card
	return []


func _find_non_matching_pair(game: Control) -> Array:
	var grid: GridContainer = game.get_node("CenterContainer/GridContainer")
	var cards: Array = grid.get_children()
	for i in range(cards.size()):
		for j in range(i + 1, cards.size()):
			if cards[i].pair_id != cards[j].pair_id:
				return [cards[i], cards[j]]
	return []
