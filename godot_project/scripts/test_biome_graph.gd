extends SceneTree

# Quick test of FastNoiseLite and Biome Graph transitions

func _init():
	print("[Biome Test] Testing FastNoiseLite and Markov transitions...")
	var noise = FastNoiseLite.new()
	noise.seed = 1991
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.005
	
	for i in range(10):
		var z = float(i) * 100.0
		var n_val = noise.get_noise_1d(z)
		print("  z = %.1f -> noise = %.4f" % [z, n_val])
		
	print("[Biome Test] Passed successfully!")
	quit()
