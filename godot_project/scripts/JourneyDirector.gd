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
		"name": "PASSO DELLE ALPI & DOLOMITI",
		"subtitle": "Salita tra i Tornanti & Quota 2244m",
		"start_m": 0.0,
		"end_m": 1400.0,
		"target_destination": "AGIP ALPI 1840M",
		"objective": "Supera i tornanti alpini delle Dolomiti e fai il primo rifornimento all'Agip prima che finisca la benzina!",
		"reward_pts": 500
	},
	{
		"index": 2,
		"name": "FORRA DELL'APPENNINO & BORGO STORICO",
		"subtitle": "Canyon Profondo, Viadotto dei Ciclopi & Borgo",
		"start_m": 1400.0,
		"end_m": 3000.0,
		"target_destination": "BORGO SAN CRISTOFORO",
		"objective": "Attraversa il Ponte dei Ciclopi nella forra appenninica e raggiungi la piazza storica in ciottoli!",
		"reward_pts": 750
	},
	{
		"index": 3,
		"name": "COLLINE TOSCANE & VAL D'ORCIA",
		"subtitle": "Filari di Cipressi, Podere del Chianti & Autogrill",
		"start_m": 3000.0,
		"end_m": 4800.0,
		"target_destination": "AUTOGRILL VALICO DEL MERIDIANO",
		"objective": "Percorri le colline dorate della Val d'Orcia e fermati all'Autogrill sul valico per tagliando e ristoro!",
		"reward_pts": 1000
	},
	{
		"index": 4,
		"name": "VALICO GLACIALE DEL DUCA - QUOTA 2650M",
		"subtitle": "Passo Alpino d'Alta Quota & Duello Finale",
		"start_m": 4800.0,
		"end_m": 5600.0,
		"target_destination": "RIFUGIO DEL DUCA 2650M",
		"objective": "Sfida il ghiaccio del valico alpino con trazione 4WD e taglia il traguardo al rifugio contro la Delta del Duca!",
		"reward_pts": 2000
	}
]

# Checkpoints / Scored Landmarks along the Italian Expedition
var milestones = [
	{
		"z": 240.0,
		"title": "MALGA PASSO DELLE ALPI",
		"alt": "1720M",
		"icon": "🏔️",
		"lore": "Primo avamposto alpino. Il silenzio delle vette dolomitiche saluta la spedizione.",
		"pts": 200,
		"reached": false
	},
	{
		"z": 480.0,
		"title": "LAGO DEI LARICI & BELVEDERE",
		"alt": "1810M",
		"icon": "🌲",
		"lore": "Specchio d'acqua cristallino che riflette i boschi montani e i motoscafi in mogano lucido.",
		"pts": 250,
		"reached": false
	},
	{
		"z": 776.0,
		"title": "STAZIONE AGIP '93 VALICO DELLE ALPI",
		"alt": "1840M",
		"icon": "⛽",
		"lore": "Oasi sul valico: rifornimento benzina Super, tagliando meccanico e caffè espresso caldo.",
		"pts": 400,
		"reached": false
	},
	{
		"z": 960.0,
		"title": "BORGO STORICO SAN CRISTOFORO",
		"alt": "1650M",
		"icon": "🏘️",
		"lore": "Case in pietra viva, piazza in ciottoli e antico campanile romanico con campane in bronzo.",
		"pts": 350,
		"reached": false
	},
	{
		"z": 1480.0,
		"title": "PONTE DEI CICLOPI",
		"alt": "1280M",
		"icon": "🌉",
		"lore": "Imponente viadotto in pietra ad archi sospeso sul baratro della Forra dell'Appennino.",
		"pts": 500,
		"reached": false
	},
	{
		"z": 2160.0,
		"title": "MULINO STORICO DELL'APPENNINO",
		"alt": "890M",
		"icon": "🪵",
		"lore": "Segheria ad acqua e punto di raccolta boscaioli lungo il corso del torrente.",
		"pts": 400,
		"reached": false
	},
	{
		"z": 3180.0,
		"title": "AUTOGRILL VALICO DEL MERIDIANO",
		"alt": "1420M",
		"icon": "☕",
		"lore": "Storico ristoro autostradale italiano: sosta vitale prima delle colline toscane.",
		"pts": 450,
		"reached": false
	},
	{
		"z": 4200.0,
		"title": "COLLINE TOSCANE & VAL D'ORCIA",
		"alt": "1180M",
		"icon": "🌾",
		"lore": "Vaste colline dorate con maestosi filari di cipressi, poderi in pietra e balle di fieno.",
		"pts": 400,
		"reached": false
	},
	{
		"z": 5200.0,
		"title": "GALLERIA PARAMASSI DEL VALICO",
		"alt": "2410M",
		"icon": "⛰️",
		"lore": "Galleria scavata nella roccia con portale monumentale e protezioni paravalanghe alpine.",
		"pts": 500,
		"reached": false
	},
	{
		"z": 5500.0,
		"title": "RIFUGIO DEL DUCA - QUOTA 2650M",
		"alt": "2650M",
		"icon": "🏁",
		"lore": "TRAGUARDO DELLA SPEDIZIONE! Il valico d'alta quota delle Alpi è conquistato!",
		"pts": 2500,
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
