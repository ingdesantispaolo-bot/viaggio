extends Control
class_name TopographicMapControl

# ==============================================================================
# CARTA TOPOGRAFICA DEL GRANDE MERIDIANO - IGM / TOURING CLUB ITALIANO (1983)
# ==============================================================================
# Vettorializzazione topografica in stile cartografia tecnica anni '80 e
# terminale cartografico Amiga 500 / CRT vector display.
# Disegna:
# 1. Griglia cartesiana UTM / Gauss-Boaga con coordinate e mirini
# 2. Curve di livello orografiche (isoipse a passo di quota 400m -> 2650m)
# 3. Idrografia (Lago Prealpino di San Rocco, Torrente glaciale dell'Orrido)
# 4. Tracciato vettoriale della strada reale con tornanti touge a 180°
# 5. Waypoints IGM con icone vettoriali dedicate, quote e mirino pulsante
# 6. Profilo altimetrico tecnico (elevation profile longitudinal cross-section)
# 7. Rosa dei venti d'epoca, barra di scala 1:25.000 e timbro ufficiale
# ==============================================================================

signal waypoint_clicked(index: int)

@export var crt_mode: bool = true # Green/amber vector CRT palette vs vintage paper
@export var selected_waypoint_idx: int = 0
@export var player_distance_z: float = 920.0 # Posizione attuale del giocatore

var pulse_time: float = 0.0
var hover_waypoint_idx: int = -1

# Definizione dei 9 Waypoint Geografici Ufficiali (con Ampia Pianura dei Poderi)
const WAYPOINTS = [
	{
		"id": "san_cristoforo",
		"name": "Borgo Storico San Cristoforo",
		"short": "BORGO S. CRISTOFORO",
		"km": 0.0,
		"alt": 380,
		"grad": "+0.0%",
		"map_pos": Vector2(0.12, 0.84),
		"icon": "city",
		"desc": "Piazza della Fontana, Chiesa romanica, Comune, Officina Paolo"
	},
	{
		"id": "cascina_san_giorgio",
		"name": "Cascina Corte San Giorgio",
		"short": "CASCINA S. GIORGIO",
		"km": 0.3,
		"alt": 382,
		"grad": "+0.2%",
		"map_pos": Vector2(0.20, 0.77),
		"icon": "farm",
		"desc": "Bivio poderale, casale padano, fienile aperto, silo, campi di grano"
	},
	{
		"id": "mulino_ruscello",
		"name": "Antico Mulino & Ruscello Chiaro",
		"short": "MULINO & RUSCELLO",
		"km": 0.5,
		"alt": 385,
		"grad": "+0.2%",
		"map_pos": Vector2(0.28, 0.70),
		"icon": "mill",
		"desc": "Ponte in pietra a schiena d'asino, ruota a pale in legno, girasoli"
	},
	{
		"id": "podere_belvedere",
		"name": "Podere Belvedere & Vigneti",
		"short": "PODERE BELVEDERE",
		"km": 0.8,
		"alt": 388,
		"grad": "+0.4%",
		"map_pos": Vector2(0.35, 0.64),
		"icon": "villa",
		"desc": "Viale di 8 cipressi secolari, cantina vinicola, botti e vigneti a spalliera"
	},
	{
		"id": "lago_dei_salici",
		"name": "Lago dei Salici & Pontile",
		"short": "LAGO DEI SALICI",
		"km": 1.1,
		"alt": 386,
		"grad": "-0.1%",
		"map_pos": Vector2(0.42, 0.58),
		"icon": "lake",
		"desc": "Bacino lacustre di pianura, pontile in legno, barche a remi e canneto"
	},
	{
		"id": "stazione_agip",
		"name": "Stazione Agip 1993",
		"short": "OASI AGIP '93",
		"km": 1.5,
		"alt": 410,
		"grad": "+1.8%",
		"map_pos": Vector2(0.50, 0.52),
		"icon": "gas",
		"desc": "Piazzale bitumato, rifornimento Super 100 ottani, cabina SIP"
	},
	{
		"id": "gola_canyon",
		"name": "Gola & Ponte dei Ciclopi",
		"short": "PONTE DEI CICLOPI",
		"km": 2.8,
		"alt": 980,
		"grad": "+7.2%",
		"map_pos": Vector2(0.62, 0.42),
		"icon": "bridge",
		"desc": "Forra rocciosa, asfalto bagnato, viadotto monumentale ad arco"
	},
	{
		"id": "tornanti_larici",
		"name": "Tornanti dei Larici",
		"short": "I TORNANTI DEI LARICI",
		"km": 4.2,
		"alt": 1650,
		"grad": "+9.8%",
		"map_pos": Vector2(0.74, 0.30),
		"icon": "hairpin",
		"desc": "14 tornanti tecnici a 180°, Touge montano, Mille Miglia"
	},
	{
		"id": "passo_meridiano",
		"name": "Valico Glaciale del Duca 2650m",
		"short": "VALICO DEL DUCA 2650m",
		"km": 6.0,
		"alt": 2650,
		"grad": "+6.0%",
		"map_pos": Vector2(0.88, 0.12),
		"icon": "peak",
		"desc": "Quota 2650m s.l.m., nevi perenni, stazione meteo"
	},
	{
		"id": "belvedere_sirene",
		"name": "Costiera delle Sirene & Faro",
		"short": "FARO DELLA SCOGLIERA",
		"km": 8.7,
		"alt": 480,
		"grad": "-7.4%",
		"map_pos": Vector2(0.85, 0.52),
		"icon": "peak",
		"desc": "Belvedere panoramico sul mare azzurro, faro monumentale a fasce bicolori"
	},
	{
		"id": "borgo_marina",
		"name": "Borgo Marina dei Pescatori",
		"short": "BORGO MARINA",
		"km": 10.2,
		"alt": 25,
		"grad": "0.0%",
		"map_pos": Vector2(0.52, 0.86),
		"icon": "city",
		"desc": "Villaggio marinaro, molo, gozzi liguri ormeggiati e chiesa sul mare"
	},
	{
		"id": "porta_marina",
		"name": "Porta Marina - Rientro a San Cristoforo",
		"short": "PORTA MARINA (CIRCUITO)",
		"km": 12.0,
		"alt": 0,
		"grad": "0.0%",
		"map_pos": Vector2(0.12, 0.84),
		"icon": "city",
		"desc": "Porta monumentale d'ingresso, chiusura perfetta del circuito di 12 km"
	}
]


func _init():
	custom_minimum_size = Vector2(420, 280)
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	mouse_filter = MOUSE_FILTER_PASS

func _process(delta: float):
	pulse_time += delta * 3.5
	queue_redraw()

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var hit_idx = find_waypoint_at_pos(event.position)
		if hit_idx >= 0:
			selected_waypoint_idx = hit_idx
			waypoint_clicked.emit(hit_idx)
			queue_redraw()
			accept_event()
	elif event is InputEventMouseMotion:
		var hit_idx = find_waypoint_at_pos(event.position)
		if hit_idx != hover_waypoint_idx:
			hover_waypoint_idx = hit_idx
			queue_redraw()

func find_waypoint_at_pos(pos: Vector2) -> int:
	var map_rect = get_map_viewport_rect()
	for i in range(WAYPOINTS.size()):
		var wp = WAYPOINTS[i]
		var screen_pt = map_rect.position + wp.map_pos * map_rect.size
		if pos.distance_to(screen_pt) < 18.0:
			return i
	return -1

func set_selected_waypoint(idx: int):
	if idx >= 0 and idx < WAYPOINTS.size():
		selected_waypoint_idx = idx
		queue_redraw()

func set_player_distance(z: float):
	player_distance_z = z
	queue_redraw()

func get_map_viewport_rect() -> Rect2:
	# Lascia uno spazio per il profilo altimetrico sul fondo e margini coordinate
	var m = 22.0
	var h_prof = 64.0
	return Rect2(m, m, max(100.0, size.x - m * 2.0), max(100.0, size.y - m * 2.0 - h_prof))

func get_profile_viewport_rect() -> Rect2:
	var m = 22.0
	var h_prof = 54.0
	return Rect2(m, size.y - m - h_prof, max(100.0, size.x - m * 2.0), h_prof)

func _draw():
	var rect_full = Rect2(Vector2.ZERO, size)
	var map_rect = get_map_viewport_rect()
	var prof_rect = get_profile_viewport_rect()
	
	# Palette 1983 Vector CRT Phosphor / IGM Tech
	var col_bg = Color(0.025, 0.045, 0.040, 1.0) # Nero fosforo verde profondo
	var col_grid_maj = Color(0.12, 0.32, 0.22, 0.65) # Griglia UTM principale
	var col_grid_min = Color(0.08, 0.20, 0.14, 0.40) # Griglia secondaria
	var col_isoline_maj = Color(0.20, 0.52, 0.35, 0.70) # Isoipse maestre
	var col_isoline_min = Color(0.14, 0.38, 0.25, 0.45) # Isoipse intermedie
	var col_water = Color(0.10, 0.45, 0.55, 0.50) # Idrografia azzurro fosforo
	var col_road = Color(0.98, 0.76, 0.18, 0.95) # Strada Maestra Giallo Ocasa / Oro
	var col_road_glow = Color(1.0, 0.60, 0.10, 0.30)
	var col_sel = Color(1.0, 0.90, 0.25, 1.0)
	var col_text = Color(0.45, 0.95, 0.65, 0.95) # Testo terminale verde IGM
	var col_text_dim = Color(0.25, 0.65, 0.42, 0.70)
	var col_player = Color(0.20, 0.95, 1.0, 0.95) # Ciano radar
	
	# 1. Base monitor background
	draw_rect(rect_full, col_bg, true)
	
	# Bordo chassis IGM con tacche metriche
	draw_rect(map_rect, col_grid_maj, false, 1.5)
	
	# 2. Reticolo Topografico UTM Gauss-Boaga (Griglia chilometrica)
	var grid_step_x = map_rect.size.x / 8.0
	var grid_step_y = map_rect.size.y / 6.0
	
	for i in range(1, 8):
		var gx = map_rect.position.x + i * grid_step_x
		draw_line(Vector2(gx, map_rect.position.y), Vector2(gx, map_rect.position.y + map_rect.size.y), col_grid_min, 1.0)
		# Crocette topografiche di intersezione
		for j in range(1, 6):
			var gy = map_rect.position.y + j * grid_step_y
			draw_line(Vector2(gx - 3, gy), Vector2(gx + 3, gy), col_grid_maj, 1.0)
			draw_line(Vector2(gx, gy - 3), Vector2(gx, gy + 3), col_grid_maj, 1.0)
			
	for j in range(1, 6):
		var gy = map_rect.position.y + j * grid_step_y
		draw_line(Vector2(map_rect.position.x, gy), Vector2(map_rect.position.x + map_rect.size.x, gy), col_grid_min, 1.0)

	# 3. Curve di Livello (Isoipse & Campi Agricoli della Pianura)
	draw_contour_lines(map_rect, col_isoline_maj, col_isoline_min)
	
	# 4. Idrografia (Ruscello Chiaro & Lago dei Salici)
	draw_hydrography(map_rect, col_water)
	
	# 5. Rete Stradale Principale & Secondaria (Bivi poderali in linea tratteggiata)
	draw_road_network(map_rect, col_road, col_road_glow)
	
	# 6. Waypoints Ufficiali IGM
	draw_waypoints(map_rect, col_text, col_sel, col_player)
	
	# 7. Profilo Altimetrico Tecnico (Fascia inferiore)
	draw_elevation_profile(prof_rect, col_bg, col_grid_maj, col_road, col_sel, col_text, col_text_dim)
	
	# 8. Elementi Cartografici Storici (Rosa dei Venti, Scala metrica, Timbri IGM)
	draw_cartographic_adornments(map_rect, col_text, col_text_dim, col_grid_maj)

func draw_contour_lines(mrect: Rect2, col_maj: Color, col_min: Color):
	# 1. Ampia Pianura Agricola dei Poderi: Campiture a scacchiera dei campi coltivati
	var plain_origin = mrect.position + Vector2(0.12, 0.60) * mrect.size
	var col_field = Color(col_maj.r, col_maj.g, col_maj.b, 0.18)
	var field_rects = [
		Rect2(plain_origin + Vector2(8, 12), Vector2(34, 20)),
		Rect2(plain_origin + Vector2(46, 16), Vector2(30, 24)),
		Rect2(plain_origin + Vector2(12, 36), Vector2(38, 22)),
		Rect2(plain_origin + Vector2(54, 42), Vector2(36, 18)),
		Rect2(plain_origin + Vector2(94, 22), Vector2(32, 26))
	]
	for fr in field_rects:
		draw_rect(fr, col_field, true)
		draw_rect(fr, col_min, false, 0.8)
		for lx in range(int(fr.position.x + 3), int(fr.position.x + fr.size.x - 2), 5):
			draw_line(Vector2(lx, fr.position.y + 2), Vector2(lx, fr.position.y + fr.size.y - 2), col_field * 1.4, 0.6)
			
	draw_string(ThemeDB.fallback_font, plain_origin + Vector2(10, 8), "PIANURA AGRICOLA DEI PODERI", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, col_maj)

	# 2. Isoipse larghe e distanziate per la pianura (Quota 380m)
	var p_iso1 = PackedVector2Array([
		mrect.position + Vector2(0.08, 0.90) * mrect.size,
		mrect.position + Vector2(0.22, 0.84) * mrect.size,
		mrect.position + Vector2(0.36, 0.78) * mrect.size,
		mrect.position + Vector2(0.48, 0.70) * mrect.size
	])
	draw_polyline(p_iso1, col_min, 0.8, true)
	draw_string(ThemeDB.fallback_font, p_iso1[1] + Vector2(0, 8), "380m", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, col_min)

	# 3. Colline da Contorno (Nord e Sud della pianura)
	var hill_north = mrect.position + Vector2(0.22, 0.52) * mrect.size
	var hill_south = mrect.position + Vector2(0.30, 0.88) * mrect.size
	for r in range(3):
		draw_arc(hill_north, (r + 1) * 12.0, 0.2, 3.2, 16, col_min, 0.8, true)
		draw_arc(hill_south, (r + 1) * 11.0, -2.8, 0.5, 16, col_min, 0.8, true)
	draw_string(ThemeDB.fallback_font, hill_north + Vector2(-16, 0), "Coll. Belvedere", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, col_min)

	# 4. Isoipse Rilievi Montuosi Alti (Gola dei Ciclopi & Valico del Duca)
	var center_valico = mrect.position + Vector2(0.85, 0.15) * mrect.size
	var center_gorge = mrect.position + Vector2(0.60, 0.40) * mrect.size
	
	for r_step in range(6):
		var rx = (r_step + 1) * (mrect.size.x * 0.045)
		var c = col_maj if r_step % 2 == 0 else col_min
		draw_arc(center_valico, rx, 0.2, 3.4, 24, c, 1.0, true)
		
	for step in range(5):
		var offset = (step + 1) * 4.0
		var p1 = mrect.position + Vector2(0.56, 0.48) * mrect.size + Vector2(-offset, offset * 0.5)
		var p2 = mrect.position + Vector2(0.64, 0.38) * mrect.size + Vector2(-offset * 0.8, 0)
		draw_polyline(PackedVector2Array([p1, p2]), col_min, 1.0, true)
		
		var q1 = mrect.position + Vector2(0.60, 0.52) * mrect.size + Vector2(offset, -offset * 0.5)
		var q2 = mrect.position + Vector2(0.68, 0.42) * mrect.size + Vector2(offset * 0.8, 0)
		draw_polyline(PackedVector2Array([q1, q2]), col_min, 1.0, true)

	draw_string(ThemeDB.fallback_font, center_valico + Vector2(-15, 20), "2650m", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, col_maj)
	draw_string(ThemeDB.fallback_font, center_gorge + Vector2(-20, -10), "980m", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, col_maj)

func draw_hydrography(mrect: Rect2, col_w: Color):
	# 1. Ruscello Chiaro (Meandro che attraversa la pianura e passa sotto al ponte del Mulino)
	var stream_pts = PackedVector2Array([
		mrect.position + Vector2(0.20, 0.56) * mrect.size,
		mrect.position + Vector2(0.24, 0.64) * mrect.size,
		mrect.position + Vector2(0.28, 0.70) * mrect.size, # Ponte statale & Mulino
		mrect.position + Vector2(0.33, 0.74) * mrect.size,
		mrect.position + Vector2(0.38, 0.68) * mrect.size,
		mrect.position + Vector2(0.42, 0.60) * mrect.size  # Sfocia nel Lago dei Salici
	])
	draw_polyline(stream_pts, col_w, 1.2, true)
	draw_string(ThemeDB.fallback_font, stream_pts[1] + Vector2(4, -4), "Ruscello Chiaro", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, col_w)

	# 2. Lago dei Salici (Specchio d'acqua di pianura con pontile)
	var lake_origin = mrect.position + Vector2(0.42, 0.58) * mrect.size
	var lake_pts = PackedVector2Array([
		lake_origin + Vector2(0, -10),
		lake_origin + Vector2(24, -14),
		lake_origin + Vector2(46, -3),
		lake_origin + Vector2(38, 16),
		lake_origin + Vector2(14, 20),
		lake_origin + Vector2(-6, 7)
	])
	draw_colored_polygon(lake_pts, Color(col_w.r, col_w.g, col_w.b, 0.25))
	draw_polyline(lake_pts, col_w, 1.2, true)
	draw_string(ThemeDB.fallback_font, lake_origin + Vector2(6, 4), "LAGO DEI SALICI", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, col_w)

	# 3. Torrente della Forra (Appennino)
	var river_pts = PackedVector2Array([
		mrect.position + Vector2(0.72, 0.28) * mrect.size,
		mrect.position + Vector2(0.64, 0.36) * mrect.size,
		mrect.position + Vector2(0.62, 0.42) * mrect.size
	])
	draw_polyline(river_pts, col_w, 1.0, true)

	# 4. Costa del Mare Ligure / Mar del Meridiano (Costa e affaccio panoramico)
	var coast_pts = PackedVector2Array([
		mrect.position + Vector2(0.98, 0.42) * mrect.size,
		mrect.position + Vector2(0.88, 0.50) * mrect.size,
		mrect.position + Vector2(0.82, 0.65) * mrect.size,
		mrect.position + Vector2(0.68, 0.82) * mrect.size,
		mrect.position + Vector2(0.52, 0.95) * mrect.size,
		mrect.position + Vector2(0.98, 0.98) * mrect.size
	])
	draw_colored_polygon(coast_pts, Color(col_w.r, col_w.g, col_w.b, 0.20))
	draw_polyline(coast_pts, col_w, 1.4, true)
	draw_string(ThemeDB.fallback_font, mrect.position + Vector2(0.80, 0.78) * mrect.size, "MAR DEL MERIDIANO", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, col_w)

func draw_road_network(mrect: Rect2, col_r: Color, col_glow: Color):
	# 1. Rete Stradale Secondaria: Strade vicinali e poderali tratteggiate verso le fattorie
	var p_cascina = mrect.position + WAYPOINTS[1].map_pos * mrect.size
	var p_cascina_farm = p_cascina + Vector2(24, -16)
	draw_dashed_line(p_cascina, p_cascina_farm, col_r * 0.7, 1.2, 3.0)
	draw_string(ThemeDB.fallback_font, p_cascina_farm + Vector2(3, -2), "Strada vicinale S. Giorgio", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, col_r * 0.8)

	var p_mulino = mrect.position + WAYPOINTS[2].map_pos * mrect.size
	var p_mulino_b = p_mulino + Vector2(-20, 14)
	draw_dashed_line(p_mulino, p_mulino_b, col_r * 0.7, 1.2, 3.0)
	draw_string(ThemeDB.fallback_font, p_mulino_b + Vector2(-55, 10), "Accesso Mulino", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, col_r * 0.8)

	var p_belvedere = mrect.position + WAYPOINTS[3].map_pos * mrect.size
	var p_belvedere_b = p_belvedere + Vector2(-22, -12)
	draw_dashed_line(p_belvedere, p_belvedere_b, col_r * 0.7, 1.2, 3.0)
	draw_string(ThemeDB.fallback_font, p_belvedere_b + Vector2(-65, -2), "Viale Cipressi", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, col_r * 0.8)

	var p_lago = mrect.position + WAYPOINTS[4].map_pos * mrect.size
	var p_lago_pier = p_lago + Vector2(16, 10)
	draw_dashed_line(p_lago, p_lago_pier, col_r * 0.7, 1.2, 3.0)

	# 2. Asse Viario Statale Principale (Circuito Chiuso Completo 12.0 km)
	var road_pts = PackedVector2Array()
	var total_samples = 180
	
	for s in range(total_samples + 1):
		var t = float(s) / float(total_samples)
		var pt = Vector2.ZERO
		
		if t < 0.08:
			var sub_t = t / 0.08
			pt = lerp(WAYPOINTS[0].map_pos, WAYPOINTS[1].map_pos, sub_t)
		elif t < 0.16:
			var sub_t = (t - 0.08) / 0.08
			pt = lerp(WAYPOINTS[1].map_pos, WAYPOINTS[2].map_pos, sub_t)
		elif t < 0.24:
			var sub_t = (t - 0.16) / 0.08
			pt = lerp(WAYPOINTS[2].map_pos, WAYPOINTS[3].map_pos, sub_t)
		elif t < 0.32:
			var sub_t = (t - 0.24) / 0.08
			pt = lerp(WAYPOINTS[3].map_pos, WAYPOINTS[4].map_pos, sub_t)
		elif t < 0.40:
			var sub_t = (t - 0.32) / 0.08
			pt = lerp(WAYPOINTS[4].map_pos, WAYPOINTS[5].map_pos, sub_t)
		elif t < 0.50:
			var sub_t = (t - 0.40) / 0.10
			pt = lerp(WAYPOINTS[5].map_pos, WAYPOINTS[6].map_pos, sub_t)
			pt.x -= sin(sub_t * PI) * 0.02
		elif t < 0.62:
			var sub_t = (t - 0.50) / 0.12
			var base_pt = lerp(WAYPOINTS[6].map_pos, WAYPOINTS[7].map_pos, sub_t)
			var hairpin_wave = sin(sub_t * PI * 12.0) * 0.022
			pt = base_pt + Vector2(-hairpin_wave * 0.6, hairpin_wave * 0.8)
		elif t < 0.72:
			var sub_t = (t - 0.62) / 0.10
			pt = lerp(WAYPOINTS[7].map_pos, WAYPOINTS[8].map_pos, sub_t)
		elif t < 0.82:
			var sub_t = (t - 0.72) / 0.10
			pt = lerp(WAYPOINTS[8].map_pos, WAYPOINTS[9].map_pos, sub_t)
			pt.x += sin(sub_t * PI) * 0.03
		elif t < 0.92:
			var sub_t = (t - 0.82) / 0.10
			pt = lerp(WAYPOINTS[9].map_pos, WAYPOINTS[10].map_pos, sub_t)
			pt.y += sin(sub_t * PI) * 0.02
		else:
			var sub_t = (t - 0.92) / 0.08
			pt = lerp(WAYPOINTS[10].map_pos, WAYPOINTS[11].map_pos, sub_t)
			
		road_pts.append(mrect.position + pt * mrect.size)

		
	draw_polyline(road_pts, col_glow, 4.0, true)
	draw_polyline(road_pts, col_r, 2.0, true)
	
	# Tacche kilometriche
	for k in range(1, 14):
		var s_idx = int((float(k) / 14.0) * total_samples)
		if s_idx < road_pts.size() - 1:
			var p = road_pts[s_idx]
			var n = (road_pts[s_idx + 1] - p).orthogonal().normalized() * 3.5
			draw_line(p - n, p + n, Color(0.9, 0.95, 0.8, 0.8), 1.2)

func draw_waypoints(mrect: Rect2, col_txt: Color, col_sel: Color, col_ply: Color):
	var time_phase = pulse_time
	
	for i in range(WAYPOINTS.size()):
		var wp = WAYPOINTS[i]
		var pt = mrect.position + wp.map_pos * mrect.size
		var is_selected = (i == selected_waypoint_idx)
		var is_hover = (i == hover_waypoint_idx)
		
		var rad = 4.0 if not is_selected else 6.0
		var col_point = col_sel if is_selected else (Color(1.0, 0.8, 0.3) if is_hover else col_txt)
		
		if is_selected:
			var p_rad = 8.5 + sin(time_phase) * 2.2
			draw_arc(pt, p_rad, 0, TAU, 16, col_sel, 1.2, true)
			draw_line(pt + Vector2(-p_rad - 4, 0), pt + Vector2(-p_rad + 2, 0), col_sel, 1.5)
			draw_line(pt + Vector2(p_rad - 2, 0), pt + Vector2(p_rad + 4, 0), col_sel, 1.5)
			draw_line(pt + Vector2(0, -p_rad - 4), pt + Vector2(0, -p_rad + 2), col_sel, 1.5)
			draw_line(pt + Vector2(0, p_rad - 2), pt + Vector2(0, p_rad + 4), col_sel, 1.5)
			
		draw_circle(pt, rad, col_point)
		draw_circle(pt, rad * 0.45, Color(0.02, 0.05, 0.03))
		
		var label_str = "[WP %d] %s" % [i + 1, wp.short]
		var label_pos = pt + Vector2(8, 3)
		if wp.map_pos.x > 0.65:
			label_pos = pt + Vector2(-125, 3)
		elif i == 1:
			label_pos = pt + Vector2(8, -6)
		elif i == 3:
			label_pos = pt + Vector2(8, -6)
			
		var font_col = col_sel if is_selected else col_txt
		draw_string(ThemeDB.fallback_font, label_pos, label_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, font_col)
		draw_string(ThemeDB.fallback_font, label_pos + Vector2(0, 8), "%dm | %s" % [wp.alt, wp.grad], HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color(font_col.r, font_col.g, font_col.b, 0.65))

	# Posizione attuale del veicolo del giocatore
	var t_ply = clamp(player_distance_z / 6000.0, 0.0, 1.0)
	var ply_screen_pt = mrect.position + lerp(WAYPOINTS[0].map_pos, WAYPOINTS[8].map_pos, t_ply) * mrect.size
	
	var ply_pulse = 5.0 + sin(time_phase * 1.5) * 2.0
	draw_circle(ply_screen_pt, ply_pulse, Color(col_ply.r, col_ply.g, col_ply.b, 0.4))
	draw_circle(ply_screen_pt, 3.0, col_ply)
	draw_string(ThemeDB.fallback_font, ply_screen_pt + Vector2(8, -4), "TU SEI QUI", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, col_ply)

func draw_elevation_profile(prect: Rect2, col_bg: Color, col_grid: Color, col_line: Color, col_sel: Color, col_txt: Color, col_dim: Color):
	draw_rect(prect, Color(col_bg.r * 1.2, col_bg.g * 1.2, col_bg.b * 1.2, 0.95), true)
	draw_rect(prect, col_grid, false, 1.0)
	
	draw_string(ThemeDB.fallback_font, prect.position + Vector2(6, 11), "PROFILO ALTIMETRICO DEL MERIDIANO (PIANURA DEI PODERI -> VALICO 2650m)", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, col_txt)
	draw_string(ThemeDB.fallback_font, prect.position + Vector2(prect.size.x - 70, 11), "DISL. +2270m", HORIZONTAL_ALIGNMENT_RIGHT, -1, 7, col_sel)
	
	var h_inner = prect.size.y - 20.0
	var y_base = prect.position.y + prect.size.y - 6.0
	
	var alt_marks = [
		{"m": 380, "label": "380m"},
		{"m": 980, "label": "980m"},
		{"m": 1650, "label": "1650m"},
		{"m": 2650, "label": "2650m"}
	]
	
	for am in alt_marks:
		var norm_y = (am.m - 350.0) / (2650.0 - 350.0)
		var py = y_base - norm_y * h_inner
		draw_line(Vector2(prect.position.x + 35, py), Vector2(prect.position.x + prect.size.x - 6, py), col_grid * 0.6, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(prect.position.x + 4, py + 3), am.label, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, col_dim)

	var prof_pts = PackedVector2Array()
	var x_start = prect.position.x + 38.0
	var x_width = prect.size.x - 44.0
	
	for i in range(WAYPOINTS.size()):
		var wp = WAYPOINTS[i]
		var norm_x = (wp.km - 0.0) / 6.0
		var norm_y = (wp.alt - 350.0) / (2650.0 - 350.0)
		var px = x_start + norm_x * x_width
		var py = y_base - norm_y * h_inner
		prof_pts.append(Vector2(px, py))
		
		draw_line(Vector2(px, y_base), Vector2(px, py), Color(col_grid.r, col_grid.g, col_grid.b, 0.35), 1.0)
		
		var is_sel = (i == selected_waypoint_idx)
		var pt_col = col_sel if is_sel else col_line
		draw_circle(Vector2(px, py), 2.5 if not is_sel else 4.0, pt_col)
		
		if is_sel:
			draw_line(Vector2(px, y_base), Vector2(px, py), col_sel, 1.2)
			draw_string(ThemeDB.fallback_font, Vector2(px - 14, py - 4), "%dm" % wp.alt, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, col_sel)

	draw_polyline(prof_pts, col_line, 1.8, true)
	draw_string(ThemeDB.fallback_font, Vector2(x_start + 12, y_base - 14), "PIANURA DEI PODERI", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, col_sel * 0.8)

func draw_cartographic_adornments(mrect: Rect2, col_txt: Color, col_dim: Color, col_maj: Color):
	# 1. Coordinate ai 4 angoli (Gauss-Boaga / UTM)
	draw_string(ThemeDB.fallback_font, mrect.position + Vector2(6, 12), "UTM 32T N 5142000 - E 0648000", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, col_dim)
	draw_string(ThemeDB.fallback_font, mrect.position + Vector2(mrect.size.x - 170, 12), "F. 42 TAV. IV NE - SERIE 25V", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, col_dim)
	
	# 2. Rosa dei Venti (Nord Topografico) in alto a destra
	var compass_center = mrect.position + Vector2(mrect.size.x - 28, 42)
	draw_line(compass_center + Vector2(0, 14), compass_center + Vector2(0, -16), col_txt, 1.5)
	draw_line(compass_center + Vector2(-10, 0), compass_center + Vector2(10, 0), col_dim, 1.0)
	# Freccia Nord
	draw_colored_polygon(PackedVector2Array([
		compass_center + Vector2(0, -18),
		compass_center + Vector2(-4, -6),
		compass_center + Vector2(0, -8)
	]), col_txt)
	draw_colored_polygon(PackedVector2Array([
		compass_center + Vector2(0, -18),
		compass_center + Vector2(4, -6),
		compass_center + Vector2(0, -8)
	]), col_dim)
	draw_string(ThemeDB.fallback_font, compass_center + Vector2(-3, -20), "N", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, col_txt)
	
	# 3. Scala Metrica 1:25.000 in basso a sinistra
	var scale_origin = mrect.position + Vector2(12, mrect.size.y - 12)
	var scale_len = 60.0
	draw_line(scale_origin, scale_origin + Vector2(scale_len, 0), col_txt, 1.5)
	draw_line(scale_origin, scale_origin + Vector2(0, -4), col_txt, 1.5)
	draw_line(scale_origin + Vector2(scale_len * 0.5, 0), scale_origin + Vector2(scale_len * 0.5, -3), col_txt, 1.0)
	draw_line(scale_origin + Vector2(scale_len, 0), scale_origin + Vector2(scale_len, -4), col_txt, 1.5)
	draw_string(ThemeDB.fallback_font, scale_origin + Vector2(0, -6), "0", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, col_dim)
	draw_string(ThemeDB.fallback_font, scale_origin + Vector2(scale_len * 0.45, -6), "1km", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, col_dim)
	draw_string(ThemeDB.fallback_font, scale_origin + Vector2(scale_len - 6, -6), "2km", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, col_dim)
	draw_string(ThemeDB.fallback_font, scale_origin + Vector2(scale_len + 8, -2), "SCALA 1:25.000", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, col_txt)
	
	# 4. Timbro Cartografia Militare / Touring 1983
	var stamp_origin = mrect.position + Vector2(mrect.size.x - 180, mrect.size.y - 12)
	draw_string(ThemeDB.fallback_font, stamp_origin, "TOURING CLUB ITALIANO / IGM © 1983", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, col_dim)
