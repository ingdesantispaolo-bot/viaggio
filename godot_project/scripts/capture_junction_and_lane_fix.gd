extends SceneTree

var frame_count = 0
var stage = 0
var main_scene: Node = null
var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/5de6aa96-819b-4902-a405-f58b4fa2f294"

func _init():
	print("[Screenshot Runner] Avvio cattura visuale Bivio Organico e Rispetto Corsia...")

func _process(_delta):
	frame_count += 1
	
	if stage == 0:
		if frame_count == 1:
			var packed = load("res://scenes/Main.tscn")
			main_scene = packed.instantiate()
			root.add_child(main_scene)
			
			if main_scene.has_method("exit_garage_to_road"):
				main_scene.exit_garage_to_road()
			
			# Nasconde i menu dell'hub
			var ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if not ui: ui = main_scene.get_node_or_null("StreetRodUI")
			if ui: ui.visible = false
			
			teleport_to_z(1722.0)
		elif frame_count == 5:
			# Disattiva banner traguardo temporanei per vista pulita della strada
			var dash = main_scene.get_node_or_null("UILayer/DashboardUI")
			if not dash: dash = main_scene.get_node_or_null("DashboardUI")
			if dash:
				var m_panel = dash.find_child("MilestoneBanner", true, false)
				if m_panel: m_panel.visible = false
				var s_panel = dash.find_child("StageClearBanner", true, false)
				if s_panel: s_panel.visible = false
		elif frame_count == 15:
			# Genera veicoli di traffico: Fiat 500 davanti a destra e Oncoming a sinistra in discesa
			var tm = main_scene.get_node_or_null("CivilianTrafficManager")
			if tm:
				tm.try_spawn_traffic_vehicle(1755.0) # Fiat 500 a destra
				tm.try_spawn_traffic_vehicle(1790.0) # Berlina sportiva a destra
				tm.try_spawn_traffic_vehicle(1840.0) # Oncoming a sinistra
		elif frame_count == 35:
			# Inquadratura chase GTA identica allo screenshot dell'utente
			var vehicle = main_scene.get_node_or_null("Vehicle")
			var road_gen = main_scene.get_node_or_null("RoadGenerator")
			var cam = main_scene.get_node_or_null("CameraController")
			if vehicle and road_gen and cam:
				var r_info = road_gen.get_road_info_at(1722.0)
				# Fiat 127 a Z = 1722m al centro della corsia di destra (+1.85m)
				vehicle.global_position = Vector3(r_info.x + 1.85, r_info.y + 0.35, 1722.0)
				vehicle.rotation = Vector3(0.0, r_info.angle + PI, 0.0)
				
				# Camera posizionata 8m dietro la 127, in asse con la corsia
				var cam_pos = Vector3(r_info.x + 1.85, r_info.y + 1.65, 1714.0)
				var look_pos = Vector3(r_info.x + 0.4, r_info.y + 1.35, 1745.0)
				cam.set_physics_process(false)
				cam.global_position = cam_pos
				cam.look_at(look_pos, Vector3.UP)
		elif frame_count > 65:
			save_screenshot("screenshot_bivio_organico_corsie_perfette.png")
			stage = 1
			frame_count = 0
	elif stage == 1:
		print("[Screenshot Runner] Screenshot completato con successo!")
		quit()

func teleport_to_z(target_z: float):
	var vehicle = main_scene.get_node_or_null("Vehicle")
	var road_gen = main_scene.get_node_or_null("RoadGenerator")
	var biome_dir = main_scene.get_node_or_null("BiomeDirector")
	
	if road_gen:
		road_gen.update_generation(target_z + 320.0)
		var info = road_gen.get_road_info_at(target_z)
		if vehicle:
			vehicle.global_position = Vector3(info.x + 1.85, info.y + 0.45, target_z)
			vehicle.rotation = Vector3(0.0, info.angle + PI, 0.0)
			vehicle.linear_velocity = Vector3.ZERO
			vehicle.angular_velocity = Vector3.ZERO
			vehicle.current_speed_kmh = 48.0
	
	if biome_dir:
		biome_dir.update_biome(target_z, 1.0)
		biome_dir.update_biome(target_z, 1.0)

func save_screenshot(filename: String):
	var img = root.get_viewport().get_texture().get_image()
	var dest_path = artifact_dir + "/" + filename
	img.save_png(dest_path)
	print("[Screenshot Runner] Immagine salvata in: %s" % dest_path)
