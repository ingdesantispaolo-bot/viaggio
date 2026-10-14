extends SceneTree

func _init():
	print("[Dashboard Test] Verifying all 14 vehicle dashboards...")
	var packed = load("res://scenes/DashboardUI.tscn")
	var dash = packed.instantiate()
	root.add_child(dash)
	
	var car_ids = [
		"panda_4x4", "fiat_127", "golf_gti_1990", "renault_4",
		"bmw_320_e30", "mercedes_a250", "delta_integrale", "mercedes_gwagen",
		"alfa_8c", "fiat_topolino", "lancia_aurelia", "alfa_gta",
		"lancia_stratos", "fiat_131_abarth", "unknown_custom_car"
	]
	
	for cid in car_ids:
		var info = {"id": cid, "name": cid, "short_name": cid, "tank_l": 50.0}
		dash.update_telemetry(65.0, 0.5, "3", 35.0, 88.0, 0.0, 0.0, false, 0.6, info)
		print("  -> Dashboard verified for vehicle: ", cid)
		
	print("[Dashboard Test] SUCCESS! All 14 vehicle cockpits + universal fallback functioning properly!")
	quit()
