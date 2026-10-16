extends SceneTree

func _init():
	print("--- INSPEZIONE DETTAGLIATA NUOVI MODELLI 3D ---")
	var models = [
		{"id": "porsche_930_turbo", "path": "res://models/free_1975_porsche_911_930_turbo.glb"},
		{"id": "porsche_911_carrera4s", "path": "res://models/free_porsche_911_carrera_4s.glb"},
		{"id": "lamborghini_countach_lpi800", "path": "res://models/2021_lamborghini_countach_lpi_800-4.glb"}
	]
	
	for m in models:
		print("\n==================================================")
		print("ANALISI: ", m.id)
		var gltf_doc = GLTFDocument.new()
		var gltf_state = GLTFState.new()
		var err = gltf_doc.append_from_file(m.path, gltf_state)
		if err != OK:
			print("  ERRORE caricamento: ", err)
			continue
			
		var root = gltf_doc.generate_scene(gltf_state)
		root_node_add(root)
		
		var total_aabb: AABB = AABB()
		var has_aabb = false
		var mesh_nodes = []
		
		var stack = [root]
		while stack.size() > 0:
			var curr = stack.pop_back()
			if curr is MeshInstance3D and curr.mesh:
				mesh_nodes.append(curr.name)
				var maabb = curr.global_transform * curr.get_aabb()
				if not has_aabb:
					total_aabb = maabb
					has_aabb = true
				else:
					total_aabb = total_aabb.merge(maabb)
			for child in curr.get_children():
				stack.push_back(child)
				
		print("  Meshes trovate: ", mesh_nodes.size())
		print("  Nomi nodi mesh (primi 8): ", mesh_nodes.slice(0, 8))
		print("  AABB Min: ", total_aabb.position)
		print("  AABB Max: ", total_aabb.end)
		print("  Size (X, Y, Z): ", total_aabb.size)
		print("  Center: ", total_aabb.get_center())
		
		# Determina asse lunghezza, larghezza, altezza
		var sx = total_aabb.size.x
		var sy = total_aabb.size.y
		var sz = total_aabb.size.z
		print("  Asse massimo (probabile lunghezza auto): ", max(sx, max(sy, sz)))
		
		root.queue_free()
		
	quit(0)

func root_node_add(n: Node):
	root.add_child(n)
