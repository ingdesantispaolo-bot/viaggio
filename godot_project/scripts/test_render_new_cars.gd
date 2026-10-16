extends SceneTree

# Render & Visual Quality Verification Suite per le nuove auto integrate
var main_scene: Node = null
var vehicle: VehicleController = null
var cam: Camera3D = null

var cars_to_test = ["porsche_930_turbo", "porsche_carrera_4s", "countach_lpi800"]
var current_car_idx = 0
var frame_count = 0
var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/859cc8ab-8592-43ca-a74a-e57264cbbd86"

func _init():
	print("[NEW CARS RENDER] Inizializzazione suite di visualizzazione...")

func _process(delta: float):
	frame_count += 1
	
	if current_car_idx == 0 and frame_count == 1:
		var main_packed = load("res://scenes/Main.tscn")
		main_scene = main_packed.instantiate()
		root.add_child(main_scene)
		vehicle = main_scene.get_node_or_null("Vehicle")
		
		# Disattiva UI garage per scatti puliti
		var sr_ui = main_scene.find_child("StreetRodUI", true, false)
		if sr_ui: sr_ui.visible = false
		
		# Crea una telecamera di bellezza a 3/4 anteriore
		cam = Camera3D.new()
		cam.name = "BeautyCam"
		cam.current = true
		cam.fov = 52.0
		root.add_child(cam)
		
		apply_car(cars_to_test[current_car_idx])
		return

	if frame_count == 35:
		var car_id = cars_to_test[current_car_idx]
		# Posiziona la cam per inquadratura 3/4 prospettica mozzafiato
		var v_pos = vehicle.global_position
		cam.global_position = v_pos + Vector3(-2.8, 1.15, -3.2)
		cam.look_at(v_pos + Vector3(0.0, 0.45, 0.0), Vector3.UP)
		
	elif frame_count == 40:
		var car_id = cars_to_test[current_car_idx]
		var shot_path = artifact_dir + "/" + car_id + "_beauty.png"
		var img = root.get_viewport().get_texture().get_image()
		img.save_png(shot_path)
		print("[NEW CARS RENDER] Salvato screenshot beauty per %s: %s" % [car_id, shot_path])
		
		current_car_idx += 1
		frame_count = 0
		if current_car_idx < cars_to_test.size():
			apply_car(cars_to_test[current_car_idx])
		else:
			print("[NEW CARS RENDER] Tutti gli screenshot completati con successo!")
			quit(0)

func apply_car(car_id: String):
	print("[NEW CARS RENDER] Applicazione modello: ", car_id)
	vehicle.apply_vehicle_model(car_id, false)
	# Assicura motore fermo e posizione stabile
	vehicle.linear_velocity = Vector3.ZERO
	vehicle.angular_velocity = Vector3.ZERO
