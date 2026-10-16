extends Node
class_name JourneyDirector

# THE LONG MERIDIAN - Expedition Journey & Gameplay Objective Director
# Coordinates the overarching trans-continental journey, stages, milestones,
# active mission objectives, and expedition score rewards.

signal journey_updated(info: Dictionary)
signal milestone_reached(milestone: Dictionary)
signal stage_cleared(stage_data: Dictionary)
signal expedition_completed(final_stats: Dictionary)

const TOTAL_JOURNEY_METERS: float = 5200.0

@export var road_generator: Node3D = null

var current_distance_m: float = 0.0
var expedition_score: int = 0
var current_stage_idx: int = 0
var last_score_meter: float = 0.0

# 4 Main Geographic Expedition Stages
var stages = [
	{
		"index": 1,
		"name": "BORGO STORICO DI SAN CRISTOFORO",
		"subtitle": "Piazza, Botteghe, Garage Paolo & Sfida al Semaforo",
		"start_m": 0.0,
		"end_m": 900.0,
		"target_destination": "CASCINA SAN ROCCO",
		"objective": "Visita il Bar dello Sport o la Panetteria, accetta la prima consegna e batti Gino al semaforo!",
		"reward_pts": 500
	},
	{
		"index": 2,
		"name": "PIANURA DEI PODERI & STAZIONE AGIP '93",
		"subtitle": "Campi di Grano, Mulino, Focaccia & Sfida BMW E30",
		"start_m": 900.0,
		"end_m": 2000.0,
		"target_destination": "STAZIONE AGIP '93",
		"objective": "Consegna le provviste alla Cascina San Rocco, raggiungi l'Agip per fare il pieno e sfida Kurt!",
		"reward_pts": 750
	},
	{
		"index": 3,
		"name": "FORRA DELL'APPENNINO & TORNANTI DEI LARICI",
		"subtitle": "Viadotto dei Ciclopi, Gola Rocciosa & Touge Alpino",
		"start_m": 2000.0,
		"end_m": 4600.0,
		"target_destination": "I TORNANTI DEI LARICI D'ORO",
		"objective": "Attraversa il Viadotto dei Ciclopi, scala i 14 tornanti alpini e sconfiggi Marco sulla Golf GTI!",
		"reward_pts": 1000
	},
	{
		"index": 4,
		"name": "VALICO GLACIALE DEL DUCA - QUOTA 2650M",
		"subtitle": "Neve, Ghiaccio & Finale della Coppa del Valico '93",
		"start_m": 4600.0,
		"end_m": 5600.0,
		"target_destination": "RIFUGIO DEL DUCA 2650M",
		"objective": "Sfida il ghiaccio del valico e sconfiggi Il Duca sulla Delta Integrale per vincere la Coppa del Valico!",
		"reward_pts": 2000
	}
]

# Checkpoints / Scored Landmarks along the Italian Expedition
var milestones = [
	{
		"z": 30.0,
		"title": "BORGO STORICO SAN CRISTOFORO",
		"alt": "420M",
		"icon": "🏘️",
		"lore": "Piazza della Repubblica in porfido, botteghe artigiane, campanile romanico e Officina Paolo.",
		"pts": 200,
		"reached": false
	},
	{
		"z": 280.0,
		"title": "CASCINA PADANA SAN ROCCO",
		"alt": "450M",
		"icon": "🌾",
		"lore": "Antica fattoria lombarda con fienile a mattoni forati, mucche al pascolo e campi di grano.",
		"pts": 250,
		"reached": false
	},
	{
		"z": 520.0,
		"title": "VECCHIO MULINO AD ACQUA",
		"alt": "490M",
		"icon": "⚙️",
		"lore": "Storica segheria e mulino idraulico alimentato dalla roggia limpida dei mugnai.",
		"pts": 300,
		"reached": false
	},
	{
		"z": 840.0,
		"title": "CONCA DEL LAGO DEI SALICI",
		"alt": "520M",
		"icon": "🌊",
		"lore": "Ampio bacino lacustre circondato da canneti, vigneti e case coloniche in pietra.",
		"pts": 350,
		"reached": false
	},
	{
		"z": 1460.0,
		"title": "STAZIONE DI SERVIZIO AGIP '93",
		"alt": "680M",
		"icon": "⛽",
		"lore": "Oasi sul valico intermedio: Super 98 ottani, tagliando meccanico e ritrovo dei piloti da rally.",
		"pts": 450,
		"reached": false
	},
	{
		"z": 2100.0,
		"title": "FORRA DELL'APPENNINO & CAVA MARMO",
		"alt": "890M",
		"icon": "⛏️",
		"lore": "Gola profonda incassata tra imponenti bastioni di roccia calcarea e carichi di marmo bianco.",
		"pts": 500,
		"reached": false
	},
	{
		"z": 2800.0,
		"title": "VIADOTTO MONUMENTALE DEI CICLOPI",
		"alt": "1280M",
		"icon": "🌉",
		"lore": "Ponte ad archi sospeso sul baratro che domina l'intera vallata appenninica.",
		"pts": 600,
		"reached": false
	},
	{
		"z": 3900.0,
		"title": "I TORNANTI DEI LARICI D'ORO (TOUGE)",
		"alt": "1850M",
		"icon": "🌲",
		"lore": "14 curve paraboliche a gomito tra i boschi montani, teatro della sfida contro la Golf GTI.",
		"pts": 750,
		"reached": false
	},
	{
		"z": 5380.0,
		"title": "VALICO GLACIALE DEL DUCA (QUOTA 2650M)",
		"alt": "2650M",
		"icon": "🏆",
		"lore": "Il tetto della spedizione: barriera del valico sferzata dalla tormenta e arena della Coppa '93.",
		"pts": 1000,
		"reached": false
	}
]

var stages_completed_flags = [false, false, false, false]
var has_completed_expedition = false

func update_progress(player_z: float, delta: float, speed_kmh: float):
	current_distance_m = max(current_distance_m, player_z)
	
	# Progressive driving points: +15 pt every 80m driven smoothly
	if current_distance_m - last_score_meter >= 80.0:
		last_score_meter = current_distance_m
		if speed_kmh > 15.0:
			expedition_score += 15
			
	# Identify current stage
	var active_st = 0
	for s_i in range(stages.size()):
		if current_distance_m >= stages[s_i].start_m:
			active_st = s_i
			
	# Check stage completion
	if active_st > current_stage_idx:
		var prev_idx = current_stage_idx
		if not stages_completed_flags[prev_idx]:
			stages_completed_flags[prev_idx] = true
			expedition_score += stages[prev_idx].reward_pts
			emit_signal("stage_cleared", {
				"stage_num": prev_idx + 1,
				"stage_name": stages[prev_idx].name,
				"reward": stages[prev_idx].reward_pts
			})
		current_stage_idx = active_st
		
	# Check milestones
	for m in milestones:
		if not m.reached and current_distance_m >= m.z:
			m.reached = true
			expedition_score += m.pts
			emit_signal("milestone_reached", {
				"title": m.title,
				"alt": m.alt,
				"icon": m.icon,
				"lore": m.lore,
				"pts": m.pts
			})
			
	# Check ultimate expedition finish
	if not has_completed_expedition and current_distance_m >= TOTAL_JOURNEY_METERS:
		has_completed_expedition = true
		emit_signal("expedition_completed", {
			"final_score": expedition_score,
			"distance_km": current_distance_m / 1000.0
		})
		
	# Next landmark query
	var next_m_title = "TRAGUARDO POLARE"
	var dist_to_next = 0.0
	for m in milestones:
		if not m.reached:
			next_m_title = m.title
			dist_to_next = max(0.0, m.z - current_distance_m)
			break
			
	var st = stages[current_stage_idx]
	var pct = clamp((current_distance_m / TOTAL_JOURNEY_METERS) * 100.0, 0.0, 100.0)
	
	emit_signal("journey_updated", {
		"distance_m": current_distance_m,
		"pk_km": current_distance_m / 1000.0,
		"progress_pct": pct,
		"stage_idx": current_stage_idx + 1,
		"total_stages": stages.size(),
		"stage_name": st.name,
		"stage_subtitle": st.subtitle,
		"objective": st.objective,
		"next_milestone": next_m_title,
		"dist_to_next_m": dist_to_next,
		"score": expedition_score,
		"seed": road_generator.expedition_seed if (road_generator and "expedition_seed" in road_generator) else 1991
	})

func register_service_bonus():
	expedition_score += 250

func add_score(pts: int):
	expedition_score += pts

var score: int:
	get:
		return expedition_score
	set(val):
		expedition_score = val
