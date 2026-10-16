extends SceneTree

func _init():
	var gltf_doc = GLTFDocument.new()
	var gltf_state = GLTFState.new()
	var err = gltf_doc.append_from_file("res://models/free_1975_porsche_911_930_turbo.glb", gltf_state)
	if err != OK:
		print("ERRORE: ", err)
		quit(1)
		return
	var root = gltf_doc.generate_scene(gltf_state)
	var stack = [root]
	var total_aabb = AABB()
	var first = true
	var count = 0
	while stack.size() > 0:
		var c = stack.pop_back()
		if c is MeshInstance3D and c.mesh:
			count += 1
			var a = c.get_aabb()
			# Calcola transform combinata relativa a root
			var t = root.transform.affine_inverse() * c.global_transform
			var ta = t * a
			if first:
				total_aabb = ta
				first = false
			else:
				total_aabb = total_aabb.merge(ta)
		for ch in c.get_children():
			stack.push_back(ch)
			
	print("PORSCHE 930 TURBO: meshes=", count)
	print("AABB Min: ", total_aabb.position)
	print("AABB Max: ", total_aabb.end)
	print("Size: ", total_aabb.size)
	print("Center: ", total_aabb.get_center())
	quit(0)
