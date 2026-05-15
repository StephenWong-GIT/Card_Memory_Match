extends GutTest

var _card_scene: PackedScene = preload("res://scenes/Card.tscn")


func test_initial_state_is_face_down():
	var card: Control = _card_scene.instantiate()
	add_child_autofree(card)
	await get_tree().process_frame
	assert_eq(card.get_state(), card.State.FACE_DOWN)


func test_flip_face_up_from_face_down():
	var card: Control = _card_scene.instantiate()
	add_child_autofree(card)
	await get_tree().process_frame
	assert_true(card.flip_face_up())
	assert_eq(card.get_state(), card.State.FACE_UP)


func test_flip_face_up_is_noop_when_face_up():
	var card: Control = _card_scene.instantiate()
	add_child_autofree(card)
	await get_tree().process_frame
	assert_true(card.flip_face_up())
	assert_false(card.flip_face_up())
	assert_eq(card.get_state(), card.State.FACE_UP)


func test_flip_face_up_is_noop_when_matched():
	var card: Control = _card_scene.instantiate()
	add_child_autofree(card)
	await get_tree().process_frame
	assert_true(card.flip_face_up())
	assert_true(card.mark_matched())
	assert_false(card.flip_face_up())
	assert_eq(card.get_state(), card.State.MATCHED)


func test_flip_face_down_from_face_up():
	var card: Control = _card_scene.instantiate()
	add_child_autofree(card)
	await get_tree().process_frame
	assert_true(card.flip_face_up())
	assert_true(card.flip_face_down())
	assert_eq(card.get_state(), card.State.FACE_DOWN)


func test_flip_face_down_noop_when_face_down():
	var card: Control = _card_scene.instantiate()
	add_child_autofree(card)
	await get_tree().process_frame
	assert_false(card.flip_face_down())


func test_flip_face_down_noop_when_matched():
	var card: Control = _card_scene.instantiate()
	add_child_autofree(card)
	await get_tree().process_frame
	assert_true(card.flip_face_up())
	assert_true(card.mark_matched())
	assert_false(card.flip_face_down())


func test_mark_matched_only_from_face_up():
	var card: Control = _card_scene.instantiate()
	add_child_autofree(card)
	await get_tree().process_frame
	assert_false(card.mark_matched())
	assert_true(card.flip_face_up())
	assert_true(card.mark_matched())
	assert_eq(card.get_state(), card.State.MATCHED)


func test_mark_matched_idempotent_rejects_second_call():
	var card: Control = _card_scene.instantiate()
	add_child_autofree(card)
	await get_tree().process_frame
	assert_true(card.flip_face_up())
	assert_true(card.mark_matched())
	assert_false(card.mark_matched())


func test_state_changed_emitted_on_transitions():
	var card: Control = _card_scene.instantiate()
	add_child_autofree(card)
	await get_tree().process_frame
	watch_signals(card)
	assert_true(card.flip_face_up())
	assert_signal_emitted(card, "state_changed")
	assert_signal_emit_count(card, "state_changed", 1)


func test_gui_click_emits_card_clicked_when_face_down():
	var card: Control = _card_scene.instantiate()
	add_child_autofree(card)
	await get_tree().process_frame
	watch_signals(card)
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	card._gui_input(ev)
	assert_signal_emitted(card, "card_clicked")


func test_gui_click_does_not_emit_card_clicked_when_matched():
	var card: Control = _card_scene.instantiate()
	add_child_autofree(card)
	await get_tree().process_frame
	assert_true(card.flip_face_up())
	assert_true(card.mark_matched())
	watch_signals(card)
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	card._gui_input(ev)
	assert_signal_emit_count(card, "card_clicked", 0)
