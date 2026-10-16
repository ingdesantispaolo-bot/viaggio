extends SceneTree

func _init():
	print("--- TEST RUNTIME GLTFDocument LOAD ---")
	var glb_path = "res://models/fiat_127.glb"
	var gltf_doc = GLTFDocument.new()
	var gltf_state = GLTFState.new()
	
	var err = gltf_doc.append_from_file(glb_path, gltf_state)
	print("gltf_doc.append_from_file result: ", err)
	if err == OK:
		var root_node = gltf_doc.generate_scene(gltf_state)
		print("SUCCESS! Scene generated: ", root_node)
		print("Child count: ", root_node.get_child_count())
		for i in range(root_node.get_child_count()):
			var child = root_node.get_child(i)
			print("  - Child [", i, "]: ", child.name, " (", child.get_class(), ")")
	else:
		print("FAILED to append from file, code: ", err)
	quit(0)
