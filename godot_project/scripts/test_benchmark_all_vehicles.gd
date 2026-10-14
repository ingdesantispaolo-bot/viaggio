extends SceneTree

var frame = 0
var main_scene = null
var vehicle = null
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

var car_time = 0.0
var t_0_50 = -1.0
var t_0_100 = -1.0
var max_speed = 0.0
var results = {}

func _init():
	print("[Benchmark All Vehicles] Starting full 8-car acceleration & speed benchmark...")

func _process(delta):
	frame += 1
	if frame == 1:
		var packed = load("res://scenes/Main.tscn")
		main_scene = packed.instantiate()
		root.add_child(main_scene)
		vehicle = main_scene.get_node("Vehicle")
		start_car_test(car_ids[current_car_idx])
		return

	if not vehicle:
		quit()
		return

	car_time += delta
	# Full throttle
	Input.action_press("accelerate")
	
	var spd = vehicle.current_speed_kmh
	if spd > max_speed:
		max_speed = spd
	if spd >= 50.0 and t_0_50 < 0:
		t_0_50 = car_time
	if spd >= 100.0 and t_0_100 < 0:
		t_0_100 = car_time
		
	# Run each car for up to 18 seconds (enough to reach 100 or top speed)
	if car_time >= 18.0:
		var c_id = car_ids[current_car_idx]
		results[c_id] = {
			"t_50": t_0_50,
			"t_100": t_0_100,
			"top_spd": max_speed,
			"gear": vehicle.gear_name,
			"rpm": int(vehicle.engine_rpm)
		}
		print("DONE: %s -> 0-50: %.2fs | 0-100: %s | MaxSpd: %.1f km/h" % [
			c_id,
			t_0_50,
			("%.2fs" % t_0_100 if t_0_100 > 0 else "N/A"),
			max_speed
		])
		
		current_car_idx += 1
		if current_car_idx < car_ids.size():
			start_car_test(car_ids[current_car_idx])
		else:
			print_final_summary()
			quit()

func start_car_test(id: String):
	car_time = 0.0
	t_0_50 = -1.0
	t_0_100 = -1.0
	max_speed = 0.0
	vehicle.global_position = Vector3(0.0, 0.45, 20.0)
	vehicle.rotation = Vector3(0.0, PI, 0.0)
	vehicle.linear_velocity = Vector3.ZERO
	vehicle.angular_velocity = Vector3.ZERO
	vehicle.apply_vehicle_model(id)

func print_final_summary():
	print("\n================== FULL 8-CAR TELEMETRY BENCHMARK ==================")
	print("%-18s | %-8s | %-8s | %-12s | %-6s" % ["CAR ID", "0-50", "0-100", "MAX SPD", "GEAR"])
	print("--------------------------------------------------------------------")
	for c_id in car_ids:
		var r = results.get(c_id, {})
		var s_50 = "%.2fs" % r.get("t_50", -1.0) if r.get("t_50", -1.0) > 0 else "N/A"
		var s_100 = "%.2fs" % r.get("t_100", -1.0) if r.get("t_100", -1.0) > 0 else "N/A"
		var s_spd = "%.1f km/h" % r.get("top_spd", 0.0)
		var s_gear = str(r.get("gear", ""))
		print("%-18s | %-8s | %-8s | %-12s | %-6s" % [c_id, s_50, s_100, s_spd, s_gear])
	print("====================================================================\n")
