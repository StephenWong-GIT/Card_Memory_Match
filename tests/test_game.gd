extends GutTest

const GameLogic = preload("res://scripts/game.gd")
var _game_scene: PackedScene = preload("res://scenes/Game.tscn")


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
