extends SceneTree

func _init():
	print("--- INSPEZIONE DIMENSIONI E ORIENTAMENTO FIAT 127 GLB ---")
	var glb_path = "res://models/fiat_127.glb"
	var gltf_doc = GLTFDocument.new()
	var gltf_state = GLTFState.new()
	var err = gltf_doc.append_from_file(glb_path, gltf_state)
	if err != OK:
		print("Errore caricamento")
		quit(1)
		return
		
	var root = gltf_doc.generate_scene(gltf_state)
	var total_aabb: AABB = AABB()
	var has_aabb = false
	
	for child in root.get_children():
		if child is MeshInstance3D and child.mesh:
			var maabb = child.transform * child.get_aabb()
			print("Nodo: ", child.name, " AABB: pos=", maabb.position, " size=", maabb.size)
			if not has_aabb:
				total_aabb = maabb
				has_aabb = true
			else:
				total_aabb = total_aabb.merge(maabb)
				
	print("\n=== AABB COMPLESSIVO MODELLO ===")
	print("Min: ", total_aabb.position)
	print("Max: ", total_aabb.end)
	print("Size (Lunghezza/Altezza/Larghezza): ", total_aabb.size)
	print("Centro: ", total_aabb.get_center())
	quit(0)
