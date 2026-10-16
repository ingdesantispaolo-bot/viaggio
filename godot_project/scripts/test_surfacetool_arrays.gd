@tool
extends SceneTree

func _init():
	var box = BoxMesh.new()
	box.subdivide_width = 4
	box.subdivide_height = 4
	box.subdivide_depth = 4
	
	var st = SurfaceTool.new()
	st.create_from(box, 0)
	var am: ArrayMesh = st.commit()
	
	var arrays = am.surface_get_arrays(0)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	print("[TEST] Verts count:", verts.size())
	
	# Displace one vertex
	verts[0] += Vector3(0.1, 0.2, 0.3)
	arrays[Mesh.ARRAY_VERTEX] = verts
	
	var st2 = SurfaceTool.new()
	st2.create_from_arrays(arrays)
	st2.generate_normals()
	var new_mesh = st2.commit()
	print("[TEST] Rebuilt mesh surface count:", new_mesh.get_surface_count())
	assert(new_mesh.get_surface_count() == 1, "Surface count must be 1")
	print("[TEST] PASS! SurfaceTool create_from_arrays and generate_normals succeeded!")
	quit(0)
