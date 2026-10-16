@tool
extends SceneTree

const RoadGenerator = preload("res://scripts/RoadGenerator.gd")
const VehicleController = preload("res://scripts/VehicleController.gd")

func _init():
	print("[FISICA URTI] Test dinamica guardrail, attrito di strisciamento e assorbimento urto...")
	
	# Crea una barriera guardrail statica identica a RoadGenerator
	var root_3d = Node3D.new()
	root.add_child(root_3d)
	
	var barrier_body = StaticBody3D.new()
	barrier_body.name = "GuardrailTestBarrier"
	var barrier_mat = PhysicsMaterial.new()
	barrier_mat.friction = 0.04 # Anti-snagging ultra-smooth sliding
	barrier_mat.bounce = 0.0
	barrier_body.physics_material_override = barrier_mat
	root_3d.add_child(barrier_body)
	
	# Piano stradale (supporto ruote e attrito asfalto)
	var road_body = StaticBody3D.new()
	road_body.name = "RoadGround"
	var road_col = CollisionShape3D.new()
	var road_box = BoxShape3D.new()
	road_box.size = Vector3(20.0, 0.50, 60.0)
	road_col.shape = road_box
	road_col.position = Vector3(0.0, -0.25, 0.0)
	road_body.add_child(road_col)
	root_3d.add_child(road_body)
	
	# Barriera lungo Z da Z=-20 a Z=+20 a X=2.0
	var col = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(0.26, 0.88, 40.0)
	col.shape = box
	col.position = Vector3(2.0, 0.44, 0.0)
	barrier_body.add_child(col)
	
	# Crea il veicolo istanziando Vehicle.tscn
	var vehicle_scene = load("res://scenes/Vehicle.tscn")
	var vehicle = vehicle_scene.instantiate()
	root_3d.add_child(vehicle)
	
	# Posiziona l'auto a Z=-10, X=1.45 (molto vicina alla barriera), diretta a 15 gradi verso la barriera (urto di striscio ad alta velocità)
	vehicle.global_position = Vector3(1.50, 0.45, -10.0)
	vehicle.global_rotation = Vector3(0.0, deg_to_rad(15.0), 0.0)
	
	# Applica velocità iniziale di 70 km/h (19.44 m/s) incidente contro il guardrail
	var v_init = Vector3(sin(deg_to_rad(15.0)), 0.0, cos(deg_to_rad(15.0))) * 19.44
	vehicle.linear_velocity = v_init
	
	print("[FISICA URTI] Auto lanciata contro guardrail a 70 km/h con angolo di 15 gradi...")
	print("[FISICA URTI] Velocità iniziale:", vehicle.linear_velocity, " | Magnitudo (km/h):", vehicle.linear_velocity.length() * 3.6)
	
	# Simula 60 step fisici (1 secondo di collisione e strisciamento)
	var max_x = vehicle.global_position.x
	var min_x = vehicle.global_position.x
	var did_penetrate = false
	var did_bounce_wildly = false
	var did_slide = false
	
	for step in range(60):
		await physics_frame
		
		var cur_pos = vehicle.global_position
		var cur_v = vehicle.linear_velocity
		max_x = max(max_x, cur_pos.x)
		min_x = min(min_x, cur_pos.x)
		
		# La faccia interna del guardrail è a X = 2.0 - 0.13 = 1.87
		# L'auto ha semi-larghezza ~0.60, quindi il contatto avviene a X ~ 1.27
		# Se penetra oltre X=2.15, c'è compenetrazione/tunneling
		if cur_pos.x > 2.15:
			did_penetrate = true
			
		# Se rimbalza violentemente indietro con velocità laterale X < -10 m/s (effetto flipper elastico)
		if cur_v.x < -8.0:
			did_bounce_wildly = true
			
		# Se prosegue in avanti lungo Z mantenendo lo strisciamento
		if cur_v.z > 8.0 and cur_pos.z > -5.0:
			did_slide = true
			
	print("[FISICA URTI] Risultati simulazione dopo 1s:")
	print("  -> Posizione finale:", vehicle.global_position)
	print("  -> Velocità finale:", vehicle.linear_velocity, " (km/h: ", vehicle.linear_velocity.length() * 3.6, ")")
	print("  -> Penetrazione/Tunneling:", did_penetrate)
	print("  -> Rimbalzo violento/Flipper elastico:", did_bounce_wildly)
	print("  -> Strisciamento fluido lungo barriera:", did_slide)
	
	assert(!did_penetrate, "L'auto non deve penetrare o oltrepassare il guardrail!")
	assert(!did_bounce_wildly, "L'auto non deve rimbalzare elasticamente come una pallina da flipper!")
	assert(did_slide, "L'auto deve scivolare fluidamente lungo il guardrail!")
	
	print("[FISICA URTI] PASS! Fisica delle collisioni coerente, anelastica e anti-incastro verificata con successo!")
	quit(0)
