extends SceneTree

func _init():
	var map_script = load("res://scripts/TopographicMapControl.gd")
	if map_script == null:
		print("[-] Errore nel caricamento di TopographicMapControl.gd")
		quit(1)
		return
	var map_inst = map_script.new()
	print("[+] TopographicMapControl caricato ed istanziato con successo!")
	print("    Waypoints censiti: %d" % map_inst.WAYPOINTS.size())
	quit(0)
