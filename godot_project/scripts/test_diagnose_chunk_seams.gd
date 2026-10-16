extends SceneTree

func _init():
	var packed = load("res://scenes/Main.tscn")
	var main = packed.instantiate()
	root.add_child(main)
	
	var road_gen = main.get_node("RoadGenerator")
	road_gen.update_generation(600.0)
	
	print("\n=== ACTIVE CHUNKS AUDIT ===")
	for i in range(road_gen.active_chunks.size()):
		var c = road_gen.active_chunks[i]
		var pts = c.points
		var p_first = pts[0]
		var p_last = pts[pts.size() - 1]
		print("Chunk %d: Z [%.1f -> %.1f] | First: (x=%.4f, y=%.4f, ang=%.4f) | Last: (x=%.4f, y=%.4f, ang=%.4f)" % [
			i, c.start_z, c.end_z,
			p_first.x, p_first.y, p_first.angle,
			p_last.x, p_last.y, p_last.angle
		])
		if i > 0:
			var prev_c = road_gen.active_chunks[i - 1]
			var prev_last = prev_c.points[prev_c.points.size() - 1]
			var dx = abs(p_first.x - prev_last.x)
			var dy = abs(p_first.y - prev_last.y)
			var dz = abs(p_first.z - prev_last.z)
			var da = abs(p_first.angle - prev_last.angle)
			if dx > 0.001 or dy > 0.001 or dz > 0.001 or da > 0.001:
				print("  >>> DISCONTINUITY AT JUNCTION Z=%.1f! dx=%.4f, dy=%.4f, dz=%.4f, da=%.4f" % [
					c.start_z, dx, dy, dz, da
				])
			else:
				print("  >>> Chunk %d to %d is CONTINUOUS at Z=%.1f" % [i-1, i, c.start_z])
	
	quit(0)
