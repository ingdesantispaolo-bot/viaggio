@tool
extends SceneTree

const VehicleModelBuilder = preload("res://scripts/VehicleModelBuilder.gd")
const VehicleCrashSystem = preload("res://scripts/VehicleCrashSystem.gd")

func _init():
	print("[TEST] Inizio verifica modelli 3D e sistema deformazione urti inelastici...")
	
	# 1. Verifica caricamento materiali PBR
	VehicleModelBuilder.init_materials()
	assert(VehicleModelBuilder.mat_glass != null, "mat_glass deve esistere")
	assert(VehicleModelBuilder.mat_chrome != null, "mat_chrome deve esistere")
	
	# 2. Crea un nodo veicolo dummy
	var root = Node3D.new()
	var dummy_car = Node3D.new()
	dummy_car.name = "DummyCar"
	root.add_child(dummy_car)
	
	var model_root = Node3D.new()
	model_root.name = "ModelRenault4"
	dummy_car.add_child(model_root)
	
	var mat_body = StandardMaterial3D.new()
	mat_body.albedo_color = Color(0.2, 0.4, 0.8)
	VehicleModelBuilder.build_renault_4(model_root, mat_body)
	
	print("[TEST] Renault 4 costruita. Figli nel modello:", model_root.get_child(0).get_child_count())
	
	# 3. Test Deformazione Impatto Inelastico (urto frontale a 45 km/h)
	var contact_point = dummy_car.global_position + Vector3(0.0, 0.5, -1.5)
	VehicleCrashSystem.apply_structural_deformation(dummy_car, contact_point, 45.0, Vector3(0, 0, 1))
	
	print("[TEST] Deformazione applicata con successo senza crash!")
	print("[TEST] PASS! Tutti i controlli preliminari superati.")
	quit(0)
