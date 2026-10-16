extends SceneTree

var frame_count = 0
var main_scene: Node = null
var artifact_dir = "C:/Users/icopa/.gemini/antigravity-ide/brain/859cc8ab-8592-43ca-a74a-e57264cbbd86"

func _init():
	print("[Capture Seam] Avvio verifica visiva giunzione chunk Z=240m...")

func _process(delta):
	frame_count += 1
	if frame_count == 1:
		var packed = load("res://scenes/Main.tscn")
		main_scene = packed.instantiate()
		root.add_child(main_scene)
		
		# Teleport car to Z = 235m (approaching Z = 240m)
		var road_gen = main_scene.get_node_or_null("RoadGenerator")
		if road_gen:
			road_gen.update_generation(450.0)
			
		var veh = main_scene.get_node_or_null("Vehicle")
		if veh and road_gen:
			var r_info = road_gen.get_road_info_at(236.0)
			var p_tf = Transform3D(Basis(Vector3.UP, PI + r_info.angle), Vector3(r_info.x - 1.8, r_info.y + 0.40, 236.0))
			veh.global_transform = p_tf
			PhysicsServer3D.body_set_state(veh.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM, p_tf)
			PhysicsServer3D.body_set_state(veh.get_rid(), PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY, Vector3.ZERO)
			PhysicsServer3D.body_set_state(veh.get_rid(), PhysicsServer3D.BODY_STATE_ANGULAR_VELOCITY, Vector3.ZERO)
			
		# Hide UI overlays and exit garage
		main_scene.is_in_garage = false
		var ui = main_scene.get_node_or_null("StreetRodUI")
		if ui:
			ui.visible = false
			ui.set_process(false)
		var uil = main_scene.get_node_or_null("UILayer")
		if uil:
			uil.visible = false
			
	elif frame_count == 30:
		# Position camera behind car looking directly at Z = 240m seam
		var cam = main_scene.get_node_or_null("CameraController")
		var road_gen = main_scene.get_node_or_null("RoadGenerator")
		if cam and road_gen:
			cam.set_process(false)
			var r_info = road_gen.get_road_info_at(236.0)
			cam.global_position = Vector3(r_info.x - 1.8, r_info.y + 2.0, 227.0)
			var look_target = Vector3(r_info.x - 1.8, r_info.y + 0.4, 245.0)
			cam.look_at(look_target, Vector3.UP)
			
	elif frame_count == 60:
		var img = root.get_viewport().get_texture().get_image()
		var dest = artifact_dir + "/screenshot_road_seam_z240_seamless.png"
		var err = img.save_png(dest)
		if err == OK:
			print("[Screenshot Saved] -> %s" % dest)
		else:
			printerr("[Screenshot Error] Code: %d" % err)
		quit(0)
