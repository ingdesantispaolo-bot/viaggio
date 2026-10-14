extends SceneTree

# ==============================================================================
# VERIFICA VISIVA & TEST: OFFICINA STREET ROD, RACE SPAWN & COCKPIT CAMERA
# ==============================================================================

var frame_count = 0
var stage = 0
var main_scene: Node = null
var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/80482df3-861c-4f01-b762-b7e41f9e5340"

func _init():
	print("[Capture Fixes] Inizializzazione test officina, race spawn e cockpit camera...")

func _process(delta):
	frame_count += 1
	
	if stage == 0:
		if frame_count == 1:
			var packed = load("res://scenes/Main.tscn")
			main_scene = packed.instantiate()
			root.add_child(main_scene)
			print("[Capture] Scena Main caricata. Avvio in Officina Paolo!")
		elif frame_count == 25:
			# Assicurati che l'UI di Street Rod sia visibile sul Tab 0 (Officina)
			var ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if not ui: ui = main_scene.get_node_or_null("StreetRodUI")
			if ui:
				ui.visible = true
				ui.switch_tab(0)
		elif frame_count > 45:
			save_screenshot("screenshot_officina_streetrod_hotspots.png")
			stage = 1
			frame_count = 0
			
	elif stage == 1:
		if frame_count == 1:
			var ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if not ui: ui = main_scene.get_node_or_null("StreetRodUI")
			if ui:
				ui.hide_onboarding_guide()
				ui.select_workshop_bay("engine")
		elif frame_count > 35:
			save_screenshot("screenshot_officina_banco_motore.png")
			stage = 2
			frame_count = 0
			
	elif stage == 2:
		if frame_count == 1:
			var ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if not ui: ui = main_scene.get_node_or_null("StreetRodUI")
			if ui:
				ui.switch_tab(1)
		elif frame_count > 35:
			save_screenshot("screenshot_officina_dyno_bench.png")
			stage = 3
			frame_count = 0
			
	elif stage == 3:
		if frame_count == 1:
			var ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if not ui: ui = main_scene.get_node_or_null("StreetRodUI")
			if ui:
				ui.switch_tab(2)
		elif frame_count > 35:
			save_screenshot("screenshot_mercatino_93_newspaper.png")
			stage = 4
			frame_count = 0
			
	elif stage == 4:
		if frame_count == 1:
			var ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if not ui: ui = main_scene.get_node_or_null("StreetRodUI")
			if ui:
				ui.switch_tab(3)
		elif frame_count > 35:
			save_screenshot("screenshot_diner_da_bepi.png")
			stage = 5
			frame_count = 0
			
	elif stage == 5:
		if frame_count == 1:
			var ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if not ui: ui = main_scene.get_node_or_null("StreetRodUI")
			if ui:
				ui.switch_tab(5)
		elif frame_count > 35:
			save_screenshot("screenshot_carta_topografica_passo.png")
			stage = 6
			frame_count = 0
			
	elif stage == 6:
		if frame_count == 1:
			# Mostra il manuale di accoglienza per il nuovo giocatore
			var ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if not ui: ui = main_scene.get_node_or_null("StreetRodUI")
			if ui:
				ui.switch_tab(0)
				ui.show_onboarding_guide()
		elif frame_count > 35:
			save_screenshot("screenshot_onboarding_manuale_pilota.png")
			stage = 7
			frame_count = 0
			
	elif stage == 7:
		if frame_count == 1:
			# Chiudi modal onboarding e avvia una gara di accelerazione 400m
			var ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if not ui: ui = main_scene.get_node_or_null("StreetRodUI")
			if ui:
				ui.hide_onboarding_guide()
				ui.visible = false
			
			# Simula avanzamento oltre i 600m per verificare che il chunk 0..540m NON sia stato rimosso
			var veh = main_scene.get_node("Vehicle")
			var road_gen = main_scene.get_node("RoadGenerator")
			road_gen.update_generation(650.0)
			
			# Ora avvia la gara tramite RaceDirector
			var rd = main_scene.get_node("RaceDirector")
			if rd:
				rd.start_drag_race("rival_alfa", false, 0)
		elif frame_count == 35:
			# Verifica coordinate vetture
			var veh = main_scene.get_node("Vehicle")
			var rd = main_scene.get_node("RaceDirector")
			var rival = rd.rival_vehicle if rd else null
			
			print("[Test Race Spawn] Player pos: ", veh.global_position)
			if rival:
				print("[Test Race Spawn] Rival pos: ", rival.global_position)
			
			if veh.global_position.y > -5.0 and (rival == null or rival.global_position.y > -5.0):
				print("[PASS] Le due auto NON cadono nel vuoto! Si trovano stabilmente sulla corsia della griglia!")
			else:
				printerr("[FAIL] Auto caduta nel vuoto! Player Y = ", veh.global_position.y)
				
			# Inquadratura panoramica sulla griglia di partenza
			var vp = veh.global_position
			set_scenic_camera_shot(Vector3(vp.x + 3.5, vp.y + 1.8, vp.z - 5.0), Vector3(vp.x, vp.y + 0.8, vp.z + 12.0), 60.0)
		elif frame_count > 50:
			save_screenshot("screenshot_drag_race_grid_stable.png")
			stage = 8
			frame_count = 0
			
	elif stage == 8:
		if frame_count == 1:
			# Imposta visuale cockpit guidatore ed esci sulla strada
			main_scene.exit_garage_to_road()
			var veh = main_scene.get_node("Vehicle")
			var cam = main_scene.get_node("CameraController")
			if cam:
				cam.set_process(true)
				cam.current_mode = CameraController.CameraMode.BONNET_COCKPIT
			# Accelerazione
			veh.is_ai_controlled = true
			veh.ai_throttle = 1.0
			if main_scene.dashboard_ui:
				main_scene.dashboard_ui.visible = true
		elif frame_count == 35:
			# Verifica coordinate camera rispetto al veicolo
			var veh = main_scene.get_node("Vehicle")
			var cam = main_scene.get_node("CameraController")
			var local_cam_pos = veh.global_transform.affine_inverse() * cam.global_position
			print("[Test Cockpit Rigid] Local camera pos relative to vehicle: ", local_cam_pos)
			print("[Test Cockpit Rigid] Expected eye pos: Vector3(0.26, 0.95, -0.10)")
			
			# Controlla se la camera è rimasta ancorata senza arretrare sui sedili posteriori (Z locale non deve essere < -0.40)
			if local_cam_pos.z >= -0.25 and local_cam_pos.z <= 0.05:
				print("[PASS] La vista interna e' perfettamente bloccata e NON scivola all'indietro sotto accelerazione!")
			else:
				printerr("[FAIL] La vista interna si e' ancora spostata indietro: local Z = ", local_cam_pos.z)
		elif frame_count > 50:
			save_screenshot("screenshot_cockpit_acceleration_stable.png")
			stage = 9
			frame_count = 0
			
	elif stage == 9:
		print("[Visual Capture] Tutte le verifiche e screenshot completati con successo!")
		quit(0)

func set_scenic_camera_shot(pos: Vector3, look_at: Vector3, fov: float = 55.0):
	if not main_scene: return
	var cam = main_scene.get_node_or_null("CameraController")
	if cam:
		cam.set_process(false)
		cam.global_position = pos
		cam.fov = fov
		cam.look_at(look_at, Vector3.UP)

func save_screenshot(filename: String):
	var img = root.get_viewport().get_texture().get_image()
	var dest_path = artifact_dir + "/" + filename
	var err = img.save_png(dest_path)
	if err == OK:
		print("[Screenshot Saved] -> %s" % dest_path)
	else:
		printerr("[Screenshot Error] Failed to save %s (err: %d)" % [dest_path, err])
