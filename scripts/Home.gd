extends Control

var button_font := DynamicFont.new()
var welcome_label_font := DynamicFont.new()
var version_label_font := DynamicFont.new()
var font_data := DynamicFontData.new()

var music_vol_change_disabled := false
var welcome_label_disabled := false
var version_label_disabled := false
var blur_blur_disabled := false
var infinite_runners_disabled := false
var boss_battle_disabled := false
var settings_disabled := false
var close_disabled := false

var window_mode := 0
var window_size_x : int
var window_size_y : int
var window_size := Vector2()
var adjust_window_size := false

func _ready():
	#Fonts setup
	font_data.font_path = "res://resources/ariblk.ttf"
	button_font.font_data = font_data
	button_font.size = 18
	welcome_label_font.font_data = font_data
	welcome_label_font.size = 30
	welcome_label_font.outline_size = 2
	version_label_font.font_data = font_data
	version_label_font.size = 16
	version_label_font.outline_size = 1
	
	# Change Welcome Label filters
	$WelcomeLabel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$WelcomeLabel.mouse_default_cursor_shape = Control.CURSOR_ARROW
	
	#Getting screen ready
	#OS.request_permissions()
	if OS.get_name() == "Windows" or OS.get_name() == "OSX" or OS.get_name() == "X11":
		$WelcomeLabel.text = "Welcome to Sonic Hub PC!"
		OS.min_window_size = Vector2(490,685)
		OS.request_attention()
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		$WelcomeLabel.text = "Welcome to Sonic Hub Mobile! (Unsupported)"
		Global.mobile_mode = true
		
	# Preparing Sonic Idle Animation & Popup
	$SonicAnimations.play("SonicLay")
	$Warning.get_close_button().hide()
	$ExitConfirmation.get_close_button().hide()
	$CanvasModulate.set_modulate(Color("#ffffff"))
	
	if Global.from_blue_blur == true and Global.from_home == false:
		music_vol_change_disabled = true
		$MenuTransitions.play("GameTransitionBlueBlur")
		Global.from_home = true
		Global.from_blue_blur = false
	
	load_game()
	

func _process(delta):
	if music_vol_change_disabled == false:
		$Music.volume_db = Global.music_vol
	$Bleep.volume_db = Global.sfx_vol
	$Accept.volume_db = Global.sfx_vol
	if adjust_window_size != false:
		if window_size != OS.window_size:
			if OS.window_fullscreen == false:
				if OS.window_borderless == false:
					if OS.window_minimized == false:
						window_size_x = OS.window_size.x
						window_size_y = OS.window_size.y
						window_size = OS.window_size
						print("size changed, saving.")
						save_game()
	if Global.music_mode == 0:
		$Music.pitch_scale = 1
		$SettingsMenu/MusicModeLabel.text = "Normal Mode"
	if Global.music_mode == 1:
		$Music.pitch_scale = 0.75
		$SettingsMenu/MusicModeLabel.text = "Chill Mode"
	if Global.music_mode == 2:
		$Music.pitch_scale = 1.25
		$SettingsMenu/MusicModeLabel.text = "Hyper Mode"

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		#var welcome_bounds = Rect2($WelcomeLabel.rect_position, $WelcomeLabel.rect_size)
		var version_bounds = Rect2($VersionLabel.rect_position, $VersionLabel.rect_size)
		"""if welcome_bounds.has_point(event.position):
			if welcome_label_disabled == false:
				welcome_label_disabled = true
				$Accept.play(0)
				$Warning.popup()"""
		if version_bounds.has_point(event.position):
			if version_label_disabled == false:
				#version_label_pressable = true
				$Accept.play(0)
				$Changelog.popup()

"""func _on_welcomeLabel_mouse_entered():
	if Global.mobile_mode == false:
		$WelcomeLabel.add_color_override("font_color", Color(0,0,0,1))
		$WelcomeLabel.add_color_override("font_outline_modulate", Color(1,1,1,1))
		$WelcomeLabel.add_font_override("font", welcome_label_font)
		$LearnMoreLabel.text = "Welcome to the alpha!"
		$Bleep.play(0)

func _on_WelcomeLabel_mouse_exited():
	if Global.mobile_mode == false:
		$WelcomeLabel.add_color_override("font_color", Color(1,1,1,1))
		$WelcomeLabel.add_color_override("font_outline_modulate", Color(0,0,0,1))
		$WelcomeLabel.add_font_override("font", welcome_label_font)
		$LearnMoreLabel.text = "Hover or tap & hold to learn more!" """

func save():
	var save_dict = {
		"window_mode" : window_mode,
		"window_size_x" : window_size_x,
		"window_size_y" : window_size_y,
		"music_volume" : Global.music_vol,
		"sfx_volume" : Global.sfx_vol,
		"music_mode" : Global.music_mode,
	}
	
	return save_dict

func save_game():
	var save_game = File.new()
	save_game.open("user://user.setngs", File.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.filename.empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# Store the save dictionary as a new line in the save file.
		save_game.store_line(to_json(node_data))
	save_game.close()
	print("Successfully saved the file!")

func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://user.setngs"):
		print("User save non-existant. Creating file.")
		save_game()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open("user://user.setngs", File.READ)
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		var node_data = parse_json(save_game.get_line())
		print(node_data)
		
		print("Successfully got user save data!\n")
		
		Global.music_mode = node_data["music_mode"]
		print("Music Mode: " + str(Global.music_mode) + "\n")
		
		Global.music_vol = node_data["music_volume"]
		print("Music Volume: " + str(Global.music_vol))
		$SettingsMenu/AudioSlider.value = Global.music_vol
		
		Global.sfx_vol = node_data["sfx_volume"]
		print("SFX Volume: " + str(Global.sfx_vol))
		$SettingsMenu/SFXSlider.value = Global.sfx_vol
		
		window_mode = node_data["window_mode"]
		print("Window Mode: " + str(window_mode))
		$SettingsMenu/WindowOptions.selected = window_mode
		set_window_settings(window_mode)
		
		window_size_x = node_data["window_size_x"]
		print("Window Size X: " + str(window_size_x))
		
		window_size_y = node_data["window_size_y"]
		print("Window Size Y: " + str(window_size_y))
		
		window_size = Vector2(window_size_x, window_size_y)
		print("Window Size: " + str(window_size))
		
		adjust_window_size = true

	save_game.close()

func _on_VersionLabel_mouse_entered():
	if Global.mobile_mode == false:
		$VersionLabel.add_color_override("font_color", Color(0,0,0,1))
		$VersionLabel.add_color_override("font_outline_modulate", Color(1,1,1,1))
		$VersionLabel.add_font_override("font", version_label_font)
		$LearnMoreLabel.text = "View the changes made!"
		$Bleep.play(0)

func _on_VersionLabel_mouse_exited():
	if Global.mobile_mode == false:
		$VersionLabel.add_color_override("font_color", Color(1,1,1,1))
		$VersionLabel.add_color_override("font_outline_modulate", Color(0,0,0,1))
		$VersionLabel.add_font_override("font", version_label_font)
		$LearnMoreLabel.text = "Hover or tap & hold to learn more!"

func _on_BlueBlur_mouse_entered():
	if Global.mobile_mode == false:
		$BlueBlur.add_color_override("font_color_hover", Color("#000000"))
		$BlueBlur.add_font_override("font", button_font)
		$LearnMoreLabel.text = "The definitive Sonic engine on Code.org. All imagination starts from here."
		$SonicAnimations.play("SonicWalk")
		$Bleep.play(0)

func _on_BlueBlur_mouse_exited():
	if Global.mobile_mode == false:
		$LearnMoreLabel.text = "Hover or tap & hold to learn more!"
		$SonicAnimations.play("SonicLay")

func _on_InfiniteRunners_mouse_entered():
	if Global.mobile_mode == false:
		$InfiniteRunners.add_color_override("font_color_hover", Color("#000000"))
		$InfiniteRunners.add_font_override("font", button_font)
		$LearnMoreLabel.text = "The infinite running game for when you need to relax & have some fun. Not really so infinite though."
		$SonicAnimations.play("SonicRun")
		$Bleep.play(0)

func _on_InfiniteRunners_mouse_exited():
	if Global.mobile_mode == false:
		$LearnMoreLabel.text = "Hover or tap & hold to learn more!"
		$SonicAnimations.play("SonicLay")

func _on_BossBattle_mouse_entered():
	if Global.mobile_mode == false:
		$BossBattle.add_color_override("font_color_hover", Color("#000000"))
		$BossBattle.add_font_override("font", button_font)
		$LearnMoreLabel.text = "Where this whole Sonic Code.org stuff came from. A little project."
		$SonicAnimations.play("BossLeft")
		$Bleep.play(0)

func _on_BossBattle_mouse_exited():
	if Global.mobile_mode == false:
		$LearnMoreLabel.text = "Hover or tap & hold to learn more!"
		$SonicAnimations.play("SonicLay")

func _on_BlueBlur_pressed():
	if blur_blur_disabled == false:
		$Accept.play(0)
		Global.from_home = true
		music_vol_change_disabled = true
		welcome_label_disabled = true
		version_label_disabled = true
		blur_blur_disabled = true
		infinite_runners_disabled = true
		boss_battle_disabled = true
		settings_disabled = true
		close_disabled = true
		$MenuTransitions.play("GameTransition")

func _on_InfiniteRunners_pressed():
	if infinite_runners_disabled == false:
		$Accept.play(0)
		OS.shell_open("https://studio.code.org/projects/gamelab/Ky2EhdDlOUdPnRi20wmjRB3DikhdEEgMKcV-OzcmNtU")
		OS.window_minimized = true

func _on_BossBattle_pressed():
	if boss_battle_disabled == false:
		$Accept.play(0)
		OS.shell_open("https://studio.code.org/projects/gamelab/bFaqM1xU5qbjsR0jmIxqyFQxmcsvVSYWwSFo7jng6M0")
		OS.window_minimized = true

func _on_BlueBlur_button_down():
	if Global.mobile_mode == false:
		$BlueBlur.add_color_override("font_color_pressed", Color("#000000"))
		$BlueBlur.add_font_override("font", button_font)

func _on_InfiniteRunners_button_down():
	if Global.mobile_mode == false:
		$InfiniteRunners.add_color_override("font_color_pressed", Color("#000000"))
		$InfiniteRunners.add_font_override("font", button_font)

func _on_BossBattle_button_down():
	if Global.mobile_mode == false:
		$BossBattle.add_color_override("font_color_pressed", Color("#000000"))
		$BossBattle.add_font_override("font", button_font)

func _on_Warning_confirmed():
	welcome_label_disabled = false

func _on_CloseButton_pressed():
	if close_disabled == false:
		$ExitConfirmation.popup_centered()
		$ExitConfirmation.popup()
		$Accept.play(0)

func _on_CloseButton_mouse_entered():
	$Bleep.play(0)
	$LearnMoreLabel.text = "Close Sonic Hub?"

func _on_CloseButton_mouse_exited():
	$LearnMoreLabel.text = "Hover or tap & hold to learn more!"

func _animation_close():
	get_tree().quit()

func _animation_blue_blur():
	get_tree().change_scene("res://scenes/BlueBlurEngine.tscn")

func _blue_blur_animation_finished():
	music_vol_change_disabled = false

func _on_ExitConfirmation_confirmed():
	$Accept.play(0)
	$CanvasModulate.set_visible(true)
	music_vol_change_disabled = true
	welcome_label_disabled = true
	version_label_disabled = true
	blur_blur_disabled = true
	infinite_runners_disabled = true
	boss_battle_disabled = true
	settings_disabled = true
	close_disabled = true
	$MenuTransitions.play("GameClose")

func _on_SettingsButton_pressed():
	if settings_disabled == false:
		$SettingsMenu.popup_centered()
		version_label_disabled = true
		welcome_label_disabled = true
		$Accept.play(0)

func _on_SettingsButton_mouse_entered():
	$Bleep.play(0)
	$LearnMoreLabel.text = "Change aspects to the look and feel of Sonic Hub!"

func _on_SettingsButton_mouse_exited():
	$LearnMoreLabel.text = "Hover or tap & hold to learn more!"

func _on_DoneButton_pressed():
	$Accept.play(0)
	version_label_disabled = false
	welcome_label_disabled = false
	$SettingsMenu.visible = false

func _on_MusicMode_pressed():
	$Accept.play(0)
	if Global.music_mode == 0:
		Global.music_mode = 1
		print("Music Mode: " + str(Global.music_mode))
	elif Global.music_mode == 1:
		Global.music_mode = 2
		print("Music Mode: " + str(Global.music_mode))
	elif Global.music_mode == 2:
		Global.music_mode = 0
		print("Music Mode: " + str(Global.music_mode))
	save_game()

func _on_WindowOptions_item_selected(index):
	if index == 0:
		OS.window_size = window_size
		$CloseButton.visible = false
		OS.window_fullscreen = false
		OS.window_borderless = false
		OS.window_maximized = false
		OS.center_window()
		window_mode = index
	elif index == 1:
		$CloseButton.visible = true
		OS.window_fullscreen = false
		OS.window_borderless = true
		OS.window_maximized = true
		OS.center_window()
		window_mode = index
	elif index == 2:
		$CloseButton.visible = true
		OS.window_borderless = false
		OS.window_maximized = false
		OS.window_fullscreen = true
		OS.center_window()
		window_mode = index
	save_game()

func set_window_settings(index : int):
	if index == 0:
		OS.window_size = window_size
		$CloseButton.visible = false
		OS.window_fullscreen = false
		OS.window_borderless = false
		OS.window_maximized = false
		OS.center_window()
	elif index == 1:
		$CloseButton.visible = true
		OS.window_fullscreen = false
		OS.window_borderless = true
		OS.window_maximized = true
		OS.center_window()
	elif index == 2:
		$CloseButton.visible = true
		OS.window_borderless = false
		OS.window_maximized = false
		OS.window_fullscreen = true
		OS.center_window()

func _on_AudioSlider_value_changed(value):
	Global.music_vol = value
	save_game()

func _on_SFXSlider_value_changed(value):
	Global.sfx_vol = value
	save_game()
