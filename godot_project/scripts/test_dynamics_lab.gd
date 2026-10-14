extends SceneTree

# High-precision Vehicle Dynamics Laboratory Benchmark
# Measures 0-50, 0-100, shift points, RPM progression, and flat-ground top speed.

var frame = 0
var test_root: Node3D = null
var vehicle = null
var car_ids = ["panda_4x4", "delta_integrale", "mercedes_gwagen"]
var current_car_idx = 0

var test_time = 0.0
var t_0_50 = -1.0
var t_0_100 = -1.0
var max_speed = 0.0
var shift_events: Array = []
var prev_gear = 1

func _init():
	print("====================================================")
	print("[DYNAMICS LAB] Initializing Pure Kinematics Test Track...")
	print("====================================================")

func _process(delta):
	frame += 1
	if frame == 1:
		setup_test_track()
		start_car_test(car_ids[current_car_idx])
		return

	if not vehicle:
		quit()
		return

	test_time += delta
	Input.action_press("accelerate")
	
	var spd = vehicle.current_speed_kmh
	var gear = vehicle.current_gear
	var rpm = vehicle.engine_rpm
	
	if spd > max_speed:
		max_speed = spd
		
	if spd >= 50.0 and t_0_50 < 0:
		t_0_50 = test_time
	if spd >= 100.0 and t_0_100 < 0:
		t_0_100 = test_time
		
	if gear != prev_gear:
		shift_events.append({
			"time": test_time,
			"from_gear": prev_gear,
			"to_gear": gear,
			"speed": spd,
			"rpm": rpm
		})
		print("  -> SHIFT: %s -> %s at %.1f km/h (RPM: %d, t: %.2fs)" % [
			vehicle.VEHICLE_CATALOG[vehicle.current_model_id].gear_names[prev_gear - 1] if ("VEHICLE_CATALOG" in vehicle and "current_model_id" in vehicle) else str(prev_gear),
			vehicle.gear_name,
			spd,
			int(rpm),
			test_time
		])
		prev_gear = gear

	# Telemetry sample every 1.0 second
	if fmod(test_time, 1.0) < delta * 1.5:
		print("  [%s] t: %4.1fs | Spd: %5.1f km/h | Gear: %s | RPM: %4d | PosZ: %6.1f m" % [
			car_ids[current_car_idx], test_time, spd, vehicle.gear_name, int(rpm), vehicle.global_position.z
		])

	# Test duration per car: 26 seconds
	if test_time >= 26.0:
		print("----------------------------------------------------")
		print("=== FINAL TELEMETRY: %s ===" % car_ids[current_car_idx].to_upper())
		print("  0-50 km/h  : %s s" % (str(snappedf(t_0_50, 0.2)) if t_0_50 > 0 else "N/A"))
		print("  0-100 km/h : %s s" % (str(snappedf(t_0_100, 0.2)) if t_0_100 > 0 else "N/A"))
		print("  Max Speed  : %.1f km/h (RPM: %d in %s)" % [max_speed, int(rpm), vehicle.gear_name])
		print("  Shifts     : %d shifts recorded" % shift_events.size())
		print("----------------------------------------------------")
		
		current_car_idx += 1
		if current_car_idx < car_ids.size():
			start_car_test(car_ids[current_car_idx])
		else:
			print("====================================================")
			print("[DYNAMICS LAB] Telemetry benchmark completed successfully!")
			print("====================================================")
			quit()

func setup_test_track():
	test_root = Node3D.new()
	root.add_child(test_root)
	
	# Create a perfectly flat 4500m asphalt track with StaticBody3D collision
	var static_body = StaticBody3D.new()
	var col_shape = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(50.0, 1.0, 4500.0)
	col_shape.shape = box
	col_shape.position = Vector3(0.0, -0.5, 2000.0)
	static_body.add_child(col_shape)
	test_root.add_child(static_body)

func start_car_test(id: String):
	print("\n>>> BENCHMARKING: %s <<<" % id.to_upper())
	test_time = 0.0
	t_0_50 = -1.0
	t_0_100 = -1.0
	max_speed = 0.0
	shift_events.clear()
	prev_gear = 1
	
	if vehicle and is_instance_valid(vehicle):
		test_root.remove_child(vehicle)
		vehicle.queue_free()
		
	var vehicle_scene = load("res://scenes/Vehicle.tscn")
	vehicle = vehicle_scene.instantiate()
	test_root.add_child(vehicle)
	vehicle.global_position = Vector3(0.0, 0.35, 10.0)
	vehicle.rotation = Vector3(0.0, PI, 0.0)
	vehicle.linear_velocity = Vector3.ZERO
	vehicle.angular_velocity = Vector3.ZERO
	vehicle.apply_vehicle_model(id)
