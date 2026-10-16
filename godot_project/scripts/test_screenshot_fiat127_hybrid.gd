extends SceneTree

var frame_count = 0
var stage = 0
var main_scene: Node = null
var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/859cc8ab-8592-43ca-a74a-e57264cbbd86"

func _init():
	print("[Fiat 127 Hybrid Screenshot] Inizializzazione render fotorealistico del modello 3D...")

func _process(delta):
	frame_count += 1
	
	# STAGE 0: Spawn Main Scene con Fiat 127 esterna GLB
	if stage == 0:
		if frame_count == 1:
			var packed = load("res://scenes/Main.tscn")
			main_scene = packed.instantiate()
			root.add_child(main_scene)
			
			# Nascondi tutte le UI/finestre modali per avere una visuale pulita del veicolo
			for ui in main_scene.find_children("*UI*", "CanvasLayer", true, false):
				ui.visible = false
			for modal in main_scene.find_children("*Modal*", "Control", true, false):
				modal.visible = false
			# Esci dall'officina per guidare su strada aperta (chiude il cofano e rimuove il vano motore temporaneo d'officina)
			if main_scene.has_method("exit_garage_to_road"):
				main_scene.exit_garage_to_road()
			var e_bay = main_scene.get_node("Vehicle").get_node_or_null("EngineBayRig")
			if e_bay: e_bay.queue_free()
			
			setup_car("fiat_127")
		elif frame_count == 25:
			# Visuale 3/4 Anteriore
			set_car_beauty_camera(-3.2, 1.25, -3.6, 0.45)
		elif frame_count > 50:
			save_screenshot("screenshot_fiat_127_glb_front.png")
			stage = 1
			frame_count = 0
			
	# STAGE 1: Visuale 3/4 Posteriore
	elif stage == 1:
		if frame_count == 10:
			set_car_beauty_camera(3.4, 1.35, 3.8, 0.45)
		elif frame_count > 40:
			save_screenshot("screenshot_fiat_127_glb_rear.png")
			stage = 2
			frame_count = 0
			
	# STAGE 2: Dettaglio frontale ravvicinato (calandra e fari)
	elif stage == 2:
		if frame_count == 10:
			set_car_beauty_camera(-1.4, 0.75, -2.4, 0.35)
		elif frame_count > 40:
			save_screenshot("screenshot_fiat_127_glb_close_front.png")
			print("[Fiat 127 Hybrid Screenshot] Tutti i frame catturati con successo!")
			quit(0)

func setup_car(model_id: String):
	var vehicle = main_scene.get_node("Vehicle")
	var road_gen = main_scene.get_node("RoadGenerator")
	var biome_dir = main_scene.get_node("BiomeDirector")
	
	var target_z = 240.0
	if road_gen:
		road_gen.update_generation(target_z)
		var info = road_gen.get_road_info_at(target_z)
		if vehicle:
			vehicle.global_position = Vector3(info.x, info.y + 0.45, target_z)
			vehicle.rotation = Vector3(0.0, info.angle + PI, 0.0)
			vehicle.linear_velocity = Vector3.ZERO
			vehicle.angular_velocity = Vector3.ZERO
			if "current_speed_kmh" in vehicle:
				vehicle.current_speed_kmh = 65.0
			if vehicle.has_method("apply_vehicle_model"):
				vehicle.apply_vehicle_model(model_id)
			
	if biome_dir:
		biome_dir.update_biome(target_z, 1.0)

func set_car_beauty_camera(rel_x: float, rel_y: float, rel_z: float, look_y: float):
	var vehicle = main_scene.get_node("Vehicle")
	var cam = main_scene.get_node("CameraController")
	if vehicle and cam:
		cam.set_physics_process(false)
		var cam_world = vehicle.global_transform * Vector3(rel_x, rel_y, rel_z)
		cam.global_position = cam_world
		cam.look_at(vehicle.global_transform * Vector3(0.0, look_y, 0.0), Vector3.UP)

func save_screenshot(filename: String):
	var img = root.get_viewport().get_texture().get_image()
	var full_path = artifact_dir + "/" + filename
	var err = img.save_png(full_path)
	if err == OK:
		print("[Fiat 127 Hybrid Screenshot] Salvato con successo: ", full_path)
	else:
		print("[Fiat 127 Hybrid Screenshot] Errore salvataggio: ", err)
