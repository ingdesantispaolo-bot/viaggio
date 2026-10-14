extends SceneTree

# Test vehicle dynamics: acceleration, top speed, gear shifting, suspension
var frame = 0
var main_scene = null
var vehicle = null
var current_car_idx = 0
var car_ids = ["renault_4", "bmw_320_e30", "mercedes_a250"]
var car_time = 0.0
var t_0_50 = -1.0
var t_0_100 = -1.0
var max_speed = 0.0

func _init():
	print("[Vehicle Dynamics Test] Starting telemetry run for Renault 4, BMW 320i, and Mercedes A 250...")

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
	# Apply full throttle
	Input.action_press("accelerate")
	
	var spd = vehicle.current_speed_kmh
	if spd > max_speed:
		max_speed = spd
	if spd >= 50.0 and t_0_50 < 0:
		t_0_50 = car_time
	if spd >= 100.0 and t_0_100 < 0:
		t_0_100 = car_time
		
	if int(car_time * 10) % 10 == 0 and fmod(car_time, 1.0) < delta * 1.5:
		print("Car: ", car_ids[current_car_idx], " | t: ", snappedf(car_time, 0.1), "s | Spd: ", snappedf(spd, 0.1), " km/h | Gear: ", vehicle.gear_name, " | RPM: ", int(vehicle.engine_rpm), " | FL_force: ", snappedf(vehicle.wheel_fl.engine_force, 0.1), " | RL_force: ", snappedf(vehicle.wheel_rl.engine_force, 0.1))
		
	# Run each car for 6.5 seconds
	if car_time >= 6.5:
		print("=== RESULTS FOR ", car_ids[current_car_idx].to_upper(), " ===")
		print("0-50 km/h: ", (snappedf(t_0_50, 0.2) if t_0_50 > 0 else "N/A"), " s")
		print("0-100 km/h: ", (snappedf(t_0_100, 0.2) if t_0_100 > 0 else "N/A"), " s")
		print("Max Speed reached: ", snappedf(max_speed, 0.1), " km/h")
		print("========================================")
		
		current_car_idx += 1
		if current_car_idx < car_ids.size():
			start_car_test(car_ids[current_car_idx])
		else:
			print("[Vehicle Dynamics Test] Completed all tests!")
			quit()

func start_car_test(id: String):
	print(">>> STARTING TEST FOR: ", id)
	car_time = 0.0
	t_0_50 = -1.0
	t_0_100 = -1.0
	max_speed = 0.0
	vehicle.global_position = Vector3(0.0, 0.45, 20.0)
	vehicle.rotation = Vector3(0.0, PI, 0.0)
	vehicle.linear_velocity = Vector3.ZERO
	vehicle.angular_velocity = Vector3.ZERO
	vehicle.apply_vehicle_model(id)
