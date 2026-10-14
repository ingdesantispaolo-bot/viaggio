extends SceneTree

# Script automatizzato per catturare screenshot delle nuove feature:
# 1. Tornanti alpini a gomito e pendenze montane
# 2. Traffico civile d'epoca (Sorpasso Ape Piaggio 50)
# 3. Incroci e bivi realistici con segnaletica STOP e specchi parabolici

var frame_count = 0
var stage = 0
var main_scene: Node = null
var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/5de6aa96-819b-4902-a405-f58b4fa2f294"

func _init():
	print("[Screenshot Traffic & Curves] Inizializzazione sessione di cattura visiva...")

func _process(delta):
	frame_count += 1
	
	if stage == 0:
		if frame_count == 1:
			var packed = load("res://scenes/Main.tscn")
			main_scene = packed.instantiate()
			root.add_child(main_scene)
			print("[Screenshot] Scena Main istanziata.")
			var ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if not ui:
				ui = main_scene.get_node_or_null("StreetRodUI")
			if ui:
				ui.close_screen()
				ui.visible = false
			teleport_to_z(220.0, 2)
		elif frame_count == 25:
			var road_gen = main_scene.get_node("RoadGenerator")
			var info = road_gen.get_road_info_at(220.0)
			# Vista panoramica dal basso sul tornante a gomito in salita (+15m)
			set_scenic_camera_shot(Vector3(info.x - 14.0, info.y + 4.8, 205.0), Vector3(info.x + 3.0, info.y + 2.5, 230.0))
		elif frame_count > 50:
			save_screenshot("screenshot_tornante_alpino.png")
			stage = 1
			frame_count = 0
			
	elif stage == 1:
		if frame_count == 1:
			teleport_to_z(90.0, 2)
			print("[Screenshot] Setup sorpasso Ape Piaggio...")
			var tm = main_scene.get_node_or_null("CivilianTrafficManager")
			var veh = main_scene.get_node("Vehicle")
			if tm and veh:
				# Crea un'Ape Piaggio a Z=104m (14m avanti)
				var ape_node = tm.create_traffic_model("ape_piaggio", false)
				tm.add_child(ape_node)
				var slow_ape = {
					"node": ape_node, "type": "ape_piaggio", "type_name": "Ape Piaggio 50",
					"current_z": 104.0, "speed_kmh": 32.0, "is_oncoming": false, "is_slow_vehicle": true,
					"lane_offset": 2.65, "pulling_aside": true, "indicator_timer": 0.0,
					"indicator_mesh": ape_node.find_child("IndicatorR", true, false),
					"tl_mesh_l": ape_node.find_child("TaillightL", true, false),
					"tl_mesh_r": ape_node.find_child("TaillightR", true, false),
					"has_collided": false, "overtaken": false
				}
				tm.active_traffic.append(slow_ape)
				var ind = ape_node.find_child("IndicatorR", true, false)
				if ind: ind.visible = true
				
				# Posiziona l'Ape sul bordo strada a destra
				var road_gen = main_scene.get_node("RoadGenerator")
				var r_ape = road_gen.get_road_info_at(104.0)
				ape_node.global_position = Vector3(r_ape.x + 2.65, r_ape.y + 0.04, 104.0)
				ape_node.rotation.y = r_ape.angle + PI
				
				# Posiziona il giocatore in fase di sorpasso sulla corsia di sinistra
				var r_p = road_gen.get_road_info_at(96.0)
				veh.global_position = Vector3(r_p.x - 1.4, r_p.y + 0.45, 96.0)
				veh.rotation.y = r_p.angle + PI
				
		elif frame_count == 25:
			var road_gen = main_scene.get_node("RoadGenerator")
			var info = road_gen.get_road_info_at(98.0)
			# Inquadratura dinamica posteriore a tre quarti che coglie il sorpasso dell'Ape
			set_scenic_camera_shot(Vector3(info.x - 3.8, info.y + 2.4, 86.0), Vector3(info.x + 0.8, info.y + 1.2, 104.0))
		elif frame_count > 50:
			save_screenshot("screenshot_sorpasso_ape_piaggio.png")
			stage = 2
			frame_count = 0
			
	elif stage == 2:
		if frame_count == 1:
			teleport_to_z(630.0, 2)
			print("[Screenshot] Setup bivio stradale e incrocio a T...")
			var veh = main_scene.get_node("Vehicle")
			var road_gen = main_scene.get_node("RoadGenerator")
			var r_p = road_gen.get_road_info_at(625.0)
			veh.global_position = Vector3(r_p.x - 0.8, r_p.y + 0.45, 625.0)
			veh.rotation.y = r_p.angle + PI
		elif frame_count == 25:
			var road_gen = main_scene.get_node("RoadGenerator")
			var info = road_gen.get_road_info_at(635.0)
			# Inquadratura sull'incrocio a T con specchio parabolico, cartello STOP e innesto
			set_scenic_camera_shot(Vector3(info.x - 8.5, info.y + 3.2, 615.0), Vector3(info.x + 6.0, info.y + 1.5, 642.0))
		elif frame_count > 50:
			save_screenshot("screenshot_bivio_incrocio.png")
			stage = 3
			frame_count = 0
			
	elif stage == 3:
		print("[Screenshot Traffic & Curves] Tutte le schermate sono state catturate con successo!")
		quit()

func set_scenic_camera_shot(cam_pos: Vector3, look_pos: Vector3):
	var cam = main_scene.get_node("CameraController")
	if cam:
		cam.set_physics_process(false)
		cam.global_position = cam_pos
		cam.look_at(look_pos, Vector3.UP)

func teleport_to_z(target_z: float, cam_mode: int):
	var vehicle = main_scene.get_node("Vehicle")
	var road_gen = main_scene.get_node("RoadGenerator")
	var biome_dir = main_scene.get_node("BiomeDirector")
	var cam = main_scene.get_node("CameraController")
	
	if road_gen:
		road_gen.update_generation(target_z)
		var info = road_gen.get_road_info_at(target_z)
		if vehicle:
			vehicle.global_position = Vector3(info.x, info.y + 0.45, target_z)
			vehicle.rotation = Vector3(0.0, info.angle + PI, 0.0)
			vehicle.linear_velocity = Vector3.ZERO
			vehicle.angular_velocity = Vector3.ZERO
			vehicle.current_speed_kmh = 45.0
	
	if biome_dir:
		biome_dir.update_biome(target_z, 1.0)
		biome_dir.update_biome(target_z, 1.0)
		
	if cam:
		cam.set_physics_process(true)
		cam.set_camera_mode(cam_mode)
		cam.setup_initial_position()

func save_screenshot(filename: String):
	var img = root.get_viewport().get_texture().get_image()
	var full_path = artifact_dir + "/" + filename
	var err = img.save_png(full_path)
	if err == OK:
		print("[Screenshot] Salvata schermata: ", full_path)
	else:
		print("[Screenshot] Errore salvataggio: ", err)
