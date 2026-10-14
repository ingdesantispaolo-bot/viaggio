extends SceneTree

# Script di cattura visiva per i nuovi requisiti di Paolo:
# 1. Avvio in Garage Paolo 3D (vettura sul ponte/box officina, banco attrezzi, insegna smaltata)
# 2. Area di Servizio Agip & Bivio con massicciata 4.5m e muri di contenimento (nessun vuoto sospeso)
# 3. Vista stradale pulita (nessuna riga tilt-shift fissa, nessuna riga wiper 2D)
# 4. Impatto e deformazione realistica (paraurti compresso, cofano piegato a cerniera, scintille)

var frame_count = 0
var stage = 0
var main_scene: Node = null
var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/5de6aa96-819b-4902-a405-f58b4fa2f294"

func _init():
	print("[Garage & Crash Visual Capture] Inizializzazione acquisizione screenshot...")

func _process(delta):
	frame_count += 1
	
	if stage == 0:
		if frame_count == 1:
			var packed = load("res://scenes/Main.tscn")
			main_scene = packed.instantiate()
			root.add_child(main_scene)
			print("[Capture] Scena Main caricata. Auto all'avvio in Garage Paolo!")
			# Nasconde temporaneamente l'UI per mostrare il modello 3D dell'officina
			var ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if not ui: ui = main_scene.get_node_or_null("StreetRodUI")
			if ui: ui.visible = false
		elif frame_count == 25:
			# Inquadratura cinematografica all'interno del Garage 3D di Paolo
			# Mostra l'auto, il ponte sollevatore, i fusti Agip Sint 2000, banco da lavoro e l'insegna smaltata
			set_scenic_camera_shot(Vector3(11.2, 1.85, 10.6), Vector3(15.5, 0.85, 14.0), 45.0)
		elif frame_count > 45:
			save_screenshot("screenshot_garage_paolo_interior_3d.png")
			stage = 1
			frame_count = 0
			
	elif stage == 1:
		if frame_count == 1:
			# Mostra il menu Street Rod all'avvio nel Garage
			var ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if not ui: ui = main_scene.get_node_or_null("StreetRodUI")
			if ui: ui.visible = true
		elif frame_count == 25:
			set_scenic_camera_shot(Vector3(11.2, 1.85, 10.6), Vector3(15.5, 0.85, 14.0), 45.0)
		elif frame_count > 45:
			save_screenshot("screenshot_garage_paolo_startup_ui.png")
			stage = 2
			frame_count = 0
			
	elif stage == 2:
		if frame_count == 1:
			# Uscita in strada e teletrasporto all'area di servizio / bivio (Z=640 - 700m)
			var ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if not ui: ui = main_scene.get_node_or_null("StreetRodUI")
			if ui: ui.visible = false
			main_scene.exit_garage_to_road()
			
			var road_gen = main_scene.get_node("RoadGenerator")
			# Assicura generazione dei chunk fino a Z=800
			for i in range(7):
				road_gen.generate_chunk()
		elif frame_count == 25:
			# Inquadratura panoramica sull'area di servizio Agip e innesto bivio (Z=640)
			# Mostra il basamento continuo di 4.5m e il muro di pietra di contenimento
			var road_gen = main_scene.get_node("RoadGenerator")
			var r_junc = road_gen.get_road_info_at(640.0)
			set_scenic_camera_shot(Vector3(r_junc.x + 8.5, r_junc.y + 4.2, 615.0), Vector3(r_junc.x - 4.0, r_junc.y + 0.8, 645.0), 55.0)
		elif frame_count > 45:
			save_screenshot("screenshot_area_servizio_basamento.png")
			stage = 3
			frame_count = 0
			
	elif stage == 3:
		if frame_count == 1:
			# Test crash con deformazione visibile
			var veh = main_scene.get_node("Vehicle")
			veh.apply_vehicle_model("fiat_127")
			var r = main_scene.road_gen.get_road_info_at(80.0)
			veh.global_position = Vector3(r.x, r.y + 0.45, 80.0)
			veh.rotation.y = r.angle + PI
			
			# Applica deformazione plastica strutturale da urto a 55 km/h
			var contact_pt = veh.global_position + (-veh.global_transform.basis.z * 1.65) + Vector3(0.15, 0.0, 0.0)
			var crash_sys = load("res://scripts/VehicleCrashSystem.gd")
			crash_sys.apply_structural_deformation(veh, contact_pt, 55.0, veh.global_transform.basis.z)
		elif frame_count == 25:
			# Inquadratura ravvicinata frontale a tre quarti sulla carrozzeria deformata
			var veh = main_scene.get_node("Vehicle")
			var vp = veh.global_position
			set_scenic_camera_shot(Vector3(vp.x + 2.4, vp.y + 1.2, vp.z + 2.8), Vector3(vp.x, vp.y + 0.5, vp.z), 42.0)
		elif frame_count > 45:
			save_screenshot("screenshot_crash_deformazione_reale.png")
			stage = 4
			frame_count = 0
			
	elif stage == 4:
		if frame_count == 1:
			# Inquadratura orizzonte / vista di guida per dimostrare l'assenza totale di linee parassite
			var veh = main_scene.get_node("Vehicle")
			var r = main_scene.road_gen.get_road_info_at(120.0)
			veh.global_position = Vector3(r.x, r.y + 0.45, 120.0)
			veh.rotation.y = r.angle + PI
			if main_scene.dashboard_ui:
				main_scene.dashboard_ui.visible = true
		elif frame_count == 25:
			var veh = main_scene.get_node("Vehicle")
			var vp = veh.global_position
			# Chase camera GTA standard guardando verso l'orizzonte e le vette
			set_scenic_camera_shot(Vector3(vp.x, vp.y + 1.8, vp.z - 5.5), Vector3(vp.x, vp.y + 1.4, vp.z + 25.0), 65.0)
		elif frame_count > 45:
			save_screenshot("screenshot_orizzonte_pulito_senza_linee.png")
			stage = 5
			frame_count = 0
			
	elif stage == 5:
		print("[Garage & Crash Visual Capture] Tutte le 5 schermate di verifica acquisite con successo!")
		quit(0)

func set_scenic_camera_shot(cam_pos: Vector3, look_at_target: Vector3, fov: float = 48.0):
	var cam = main_scene.get_node_or_null("CameraController")
	if not cam:
		cam = main_scene.get_node_or_null("Vehicle/Camera3D")
	if not cam:
		cam = main_scene.get_viewport().get_camera_3d()
	if cam:
		cam.set_process(false)
		cam.set_physics_process(false)
		cam.global_position = cam_pos
		cam.look_at(look_at_target, Vector3.UP)
		cam.fov = fov

func save_screenshot(filename: String):
	var vp = root.get_viewport()
	var img = vp.get_texture().get_image()
	if img:
		var target_path = artifact_dir + "/" + filename
		var err = img.save_png(target_path)
		if err == OK:
			print("[Capture] Screenshot salvato: ", target_path)
		else:
			print("[Capture] Errore nel salvataggio screenshot: ", err)
