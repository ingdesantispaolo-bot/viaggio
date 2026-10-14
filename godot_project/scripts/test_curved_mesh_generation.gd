extends SceneTree

func _init():
	print("[Curved Mesh Test] Testing SurfaceTool parametric lofting & curved geometry...")
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Create a curved hood profile: 5 lengthwise sections x 7 crosswise points
	var length_slices = 8
	var width_slices = 8
	var length = 1.8
	var width = 1.4
	
	for i in range(length_slices):
		var t_z = float(i) / float(length_slices - 1)
		var z = -0.5 - t_z * length
		# Curvature height: drooping towards the front nose
		var base_y = 0.65 - pow(t_z, 1.4) * 0.18
		
		var row_curr = []
		var row_next = []
		
		# Current row
		for j in range(width_slices):
			var t_x = float(j) / float(width_slices - 1) * 2.0 - 1.0 # -1.0 to 1.0
			var x = t_x * (width * 0.5 * (1.0 - t_z * 0.12)) # Taper inward at front
			var camber = cos(t_x * PI * 0.5) * 0.08 # Crown curve in center
			row_curr.append(Vector3(x, base_y + camber, z))
			
		# Next row
		var t_z_next = float(i + 1) / float(length_slices - 1)
		var z_next = -0.5 - t_z_next * length
		var base_y_next = 0.65 - pow(t_z_next, 1.4) * 0.18
		for j in range(width_slices):
			var t_x = float(j) / float(width_slices - 1) * 2.0 - 1.0
			var x = t_x * (width * 0.5 * (1.0 - t_z_next * 0.12))
			var camber = cos(t_x * PI * 0.5) * 0.08
			row_next.append(Vector3(x, base_y_next + camber, z_next))
			
		if i < length_slices - 1:
			for j in range(width_slices - 1):
				var p00 = row_curr[j]
				var p01 = row_curr[j + 1]
				var p10 = row_next[j]
				var p11 = row_next[j + 1]
				
				# Tri 1
				st.set_uv(Vector2(float(j)/width_slices, t_z))
				st.add_vertex(p00)
				st.set_uv(Vector2(float(j)/width_slices, t_z_next))
				st.add_vertex(p10)
				st.set_uv(Vector2(float(j+1)/width_slices, t_z))
				st.add_vertex(p01)
				
				# Tri 2
				st.set_uv(Vector2(float(j+1)/width_slices, t_z))
				st.add_vertex(p01)
				st.set_uv(Vector2(float(j)/width_slices, t_z_next))
				st.add_vertex(p10)
				st.set_uv(Vector2(float(j+1)/width_slices, t_z_next))
				st.add_vertex(p11)
				
	st.generate_normals()
	var mesh = st.commit()
	print("[Curved Mesh Test] Mesh created successfully! Vertex count: ", mesh.get_faces().size())
	quit()
