class_name BiomeGraph
extends RefCounted

# THE LONG MERIDIAN - Procedural Biome Graph & Geomorphological State Machine
# Implements seed-driven Markov transitions, atmospheric schedules, and modular biomes
# inspired by Dorfromantik, Tiny Glade & Art of Rally.

enum BiomeType {
	ALPINE_MEADOWS,   # 0: Passo delle Alpi & Dolomiti, baite, mucche al pascolo con campanacci
	GLACIAL_LAKE,     # 1: Lago Prealpino, belvedere con cannocchiale, molo, motoscafi Riva in legno
	SERVICE_OASIS,    # 2: Stazione Agip '93 / Autogrill Valico, pensilina Cane a 6 Zampe, pompe benzina
	ALPINE_VILLAGE,   # 3: Borgo Storico San Cristoforo, case in pietra, campanile romanico, fontana
	ROCKY_GORGE,      # 4: Forra dell'Appennino, gole rocciose, viadotto monumentale dei Ciclopi
	AUTUMN_LARCH,     # 5: Valico dei Larici - Mille Miglia, tornanti panoramici, legnaie
	GOLDEN_PLATEAU,   # 6: Colline Toscane & Val d'Orcia, filari di cipressi, poderi in pietra, rotoballe
	POLAR_TUNDRA,     # 7: Valico Glaciale delle Alpi - Quota 2650m (Valico del Duca, neve d'alta quota)
	TUSCAN_HILLS,     # 8: Poderi del Chianti, vigneti a spalliera, muretti a secco dorati
	COASTAL_RIVIERA   # 9: Riviera Ligure & Costiera Panoramica, pini marittimi, mare blu cobalto
}

const TRANSITIONS = {
	BiomeType.ALPINE_MEADOWS: [BiomeType.GLACIAL_LAKE, BiomeType.SERVICE_OASIS, BiomeType.ALPINE_VILLAGE, BiomeType.AUTUMN_LARCH],
	BiomeType.GLACIAL_LAKE: [BiomeType.ALPINE_MEADOWS, BiomeType.SERVICE_OASIS, BiomeType.ROCKY_GORGE],
	BiomeType.SERVICE_OASIS: [BiomeType.ALPINE_MEADOWS, BiomeType.ALPINE_VILLAGE, BiomeType.ROCKY_GORGE, BiomeType.AUTUMN_LARCH, BiomeType.GOLDEN_PLATEAU],
	BiomeType.ALPINE_VILLAGE: [BiomeType.ALPINE_MEADOWS, BiomeType.AUTUMN_LARCH, BiomeType.GOLDEN_PLATEAU, BiomeType.SERVICE_OASIS],
	BiomeType.ROCKY_GORGE: [BiomeType.AUTUMN_LARCH, BiomeType.GOLDEN_PLATEAU, BiomeType.SERVICE_OASIS],
	BiomeType.AUTUMN_LARCH: [BiomeType.SERVICE_OASIS, BiomeType.GOLDEN_PLATEAU, BiomeType.POLAR_TUNDRA, BiomeType.TUSCAN_HILLS],
	BiomeType.GOLDEN_PLATEAU: [BiomeType.ALPINE_VILLAGE, BiomeType.SERVICE_OASIS, BiomeType.TUSCAN_HILLS, BiomeType.COASTAL_RIVIERA],
	BiomeType.POLAR_TUNDRA: [BiomeType.ALPINE_MEADOWS, BiomeType.AUTUMN_LARCH],
	BiomeType.TUSCAN_HILLS: [BiomeType.GOLDEN_PLATEAU, BiomeType.COASTAL_RIVIERA, BiomeType.SERVICE_OASIS],
	BiomeType.COASTAL_RIVIERA: [BiomeType.TUSCAN_HILLS, BiomeType.GOLDEN_PLATEAU, BiomeType.SERVICE_OASIS]
}

var expedition_seed: int = 1991
var rng: RandomNumberGenerator
var segments: Array = [] # Array of Dictionary segments

func _init(seed_val: int = 1991):
	expedition_seed = seed_val
	rng = RandomNumberGenerator.new()
	rng.seed = expedition_seed
	build_expedition_route()

func build_expedition_route():
	segments.clear()
	
	# Segment 1: Passo delle Alpi & Dolomiti (0m -> 360m)
	add_segment(BiomeType.ALPINE_MEADOWS, 0.0, 360.0, {
		"name": "PASSO DELLE ALPI & DOLOMITI - QUOTA 2244M",
		"curv_factor": 1.0,
		"has_chalet": true, "has_cows": true, "has_sheep": true,
		"fog_density": 0.00028, "fog_color": Color(0.82, 0.88, 0.96),
		"sun_color": Color(1.0, 0.95, 0.88), "sun_energy": 1.28,
		"sun_angle_x": -35.0, "sun_angle_y": 140.0,
		"sky_top": Color(0.16, 0.38, 0.75), "sky_horizon": Color(0.75, 0.84, 0.94),
		"wetness": 0.10, "wind": 1.0
	})
	
	# Segment 2: Conca del Lago dei Larici & Belvedere (360m -> 660m)
	add_segment(BiomeType.GLACIAL_LAKE, 360.0, 660.0, {
		"name": "CONCA DEL LAGO DEI LARICI & BELVEDERE",
		"curv_factor": 0.9,
		"has_lake": true, "has_pier": true, "has_belvedere": true, "has_chalet": true,
		"fog_density": 0.00032, "fog_color": Color(0.80, 0.86, 0.94),
		"sun_color": Color(1.0, 0.96, 0.90), "sun_energy": 1.30,
		"sun_angle_x": -33.0, "sun_angle_y": 142.0,
		"sky_top": Color(0.18, 0.40, 0.76), "sky_horizon": Color(0.76, 0.85, 0.95),
		"wetness": 0.25, "wind": 1.1
	})
	
	# Segment 3: Oasi di Rifornimento Agip '93 (660m -> 840m)
	add_segment(BiomeType.SERVICE_OASIS, 660.0, 840.0, {
		"name": "STAZIONE AGIP '93 VALICO DELLE ALPI",
		"curv_factor": 0.7,
		"has_service": true, "has_rural": true,
		"fog_density": 0.00028, "fog_color": Color(0.84, 0.88, 0.95),
		"sun_color": Color(1.0, 0.94, 0.86), "sun_energy": 1.28,
		"sun_angle_x": -32.0, "sun_angle_y": 144.0,
		"sky_top": Color(0.18, 0.38, 0.72), "sky_horizon": Color(0.78, 0.84, 0.92),
		"wetness": 0.12, "wind": 0.95
	})
	
	# Segment 4: Borgo Storico San Cristoforo (840m -> 1140m)
	add_segment(BiomeType.ALPINE_VILLAGE, 840.0, 1140.0, {
		"name": "BORGO STORICO SAN CRISTOFORO - CORSO & PIAZZA",
		"curv_factor": 1.1,
		"has_village": true, "has_campanile": true, "has_fountain": true, "has_lanterns": true,
		"fog_density": 0.00026, "fog_color": Color(0.86, 0.88, 0.92),
		"sun_color": Color(1.0, 0.93, 0.84), "sun_energy": 1.25,
		"sun_angle_x": -30.0, "sun_angle_y": 145.0,
		"sky_top": Color(0.20, 0.38, 0.70), "sky_horizon": Color(0.80, 0.82, 0.90),
		"wetness": 0.15, "wind": 0.8
	})
	
	# Segment 5: Campagna Padana & Pascoli Alti (1140m -> 1440m)
	add_segment(BiomeType.ALPINE_MEADOWS, 1140.0, 1440.0, {
		"name": "CAMPAGNA PADANA & PASCOLI ALTI",
		"curv_factor": 1.2,
		"has_rural": true, "has_cows": true, "has_sheep": true, "has_straw_bales": true, "has_cart": true,
		"fog_density": 0.00030, "fog_color": Color(0.82, 0.88, 0.96),
		"sun_color": Color(0.98, 0.94, 0.88), "sun_energy": 1.28,
		"sun_angle_x": -32.0, "sun_angle_y": 140.0,
		"sky_top": Color(0.18, 0.40, 0.74), "sky_horizon": Color(0.76, 0.84, 0.92),
		"wetness": 0.18, "wind": 1.2
	})
	
	# Segment 6: Forra dell'Appennino & Ponte dei Ciclopi (1440m -> 3000m)
	add_segment(BiomeType.ROCKY_GORGE, 1440.0, 3000.0, {
		"name": "FORRA DELL'APPENNINO & PONTE DEI CICLOPI",
		"curv_factor": 1.45,
		"has_gorge": true, "has_bridge": true, "has_torrent": true, "has_shrine": true, "has_eagles": true,
		"is_rainy": true,
		"fog_density": 0.00065, "fog_color": Color(0.48, 0.54, 0.62),
		"sun_color": Color(0.72, 0.78, 0.86), "sun_energy": 0.45,
		"sun_angle_x": -45.0, "sun_angle_y": 135.0,
		"sky_top": Color(0.14, 0.18, 0.24), "sky_horizon": Color(0.32, 0.38, 0.44),
		"wetness": 0.95, "wind": 1.8
	})
	
	# Segment 7: Valico dei Larici - Mille Miglia & Autogrill (3000m -> 4800m)
	add_segment(BiomeType.AUTUMN_LARCH, 3000.0, 4800.0, {
		"name": "VALICO DEI LARICI - MILLE MIGLIA & TORNANTI",
		"curv_factor": 1.35,
		"has_larch": true, "has_service": true, "has_woodpiles": true, "has_cows": true, "has_logs": true,
		"fog_density": 0.00035, "fog_color": Color(0.82, 0.84, 0.80),
		"sun_color": Color(1.0, 0.92, 0.80), "sun_energy": 1.30,
		"sun_angle_x": -26.0, "sun_angle_y": 150.0,
		"sky_top": Color(0.22, 0.38, 0.62), "sky_horizon": Color(0.85, 0.72, 0.56),
		"wetness": 0.35, "wind": 1.2
	})
	
	# Segment 8: Colline Toscane & Val d'Orcia (4800m -> 5600m)
	add_segment(BiomeType.GOLDEN_PLATEAU, 4800.0, 5600.0, {
		"name": "COLLINE TOSCANE & VAL D'ORCIA - ORA D'ORO",
		"curv_factor": 0.75,
		"has_golden": true, "has_windmill": true, "has_village": true, "has_straw_bales": true, "has_cart": true,
		"fog_density": 0.00028, "fog_color": Color(0.88, 0.78, 0.70),
		"sun_color": Color(1.0, 0.88, 0.68), "sun_energy": 1.32,
		"sun_angle_x": -18.0, "sun_angle_y": 165.0,
		"sky_top": Color(0.25, 0.26, 0.52), "sky_horizon": Color(0.92, 0.64, 0.45),
		"wetness": 0.18, "wind": 0.85
	})
	
	# Segment 9: Valico Glaciale delle Alpi - Quota 2650m (5600m+)
	add_segment(BiomeType.POLAR_TUNDRA, 5600.0, 6800.0, {
		"name": "VALICO GLACIALE DELLE ALPI - QUOTA 2650M",
		"curv_factor": 0.90,
		"has_polar": true, "has_snow": true,
		"fog_density": 0.00038, "fog_color": Color(0.86, 0.92, 1.0),
		"sun_color": Color(0.92, 0.96, 1.0), "sun_energy": 1.25,
		"sun_angle_x": -14.0, "sun_angle_y": 175.0,
		"sky_top": Color(0.14, 0.24, 0.48), "sky_horizon": Color(0.80, 0.88, 0.98),
		"wetness": 0.85, "wind": 1.8
	})

func add_segment(type: BiomeType, z_start: float, z_end: float, params: Dictionary):
	params["type"] = type
	params["start_z"] = z_start
	params["end_z"] = z_end
	params["length"] = z_end - z_start
	segments.append(params)

func get_biome_at(z: float) -> Dictionary:
	# Check inside generated segments
	for seg in segments:
		if z >= seg.start_z and z < seg.end_z:
			return seg
			
	# If past the planned segments, procedural Markov expansion
	if segments.size() > 0:
		var last_seg = segments[segments.size() - 1]
		if z >= last_seg.end_z:
			return generate_next_segment(z)
			
	return segments[0] if segments.size() > 0 else {}

func generate_next_segment(target_z: float) -> Dictionary:
	while segments.size() > 0 and target_z >= segments[segments.size() - 1].end_z:
		var last_seg = segments[segments.size() - 1]
		var last_type = last_seg.type
		var possible_next = TRANSITIONS.get(last_type, [BiomeType.ALPINE_MEADOWS])
		var next_type = possible_next[rng.randi() % possible_next.size()]
		var next_start = last_seg.end_z
		var next_len = rng.randf_range(360.0, 720.0)
		var next_end = next_start + next_len
		
		var cfg = get_template_for_biome(next_type)
		add_segment(next_type, next_start, next_end, cfg)
		
	return segments[segments.size() - 1]

func get_template_for_biome(type: BiomeType) -> Dictionary:
	match type:
		BiomeType.ALPINE_MEADOWS:
			return {
				"name": "VALLE ALPINA DELLE DOLOMITI",
				"curv_factor": 1.0,
				"has_chalet": true, "has_cows": true, "has_sheep": true,
				"fog_density": 0.00028, "fog_color": Color(0.82, 0.88, 0.96),
				"sun_color": Color(1.0, 0.95, 0.88), "sun_energy": 1.28,
				"sun_angle_x": -35.0, "sun_angle_y": 140.0,
				"sky_top": Color(0.16, 0.38, 0.75), "sky_horizon": Color(0.75, 0.84, 0.94),
				"wetness": 0.10, "wind": 1.0
			}
		BiomeType.GLACIAL_LAKE:
			return {
				"name": "LAGO PREALPINO & BELVEDERE",
				"curv_factor": 0.9,
				"has_lake": true, "has_pier": true, "has_belvedere": true,
				"fog_density": 0.00032, "fog_color": Color(0.80, 0.86, 0.94),
				"sun_color": Color(1.0, 0.96, 0.90), "sun_energy": 1.30,
				"sun_angle_x": -33.0, "sun_angle_y": 142.0,
				"sky_top": Color(0.18, 0.40, 0.76), "sky_horizon": Color(0.76, 0.85, 0.95),
				"wetness": 0.25, "wind": 1.1
			}
		BiomeType.SERVICE_OASIS:
			return {
				"name": "AREA DI SERVIZIO AGIP '93",
				"curv_factor": 0.7,
				"has_service": true,
				"fog_density": 0.00028, "fog_color": Color(0.84, 0.88, 0.95),
				"sun_color": Color(1.0, 0.94, 0.86), "sun_energy": 1.28,
				"sun_angle_x": -32.0, "sun_angle_y": 144.0,
				"sky_top": Color(0.18, 0.38, 0.72), "sky_horizon": Color(0.78, 0.84, 0.92),
				"wetness": 0.12, "wind": 0.95
			}
		BiomeType.ALPINE_VILLAGE:
			return {
				"name": "BORGO STORICO APPENNINICO",
				"curv_factor": 1.1,
				"has_village": true, "has_campanile": true,
				"fog_density": 0.00026, "fog_color": Color(0.86, 0.88, 0.92),
				"sun_color": Color(1.0, 0.93, 0.84), "sun_energy": 1.25,
				"sun_angle_x": -30.0, "sun_angle_y": 145.0,
				"sky_top": Color(0.20, 0.38, 0.70), "sky_horizon": Color(0.80, 0.82, 0.90),
				"wetness": 0.15, "wind": 0.8
			}
		BiomeType.ROCKY_GORGE:
			return {
				"name": "FORRA DELL'APPENNINO & FORRE",
				"curv_factor": 1.45,
				"has_gorge": true, "has_bridge": true, "has_torrent": true,
				"fog_density": 0.00038, "fog_color": Color(0.72, 0.80, 0.88),
				"sun_color": Color(0.94, 0.96, 1.0), "sun_energy": 1.30,
				"sun_angle_x": -32.0, "sun_angle_y": 135.0,
				"sky_top": Color(0.24, 0.45, 0.68), "sky_horizon": Color(0.72, 0.80, 0.86),
				"wetness": 0.90, "wind": 1.6
			}
		BiomeType.AUTUMN_LARCH:
			return {
				"name": "VALICO DEI LARICI & MILLE MIGLIA",
				"curv_factor": 1.35,
				"has_larch": true, "has_woodpiles": true,
				"fog_density": 0.00035, "fog_color": Color(0.82, 0.84, 0.80),
				"sun_color": Color(1.0, 0.92, 0.80), "sun_energy": 1.30,
				"sun_angle_x": -26.0, "sun_angle_y": 150.0,
				"sky_top": Color(0.22, 0.38, 0.62), "sky_horizon": Color(0.85, 0.72, 0.56),
				"wetness": 0.35, "wind": 1.2
			}
		BiomeType.GOLDEN_PLATEAU:
			return {
				"name": "COLLINE TOSCANE & VAL D'ORCIA",
				"curv_factor": 0.75,
				"has_golden": true, "has_windmill": true, "has_straw_bales": true,
				"fog_density": 0.00028, "fog_color": Color(0.88, 0.78, 0.70),
				"sun_color": Color(1.0, 0.88, 0.68), "sun_energy": 1.32,
				"sun_angle_x": -18.0, "sun_angle_y": 165.0,
				"sky_top": Color(0.25, 0.26, 0.52), "sky_horizon": Color(0.92, 0.64, 0.45),
				"wetness": 0.18, "wind": 0.85
			}
		BiomeType.TUSCAN_HILLS:
			return {
				"name": "PODERI DEL CHIANTI & VIALI DI CIPRESSI",
				"curv_factor": 0.85,
				"has_golden": true, "has_village": true, "has_straw_bales": true,
				"fog_density": 0.00025, "fog_color": Color(0.90, 0.80, 0.68),
				"sun_color": Color(1.0, 0.90, 0.70), "sun_energy": 1.34,
				"sun_angle_x": -20.0, "sun_angle_y": 160.0,
				"sky_top": Color(0.22, 0.32, 0.60), "sky_horizon": Color(0.94, 0.68, 0.48),
				"wetness": 0.14, "wind": 0.75
			}
		BiomeType.COASTAL_RIVIERA:
			return {
				"name": "RIVIERA LIGURE & STRADA PANORAMICA SUL MARE",
				"curv_factor": 1.15,
				"has_lake": true, "has_pier": true, "has_belvedere": true,
				"fog_density": 0.00022, "fog_color": Color(0.84, 0.90, 0.96),
				"sun_color": Color(1.0, 0.96, 0.88), "sun_energy": 1.35,
				"sun_angle_x": -28.0, "sun_angle_y": 155.0,
				"sky_top": Color(0.12, 0.34, 0.78), "sky_horizon": Color(0.78, 0.88, 0.96),
				"wetness": 0.20, "wind": 1.3
			}
		_:
			return {
				"name": "VALICO GLACIALE DELLE ALPI - QUOTA 2650M",
				"curv_factor": 0.90,
				"has_polar": true, "has_snow": true,
				"fog_density": 0.00038, "fog_color": Color(0.86, 0.92, 1.0),
				"sun_color": Color(0.92, 0.96, 1.0), "sun_energy": 1.25,
				"sun_angle_x": -14.0, "sun_angle_y": 175.0,
				"sky_top": Color(0.14, 0.24, 0.48), "sky_horizon": Color(0.80, 0.88, 0.98),
				"wetness": 0.85, "wind": 1.8
			}
