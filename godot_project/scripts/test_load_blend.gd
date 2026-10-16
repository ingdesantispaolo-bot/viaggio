extends SceneTree

func _init():
	print("--- TEST CARICAMENTO MODELLO 127 ---")
	var paths = [
		"res://models/Fiat_127.blend",
		"res://models/fiat_127.blend",
		"res://models/fiat_127.glb",
		"res://models/Fiat_127.glb",
		"res://models/fiat_127.gltf"
	]
	for p in paths:
		var exists = ResourceLoader.exists(p)
		print("ResourceLoader.exists('", p, "') = ", exists)
		if exists:
			var res = load(p)
			print("  -> Caricato con successo: ", res)
			if res is PackedScene:
				var node = res.instantiate()
				print("  -> Instanziato nodo: ", node.name, " con ", node.get_child_count(), " figli.")
	quit(0)
