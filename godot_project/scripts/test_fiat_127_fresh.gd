extends SceneTree

var frame = 0
var main_scene = null
var vehicle = null

func _init():
	print("Checking 127 launch from fresh start...")

func _process(delta):
	frame += 1
	if frame == 1:
		var packed = load("res://scenes/Main.tscn")
		main_scene = packed.instantiate()
		root.add_child(main_scene)
		vehicle = main_scene.get_node("Vehicle")
		vehicle.apply_vehicle_model("fiat_127")
		return

	if frame < 10:
		# Let physics settle
		return

	# Apply throttle
	Input.action_press("accelerate")
	var t = (frame - 10) * delta
	var spd = vehicle.current_speed_kmh
	if frame % 30 == 0:
		print("t: %.2fs | Spd: %.1f km/h | Gear: %s | RPM: %d | WheelFL force: %.1f" % [
			t, spd, vehicle.gear_name, int(vehicle.engine_rpm), vehicle.wheel_fl.engine_force
		])
	if spd >= 100.0 or t >= 20.0:
		print("FINAL FIAT 127 0-100: %.2fs (Max Spd: %.1f)" % [t, spd])
		quit()
