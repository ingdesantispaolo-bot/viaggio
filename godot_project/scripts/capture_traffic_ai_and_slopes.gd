extends SceneTree

var frame_count = 0
var stage = 0
var main_scene: Node = null
var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/5de6aa96-819b-4902-a405-f58b4fa2f294"

func _init():
	print("[Screenshot IA & Salite] Avvio procedura cattura...")

func _process(_delta):
	frame_count += 1
	
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
				
			var veh = main_scene.get_node("Vehicle")
			var road_gen = main_scene.get_node("RoadGenerator")
			var tm = main_scene.get_node_or_null("CivilianTrafficManager")
			
			veh.apply_vehicle_model("fiat_127")
			var r_info = road_gen.get_road_info_at(160.0)
			veh.global_position = Vector3(r_info.x + 1.8, r_info.y + 0.45, 160.0)
			veh.linear_velocity = Vector3(0, 0, 15.0)
			
			# Posiziona l'Ape che accosta sulla banchina a Z=190
			if tm:
				tm.active_traffic.clear()
				var ape = tm.create_traffic_model("ape_piaggio", false)
				tm.add_child(ape)
				var r_ape = road_gen.get_road_info_at(190.0)
				ape.global_position = Vector3(r_ape.x + 2.7, r_ape.y + 0.05, 190.0)
				
				# Posiziona l'Alfa Giulietta in sorpasso a Z=175
				var alfa = tm.create_traffic_model("sport_sedan", false)
				tm.add_child(alfa)
				var r_alfa = road_gen.get_road_info_at(175.0)
				alfa.global_position = Vector3(r_alfa.x - 1.85, r_alfa.y + 0.05, 175.0)
				var ind_l = alfa.find_child("IndicatorL", true, false)
				if ind_l: ind_l.visible = true
				
				# Posiziona un'Autobianchi che scende regolarmente a Z=230
				var auto = tm.create_traffic_model("oncoming_sedan", true)
				tm.add_child(auto)
				var r_auto = road_gen.get_road_info_at(230.0)
				auto.global_position = Vector3(r_auto.x - 1.85, r_auto.y + 0.05, 230.0)
				auto.rotation.y = r_auto.angle + PI
				
		elif frame_count == 20:
			var road_gen = main_scene.get_node("RoadGenerator")
			var r_info = road_gen.get_road_info_at(175.0)
			# Camera prospettica che inquadra il convoglio: Fiat 127, Alfa in sorpasso e Ape sulla banchina
			set_camera_pos(Vector3(r_info.x + 5.5, r_info.y + 4.2, 142.0), Vector3(r_info.x, r_info.y + 1.2, 185.0))
		elif frame_count > 45:
			save_screenshot("screenshot_traffico_intelligente_corsie.png")
			stage = 1
			frame_count = 0
			
	elif stage == 1:
		if frame_count == 1:
			var veh = main_scene.get_node("Vehicle")
			var road_gen = main_scene.get_node("RoadGenerator")
			# Portiamo la 127 sulla salita continua ripida del passo alpino a Z = 260m
			var r_info = road_gen.get_road_info_at(260.0)
			veh.global_position = Vector3(r_info.x + 1.8, r_info.y + 0.45, 260.0)
			veh.linear_velocity = Vector3(0, 0, 12.0)
		elif frame_count == 20:
			var road_gen = main_scene.get_node("RoadGenerator")
			var r_info = road_gen.get_road_info_at(260.0)
			# Vista laterale-posteriore che mostra la fluidità della rampa senza spigoli o gradini
			set_camera_pos(Vector3(r_info.x - 7.5, r_info.y + 2.8, 246.0), Vector3(r_info.x + 1.2, r_info.y + 1.5, 275.0))
		elif frame_count > 45:
			save_screenshot("screenshot_salita_continua_senza_spigoli.png")
			print("[Screenshot] Tutte le immagini catturate con successo!")
			quit(0)

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
