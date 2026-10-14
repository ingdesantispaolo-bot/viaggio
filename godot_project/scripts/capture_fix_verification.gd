extends SceneTree

# Script di cattura visiva per verificare i fix:
# 1. Dettaglio targa e carrozzeria Fiat 127 (senza SSR rumoroso, targa pulita senza z-fighting)
# 2. Asfalto e geometria stradale (senza linee diagonali random, senza box-patch penetranti)
# 3. Fiat 127 in salita sul tornante alpino (coerenza fisica pendenza/potenza motore)

var frame_count = 0
var stage = 0
var main_scene: Node = null
var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/5de6aa96-819b-4902-a405-f58b4fa2f294"

func _init():
	print("[Screenshot Verification] Avvio sessione di cattura visiva...")

func _process(delta):
	frame_count += 1
	
	if stage == 0:
		if frame_count == 1:
			var packed = load("res://scenes/Main.tscn")
			main_scene = packed.instantiate()
			root.add_child(main_scene)
			print("[Screenshot Verification] Scena Main caricata.")
			var ui = main_scene.get_node_or_null("UILayer/StreetRodUI")
			if not ui:
				ui = main_scene.get_node_or_null("StreetRodUI")
			if ui:
				ui.close_screen()
				ui.visible = false
			teleport_to_z(50.0)
		elif frame_count == 25:
			# Inquadratura ravvicinata posteriore / 3 quarti sulla Fiat 127
			# Mostra chiaramente la targa d'epoca (MI 834921) e l'assenza di SSR distorto
			var veh = main_scene.get_node("Vehicle")
			var vp = veh.global_position
			set_scenic_camera_shot(Vector3(vp.x - 1.8, vp.y + 0.9, vp.z - 3.2), Vector3(vp.x, vp.y + 0.6, vp.z))
		elif frame_count > 50:
			save_screenshot("screenshot_fiat127_targa_riflessi.png")
			stage = 1
			frame_count = 0
			
	elif stage == 1:
		if frame_count == 1:
			teleport_to_z(140.0)
		elif frame_count == 25:
			# Inquadratura prospettica sulla carreggiata stradale per evidenziare la pulizia della superficie
			var road_gen = main_scene.get_node("RoadGenerator")
			var r = road_gen.get_road_info_at(155.0)
			# Posizionamento radente alla strada guardando avanti
			set_scenic_camera_shot(Vector3(r.x - 2.5, r.y + 1.2, 140.0), Vector3(r.x, r.y + 0.4, 185.0))
		elif frame_count > 50:
			save_screenshot("screenshot_strada_asfalto_pulito.png")
			stage = 2
			frame_count = 0
			
	elif stage == 2:
		if frame_count == 1:
			# Salita ripida alpina (tornante / salita Z=230)
			teleport_to_z(225.0)
			var veh = main_scene.get_node("Vehicle")
			veh.linear_velocity = Vector3(0, 1.2, 8.5) # In salita dinamica
		elif frame_count == 25:
			var veh = main_scene.get_node("Vehicle")
			var vp = veh.global_position
			# Vista laterale-posteriore della 127 che affronta la salita ripida
			set_scenic_camera_shot(Vector3(vp.x - 5.5, vp.y + 2.2, vp.z - 6.0), Vector3(vp.x + 0.5, vp.y + 0.8, vp.z + 4.0))
		elif frame_count > 50:
			save_screenshot("screenshot_fiat127_salita_ripida.png")
			stage = 3
			frame_count = 0
			
	elif stage == 3:
		print("[Screenshot Verification] Tutte le schermate catturate con successo!")
		quit(0)

func teleport_to_z(z_pos: float):
	var veh = main_scene.get_node("Vehicle")
	var road_gen = main_scene.get_node("RoadGenerator")
	veh.apply_vehicle_model("fiat_127") # Fiat 127 Special 1974
	var r = road_gen.get_road_info_at(z_pos)
	veh.global_position = Vector3(r.x, r.y + 0.45, z_pos)
	veh.rotation.y = r.angle + PI
	veh.linear_velocity = Vector3.ZERO
	veh.angular_velocity = Vector3.ZERO

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
	var img = root.get_viewport().get_texture().get_image()
	var path = artifact_dir + "/" + filename
	var err = img.save_png(path)
	if err == OK:
		print("[Screenshot Verification] Salvato: ", path)
	else:
		print("[Screenshot Verification] Errore nel salvataggio: ", err)
