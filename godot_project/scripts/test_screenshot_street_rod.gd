extends SceneTree

# Automated Test Script to Capture High-Res Screenshots of Street Rod Amiga 500 System
var frame_count = 0
var stage = 0
var main_scene: Node = null
var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/ce96d1d9-7d18-4ad4-9e3e-5dd4c776d866"

func _init():
	print("[Street Rod Screenshot Runner] Starting visual capture...")

func _process(delta):
	frame_count += 1
	
	# STAGE 0: Initialize Main Scene & Driving View with Street Rod HUD
	if stage == 0:
		if frame_count == 1:
			var packed = load("res://scenes/Main.tscn")
			main_scene = packed.instantiate()
			root.add_child(main_scene)
			print("[Street Rod Screenshot Runner] Main scene added.")
		elif frame_count > 45:
			save_screenshot("screenshot_street_rod_hud.png")
			stage = 1
			frame_count = 0
			
	# STAGE 1: Open Street Rod UI - Tab 0 (Il Mercatino '93 Newspaper)
	elif stage == 1:
		if frame_count == 1:
			var sr_ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if sr_ui:
				sr_ui.open_screen(0)
				print("[Street Rod Screenshot Runner] Opened Tab 0 (Mercatino)")
		elif frame_count > 35:
			save_screenshot("screenshot_street_rod_market.png")
			stage = 2
			frame_count = 0
			
	# STAGE 2: Tab 1 (Officina & Tuning)
	elif stage == 2:
		if frame_count == 1:
			var sr_ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if sr_ui:
				sr_ui.open_screen(1)
				print("[Street Rod Screenshot Runner] Opened Tab 1 (Officina & Tuning)")
		elif frame_count > 35:
			save_screenshot("screenshot_street_rod_garage.png")
			stage = 3
			frame_count = 0
			
	# STAGE 3: Tab 2 (Diner "Da Bepi")
	elif stage == 3:
		if frame_count == 1:
			var sr_ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if sr_ui:
				sr_ui.open_screen(2)
				print("[Street Rod Screenshot Runner] Opened Tab 2 (Diner Da Bepi)")
		elif frame_count > 35:
			save_screenshot("screenshot_street_rod_diner.png")
			stage = 4
			frame_count = 0
			
	# STAGE 4: Tab 3 (Drag Strip)
	elif stage == 4:
		if frame_count == 1:
			var sr_ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if sr_ui:
				sr_ui.open_screen(3)
				print("[Street Rod Screenshot Runner] Opened Tab 3 (Rettifilo Drag)")
		elif frame_count > 35:
			save_screenshot("screenshot_street_rod_drag.png")
			print("[Street Rod Screenshot Runner] All screenshots captured successfully!")
			quit()

func save_screenshot(filename: String):
	var img = root.get_viewport().get_texture().get_image()
	var dest_path = artifact_dir + "/" + filename
	var err = img.save_png(dest_path)
	if err == OK:
		print(">>> Screenshot saved: %s" % dest_path)
	else:
		print("!!! FAILED to save screenshot: %s (err %d)" % [dest_path, err])
