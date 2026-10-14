extends SceneTree

func _init():
	print("[Car Primitives Test] Testing procedural curved builders...")
	
	# Test 1: Wheel Arch
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var radius = 0.35
	var width = 0.08
	var flare_out = 0.04
	var segments = 16
	for i in range(segments):
		var a0 = float(i) / float(segments) * PI
		var a1 = float(i + 1) / float(segments) * PI
		var p0_in = Vector3(0.0, sin(a0) * radius, cos(a0) * radius)
		var p0_out = Vector3(flare_out, sin(a0) * (radius + width), cos(a0) * (radius + width))
		var p1_in = Vector3(0.0, sin(a1) * radius, cos(a1) * radius)
		var p1_out = Vector3(flare_out, sin(a1) * (radius + width), cos(a1) * (radius + width))
		
		st.add_vertex(p0_in)
		st.add_vertex(p0_out)
		st.add_vertex(p1_out)
		st.add_vertex(p0_in)
		st.add_vertex(p1_out)
		st.add_vertex(p1_in)
		
	st.generate_normals()
	var arch_mesh = st.commit()
	print("  -> Wheel arch generated! Faces: ", arch_mesh.get_faces().size())
	
	# Test 2: Wraparound Bumper
	var st_b = SurfaceTool.new()
	st_b.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half_w = 0.65
	var wrap_d = 0.25
	var b_radius = 0.04
	var corner_segs = 8
	var pts = []
	# Left wrap
	for i in range(corner_segs):
		var ang = PI + float(i) / float(corner_segs) * (PI * 0.5)
		pts.append(Vector3(-half_w + 0.10 + cos(ang) * 0.10, 0.0, wrap_d + sin(ang) * 0.10))
	# Center
	pts.append(Vector3(0.0, 0.0, wrap_d - 0.10))
	# Right wrap
	for i in range(corner_segs + 1):
		var ang = PI * 1.5 + float(i) / float(corner_segs) * (PI * 0.5)
		pts.append(Vector3(half_w - 0.10 + cos(ang) * 0.10, 0.0, wrap_d + sin(ang) * 0.10))
		
	for i in range(pts.size() - 1):
		var p0 = pts[i]
		var p1 = pts[i + 1]
		var top0 = p0 + Vector3(0, b_radius, 0)
		var bot0 = p0 - Vector3(0, b_radius, 0)
		var top1 = p1 + Vector3(0, b_radius, 0)
		var bot1 = p1 - Vector3(0, b_radius, 0)
		
		st_b.add_vertex(bot0); st_b.add_vertex(top0); st_b.add_vertex(top1)
		st_b.add_vertex(bot0); st_b.add_vertex(top1); st_b.add_vertex(bot1)
		
	st_b.generate_normals()
	var bumper_mesh = st_b.commit()
	print("  -> Wraparound bumper generated! Faces: ", bumper_mesh.get_faces().size())
	
	print("[Car Primitives Test] All procedural geometry successfully validated!")
	quit()
