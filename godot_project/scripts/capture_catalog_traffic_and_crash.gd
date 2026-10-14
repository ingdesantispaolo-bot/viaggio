extends SceneTree

var frame_count = 0
var main_scene: Node = null
var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/80482df3-861c-4f01-b762-b7e41f9e5340"

func _init():
	print("[Capture Traffic & Crash] Avvio procedura cattura...")

func _process(_delta):
	frame_count += 1
	
	if frame_count == 1:
		var packed = load("res://scenes/Main.tscn")
		main_scene = packed.instantiate()
		root.add_child(main_scene)
		
		# Chiudi eventuale menu garage iniziale per mostrare la strada e le auto
		if main_scene.has_method("exit_garage_to_road"):
			main_scene.exit_garage_to_road()
			
		var ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
		if not ui: ui = main_scene.get_node_or_null("StreetRodUI")
		if ui:
			ui.close_screen()
			ui.visible = false
			
		var veh = main_scene.get_node("Vehicle")
		var road_gen = main_scene.get_node("RoadGenerator")
		var tm = main_scene.get_node_or_null("CivilianTrafficManager")
		
		veh.apply_vehicle_model("fiat_127")
		var r_info = road_gen.get_road_info_at(75.0)
		veh.global_position = Vector3(r_info.x + 1.95, r_info.y + 0.45, 75.0)
		veh.rotation.y = r_info.angle + PI
		veh.linear_velocity = Vector3.ZERO
		
		if tm:
			tm.active_traffic.clear()
			
			# 1. Fiat Panda 4x4 dal catalogo in discesa nella corsia sinistra (-half_w * 0.48)
			var r_panda = road_gen.get_road_info_at(105.0)
			var panda_node = tm.create_traffic_model("panda_4x4", true)
			tm.add_child(panda_node)
			panda_node.global_position = Vector3(r_panda.x - 1.88, r_panda.y + 0.05, 105.0)
			# Discesa: muso in avanti verso valle
			panda_node.rotation.y = r_panda.angle
			
			# 2. Renault 4 GTL dal catalogo che sale nella corsia destra (+half_w * 0.48)
			var r_r4 = road_gen.get_road_info_at(125.0)
			var r4_node = tm.create_traffic_model("renault_4", false)
			tm.add_child(r4_node)
			r4_node.global_position = Vector3(r_r4.x + 1.88, r_r4.y + 0.05, 125.0)
			# Salita: muso in avanti verso monte (visibile dal retro con targa dal player)
			r4_node.rotation.y = r_r4.angle + PI
			
			# 3. Golf GTI fermata dopo impatto con 4 frecce e deformazione
			var r_golf = road_gen.get_road_info_at(86.0)
			var golf_node = tm.create_traffic_model("golf_gti_1990", true)
			tm.add_child(golf_node)
			golf_node.global_position = Vector3(r_golf.x - 1.88, r_golf.y + 0.05, 86.0)
			golf_node.rotation.y = r_golf.angle
			
			# Applica deformazione e 4 frecce di sosta post-incidente
			var VehicleCrashSystem = preload("res://scripts/VehicleCrashSystem.gd")
			VehicleCrashSystem.apply_structural_deformation(golf_node, golf_node.global_position + Vector3(0, 0.5, -1.8), 45.0, Vector3(0, 0, 1))
			
			var ind_l = golf_node.find_child("IndicatorL", true, false)
			var ind_r = golf_node.find_child("IndicatorR", true, false)
			if ind_l: ind_l.visible = true
			if ind_r: ind_r.visible = true
			
	elif frame_count == 25:
		var cam = main_scene.get_node_or_null("CameraMount/Camera3D")
		if not cam: cam = main_scene.get_node_or_null("Camera3D")
		var veh = main_scene.get_node("Vehicle")
		if cam and veh:
			# Inquadratura panoramica cinematografica che abbraccia carreggiata, auto del catalogo e arresto con 4 frecce
			cam.global_position = Vector3(veh.global_position.x + 3.8, veh.global_position.y + 2.8, veh.global_position.z - 7.5)
			cam.look_at(Vector3(veh.global_position.x, veh.global_position.y + 0.9, veh.global_position.z + 18.0), Vector3.UP)
			
	elif frame_count == 35:
		var img = root.get_viewport().get_texture().get_image()
		var out_path = artifact_dir + "/screenshot_traffic_catalog_and_crash.png"
		var err = img.save_png(out_path)
		if err == OK:
			print("[SUCCESS] Screenshot salvato: " + out_path)
		else:
			print("[ERROR] Impossibile salvare screenshot: " + str(err))
		quit(0)
