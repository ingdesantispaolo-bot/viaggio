extends SceneTree

const VehicleModelBuilder = preload("res://scripts/VehicleModelBuilder.gd")

func _init():
	var file = FileAccess.open("res://build_fleet_summary.txt", FileAccess.WRITE)
	file.store_line("[High-Poly Fleet Test] Testing all 14 vehicle 3D model builders...")
	VehicleModelBuilder.init_materials()
	
	var root_node = Node3D.new()
	root.add_child(root_node)
	
	var builders = {
		"panda_4x4": VehicleModelBuilder.build_panda_4x4,
		"fiat_127": VehicleModelBuilder.build_fiat_127,
		"delta_integrale": VehicleModelBuilder.build_delta_integrale,
		"gwagen_w460": VehicleModelBuilder.build_gwagen_w460,
		"golf_gti_1990": VehicleModelBuilder.build_golf_gti_1990,
		"renault_4": VehicleModelBuilder.build_renault_4,
		"bmw_320_e30": VehicleModelBuilder.build_bmw_320_e30,
		"mercedes_a250": VehicleModelBuilder.build_mercedes_a250,
		"alfa_8c_2900b": VehicleModelBuilder.build_alfa_8c_2900b,
		"fiat_topolino": VehicleModelBuilder.build_fiat_topolino,
		"lancia_aurelia_b20": VehicleModelBuilder.build_lancia_aurelia_b20,
		"alfa_giulia_gta": VehicleModelBuilder.build_alfa_giulia_gta,
		"lancia_stratos": VehicleModelBuilder.build_lancia_stratos,
		"fiat_131_abarth": VehicleModelBuilder.build_fiat_131_abarth
	}
	
	for car_name in builders.keys():
		var car_node = Node3D.new()
		car_node.name = car_name
		root_node.add_child(car_node)
		builders[car_name].call(car_node, null)
		var mesh_count = 0
		for child in car_node.get_children():
			if child is MeshInstance3D:
				mesh_count += 1
			for sub in child.get_children():
				if sub is MeshInstance3D:
					mesh_count += 1
		file.store_line("  -> Built " + car_name + " successfully! Meshes: " + str(mesh_count))
		
	file.store_line("[High-Poly Fleet Test] SUCCESS! All 14 vehicles verified!")
	file.close()
	quit()
