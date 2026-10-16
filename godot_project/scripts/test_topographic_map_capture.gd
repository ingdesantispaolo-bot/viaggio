extends SceneTree

# ==============================================================================
# CAPTURE SCREENSHOT: CARTA TOPOGRAFICA AMIGA 500 / IGM '83 IN-GAME
# ==============================================================================

var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/859cc8ab-8592-43ca-a74a-e57264cbbd86"
var root_node: Node3D
var sr_ui: Control
var frame_count: int = 0
var stage: int = 0

func _init():
	print(">>> AVVIO CAPTURE SCREENSHOT: CARTA TOPOGRAFICA IN-GAME")

func _process(_delta: float):
	frame_count += 1
	
	if stage == 0:
		if frame_count == 1:
			var main_scene = load("res://scenes/Main.tscn")
			root_node = main_scene.instantiate()
			root.add_child(root_node)
			sr_ui = root_node.find_child("StreetRodUI", true, false)
			if sr_ui:
				sr_ui.has_seen_onboarding = true
				if sr_ui.has_node("OnboardingModal"):
					sr_ui.get_node("OnboardingModal").queue_free()
		elif frame_count >= 8:
			stage = 1
			frame_count = 0
			
	elif stage == 1:
		if frame_count == 2:
			print(">>> Apertura Tab 5 (Index 5): CARTA TOPOGRAFICA DEL MERIDIANO...")
			if sr_ui:
				sr_ui.has_seen_onboarding = true
				sr_ui.open_screen(5)
				if sr_ui.onboarding_modal and is_instance_valid(sr_ui.onboarding_modal):
					sr_ui.onboarding_modal.visible = false
				sr_ui.select_map_waypoint(4) # Tornanti dei Larici
		elif frame_count == 14:
			var img = root.get_texture().get_image()
			var dest = artifact_dir + "/screenshot_amiga_topographic_map_80s.png"
			var err = img.save_png(dest)
			if err == OK:
				print(">>> [SCREENSHOT SALVATO CON SUCCESSO] -> ", dest)
			else:
				print("[-] Errore salvataggio: ", err)
			quit(0)
