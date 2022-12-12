extends Control

var button_font := DynamicFont.new()
var font_data := DynamicFontData.new()

var music_vol_change_disabled := false
var welcome_label_pressable := true
var demo_disabled := false
var code_disabled := false
var game_disabled := false
var back_disabled := false

func _ready():
	font_data.font_path = "res://resources/ariblk.ttf"
	button_font.font_data = font_data
	button_font.size = 18
	
	if Global.from_home == true and Global.from_blue_blur == false:
		music_vol_change_disabled = true
		$CanvasModulate.visible = true
		$GameTransitions.play("GameTransitionHome")
		Global.from_home = false
		Global.from_blue_blur = true
		welcome_label_pressable = true
		demo_disabled = false
		code_disabled = false
		game_disabled = false
		back_disabled = false

func _process(delta):
	if music_vol_change_disabled == false:
		$Music.volume_db = Global.music_vol
	$Bleep.volume_db = Global.sfx_vol
	$Accept.volume_db = Global.sfx_vol
	if Global.music_mode == 0:
		$Music.pitch_scale = 1
	if Global.music_mode == 1:
		$Music.pitch_scale = 0.75
	if Global.music_mode == 2:
		$Music.pitch_scale = 1.25

func _on_BackButton_mouse_entered():
	$Bleep.play(0)

func _on_BackButton_pressed():
	$Accept.play(0)
	music_vol_change_disabled = true
	welcome_label_pressable = false
	demo_disabled = true
	code_disabled = true
	game_disabled = true
	back_disabled = true
	$GameTransitions.play("GameTranisiton")
	$CanvasModulate.visible = true

func transition_done():
	get_tree().change_scene("res://scenes/Home.tscn") 

func home_transition_done():
	music_vol_change_disabled = false
	$CanvasModulate.visible = false

func _on_BlueBlurDemo_mouse_entered():
	if Global.mobile_mode == false:
		$BlueBlurDemo.add_color_override("font_color_hover", Color("#000000"))
		$BlueBlurDemo.add_font_override("font", button_font)
		$LearnMoreLabel.text = "Take a look at what's in store before you use it. It's taken a while to get here."
		$Bleep.play(0)

func _on_BlueBlurCode_mouse_entered():
	if Global.mobile_mode == false:
		$BlueBlurCode.add_color_override("font_color_hover", Color("#000000"))
		$BlueBlurCode.add_font_override("font", button_font)
		$LearnMoreLabel.text = "View the source code & remix it to make your own sonic games! Infinite possibilities!"
		$Bleep.play(0)

func _on_BlueBlurGame_mouse_entered():
	if Global.mobile_mode == false:
		$BlueBlurGame.add_color_override("font_color_hover", Color("#000000"))
		$BlueBlurGame.add_font_override("font", button_font)
		$LearnMoreLabel.text = "View an official project remade with the Blue Blur Engine. Same old story, revamped."
		$Bleep.play(0)

func _on_BlueBlurDemo_mouse_exited():
	if Global.mobile_mode == false:
		if demo_disabled == false:
			$LearnMoreLabel.text = "Hover or tap & hold to learn more!"

func _on_BlueBlurCode_mouse_exited():
	if Global.mobile_mode == false:
		if code_disabled == false:
			$LearnMoreLabel.text = "Hover or tap & hold to learn more!"

func _on_BlueBlurGame_mouse_exited():
	if Global.mobile_mode == false:
		if game_disabled == false:
			$LearnMoreLabel.text = "Hover or tap & hold to learn more!"

func _on_BlueBlurDemo_pressed():
	if demo_disabled == false:
		OS.shell_open("https://studio.code.org/projects/gamelab/jpmF9w7_cBeq-Ib4SiN06Y0yyyaLG2XS0k1ecbHyvBg")
		$Accept.play(0)
		OS.window_minimized = true

func _on_BlueBlurCode_pressed():
	if code_disabled == false:
		OS.shell_open("https://studio.code.org/projects/gamelab/jpmF9w7_cBeq-Ib4SiN06Y0yyyaLG2XS0k1ecbHyvBg/view")
		$Accept.play(0)
		OS.window_minimized = true

func _on_BlueBlurGame_pressed():
	if game_disabled == false:
		OS.shell_open("https://studio.code.org/projects/gamelab/2_6vHmirmrS1mFc3JEqbFiQ7Ns275YiPltd_JSmYfRc/")
		$Accept.play(0)
		OS.window_minimized = true

func _on_BlueBlurDemo_button_down():
	if Global.mobile_mode == false:
		$BlueBlurDemo.add_color_override("font_color_pressed", Color("#000000"))
		$BlueBlurDemo.add_font_override("font", button_font)

func _on_BlueBlurCode_button_down():
	if Global.mobile_mode == false:
		$BlueBlurCode.add_color_override("font_color_pressed", Color("#000000"))
		$BlueBlurCode.add_font_override("font", button_font)

func _on_BlueBlurGame_button_down():
	if Global.mobile_mode == false:
		$BlueBlurGame.add_color_override("font_color_pressed", Color("#000000"))
		$BlueBlurGame.add_font_override("font", button_font)
