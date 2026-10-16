extends SceneTree

func _init():
	var CityScript = load("res://scripts/CityEnvironmentBuilder.gd")
	if CityScript == null:
		print("[-] Errore nel caricamento di CityEnvironmentBuilder.gd")
		quit(1)
		return
	var test_root = Node3D.new()
	var city_inst = CityScript.build_starting_city(test_root)
	if city_inst != null:
		print("[+] CityEnvironmentBuilder eseguito con successo!")
		print("    Nodi città generati: %d" % city_inst.get_child_count())
	else:
		print("[-] city_inst nullo")
		quit(1)
		return
	quit(0)
