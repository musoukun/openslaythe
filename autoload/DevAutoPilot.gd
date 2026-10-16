extends Node
## 開発用: 画面キャプチャ検証のため、起動引数で自動的にランを進める。
## 例: godot --path . --write-movie shots/x.png --fixed-fps 10 --quit-after 60 -- --auto=combat
## --auto=map    : ラン開始してマップを表示
## --auto=combat : ラン開始して最初の戦闘に入る
## --auto=new_run : タイトルから「新しいラン」画面を開く
## --auto=menu:<ボタン名> : タイトルのメニューボタンを押す (例: menu:CodexButton)
## --auto=combat_hover : 最初の戦闘で手札の3枚目にカーソルを乗せた状態にする (ホバー拡大の確認用)
## --auto=weapon:<artifact_id|none> : 開始時の武器を選んで最初の戦闘に入り、攻撃カードの補正後ダメージを出力する
## --auto=blessing[:<選択肢番号>[:<幕>]] : 開始地点の祝福画面を出し、指定があれば選択肢を押して受け取りの演出を見る (番号を空にすると押さない。例 blessing::3)
## --auto=shop : 1階の部屋をショップにして訪れ、商人の場面を出す
## --auto=shop_buy : 購入画面を開き、商品にカーソルを乗せる (指さしとツールチップの確認用)
## --auto=shop_remove : 購入画面からカード削除を押す
## --auto=shop_check : カード削除とカードの購入を実際に行い、お金とデッキの変化を出力する
## --auto=rest[:many][:<タイル番号>] : 1階の部屋を休憩所にして訪れる。many で登録済みの行動を全部並べ、番号のタイルにホバーする (例 rest:many:6)
## --auto=death[:<倒れ方>[:plain]] : 最初の戦闘で主人公を倒して死亡画面を出す。倒れ方 (dissolve / collapse / explode) を上書きでき、plain なら倒れる絵を使わない
## --auto=click_test : 最初の戦闘で、手札の各カードのどこを押せば CardButton に届くかを数え、実際にクリックでカードを出す
## --auto=playthrough [--seed=<数>] [--god] : タイトルからクリックだけで最終ボスまで遊び、詰まり・押せない場所を出力する (--god はテスト専用で、毎ターン体力を満タンに戻す。--shots=<フォルダ> でウィンドウ実行時に要所を撮る)
## --warp-mouse : 本物のカーソルも動かす (shop_buy の指さしを撮るとき用。使っている人のマウスを奪うので普段は付けない)
## --hero=<character_id> : ラン開始系のモードで使う主人公 (省略時は character_green。例 --hero=character_blue)
## 引数が無い場合は何もしない。

const CHARACTER_ID := "character_green"

func _ready() -> void:
	var shot_path := _get_user_arg("--shot=")
	if shot_path != "":
		_save_shot_later(shot_path)
	var mode := _get_mode()
	if mode == "":
		return
	if mode == "dump_strings":
		StringDumper.dump()
		get_tree().quit()
		return
	if DisplayServer.get_name() == "headless":
		# ウィンドウなしで回すとき: 画面を基準サイズにし、マウスが画面内にいる扱いにする (でないとホバーもクリックも届かない)
		get_tree().root.size = Vector2i(1200, 700)
		get_tree().root.notification(NOTIFICATION_WM_MOUSE_ENTER)
	await get_tree().create_timer(0.3).timeout
	var menu_aliases := {"settings": "menu:SettingsButton", "new_run": "menu:NewRunButton"}
	mode = menu_aliases.get(mode, mode)
	if mode.begins_with("menu:"):
		var button_name := mode.trim_prefix("menu:")
		var menu_button := get_tree().root.find_child(button_name, true, false) as BaseButton
		if menu_button:
			menu_button.pressed.emit()
			menu_button.button_up.emit()
		# 新しいラン画面で --hero のキャラを選んだ状態にする
		var new_run_menu := get_tree().root.find_child("NewRunMenu", true, false)
		if new_run_menu and _get_user_arg("--hero=") != "":
			await get_tree().process_frame
			new_run_menu._on_character_selected(_get_user_arg("--hero="))
		return
	if mode == "playthrough":
		# --auto=playthrough [--seed=<数>] : タイトルからクリックだけで最後まで遊ぶ (scripts/dev/PlaythroughBot.gd)
		var bot := PlaythroughBot.new()
		add_child(bot)
		if _get_user_arg("--hero=") != "":
			bot.hero_id = _get_user_arg("--hero=")
		if _get_user_arg("--seed=") != "":
			bot.run_seed = int(_get_user_arg("--seed="))
		bot.god_mode = OS.get_cmdline_user_args().has("--god")
		bot.shots_dir = _get_user_arg("--shots=")
		await bot.run()
		get_tree().quit()
		return
	var hero_id := _get_user_arg("--hero=")
	Global.start_run(hero_id if hero_id != "" else CHARACTER_ID, 12345)
	await get_tree().create_timer(0.5).timeout
	if mode.begins_with("event:"):
		# --auto=event:<event_id>[:<選択肢番号>,<選択肢番号>...]
		# 1階の部屋を指定イベントにして訪れ、指定があれば選択肢を順に押して結果を出力する
		var parts := mode.split(":")
		var location: LocationData = Global.get_next_locations()[0]
		location.location_type = LocationData.LOCATION_TYPES.EVENT
		location.location_obfuscated = false
		location.location_event_object_id = parts[1]
		ActionGenerator.generate_visition_location(location.location_id)
		if parts.size() > 2:
			await _click_event_options(parts[2].split(","))
		return
	if mode.begins_with("shop"):
		await _shop(mode)
		return
	if mode.begins_with("rest"):
		await _rest_site(mode.split(":"))
		return
	if mode.begins_with("blessing"):
		await _blessing(mode.split(":"))
		return
	if mode.begins_with("death"):
		await _death(mode.split(":"))
		return
	if mode.begins_with("weapon:"):
		# --auto=weapon:<artifact_id|none>
		# ラン開始の武器選択肢 (BuildContent) を選んだ扱いで最初の戦闘に入り、手札のカード説明 (補正後の数値) を出力する
		var weapon_id := mode.trim_prefix("weapon:")
		if weapon_id != "none":
			# RunStartOptions._on_dialogue_option_clicked() と同じ経路で選択肢の actions を流す
			var option: RunStartOptionData = Global.get_run_start_option_data("run_start_option_" + weapon_id)
			var player: Player = Global.get_player()
			var request: CardPlayRequest = HandManager.create_card_play_request(null, player, false, false)
			ActionHandler.add_actions(ActionGenerator.create_actions(player, request, [player], option.run_start_option_actions, null))
		await get_tree().create_timer(0.5).timeout
		print("WEAPON ", weapon_id, " values=", Global.player_data.player_values)
		for location in Global.get_next_locations():
			if location.location_type == LocationData.LOCATION_TYPES.COMBAT:
				ActionGenerator.generate_visition_location(location.location_id)
				break
		await get_tree().create_timer(2.0).timeout
		for card: Card in get_tree().root.find_children("*", "Card", true, false):
			if HandManager.player_hand.has(card.card_data):
				print("WEAPON hand ", card.card_data.object_id, " : ", card.get_card_description())
		# 手札に来ないカードも含め、デッキ内の攻撃カードの補正後ダメージ (Card.get_card_description と同じ計算)
		var checked: Array[String] = []
		for card_data: CardData in Global.player_data.player_deck:
			if card_data.card_type != CardData.CARD_TYPES.ATTACK or checked.has(card_data.object_id):
				continue
			checked.append(card_data.object_id)
			var targets: Array[BaseCombatant] = [null]
			var request: CardPlayRequest = HandManager.create_card_play_request(card_data, null, true, true)
			var action: BaseAction = ActionGenerator.create_actions(Global.get_player(), request, targets, [{Scripts.ACTION_ATTACK: {}}], null)[0]
			var damage: int = action._intercept_action(targets, true)[0].get_shadowed_action_values("damage", 0)
			print("WEAPON deck ", card_data.object_id, " tags=", card_data.card_tags, " damage ", card_data.card_values.get("damage", 0), " -> ", damage)
		return
	match mode:
		"map", "map_top":
			_print_map_stats()
			# ラン開始の選択肢パネルがマップを覆うので閉じてから表示する
			var run_start_options := get_tree().root.find_child("RunStartOptions", true, false) as Control
			if run_start_options:
				run_start_options.visible = false
			var map := get_tree().root.find_child("Map", true, false)
			if map:
				map.show_map()
				# map_top: ボス紋章のある上端までスクロールして見せる
				if mode == "map_top":
					await get_tree().process_frame
					map.scroll_container.scroll_vertical = 0
		"deck":
			var deck_button := get_tree().root.find_child("DeckButton", true, false) as BaseButton
			if deck_button:
				deck_button.button_up.emit()
		"combat", "combat_hover", "vfx", "profile", "hitstop":
			for location in Global.get_next_locations():
				if location.location_type == LocationData.LOCATION_TYPES.COMBAT:
					ActionGenerator.generate_visition_location(location.location_id)
					break
			if mode == "combat_hover":
				await get_tree().create_timer(2.0).timeout
				var hand_cards: Array[Card] = HandManager.hand.get_player_hand_cards()
				if hand_cards.size() > 2:
					HandManager.hand._on_card_hovered(hand_cards[2])
			if mode == "vfx":
				await get_tree().create_timer(1.0).timeout
				_preview_vfx()
			if mode == "hitstop":
				await get_tree().create_timer(1.0).timeout
				var enemy := get_tree().get_first_node_in_group("enemies") as BaseCombatant
				await get_tree().create_timer(2.0).timeout
				print("HITSTOP hand ", HandManager.player_hand.map(func(c): return c.object_id))
				# 手札のアタックカードを本当にプレイする
				for card_data: CardData in HandManager.player_hand:
					if card_data.card_type == CardData.CARD_TYPES.ATTACK:
						print("HITSTOP play ", card_data.object_id)
						HandManager.add_card_to_play_queue(HandManager.create_card_play_request(card_data, enemy))
						break
				for i in 20:
					await get_tree().create_timer(0.1, true, false, true).timeout
					print("HITSTOP t=%.1f time_scale=%.2f" % [i * 0.1 + 0.1, Engine.time_scale])
				get_tree().quit()
			if mode == "profile":
				await get_tree().create_timer(1.0).timeout
				_profile()
		"click_test":
			for location in Global.get_next_locations():
				if location.location_type == LocationData.LOCATION_TYPES.COMBAT:
					ActionGenerator.generate_visition_location(location.location_id)
					break
			await get_tree().create_timer(3.0).timeout
			await _click_map()
			await _click_test()
		"mana_check":
			# 青の主人公 (--hero=character_blue) で戦闘に入り、マナの支払い・蒼刃の強化・蒼刃の戻り先を出力する
			for location in Global.get_next_locations():
				if location.location_type == LocationData.LOCATION_TYPES.COMBAT:
					ActionGenerator.generate_visition_location(location.location_id)
					break
			await get_tree().create_timer(3.0).timeout
			await _mana_check()
			get_tree().quit()


func _mana_check() -> void:
	var player: Player = Global.get_player()
	var mana := func() -> int: return player.get_status_charges(HeroBlueContent.STATUS_MANA)
	var blade: CardData = null
	for card_data: CardData in HandManager.player_hand:
		if card_data.object_id == "card_blue_mana_blade":
			blade = card_data
	print("MANA hand ", HandManager.player_hand.map(func(c): return c.object_id), " mana=", mana.call(), " energy=", Global.player_data.player_energy)
	if blade == null:
		print("MANA blade is not in the opening hand")
		return
	# 1. 強化前の蒼刃を振る: 8 ダメージで、山札の一番上に戻る
	var enemy: BaseCombatant = Global.get_alive_enemies()[0]
	var hp_before: int = enemy.get_combatant_health()
	var blade_request: CardPlayRequest = HandManager.create_card_play_request(blade, enemy)
	blade_request.card_destination_pile = blade.card_play_destination # Hand.gd と同じく行き先はカードの設定から
	blade_request.card_destination_strategy = blade.card_play_destination_strategy
	HandManager.add_card_to_play_queue(blade_request)
	await get_tree().create_timer(2.0).timeout
	print("MANA blade hit: enemy hp ", hp_before, " -> ", enemy.get_combatant_health(), " (expected -8)")
	print("MANA blade back on top of draw pile: ", not HandManager.player_draw.is_empty() and HandManager.player_draw.back() == blade)
	# 2. マナで払う呪文: マナが足りないと使えない
	var flash: CardData = Global.get_card_data_from_prototype("card_blue_flash")
	player.add_status_effect_charges(HeroBlueContent.STATUS_MANA, -mana.call())
	print("MANA flash playable with mana=", mana.call(), ": ", Global.validate(flash.card_play_validators, flash, null), " (expected false)")
	player.add_status_effect_charges(HeroBlueContent.STATUS_MANA, 99)
	print("MANA mana capped at ", mana.call(), " (expected ", HeroBlueContent.MANA_MAX, ")")
	print("MANA flash playable with mana=", mana.call(), ": ", Global.validate(flash.card_play_validators, flash, null), " (expected true)")
	# 3. マナを注いで蒼刃を強化する
	var extend: CardData = Global.get_card_data_from_prototype("card_blue_extend_blade")
	var twin: CardData = Global.get_card_data_from_prototype("card_blue_twin_blade")
	HandManager.add_cards_to_hand([extend, twin] as Array[CardData], 99)
	await get_tree().create_timer(0.5).timeout
	for card_data: CardData in [extend, twin]:
		HandManager.add_card_to_play_queue(HandManager.create_card_play_request(card_data, null))
		await get_tree().create_timer(1.5).timeout
		print("MANA played ", card_data.object_id, " mana=", mana.call(), " edge=", player.get_status_charges(HeroBlueContent.STATUS_BLADE_EDGE), " twin=", player.get_status_charges(HeroBlueContent.STATUS_BLADE_TWIN))
	var targets: Array[BaseCombatant] = [enemy]
	var request: CardPlayRequest = HandManager.create_card_play_request(blade, enemy, true, true)
	var preview: BaseAction = ActionGenerator.create_actions(player, request, targets, [{Scripts.ACTION_ATTACK: {}}], null)[0]
	print("MANA blade damage per hit after Extend Blade: ", preview._intercept_action(targets, true)[0].get_shadowed_action_values("damage", 0), " (expected 14)")


## 性能計測: 何もしない時 / デッキ一覧を開いた直後 のフレーム時間
func _profile() -> void:
	for phase in ["idle", "mouse_sweep", "open_deck"]:
		var worst := 0.0
		var total := 0.0
		for i in 60:
			var t := Time.get_ticks_usec()
			if phase == "mouse_sweep":
				# 手札 (y=620) と敵 (y=380) の上を往復させる
				var pos := Vector2(200 + (i % 30) * 30, 620 if i < 30 else 380)
				_move_mouse(pos)
			if phase == "open_deck" and i == 0:
				var deck_button := get_tree().root.find_child("DeckButton", true, false) as BaseButton
				deck_button.button_up.emit()
			await get_tree().process_frame
			var ms := (Time.get_ticks_usec() - t) / 1000.0
			worst = max(worst, ms)
			total += ms
		print("PROFILE %s: avg %.1f ms, worst %.1f ms, cards %d" % [phase, total / 60.0, worst, get_tree().get_nodes_in_group("cards").size()])
	get_tree().quit()


## 休憩所。1階の部屋を休憩所にして訪れる。many なら登録済みの行動を全部並べ、番号があればそのタイルにホバーする
func _rest_site(parts: PackedStringArray) -> void:
	if parts.has("many"):
		for rest_action_id: String in Global._id_to_rest_action_data.keys():
			Global.player_data.enable_rest_action(rest_action_id)
	var location: LocationData = Global.get_next_locations()[0]
	location.location_type = LocationData.LOCATION_TYPES.REST_SITE
	ActionGenerator.generate_visition_location(location.location_id)
	var hover_index := parts[parts.size() - 1]
	if not hover_index.is_valid_int():
		return
	await get_tree().create_timer(1.5).timeout
	var buttons := get_tree().root.find_children("*", "RestActionButton", true, false)
	print("REST actions=", buttons.map(func(b): return b.rest_action_object_id))
	if int(hover_index) < buttons.size():
		buttons[int(hover_index)].mouse_entered.emit()


## 祝福の画面 (RunStartOptions)。幕の指定があれば、その幕の開始として出し直す
func _blessing(parts: PackedStringArray) -> void:
	if parts.size() > 2:
		Global.player_data.player_act = int(parts[2])
		Signals.act_started.emit()
	var run_start_options := get_tree().root.find_child("RunStartOptions", true, false)
	await get_tree().create_timer(2.5).timeout
	var options := run_start_options.find_children("*", "DialogueOption", true, false)
	print("BLESSING act=", Global.player_data.player_act, " options=", options.map(func(o): return o.rich_text_label.get_parsed_text()))
	if parts.size() < 2 or parts[1] == "":
		return
	print("BLESSING before: ", _player_summary())
	var option: DialogueOption = options[int(parts[1])]
	option.dialogue_option_clicked.emit(option)
	await get_tree().create_timer(3.0).timeout
	print("BLESSING after: ", _player_summary())


## ショップ。1階の部屋をショップにして訪れる。
## shop: 商人の場面 / shop_buy: 購入画面を開き、カーソルを商品に乗せて指さしとツールチップを見る
## shop_remove: 購入画面からカード削除を押す
func _shop(mode: String) -> void:
	var run_start_options := get_tree().root.find_child("RunStartOptions", true, false) as Control
	if run_start_options:
		run_start_options.visible = false
	var location: LocationData = Global.get_next_locations()[0]
	location.location_type = LocationData.LOCATION_TYPES.SHOP
	location.location_obfuscated = false
	ActionGenerator.generate_visition_location(location.location_id)
	if mode == "shop":
		return
	await get_tree().create_timer(1.2).timeout
	var overlay := get_tree().root.find_child("ShopOverlay", true, false)
	overlay.open_counter()
	await get_tree().create_timer(0.8).timeout
	if mode == "shop_remove" or mode == "shop_check":
		print("SHOP before: ", _player_summary(), " removal price ", Global.get_shop_at_player_location().get_card_removal_price())
		overlay.find_child("CardRemovalButton", true, false).get_node("Button").button_up.emit()
		if mode == "shop_remove":
			return
		# shop_check: デッキの先頭のカードを選んで削除し、カードを1枚買って、お金とデッキの変化を出力する
		await get_tree().create_timer(1.0).timeout
		var selection := get_tree().root.find_child("CardSelectionOverlay", true, false)
		selection.current_card_pick_action.picked_cards = [Global.player_data.player_deck[0]] as Array[CardData]
		Signals.card_pick_confirmed.emit()
		await get_tree().create_timer(1.0).timeout
		print("SHOP removed: ", _player_summary(), " used ", Global.get_shop_at_player_location().shop_card_removal_used, " next price ", Global.get_shop_at_player_location().get_card_removal_price())
		var card_button: BaseShopButton = overlay.get_shop_items()[0]
		print("SHOP buy card price ", card_button.price_label.text)
		card_button.card.card_selected.emit(card_button.card)
		await get_tree().create_timer(1.0).timeout
		print("SHOP bought: ", _player_summary(), " items left ", overlay.get_shop_items().size())
		get_tree().quit()
		return
	# 下段の最初のレリックの上にカーソルを置く
	var target := overlay.get_shop_items()[6] as Control
	_move_mouse(target.get_global_rect().get_center())


## 手札のカードを本物のマウス入力 (移動 → 押す → 離す) でクリックし、出せたかを出力する
func _click_test() -> void:
	for attempt in 3:
		var hand_cards: Array[Card] = HandManager.hand.get_player_hand_cards()
		if hand_cards.is_empty():
			break
		var card: Card = hand_cards[[hand_cards.size() / 2, hand_cards.size() - 1, 0][attempt]]
		var pos: Vector2 = card.card_button.get_global_rect().get_center()
		_move_mouse(pos)
		await get_tree().create_timer(0.4).timeout
		var hovered_control := get_viewport().gui_get_hovered_control()
		print("CLICK hover at ", pos, " hovered=", hovered_control.get_path() if hovered_control else null, " script=", hovered_control.get_script().resource_path if hovered_control and hovered_control.get_script() else "", " filter=", hovered_control.mouse_filter if hovered_control else -1, " card=", card.card_data.object_id, " hand=", HandManager.player_hand.size(), " energy=", Global.player_data.player_energy)
		await _click(pos)
		await get_tree().create_timer(0.3).timeout
		print("CLICK after: target_label=", HandManager.hand.select_target_label.visible, " selected=", HandManager.hand.current_selected_card, " queue=", HandManager.card_play_queue.size())
		if HandManager.hand.current_selected_card != null:
			var enemy := get_tree().get_first_node_in_group("enemies") as Control
			var enemy_pos: Vector2 = enemy.get_global_rect().get_center() if enemy else Vector2.ZERO
			print("CLICK enemy at ", enemy_pos, " node=", enemy)
			_move_mouse(enemy_pos)
			await get_tree().create_timer(0.2).timeout
			await _click(enemy_pos)
		await get_tree().create_timer(1.5).timeout
		print("CLICK result: hand=", HandManager.player_hand.size(), " energy=", Global.player_data.player_energy, " enemy hp=", Global.get_alive_enemies().map(func(e): return e.get_combatant_health()))


## 手札の各カードの上を格子状にマウスで動き、そこでクリックが CardButton に届くかを数える
## (ホバーで拡大した後の状態で調べる。届かない場所は何が塞いでいるかを出力する)
func _click_map() -> void:
	var hand_cards: Array[Card] = HandManager.hand.get_player_hand_cards()
	for index in hand_cards.size():
		var card: Card = hand_cards[index]
		var rect: Rect2 = card.card_button.get_global_rect()
		var hits := 0
		var total := 0
		var blockers := {}
		for gy in 5:
			for gx in 5:
				var pos := rect.position + rect.size * Vector2((gx + 0.5) / 5.0, (gy + 0.5) / 5.0)
				if pos.y >= get_viewport().get_visible_rect().size.y:
					continue
				_move_mouse(pos)
				await get_tree().create_timer(0.25).timeout
				var hovered := get_viewport().gui_get_hovered_control()
				total += 1
				if hovered == card.card_button:
					hits += 1
				else:
					var key: String = str(hovered.get_path()) if hovered else "null"
					blockers[key] = blockers.get(key, 0) + 1
		print("CLICKMAP card %d %s rect=%s clickable %d/%d blockers=%s" % [index, card.card_data.object_id, rect, hits, total, blockers])
	_move_mouse(Vector2(10, 10))


## マウスの左ボタンをその位置で押して離す (ウィンドウが受けたクリックと同じく Viewport の GUI に流す)
func _click(position: Vector2) -> void:
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		event.position = position
		event.global_position = position
		get_viewport().push_input(event)
		await get_tree().process_frame


## マウスをその位置へ動かしたことにする (ホバーと指さしの確認用)
## NOTE: warp_mouse は Windows の本物のカーソルを動かす (使っている人の操作を奪う) ので、既定ではゲームの中にだけ流す。
## ショップの指さしのように OS のカーソル位置を読む絵を撮るときだけ --warp-mouse を付ける
func _move_mouse(position: Vector2) -> void:
	if OS.get_cmdline_user_args().has("--warp-mouse"):
		get_viewport().warp_mouse(position)
	var motion := InputEventMouseMotion.new()
	motion.position = position
	motion.global_position = position
	get_viewport().push_input(motion)


## イベントの選択肢を順に押し、各段階のプレイヤー状態を出力 (イベント確認用)
func _death(parts: PackedStringArray) -> void:
	var character: CharacterData = Global.get_player_character_data()
	if parts.size() > 1 and parts[1] != "":
		character.character_death_style = parts[1]
	if parts.size() > 2 and parts[2] == "plain":
		# 倒れる絵が無い主人公と同じにする (待機の1枚だけ)
		var frames: SpriteFrames = Global.get_animation_data(character.character_animation_id).animations
		var idle := frames.get_frame_texture(AnimationData.ANIMATION_IDLE, 0)
		frames.clear(AnimationData.ANIMATION_DEATH)
		frames.add_frame(AnimationData.ANIMATION_DEATH, idle)
	for location in Global.get_next_locations():
		if location.location_type == LocationData.LOCATION_TYPES.COMBAT:
			ActionGenerator.generate_visition_location(location.location_id)
			break
	await get_tree().create_timer(1.5).timeout
	Global.get_player().damage(9999, true)


func _click_event_options(indices: PackedStringArray) -> void:
	var overlay := get_tree().root.find_child("DialogueOverlay", true, false)
	await get_tree().create_timer(0.5).timeout
	print("EVENT before: ", _player_summary())
	for index_text in indices:
		var options := overlay.find_children("*", "DialogueOption", true, false)
		var index := int(index_text)
		if index >= options.size():
			print("EVENT no option ", index)
			break
		print("EVENT click ", index, " / ", options.size(), " options")
		options[index].dialogue_option_clicked.emit(options[index])
		await get_tree().create_timer(1.0).timeout
		print("EVENT after: ", _player_summary())


func _player_summary() -> String:
	var p := Global.player_data
	return "hp=%d/%d gold=%d deck=%d relics=%d potions=%s waste=%d" % [p.player_health, p.player_health_max, p.player_money, p.player_deck.size(), p.player_artifact_uid_to_artifact_data.size(), p.player_consumable_slot_to_consumable_object_id.values(), p.player_deck.filter(func(c): return c.object_id == "card_waste").size()]


## マップの部屋の種類ごとの数と階数を出力 (生成ルール確認用)
func _print_map_stats() -> void:
	var counts := {}
	var max_floor := 0
	var hidden := 0
	for location: LocationData in Global.get_all_act_locations():
		var type_name: String = LocationData.LOCATION_TYPES.keys()[location.location_type]
		counts[type_name] = counts.get(type_name, 0) + 1
		max_floor = max(max_floor, location.location_floor)
		hidden += 1 if location.location_obfuscated else 0
	print("MAPSTATS floors=%d types=%s unknown(?)=%d" % [max_floor, counts, hidden])


## 全トリガーを順番に再生する (VFX 確認用)
func _preview_vfx() -> void:
	var enemy := get_tree().get_first_node_in_group("enemies")
	var player := get_tree().get_first_node_in_group("players")
	for trigger in Vfx.triggers.keys():
		var on_player: bool = trigger in ["enemy_attack", "block_gain", "heal", "status_buff", "overheat", "energy_gain", "card_play_power"]
		print("VFX trigger: ", trigger)
		Vfx.play_trigger(trigger, player if on_player else enemy, 12)
		await get_tree().create_timer(0.8, true, false, true).timeout

func _get_mode() -> String:
	return _get_user_arg("--auto=")

func _get_user_arg(prefix: String) -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with(prefix):
			return arg.trim_prefix(prefix)
	return ""

## --shot=<png>: 8秒後 (手札が配られた後) に画面を実際の解像度のまま保存して終了する
## (--write-movie は基準サイズ 1200x700 に縮めて書き出すので、全画面の見た目はこちらで撮る)
func _save_shot_later(path: String) -> void:
	await get_tree().create_timer(8.0, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
	print("SHOT ", path)
	get_tree().quit()
