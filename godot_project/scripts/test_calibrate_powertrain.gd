extends SceneTree

# Calibrator: Tests each car in complete isolation with clean scene instantiation
var current_car_idx = 0
var car_ids = [
	"panda_4x4",
	"fiat_127",
	"renault_4",
	"golf_gti_1990",
	"bmw_320_e30",
	"delta_integrale",
	"mercedes_gwagen",
	"mercedes_a250"
]

var main_scene = null
var vehicle = null
var elapsed = 0.0
var t_50 = -1.0
var t_100 = -1.0
var max_spd = 0.0
var settle_frames = 0
var results = {}

func _init():
	print("[Powertrain Calibrator] Testing all 8 cars in fresh isolated physics environments...")

func _process(delta):
	if main_scene == null:
		var packed = load("res://scenes/Main.tscn")
		main_scene = packed.instantiate()
		root.add_child(main_scene)
		vehicle = main_scene.get_node("Vehicle")
		var target_car = car_ids[current_car_idx]
		vehicle.apply_vehicle_model(target_car)
		settle_frames = 15
		elapsed = 0.0
		t_50 = -1.0
		t_100 = -1.0
		max_spd = 0.0
		print("\n>>> STARTING FRESH RUN FOR: ", target_car.to_upper())
		return

	if settle_frames > 0:
		settle_frames -= 1
		return

	elapsed += delta
	Input.action_press("accelerate")
	
	var spd = vehicle.current_speed_kmh
	if spd > max_spd: max_spd = spd
	if spd >= 50.0 and t_50 < 0: t_50 = elapsed
	if spd >= 100.0 and t_100 < 0: t_100 = elapsed
	
	# Sample every 1.5s
	if fmod(elapsed, 1.5) < delta * 1.5:
		print("  t=%.1fs | spd=%.1f km/h | gear=%s | rpm=%d" % [elapsed, spd, vehicle.gear_name, int(vehicle.engine_rpm)])

	# Stop after 25s or after car reaches top speed plateau
	if elapsed >= 25.0 or (t_100 > 0 and elapsed >= t_100 + 4.0 and spd > 140.0):
		var c_id = car_ids[current_car_idx]
		results[c_id] = {
			"t_50": t_50,
			"t_100": t_100,
			"max_spd": max_spd
		}
		print("<<< FINISHED: %s -> 0-50: %s | 0-100: %s | MaxSpd: %.1f km/h" % [
			c_id,
			("%.2fs" % t_50 if t_50 > 0 else "N/A"),
			("%.2fs" % t_100 if t_100 > 0 else "N/A"),
			max_spd
		])
		
		# Cleanly free main scene and prepare next car
		main_scene.queue_free()
		main_scene = null
		vehicle = null
		current_car_idx += 1
		
		if current_car_idx >= car_ids.size():
			print_summary()
			quit()

func print_summary():
	print("\n======================= CALIBRATION RESULTS =======================")
	print("%-18s | %-8s | %-8s | %-12s" % ["CAR", "0-50", "0-100", "MAX SPD (20s)"])
	print("-------------------------------------------------------------------")
	for c_id in car_ids:
		var r = results.get(c_id, {})
		var s50 = "%.2fs" % r.get("t_50", -1.0) if r.get("t_50", -1.0) > 0 else "N/A"
		var s100 = "%.2fs" % r.get("t_100", -1.0) if r.get("t_100", -1.0) > 0 else "N/A"
		var s_spd = "%.1f km/h" % r.get("max_spd", 0.0)
		print("%-18s | %-8s | %-8s | %-12s" % [c_id, s50, s100, s_spd])
	print("===================================================================\n")
