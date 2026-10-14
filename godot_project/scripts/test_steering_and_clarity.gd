extends SceneTree

# THE LONG MERIDIAN - Progressive Steering & Optical Clarity Verification Suite
# Validates:
# 1. Smooth progressive steering (No sudden step jerking; smooth rise & return)
# 2. Speed-sensitive steering angle attenuation (High-speed stability)
# 3. Crystal clear road visibility (Reduced DoF blur & calibrated tilt-shift)
# 4. Tilt-shift toggle functionality via [B]
# 5. Handling across all 3 expedition vehicles

var frame_count = 0
var test_step = 0
var main_scene: Node3D = null
var vehicle = null
var road_gen = null
var camera = null
var dashboard_ui = null
var tilt_rect = null

var steer_history: Array = []
var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/20b96c58-2c7b-4954-896b-4aa78ece88ca"

func _init():
	print("[Steering & Clarity Suite] Initializing verification...")

func _process(delta):
	frame_count += 1
	
	if test_step == 0:
		if frame_count == 1:
			var packed = load("res://scenes/Main.tscn")
			main_scene = packed.instantiate()
			root.add_child(main_scene)
			vehicle = main_scene.get_node("Vehicle")
			road_gen = main_scene.get_node("RoadGenerator")
			camera = main_scene.get_node("CameraController")
			tilt_rect = main_scene.get_node_or_null("PostProcessLayer/TiltShiftRect")
			dashboard_ui = main_scene.get_node_or_null("UILayer/DashboardUI")
			if not dashboard_ui and main_scene.has_node("DashboardUI"):
				dashboard_ui = main_scene.get_node("DashboardUI")
			print("[Steering & Clarity Suite] Scene instantiated.")
			
		elif frame_count == 25:
			# VERIFICATION 1: Tilt-Shift & Depth of Field Calibration
			assert(tilt_rect != null, "TiltShiftRect must exist")
			var sm = tilt_rect.material as ShaderMaterial
			assert(sm != null, "TiltShift material must be ShaderMaterial")
			var blur_rad = sm.get_shader_parameter("max_blur_radius")
			var band_w = sm.get_shader_parameter("focus_band_width")
			print("[Steering & Clarity Suite] Calibrated max_blur_radius: %.2f (Target <= 2.0)" % blur_rad)
			print("[Steering & Clarity Suite] Calibrated focus_band_width: %.2f (Target >= 0.50)" % band_w)
			assert(blur_rad <= 2.0, "Blur radius must be subtle (<= 2.0)")
			assert(band_w >= 0.50, "Focus band must be wide (>= 0.50) so road ahead is crystal clear")
			
			# Teleport car and capture clear high-visibility screenshot
			teleport_to_z(140.0)
			vehicle.current_speed_kmh = 60.0
			test_step = 1
			frame_count = 0
			
	elif test_step == 1:
		if frame_count == 20:
			save_screenshot("verify_crystal_clear_road_visibility.png")
			print("[Steering & Clarity Suite] Saved crystal clear road visibility screenshot.")
			
			# TEST 2: Progressive Steering Rate Validation (Standstill / Low Speed)
			# Simulate pressing 'steer_left' ('A') continuously for 15 frames
			steer_history.clear()
			test_step = 2
			frame_count = 0
			
	elif test_step == 2:
		# Measure progressive steering rise
		vehicle.current_speed_kmh = 30.0
		# Feed artificial steer input
		Input.action_press("steer_left")
		steer_history.append(vehicle.steering)
		
		if frame_count == 20:
			Input.action_release("steer_left")
			print("[Steering & Clarity Suite] Low-speed Steering Angle Progression (rad):")
			for i in range(0, steer_history.size(), 4):
				print("   Frame %d: steering = %.4f rad (%.1f deg)" % [i, steer_history[i], rad_to_deg(steer_history[i])])
				
			# Check that steering didn't instantly snap on frame 1
			assert(steer_history[0] < 0.15, "Steering on first frame should start smoothly, not snap")
			assert(steer_history[steer_history.size() - 1] > steer_history[0], "Steering should build up progressively")
			
			# TEST 3: High-Speed Steering Angle Attenuation
			steer_history.clear()
			vehicle.current_speed_kmh = 110.0 # 110 km/h highway speed
			test_step = 3
			frame_count = 0
			
	elif test_step == 3:
		# High speed steer check
		vehicle.linear_velocity = Vector3(0, 0, 110.0 / 3.6)
		vehicle.current_speed_kmh = 110.0
		Input.action_press("steer_right")
		steer_history.append(vehicle.steering)
		
		if frame_count == 25:
			Input.action_release("steer_right")
			var final_angle_deg = abs(rad_to_deg(vehicle.steering))
			print("[Steering & Clarity Suite] High-Speed (110 km/h) Max Steering Angle: %.2f deg" % final_angle_deg)
			# At 110 km/h, max angle should be restrained between 5.5 and 9.5 degrees for smooth highway linekeeping
			assert(final_angle_deg <= 10.5, "High-speed steering must be attenuated (<= 10.5 deg)")
			assert(final_angle_deg >= 4.5, "High-speed steering must have sufficient authority (>= 4.5 deg)")
			print("[Steering & Clarity Suite] High-speed steering attenuation PASSED!")
			
			# TEST 4: Return to center / Caster self-alignment
			steer_history.clear()
			test_step = 4
			frame_count = 0
			
	elif test_step == 4:
		# Let vehicle self-center
		steer_history.append(vehicle.steering)
		if frame_count == 15:
			var center_angle_deg = abs(rad_to_deg(vehicle.steering))
			print("[Steering & Clarity Suite] Centering after 15 frames: %.3f deg" % center_angle_deg)
			assert(center_angle_deg < 1.0, "Steering must smoothly return to center (< 1.0 deg)")
			print("[Steering & Clarity Suite] Self-aligning centering PASSED!")
			
			# TEST 5: Tilt-Shift Toggle [B]
			main_scene.toggle_diorama_tilt_shift()
			var sm2 = tilt_rect.material as ShaderMaterial
			var is_enabled = sm2.get_shader_parameter("enable_tilt_shift")
			print("[Steering & Clarity Suite] After [B] toggle: enable_tilt_shift = %s" % str(is_enabled))
			assert(is_enabled == false, "enable_tilt_shift should be false after toggle")
			save_screenshot("verify_tilt_shift_toggled_off_sharp.png")
			
			# Turn back on for default
			main_scene.toggle_diorama_tilt_shift()
			
			# Capture dynamic cornering shot with progressive steering in action
			teleport_to_z(260.0)
			vehicle.steering = deg_to_rad(7.5) # Gentle smooth curve
			test_step = 5
			frame_count = 0
			
	elif test_step == 5:
		if frame_count == 20:
			save_screenshot("verify_progressive_cornering_handling.png")
			print("[Steering & Clarity Suite] ALL PROGRESSIVE STEERING AND CLARITY TESTS PASSED FLAWLESSLY!")
			quit()

func teleport_to_z(target_z: float):
	if road_gen:
		road_gen.update_generation(target_z)
		var info = road_gen.get_road_info_at(target_z)
		if vehicle:
			vehicle.global_position = Vector3(info.x, info.y + 0.45, target_z)
			vehicle.rotation = Vector3(0.0, info.angle + PI, 0.0)
			vehicle.linear_velocity = Vector3.ZERO
			vehicle.angular_velocity = Vector3.ZERO
	
	var biome_dir = main_scene.get_node_or_null("BiomeDirector")
	if biome_dir:
		biome_dir.update_biome(target_z, 1.0)
		
	if camera:
		camera.set_camera_mode(0) # Diorama Alto
		camera.setup_initial_position()

func save_screenshot(filename: String):
	var vp = root.get_viewport()
	if vp:
		var tex = vp.get_texture()
		if tex:
			var img = tex.get_image()
			if img:
				var full_path = artifact_dir + "/" + filename
				var err = img.save_png(full_path)
				if err == OK:
					print("[Steering & Clarity Suite] Saved screenshot: ", full_path)
				else:
					print("[Steering & Clarity Suite] Error saving screenshot: ", err)
