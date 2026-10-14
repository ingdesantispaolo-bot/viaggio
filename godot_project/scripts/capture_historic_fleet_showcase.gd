extends SceneTree

var frame_count = 0
var stage = 0
var main_scene: Node = null
var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/5de6aa96-819b-4902-a405-f58b4fa2f294"

func _init():
	print("[Screenshot Flotta Storica] Avvio sessione di rendering fotografico per l'Ing. Paolo (Prospettive Frontali 3/4 & Mercatino)...")

func _process(_delta):
	frame_count += 1
	
	# STAGE 0: Setup iniziale scena e Alfa Romeo 8C 2900B Spider Corto (1938)
	if stage == 0:
		if frame_count == 1:
			var packed = load("res://scenes/Main.tscn")
			main_scene = packed.instantiate()
			root.add_child(main_scene)
			
			var ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if not ui: ui = main_scene.get_node_or_null("StreetRodUI")
			if ui:
				ui.close_screen()
				ui.visible = false
				
			# Rimuovi eventuali notifiche di checkpoint o toast a schermo per scatti puliti
			var notif_banner = main_scene.find_child("NotificationBanner", true, false)
			if notif_banner: notif_banner.visible = false
			var toast = main_scene.find_child("ToastPanel", true, false)
			if toast: toast.visible = false
			
			# Aggiungi luce di riempimento fotografica (key-light) morbida per far brillare le cromature e i riflessi PBR
			var photo_light = DirectionalLight3D.new()
			photo_light.name = "PhotoStudioLight"
			photo_light.light_energy = 0.85
			photo_light.light_color = Color(1.0, 0.98, 0.95)
			photo_light.rotation_degrees = Vector3(-35, 140, 0)
			main_scene.add_child(photo_light)
				
			var veh = main_scene.get_node("Vehicle")
			var road_gen = main_scene.get_node("RoadGenerator")
			
			# Alfa Romeo 8C 2900B Spider Corto Touring Superleggera (1938)
			veh.apply_vehicle_model("alfa_8c")
			var r_info = road_gen.get_road_info_at(180.0)
			veh.global_position = Vector3(r_info.x + 1.2, r_info.y + 0.45, 180.0)
			veh.rotation = Vector3(0, PI + 0.35, 0) # Ruotata leggermente per esporre la splendida fiancata e la calandra a freccia
			veh.linear_velocity = Vector3.ZERO
			
		elif frame_count == 15:
			var veh = main_scene.get_node("Vehicle")
			var vpos = veh.global_position
			# Camera prospettica 3/4 frontale: esalta il lungo cofano dell'8 cilindri, i fari a goccia, ruote a raggi Borrani e parabrezza sdoppiato
			set_camera_pos(vpos + Vector3(2.8, 1.25, 3.8), vpos + Vector3(0.1, 0.45, -0.2))
		elif frame_count > 35:
			save_screenshot("screenshot_alfa_8c_2900b.png")
			stage = 1
			frame_count = 0
			
	# STAGE 1: Lancia Stratos HF Stradale (1974)
	elif stage == 1:
		if frame_count == 1:
			var veh = main_scene.get_node("Vehicle")
			var road_gen = main_scene.get_node("RoadGenerator")
			veh.apply_vehicle_model("lancia_stratos")
			var r_info = road_gen.get_road_info_at(220.0)
			veh.global_position = Vector3(r_info.x + 1.2, r_info.y + 0.38, 220.0)
			veh.rotation = Vector3(0, PI - 0.40, 0)
			veh.linear_velocity = Vector3.ZERO
		elif frame_count == 15:
			var veh = main_scene.get_node("Vehicle")
			var vpos = veh.global_position
			# Vista 3/4 frontale bassa: profilo a cuneo di Gandini/Bertone, fari a scomparsa sul muso affilato, parabrezza a elmo e alettone sul tetto
			set_camera_pos(vpos + Vector3(-2.9, 0.95, 3.5), vpos + Vector3(0.0, 0.40, 0.0))
		elif frame_count > 35:
			save_screenshot("screenshot_lancia_stratos_hf.png")
			stage = 2
			frame_count = 0
			
	# STAGE 2: Fiat 131 Abarth Rally (1976)
	elif stage == 2:
		if frame_count == 1:
			var veh = main_scene.get_node("Vehicle")
			var road_gen = main_scene.get_node("RoadGenerator")
			veh.apply_vehicle_model("fiat_131_abarth")
			var r_info = road_gen.get_road_info_at(250.0)
			veh.global_position = Vector3(r_info.x + 1.2, r_info.y + 0.45, 250.0)
			veh.rotation = Vector3(0, PI - 0.42, 0)
			veh.linear_velocity = Vector3.ZERO
		elif frame_count == 15:
			var veh = main_scene.get_node("Vehicle")
			var vpos = veh.global_position
			# Vista 3/4 frontale: presa d'aria asimmetrica sul cofano, quadrupli fari tondi Carello, spoiler anteriore e allargamenti squadrati
			set_camera_pos(vpos + Vector3(-2.8, 1.25, 3.7), vpos + Vector3(0.0, 0.45, 0.0))
		elif frame_count > 35:
			hide_ui_banners()
			save_screenshot("screenshot_fiat_131_abarth.png")
			stage = 3
			frame_count = 0
			
	# STAGE 3: Alfa Romeo Giulia Sprint GTA (1965)
	elif stage == 3:
		if frame_count == 1:
			var veh = main_scene.get_node("Vehicle")
			var road_gen = main_scene.get_node("RoadGenerator")
			veh.apply_vehicle_model("alfa_gta")
			var r_info = road_gen.get_road_info_at(280.0)
			veh.global_position = Vector3(r_info.x + 1.2, r_info.y + 0.45, 280.0)
			veh.rotation = Vector3(0, PI - 0.35, 0)
			veh.linear_velocity = Vector3.ZERO
		elif frame_count == 15:
			var veh = main_scene.get_node("Vehicle")
			var vpos = veh.global_position
			# Vista scalino Bertone, scudetto Alfa Romeo, fari tondi da corsa, presa d'aria frontale e carrozzeria alleggerita Autodelta
			set_camera_pos(vpos + Vector3(-2.7, 1.15, 3.6), vpos + Vector3(0.0, 0.42, 0.0))
		elif frame_count > 35:
			hide_ui_banners()
			save_screenshot("screenshot_alfa_giulia_gta.png")
			stage = 4
			frame_count = 0
			
	# STAGE 4: Lancia Aurelia B20 GT 2500 (1953)
	elif stage == 4:
		if frame_count == 1:
			var veh = main_scene.get_node("Vehicle")
			var road_gen = main_scene.get_node("RoadGenerator")
			veh.apply_vehicle_model("lancia_aurelia")
			var r_info = road_gen.get_road_info_at(310.0)
			veh.global_position = Vector3(r_info.x + 1.2, r_info.y + 0.45, 310.0)
			veh.rotation = Vector3(0, PI + 0.35, 0)
			veh.linear_velocity = Vector3.ZERO
		elif frame_count == 15:
			var veh = main_scene.get_node("Vehicle")
			var vpos = veh.global_position
			# Vista scudetto cromato Lancia a scudo, cofano bombato V6, paraurti a lama e linea fastback Pininfarina
			set_camera_pos(vpos + Vector3(2.8, 1.20, 3.8), vpos + Vector3(0.0, 0.45, 0.0))
		elif frame_count > 35:
			hide_ui_banners()
			save_screenshot("screenshot_lancia_aurelia_b20.png")
			stage = 5
			frame_count = 0
			
	# STAGE 5: Fiat 500A "Topolino" (1936)
	elif stage == 5:
		if frame_count == 1:
			var veh = main_scene.get_node("Vehicle")
			var road_gen = main_scene.get_node("RoadGenerator")
			veh.apply_vehicle_model("fiat_topolino")
			var r_info = road_gen.get_road_info_at(340.0)
			veh.global_position = Vector3(r_info.x + 1.1, r_info.y + 0.45, 340.0)
			veh.rotation = Vector3(0, PI + 0.42, 0)
			veh.linear_velocity = Vector3.ZERO
		elif frame_count == 15:
			var veh = main_scene.get_node("Vehicle")
			var vpos = veh.global_position
			# Muso a goccia di Dante Giacosa, calandra a listelli cromata, fari incassati sui parafanghi e capote in tela
			set_camera_pos(vpos + Vector3(2.5, 1.15, 3.4), vpos + Vector3(0.0, 0.40, 0.0))
		elif frame_count > 35:
			hide_ui_banners()
			save_screenshot("screenshot_fiat_topolino_1936.png")
			stage = 6
			frame_count = 0
			
	# STAGE 6: Mercatino dell'Usato '93 (Tab 2) con annunci e quotazioni storiche
	elif stage == 6:
		if frame_count == 1:
			var ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if not ui: ui = main_scene.get_node_or_null("StreetRodUI")
			if ui:
				ui.visible = true
				if ui.has_method("open_screen"):
					ui.open_screen(2) # Tab 2 = Il Mercatino '93 con annunci d'epoca
		elif frame_count > 25:
			save_screenshot("screenshot_mercatino_auto_storiche.png")
			print("[Screenshot Flotta Storica] Tutte le 7 immagini acquisite con successo!")
			quit(0)

func hide_ui_banners():
	if not main_scene: return
	for b_name in ["NotificationBanner", "ToastPanel", "GoalPanel", "CheckpointBanner"]:
		var n = main_scene.find_child(b_name, true, false)
		if n: n.visible = false

func set_camera_pos(cam_pos: Vector3, look_target: Vector3):
	var cam = main_scene.get_node("CameraController")
	if cam:
		cam.set_process(false)
		cam.set_physics_process(false)
		cam.global_position = cam_pos
		cam.look_at(look_target, Vector3.UP)

func save_screenshot(filename: String):
	var vp = root.get_viewport()
	var img = vp.get_texture().get_image()
	var save_path = artifact_dir + "/" + filename
	img.save_png(save_path)
	print("[Screenshot Salvato] -> " + save_path)
