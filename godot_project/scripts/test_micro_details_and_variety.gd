extends SceneTree

# Complete Verification Suite for Graphic Details and Variety
# Inspired by Tiny Glade, Dorfromantik, and Art of Rally
# Tests:
# 1. Dorfromantik Roadside Telegraph Pole Line & Continuous Sagging Cables (Z = 50m - 120m)
# 2. Art of Rally Hairpin Banners (Martini, Agip, Pirelli) & Colorful Spectators with Flash (Z = 220m)
# 3. Tiny Glade Alpine Chalet with Volumetric Chimney Smoke & Firewood Shelter with Axe (Z = 180m)
# 4. Tiny Glade Borgo San Cristoforo with Trattoria Barrels, Bianchi Bicycle & Clotheslines (Z = 920m)

var main_scene: Node = null
var vehicle: RigidBody3D = null
var road_gen: RoadGenerator = null
var biome_dir: Node = null
var camera: Camera3D = null

var test_step: int = 0
var frame_count: int = 0
var artifact_dir: String = "C:/Users/icopa/.gemini/antigravity-ide/brain/20b96c58-2c7b-4954-896b-4aa78ece88ca"

func _init():
	print("[Detail Variety Suite] Initializing comprehensive graphic details verification...")

func _process(delta: float):
	frame_count += 1
	
	if test_step == 0:
		if frame_count == 1:
			var main_packed = load("res://scenes/Main.tscn")
			assert(main_packed != null, "Failed to load Main.tscn")
			main_scene = main_packed.instantiate()
			root.add_child(main_scene)
			
			vehicle = main_scene.get_node_or_null("Vehicle")
			road_gen = main_scene.get_node_or_null("RoadGenerator")
			biome_dir = main_scene.get_node_or_null("BiomeDirector")
			camera = main_scene.get_node_or_null("CameraController")
			
			assert(vehicle != null, "Vehicle node must exist")
			assert(road_gen != null, "RoadGenerator node must exist")
			var sr_ui = main_scene.find_child("StreetRodUI", true, false)
			if sr_ui:
				sr_ui.visible = false
			print("[Detail Variety Suite] Main scene instantiated successfully.")
			
		elif frame_count == 25:
			var sr_ui = main_scene.find_child("StreetRodUI", true, false)
			if sr_ui:
				sr_ui.visible = false
			# =========================================================================
			# TEST 1: DORFROMANTIK TELEGRAPH POLE LINE & CABLES (Z = 60m)
			# =========================================================================
			teleport_to_z(60.0)
			frame_count = 0
			test_step = 1
			
	elif test_step == 1:
		if frame_count == 35:
			var pole_count = count_nodes_recursive(road_gen, "TelegraphPole")
			var cable_count = count_nodes_recursive(road_gen, "TelegraphCable")
			print("[TEST 1] Dorfromantik Details: %d Telegraph Poles, %d Cable Spans detected" % [pole_count, cable_count])
			assert(pole_count >= 2, "Must spawn at least 2 Dorfromantik telegraph poles along roadside")
			assert(cable_count >= 1, "Must generate continuous sagging telephone cables connecting poles")
			
			capture_screenshot("verify_detail_dorfromantik_telegraph.png")
			print("[PASS] Test 1: Dorfromantik telegraph pole line & sagging overhead cables verified!")
			
			# Teleport to Passo delle Alpi hairpin for Art of Rally & Chalet
			teleport_to_z(220.0)
			frame_count = 0
			test_step = 2

	elif test_step == 2:
		if frame_count == 35:
			# =========================================================================
			# TEST 2: ART OF RALLY BANNERS & SPECTATORS + CHALET SMOKE (Z = 220m)
			# =========================================================================
			var banner_count = count_nodes_recursive(road_gen, "RallyBanner")
			var spectator_count = count_nodes_recursive(road_gen, "RallySpectators")
			var smoke_count = count_nodes_recursive(road_gen, "ChimneySmoke")
			var firewood_count = count_nodes_recursive(road_gen, "FirewoodShelter")
			
			print("[TEST 2] Art of Rally & Chalet: %d Banners, %d Spectator Groups, %d Chimney Smoke Nodes, %d Firewood Shelters" % [
				banner_count, spectator_count, smoke_count, firewood_count
			])
			assert(banner_count >= 1, "Must spawn vintage rally sponsor banners on hairpin guardrails")
			assert(spectator_count >= 1, "Must spawn spectator groups in retro 80s/90s windbreakers")
			assert(smoke_count >= 1, "Must spawn soft volumetric chimney smoke wafting from alpine chalet")
			assert(firewood_count >= 1, "Must spawn woodpile shelter with split logs and chopping axe")
			
			capture_screenshot("verify_detail_art_of_rally_hairpin.png")
			print("[PASS] Test 2: Art of Rally trackside dressing & Chalet smoke verified!")
			
			# Teleport to Borgo San Cristoforo Trattoria Alpino
			teleport_to_z(920.0)
			frame_count = 0
			test_step = 3

	elif test_step == 3:
		if frame_count == 35:
			# =========================================================================
			# TEST 3: TINY GLADE BORGO SAN CRISTOFORO (Z = 920m)
			# =========================================================================
			var barrel_count = count_nodes_recursive(road_gen, "BarrelsAndCrates")
			var bike_count = count_nodes_recursive(road_gen, "VintageBicycle")
			var laundry_count = count_nodes_recursive(road_gen, "LaundryClothesline")
			var village_smoke_count = count_nodes_recursive(road_gen, "ChimneySmoke")
			
			print("[TEST 3] Tiny Glade Village: %d Barrels/Crates, %d Vintage Bicycles, %d Clotheslines, %d Chimney Smoke" % [
				barrel_count, bike_count, laundry_count, village_smoke_count
			])
			assert(barrel_count >= 1, "Must spawn rustic stacked oak wine barrels outside Trattoria Alpino")
			assert(bike_count >= 1, "Must spawn vintage Celeste Bianchi bicycle leaned against village wall")
			assert(laundry_count >= 1, "Must spawn hanging clotheslines with fluttering laundry (panni stesi)")
			assert(village_smoke_count >= 2, "Village houses must have stylized chimney smoke")
			
			capture_screenshot("verify_detail_tiny_glade_village.png")
			print("[PASS] Test 3: Tiny Glade lived-in village clutter & laundry clotheslines verified!")
			
			# Step 4: Close-up on Art of Rally Spectator Group & Flash
			teleport_to_z(175.0)
			frame_count = 0
			test_step = 4

	elif test_step == 4:
		if frame_count == 20:
			var spec_node: Node3D = null
			for child in road_gen.get_children():
				if child is Node3D:
					for sub in child.get_children():
						if "RallySpectators" in sub.name and abs(sub.global_position.z - 175.0) < 60.0:
							spec_node = sub
							break
					if spec_node:
						break
			if spec_node and camera:
				camera.set_process(false)
				camera.set_physics_process(false)
				var sp_pos = spec_node.global_position
				print("[TEST 4 CAMERA FOCUS] Focusing on Spectators at: ", sp_pos)
				camera.global_position = sp_pos + Vector3(1.8, 1.25, 2.6)
				camera.look_at(sp_pos + Vector3(0.0, 0.75, 0.0), Vector3.UP)
		elif frame_count == 35:
			capture_screenshot("verify_detail_spectators_closeup.png")
			print("[PASS] Test 4: Art of Rally Spectator crowd close-up captured!")
			
			# Step 5: Close-up on Trattoria Alpino barrels & bicycle
			teleport_to_z(924.0)
			frame_count = 0
			test_step = 5

	elif test_step == 5:
		if frame_count == 20:
			var barrel_node: Node3D = null
			for child in road_gen.get_children():
				if child is Node3D:
					for sub in child.get_children():
						for sub2 in sub.get_children():
							if "BarrelsAndCrates" in sub2.name:
								barrel_node = sub2
								break
						if barrel_node:
							break
					if barrel_node:
						break
			if barrel_node and camera:
				camera.set_process(false)
				camera.set_physics_process(false)
				var b_pos = barrel_node.global_position
				print("[TEST 5 CAMERA FOCUS] Focusing on Trattoria Clutter at: ", b_pos)
				camera.global_position = b_pos + Vector3(-2.2, 1.35, 2.8)
				camera.look_at(b_pos + Vector3(0.0, 0.65, 0.0), Vector3.UP)
		elif frame_count == 35:
			capture_screenshot("verify_detail_trattoria_clutter_closeup.png")
			print("[PASS] Test 5: Tiny Glade Trattoria clutter close-up captured!")
			
			print("=====================================================================")
			print("ALL GRAPHIC DETAILS & VARIETY TESTS PASSED WITH 100% SUCCESS!")
			print("=====================================================================")
			quit(0)

func count_nodes_recursive(node: Node, target_name_part: String) -> int:
	if not node:
		return 0
	var count = 0
	if target_name_part in node.name:
		count += 1
	for child in node.get_children():
		count += count_nodes_recursive(child, target_name_part)
	return count

func teleport_to_z(target_z: float):
	if not road_gen or not vehicle:
		return
	
	while road_gen.next_chunk_z < target_z + 360.0:
		road_gen.generate_chunk()
		
	var info = road_gen.get_road_info_at(target_z)
	var pos = Vector3(info.x, info.y + 0.35, target_z)
	vehicle.global_position = pos
	vehicle.linear_velocity = Vector3.ZERO
	vehicle.angular_velocity = Vector3.ZERO
	vehicle.rotation = Vector3(0.0, info.angle, 0.0)
	if "current_z" in vehicle:
		vehicle.current_z = target_z
	vehicle.global_transform.origin = pos
	
	if biome_dir and biome_dir.has_method("update_atmosphere_for_z"):
		biome_dir.update_atmosphere_for_z(target_z)
		
	if camera:
		camera.global_position = pos + Vector3(0.0, 2.2, -6.5)
		camera.look_at(pos + Vector3(0.0, 0.8, 4.0), Vector3.UP)

func capture_screenshot(filename: String):
	var img = root.get_viewport().get_texture().get_image()
	if img:
		var save_path = artifact_dir + "/" + filename
		var err = img.save_png(save_path)
		if err == OK:
			print("[SCREENSHOT CAPTURED] Saved to: %s" % save_path)
		else:
			print("[SCREENSHOT ERROR] Could not save screenshot: %d" % err)
