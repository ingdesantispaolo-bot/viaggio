extends Control
class_name AnalogGauge

# THE LONG MERIDIAN - Authentic Period-Accurate Automotive Cockpits & Gauges (Godot 4)
# 100% Period-Authentic Custom Vector Rendering for:
# 1. PANDA 4x4 (1983): Veglia Borletti Cubo, Veglia round tacho, Giugiaro Marsupio & Steyr 4WD lever, Steyr dual clinometer
# 2. DELTA INTEGRALE (1991): Veglia Corse 260 speedo, Veglia Corse 8k tacho, Garrett T3 turbo, Check Control, Fuel/Oil aux
# 3. G-KLASSE W460 (1979): VDO Stuttgart 200 speedo, VDO 6k tacho, VDO Kombi (fuel/temp), 3x Sperren diff locks, Angstgriff

enum GaugeType {
	PANDA_SPEEDO,
	PANDA_TACHO,
	PANDA_CLINO,
	PANDA_CONSOLE,
	DELTA_SPEEDO,
	DELTA_TACHO,
	DELTA_TURBO,
	DELTA_CHECK_PANEL,
	DELTA_AUX,
	GWAGEN_SPEEDO,
	GWAGEN_TACHO,
	GWAGEN_KOMBI,
	GWAGEN_DIFFS,
	GWAGEN_CONSOLE,
	FIAT127_SPEEDO,
	FIAT127_CONSOLE,
	GOLF_SPEEDO,
	GOLF_TACHO,
	GOLF_MFA_AUX,
	GOLF_CONSOLE,
	RENAULT4_SPEEDO,
	RENAULT4_CONSOLE,
	BMW_SPEEDO,
	BMW_TACHO_ECONO,
	BMW_CONSOLE,
	A250_CLUSTER,
	A250_SCREEN,
	A250_CONSOLE,
	# 9. ALFA ROMEO 8C 2900B / MONZA (1931)
	ALFA8C_SPEEDO,
	ALFA8C_TACHO,
	ALFA8C_CONSOLE,
	# 10. FIAT 500 TOPOLINO (1936)
	TOPOLINO_SPEEDO,
	TOPOLINO_CONSOLE,
	# 11. LANCIA AURELIA B20 GT (1950)
	AURELIA_SPEEDO,
	AURELIA_TACHO,
	AURELIA_CONSOLE,
	# 12. ALFA ROMEO GIULIA SPRINT GTA AUTODELTA (1965)
	ALFAGTA_SPEEDO,
	ALFAGTA_TACHO,
	ALFAGTA_CONSOLE,
	# 13. LANCIA STRATOS HF STRADALE (1973)
	STRATOS_SPEEDO,
	STRATOS_TACHO,
	STRATOS_CONSOLE,
	# 14. FIAT 131 ABARTH RALLY (1976)
	FIAT131_SPEEDO,
	FIAT131_TACHO,
	FIAT131_CONSOLE
}

@export var gauge_type: GaugeType = GaugeType.PANDA_SPEEDO
@export var current_value: float = 0.0
@export var max_value: float = 160.0
@export var min_value: float = 0.0
@export var aux_value: float = 0.0 # roll, boost, temp, fuel, etc.
@export var temp_value: float = 85.0
@export var oil_value: float = 4.5
@export var is_active: bool = false
@export var steer_norm: float = 0.0 # -1.0 to +1.0 for steering wheel rotation
@export var gear_text: String = ""

var smoothed_val: float = 0.0
var smoothed_aux: float = 0.0
var smoothed_temp: float = 85.0
var smoothed_oil: float = 4.5
var smoothed_steer: float = 0.0
var odometer_km: float = 84320.0

func _process(delta: float):
	smoothed_val = lerp(smoothed_val, current_value, delta * 14.0)
	smoothed_aux = lerp(smoothed_aux, aux_value, delta * 12.0)
	smoothed_temp = lerp(smoothed_temp, temp_value, delta * 8.0)
	smoothed_oil = lerp(smoothed_oil, oil_value, delta * 10.0)
	smoothed_steer = lerp(smoothed_steer, steer_norm, delta * 14.0)
	
	if gauge_type in [GaugeType.PANDA_SPEEDO, GaugeType.DELTA_SPEEDO, GaugeType.GWAGEN_SPEEDO, GaugeType.FIAT127_SPEEDO, GaugeType.GOLF_SPEEDO, GaugeType.RENAULT4_SPEEDO, GaugeType.BMW_SPEEDO, GaugeType.A250_CLUSTER]:
		odometer_km += (smoothed_val / 3600.0) * delta
	queue_redraw()

func _draw():
	var rect = Rect2(Vector2.ZERO, size)
	var center = rect.size * 0.5
	var radius = min(center.x, center.y) - 6.0
	
	match gauge_type:
		GaugeType.PANDA_SPEEDO:
			draw_panda_speedo(rect, center, radius)
		GaugeType.PANDA_TACHO:
			draw_panda_tacho(rect, center, radius)
		GaugeType.PANDA_CLINO:
			draw_panda_clino(rect, center, radius)
		GaugeType.PANDA_CONSOLE:
			draw_panda_console(rect, center)
		GaugeType.DELTA_SPEEDO:
			draw_delta_speedo(rect, center, radius)
		GaugeType.DELTA_TACHO:
			draw_delta_tacho(rect, center, radius)
		GaugeType.DELTA_TURBO:
			draw_delta_turbo(rect, center, radius)
		GaugeType.DELTA_CHECK_PANEL:
			draw_delta_check_panel(rect, center)
		GaugeType.DELTA_AUX:
			draw_delta_aux(rect, center, radius)
		GaugeType.GWAGEN_SPEEDO:
			draw_gwagen_speedo(rect, center, radius)
		GaugeType.GWAGEN_TACHO:
			draw_gwagen_tacho(rect, center, radius)
		GaugeType.GWAGEN_KOMBI:
			draw_gwagen_kombi(rect, center, radius)
		GaugeType.GWAGEN_DIFFS:
			draw_gwagen_diffs(rect, center)
		GaugeType.GWAGEN_CONSOLE:
			draw_gwagen_console(rect, center)
		GaugeType.FIAT127_SPEEDO:
			draw_fiat127_speedo(rect, center, radius)
		GaugeType.FIAT127_CONSOLE:
			draw_fiat127_console(rect, center)
		GaugeType.GOLF_SPEEDO:
			draw_golf_speedo(rect, center, radius)
		GaugeType.GOLF_TACHO:
			draw_golf_tacho(rect, center, radius)
		GaugeType.GOLF_MFA_AUX:
			draw_golf_mfa_aux(rect, center, radius)
		GaugeType.GOLF_CONSOLE:
			draw_golf_console(rect, center)
		GaugeType.RENAULT4_SPEEDO:
			draw_renault4_speedo(rect, center, radius)
		GaugeType.RENAULT4_CONSOLE:
			draw_renault4_console(rect, center)
		GaugeType.BMW_SPEEDO:
			draw_bmw_speedo(rect, center, radius)
		GaugeType.BMW_TACHO_ECONO:
			draw_bmw_tacho_econo(rect, center, radius)
		GaugeType.BMW_CONSOLE:
			draw_bmw_console(rect, center)
		GaugeType.A250_CLUSTER:
			draw_a250_cluster(rect, center, radius)
		GaugeType.A250_SCREEN:
			draw_a250_screen(rect, center)
		GaugeType.A250_CONSOLE:
			draw_a250_console(rect, center)
		# 9. ALFA ROMEO 8C 2900B
		GaugeType.ALFA8C_SPEEDO:
			draw_alfa8c_speedo(rect, center, radius)
		GaugeType.ALFA8C_TACHO:
			draw_alfa8c_tacho(rect, center, radius)
		GaugeType.ALFA8C_CONSOLE:
			draw_alfa8c_console(rect, center)
		# 10. FIAT 500 TOPOLINO
		GaugeType.TOPOLINO_SPEEDO:
			draw_topolino_speedo(rect, center, radius)
		GaugeType.TOPOLINO_CONSOLE:
			draw_topolino_console(rect, center)
		# 11. LANCIA AURELIA B20 GT
		GaugeType.AURELIA_SPEEDO:
			draw_aurelia_speedo(rect, center, radius)
		GaugeType.AURELIA_TACHO:
			draw_aurelia_tacho(rect, center, radius)
		GaugeType.AURELIA_CONSOLE:
			draw_aurelia_console(rect, center)
		# 12. ALFA ROMEO GIULIA SPRINT GTA
		GaugeType.ALFAGTA_SPEEDO:
			draw_alfagta_speedo(rect, center, radius)
		GaugeType.ALFAGTA_TACHO:
			draw_alfagta_tacho(rect, center, radius)
		GaugeType.ALFAGTA_CONSOLE:
			draw_alfagta_console(rect, center)
		# 13. LANCIA STRATOS HF
		GaugeType.STRATOS_SPEEDO:
			draw_stratos_speedo(rect, center, radius)
		GaugeType.STRATOS_TACHO:
			draw_stratos_tacho(rect, center, radius)
		GaugeType.STRATOS_CONSOLE:
			draw_stratos_console(rect, center)
		# 14. FIAT 131 ABARTH RALLY
		GaugeType.FIAT131_SPEEDO:
			draw_fiat131_speedo(rect, center, radius)
		GaugeType.FIAT131_TACHO:
			draw_fiat131_tacho(rect, center, radius)
		GaugeType.FIAT131_CONSOLE:
			draw_fiat131_console(rect, center)

# ==============================================================================
# 1. PANDA 4x4 (1983) GIUGIARO COCKPIT - VEGLIA BORLETTI
# ==============================================================================
func draw_panda_speedo(rect: Rect2, _center: Vector2, _radius: float):
	# Authentic Veglia Borletti "Quadro a Cubo" Binnacle in textured matte black
	draw_rect(rect, Color(0.07, 0.08, 0.07, 0.98), true)
	draw_rect(rect, Color(0.24, 0.28, 0.24, 0.90), false, 2.0)
	
	# Bezel inner groove
	draw_rect(Rect2(rect.position + Vector2(3, 3), rect.size - Vector2(6, 6)), Color(0.04, 0.05, 0.04, 0.95), false, 1.0)
	
	var gear_label = ("[" + gear_text + "]") if gear_text != "" else "4WD STEYR"
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "VEGLIA BORLETTI", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.85, 0.90, 0.85))
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 70, 16), gear_label, HORIZONTAL_ALIGNMENT_RIGHT, -1, 10, Color(0.65, 0.85, 0.70))
	
	# --- MAIN DIAL: Authentic Analog Speedometer Dial ---
	var dial_r = clamp(rect.size.y * 0.42, 36.0, 45.0)
	var dial_c = Vector2(dial_r + 14.0, rect.size.y * 0.54)
	
	draw_circle(dial_c, dial_r + 3.0, Color(0.14, 0.16, 0.14))
	draw_circle(dial_c, dial_r, Color(0.03, 0.04, 0.03))
	draw_arc(dial_c, dial_r, 0.0, TAU, 36, Color(0.30, 0.36, 0.30), 1.5)
	
	var start_angle = deg_to_rad(140.0)
	var end_angle = deg_to_rad(400.0)
	draw_arc(dial_c, dial_r - 2.0, start_angle, end_angle, 32, Color(0.40, 0.48, 0.40), 1.2)
	
	for spd in range(0, 161, 10):
		var t = float(spd) / 160.0
		var ang = lerp(start_angle, end_angle, t)
		var dir = Vector2(cos(ang), sin(ang))
		var is_major = (spd % 20 == 0)
		var tick_len = 6.0 if is_major else 3.5
		
		# Characteristic Fiat / Veglia markings (orange at 50 km/h city limit and 130 km/h highway)
		var tick_col = Color(0.88, 0.92, 0.88)
		if spd == 50: tick_col = Color(1.0, 0.50, 0.10)
		elif spd == 130: tick_col = Color(1.0, 0.30, 0.20)
			
		var p_outer = dial_c + dir * (dial_r - 2.0)
		var p_inner = dial_c + dir * (dial_r - 2.0 - tick_len)
		draw_line(p_inner, p_outer, tick_col, 2.0 if is_major else 1.2)
		
		if is_major:
			var p_text = dial_c + dir * (dial_r - 13.0) + Vector2(-6, 3.5)
			draw_string(ThemeDB.fallback_font, p_text, str(spd), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.88, 0.92, 0.88))
			
	# Dial branding text
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 14, dial_c.y - 12), "km/h", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.60, 0.70, 0.62))
	
	# --- AUTHENTIC ROLLING MECHANICAL DRUM ODOMETER (inside lower dial) ---
	var odo_w = 46.0
	var odo_h = 13.0
	var odo_pos = Vector2(dial_c.x - odo_w * 0.5, dial_c.y + 10.0)
	draw_rect(Rect2(odo_pos, Vector2(odo_w, odo_h)), Color(0.01, 0.01, 0.01), true)
	draw_rect(Rect2(odo_pos, Vector2(odo_w, odo_h)), Color(0.35, 0.42, 0.36), false, 1.0)
	
	var whole_km = int(odometer_km)
	var tenth_km = int(fmod(odometer_km * 10.0, 10.0))
	var km_str = "%05d" % (whole_km % 100000)
	
	# 5 black drums for km
	for d_i in range(5):
		var drum_x = odo_pos.x + float(d_i) * 7.5
		draw_rect(Rect2(drum_x, odo_pos.y, 7.0, odo_h), Color(0.06, 0.07, 0.06), true)
		draw_string(ThemeDB.fallback_font, Vector2(drum_x + 1.2, odo_pos.y + 10.0), km_str[d_i], HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.92, 0.94, 0.90))
	
	# 1 red drum for tenths of km
	var red_drum_x = odo_pos.x + 38.0
	draw_rect(Rect2(red_drum_x, odo_pos.y, 7.5, odo_h), Color(0.75, 0.15, 0.12), true)
	draw_string(ThemeDB.fallback_font, Vector2(red_drum_x + 1.5, odo_pos.y + 10.0), str(tenth_km), HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color.WHITE)
	
	# --- ANALOG SPEEDO NEEDLE ---
	var val_t = clamp(smoothed_val / 160.0, 0.0, 1.0)
	var needle_ang = lerp(start_angle, end_angle, val_t)
	var needle_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	draw_line(dial_c + Vector2(1.5, 1.5), dial_c + needle_dir * (dial_r - 2.0) + Vector2(1.5, 1.5), Color(0, 0, 0, 0.55), 3.0)
	draw_line(dial_c - needle_dir * 5.0, dial_c + needle_dir * (dial_r - 3.0), Color(1.0, 0.45, 0.08), 2.5)
	draw_circle(dial_c, 5.0, Color(0.12, 0.14, 0.12))
	draw_circle(dial_c, 2.2, Color(0.85, 0.90, 0.88))
	
	# --- RIGHT SECTION: INTEGRATED VEGLIA AUXILIARY GAUGES & WARNING LAMPS ---
	var right_x = dial_c.x + dial_r + 14.0
	var right_w = max(45.0, rect.size.x - right_x - 10.0)
	
	# 1. Fuel Gauge (Livello Carburante)
	var fuel_y = 26.0
	draw_string(ThemeDB.fallback_font, Vector2(right_x, fuel_y), "BENZINA", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.70, 0.80, 0.72))
	draw_line(Vector2(right_x, fuel_y + 12), Vector2(right_x + right_w, fuel_y + 12), Color(0.20, 0.28, 0.22), 2.0)
	
	var fuel_pct = clamp(aux_value / 35.0, 0.0, 1.0) # 35L tank
	var fuel_needle_x = right_x + fuel_pct * right_w
	draw_line(Vector2(fuel_needle_x, fuel_y + 5), Vector2(fuel_needle_x, fuel_y + 16), Color(1.0, 0.50, 0.10), 2.5)
	draw_string(ThemeDB.fallback_font, Vector2(right_x, fuel_y + 24), "R", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.35, 0.20))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w * 0.5 - 4, fuel_y + 24), "½", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.75, 0.82, 0.75))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w - 6, fuel_y + 24), "4/4", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.75, 0.82, 0.75))
	
	# Fuel reserve light
	var is_reserve = aux_value < 6.5
	var res_col = Color(1.0, 0.50, 0.10) if is_reserve else Color(0.25, 0.18, 0.10)
	draw_circle(Vector2(right_x + 12, fuel_y + 21), 3.0, res_col)
	
	# 2. Coolant Temperature (Temperatura Acqua)
	var temp_y = 56.0
	draw_string(ThemeDB.fallback_font, Vector2(right_x, temp_y), "ACQUA", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.70, 0.80, 0.72))
	draw_line(Vector2(right_x, temp_y + 12), Vector2(right_x + right_w, temp_y + 12), Color(0.20, 0.28, 0.22), 2.0)
	var temp_pct = clamp((smoothed_temp - 40.0) / 80.0, 0.0, 1.0) # 40C to 120C
	var temp_needle_x = right_x + temp_pct * right_w
	draw_line(Vector2(temp_needle_x, temp_y + 5), Vector2(temp_needle_x, temp_y + 16), Color(1.0, 0.50, 0.10), 2.5)
	draw_string(ThemeDB.fallback_font, Vector2(right_x, temp_y + 24), "C", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.35, 0.75, 0.95))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w * 0.5 - 6, temp_y + 24), "90°", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.75, 0.82, 0.75))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w - 6, temp_y + 24), "H", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.25, 0.20))
	
	# 3. Authentic Veglia Warning Light Strip (GEN, OLIO, LUCI, 4WD)
	var lamp_y = 88.0
	var lamps = [
		{ "label": "GEN", "col": Color(1.0, 0.20, 0.15) if smoothed_val < 3.0 else Color(0.25, 0.08, 0.08) },
		{ "label": "OLIO", "col": Color(1.0, 0.20, 0.15) if smoothed_val < 3.0 else Color(0.25, 0.08, 0.08) },
		{ "label": "LUCI", "col": Color(0.25, 0.95, 0.45) },
	]
	var lamp_w = 20.0
	for l_idx in range(lamps.size()):
		var lx = right_x + float(l_idx) * (lamp_w + 3.0)
		var lamp = lamps[l_idx]
		draw_rect(Rect2(lx, lamp_y, lamp_w, 11), lamp.col * 0.4, true)
		draw_rect(Rect2(lx, lamp_y, lamp_w, 11), lamp.col, false, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(lx + 2.0, lamp_y + 9), lamp.label, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, lamp.col)
		
	# 4. Illuminated 4WD Steyr-Puch indicator lamp
	var steyr_4wd_col = Color(0.20, 1.00, 0.40) if is_active else Color(0.12, 0.24, 0.15)
	var steyr_rect = Rect2(right_x + 72.0, lamp_y - 1, 38.0, 13.0)
	draw_rect(steyr_rect, steyr_4wd_col * (0.35 if is_active else 0.15), true)
	draw_rect(steyr_rect, steyr_4wd_col, false, 1.2 if is_active else 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(steyr_rect.position.x + 3.0, lamp_y + 9), "4WD STEYR", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, steyr_4wd_col)

func draw_panda_tacho(rect: Rect2, center: Vector2, radius: float):
	# Authentic supplementary Veglia round rev counter pod (A112 Abarth style)
	draw_rect(rect, Color(0.07, 0.08, 0.07, 0.98), true)
	draw_rect(rect, Color(0.24, 0.28, 0.24, 0.90), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "CONTAGIRI A112", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.85, 0.90, 0.85))
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 58, 16), "RPM x1000", HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.65, 0.80, 0.68))
	
	var dial_r = min(radius - 6.0, 42.0)
	var dial_c = Vector2(center.x, center.y + 4.0)
	
	draw_circle(dial_c, dial_r + 3.0, Color(0.14, 0.16, 0.14))
	draw_circle(dial_c, dial_r, Color(0.03, 0.04, 0.03))
	
	var start_ang = deg_to_rad(140.0)
	var end_ang = deg_to_rad(400.0)
	draw_arc(dial_c, dial_r - 2.0, start_ang, end_ang, 32, Color(0.40, 0.48, 0.40), 1.2)
	
	# Yellow caution arc from 5.5 to 6.0, redline arc from 6.0 to 7.0
	var yellow_ang = lerp(start_ang, end_ang, 5.5 / 7.0)
	var red_ang = lerp(start_ang, end_ang, 6.0 / 7.0)
	draw_arc(dial_c, dial_r - 3.5, yellow_ang, red_ang, 6, Color(1.0, 0.75, 0.2), 3.0)
	draw_arc(dial_c, dial_r - 3.5, red_ang, end_ang, 8, Color(0.95, 0.20, 0.15), 3.0)
	
	for rpm_k in range(0, 8):
		var t = float(rpm_k) / 7.0
		var ang = lerp(start_ang, end_ang, t)
		var dir = Vector2(cos(ang), sin(ang))
		var is_red = (rpm_k >= 6)
		var col = Color(0.95, 0.20, 0.15) if is_red else (Color(1.0, 0.75, 0.2) if rpm_k == 5 else Color(0.88, 0.92, 0.88))
		
		var p_out = dial_c + dir * (dial_r - 2.0)
		var p_in = dial_c + dir * (dial_r - 7.0)
		draw_line(p_in, p_out, col, 2.0)
		
		var p_txt = dial_c + dir * (dial_r - 15.0) + Vector2(-4, 3.5)
		draw_string(ThemeDB.fallback_font, p_txt, str(rpm_k), HORIZONTAL_ALIGNMENT_CENTER, -1, 9, col)
		
	var rpm_val = smoothed_val # 0.85 to 6.0
	var rpm_t = clamp((rpm_val - 0.0) / 7.0, 0.0, 1.0)
	var needle_ang = lerp(start_ang, end_ang, rpm_t)
	var n_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	draw_line(dial_c + Vector2(1.5, 1.5), dial_c + n_dir * (dial_r - 2.0) + Vector2(1.5, 1.5), Color(0, 0, 0, 0.55), 3.0)
	draw_line(dial_c - n_dir * 5.0, dial_c + n_dir * (dial_r - 3.0), Color(1.0, 0.45, 0.08), 2.5)
	draw_circle(dial_c, 5.0, Color(0.12, 0.14, 0.12))
	draw_circle(dial_c, 2.2, Color(0.85, 0.90, 0.88))
	
	# Brand sub-label
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 18, dial_c.y + 16), "VEGLIA", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.60, 0.70, 0.62))

func draw_panda_clino(rect: Rect2, center: Vector2, radius: float):
	# Authentic Steyr-Puch Dual Inclinometer Box
	draw_rect(rect, Color(0.07, 0.08, 0.07, 0.98), true)
	draw_rect(rect, Color(0.24, 0.28, 0.24, 0.90), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "CLINOMETRO 4x4", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.85, 0.90, 0.85))
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 72, 16), "STEYR-PUCH", HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.65, 0.80, 0.68))
	
	var half_w = rect.size.x * 0.5
	var left_c = Vector2(half_w * 0.5, center.y + 5.0)
	var right_c = Vector2(half_w * 1.5, center.y + 5.0)
	var sub_r = min(half_w * 0.44, radius - 8.0)
	
	# Dial 1: PITCH (Salita / Discesa)
	draw_circle(left_c, sub_r + 2.0, Color(0.12, 0.14, 0.12))
	draw_circle(left_c, sub_r, Color(0.04, 0.05, 0.04))
	draw_arc(left_c, sub_r, 0, TAU, 32, Color(0.35, 0.45, 0.38), 1.5)
	draw_line(Vector2(left_c.x - sub_r + 4, left_c.y), Vector2(left_c.x + sub_r - 4, left_c.y), Color(0.3, 0.4, 0.35), 1.0)
	
	# Pitch angle graduation ticks (-30, -15, 0, +15, +30)
	for p_tick in [-30, -15, 0, 15, 30]:
		var t_ang = deg_to_rad(-90.0 + float(p_tick) * 2.0)
		var t_dir = Vector2(cos(t_ang), sin(t_ang))
		draw_line(left_c + t_dir * (sub_r - 5), left_c + t_dir * (sub_r - 1), Color(0.65, 0.75, 0.68), 1.2)
	
	var pitch_deg = clamp(smoothed_val, -35.0, 35.0)
	var p_ang = deg_to_rad(-90.0 + pitch_deg * 2.0)
	var p_dir = Vector2(cos(p_ang), sin(p_ang))
	draw_line(left_c, left_c + p_dir * (sub_r - 3.0), Color(0.2, 0.95, 0.4), 2.0)
	draw_circle(left_c, 3.5, Color(0.2, 0.95, 0.4))
	draw_string(ThemeDB.fallback_font, Vector2(left_c.x - 24, rect.size.y - 6), "%+02d° PITCH" % int(round(pitch_deg)), HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color(0.9, 0.95, 0.9))
	
	# Dial 2: ROLL (Inclinazione Laterale con Sagoma Panda 4x4)
	draw_circle(right_c, sub_r + 2.0, Color(0.12, 0.14, 0.12))
	draw_circle(right_c, sub_r, Color(0.04, 0.05, 0.04))
	draw_arc(right_c, sub_r, 0, TAU, 32, Color(0.35, 0.45, 0.38), 1.5)
	
	var roll_deg = clamp(smoothed_aux, -35.0, 35.0)
	var r_ang = deg_to_rad(-roll_deg)
	var h_left = right_c + Vector2(-cos(r_ang), -sin(r_ang)) * (sub_r - 4.0)
	var h_right = right_c + Vector2(cos(r_ang), sin(r_ang)) * (sub_r - 4.0)
	draw_line(h_left, h_right, Color(0.95, 0.75, 0.2), 2.0)
	
	# Boxy Fiat Panda silhouette tilting on artificial horizon
	var car_w = 12.0; var car_h = 7.0
	var pts = [
		right_c + Vector2(-car_w, -car_h).rotated(r_ang),
		right_c + Vector2(car_w, -car_h).rotated(r_ang),
		right_c + Vector2(car_w, 2.0).rotated(r_ang),
		right_c + Vector2(-car_w, 2.0).rotated(r_ang)
	]
	draw_colored_polygon(pts, Color(0.2, 0.95, 0.4, 0.85))
	draw_string(ThemeDB.fallback_font, Vector2(right_c.x - 22, rect.size.y - 6), "%+02d° ROLL" % int(round(roll_deg)), HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color(0.9, 0.95, 0.9))

func draw_panda_console(rect: Rect2, center: Vector2):
	# Authentic Giorgetto Giugiaro "Marsupio" Padded Fabric Pocket & Steyr 4WD Lever
	draw_rect(rect, Color(0.12, 0.14, 0.13, 0.98), true)
	draw_rect(rect, Color(0.26, 0.32, 0.26, 0.90), false, 2.0)
	
	# Fabric weave texture / ribbing stitches of the Giugiaro pouch
	for rib_idx in range(4):
		var y_stitch = 20.0 + float(rib_idx) * 18.0
		draw_line(Vector2(6, y_stitch), Vector2(rect.size.x - 6, y_stitch), Color(0.18, 0.22, 0.19, 0.8), 1.0)
		
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "GIUGIARO MARSUPIO", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.85, 0.90, 0.85))
	
	# Left: Dual Heating/Ventilation Slide Controls
	var slide_w = rect.size.x * 0.40
	var slider_y1 = center.y - 10.0
	var slider_y2 = center.y + 8.0
	
	draw_string(ThemeDB.fallback_font, Vector2(16, slider_y1 - 3), "ARIA FREDDA", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.40, 0.70, 0.95))
	draw_rect(Rect2(16, slider_y1, slide_w, 4), Color(0.05, 0.06, 0.05), true)
	draw_line(Vector2(16, slider_y1 + 2), Vector2(16 + slide_w, slider_y1 + 2), Color(0.25, 0.65, 0.95), 2.0)
	draw_circle(Vector2(16 + slide_w * 0.65, slider_y1 + 2), 4.0, Color(0.88, 0.90, 0.88))
	
	draw_string(ThemeDB.fallback_font, Vector2(16, slider_y2 - 3), "RISCALDAMENTO", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.95, 0.45, 0.30))
	draw_rect(Rect2(16, slider_y2, slide_w, 4), Color(0.05, 0.06, 0.05), true)
	draw_line(Vector2(16, slider_y2 + 2), Vector2(16 + slide_w, slider_y2 + 2), Color(0.95, 0.30, 0.20), 2.0)
	draw_circle(Vector2(16 + slide_w * 0.35, slider_y2 + 2), 4.0, Color(0.88, 0.90, 0.88))
	
	# Right: Authentic Steyr-Puch 4WD Mechanical Pull Lever
	var lever_x = rect.size.x * 0.75
	var boot_w = 40.0
	var boot_h = 32.0
	var boot_rect = Rect2(lever_x - boot_w * 0.5, center.y - 8.0, boot_w, boot_h)
	draw_rect(boot_rect, Color(0.05, 0.06, 0.05), true)
	draw_rect(boot_rect, Color(0.30, 0.38, 0.32), false, 1.2)
	
	# Rubber bellows ribs
	for b_y in range(int(boot_rect.position.y) + 4, int(boot_rect.position.y + boot_h), 6):
		draw_line(Vector2(boot_rect.position.x + 3, b_y), Vector2(boot_rect.position.x + boot_w - 3, b_y), Color(0.18, 0.22, 0.18), 2.0)
		
	# Lever knob position: pulled UP if 4WD is active!
	var knob_y = boot_rect.position.y + (2.0 if is_active else 14.0)
	# Chrome lever rod
	draw_line(Vector2(lever_x, boot_rect.position.y + 22.0), Vector2(lever_x, knob_y), Color(0.70, 0.75, 0.72), 3.5)
	
	# Fluted Steyr 4WD knob (Yellow top with black grip)
	var knob_col = Color(1.0, 0.78, 0.15) if is_active else Color(0.65, 0.60, 0.40)
	draw_circle(Vector2(lever_x, knob_y), 7.5, Color(0.10, 0.12, 0.10))
	draw_circle(Vector2(lever_x, knob_y), 6.0, knob_col)
	draw_string(ThemeDB.fallback_font, Vector2(lever_x - 6.0, knob_y + 3.0), "4WD", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color.BLACK)
	
	var status_text = "4WD INSERITA" if is_active else "2WD ANTERIORE"
	var status_col = Color(0.20, 1.00, 0.40) if is_active else Color(0.60, 0.65, 0.60)
	draw_string(ThemeDB.fallback_font, Vector2(lever_x - 36, rect.size.y - 6), status_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 8, status_col)

# ==============================================================================
# 2. LANCIA DELTA HF INTEGRALE EVOLUZIONE (1991) - VEGLIA CORSE
# ==============================================================================
func draw_delta_speedo(rect: Rect2, _center: Vector2, _radius: float):
	draw_rect(rect, Color(0.06, 0.06, 0.07, 0.96), true)
	draw_rect(rect, Color(0.45, 0.36, 0.14, 0.85), false, 2.0)
	
	var gear_label = ("[" + gear_text + "]") if gear_text != "" else "MARTINI RACING"
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "VEGLIA CORSE", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.82, 0.15))
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 70, 16), gear_label, HORIZONTAL_ALIGNMENT_RIGHT, -1, 10, Color(0.95, 0.45, 0.25))
	
	var dial_r = clamp(rect.size.y * 0.38, 32.0, 42.0)
	var dial_c = Vector2(dial_r + 14.0, rect.size.y * 0.54)
	
	draw_circle(dial_c, dial_r + 3.0, Color(0.12, 0.12, 0.14))
	draw_circle(dial_c, dial_r, Color(0.04, 0.04, 0.05))
	draw_arc(dial_c, dial_r, 0.0, TAU, 36, Color(0.40, 0.32, 0.15), 1.5)
	
	var start_angle = deg_to_rad(135.0)
	var end_angle = deg_to_rad(405.0)
	draw_arc(dial_c, dial_r - 2.0, start_angle, end_angle, 32, Color(0.50, 0.40, 0.18), 1.5)
	
	for spd in range(0, 261, 20):
		var t = float(spd) / 260.0
		var ang = lerp(start_angle, end_angle, t)
		var dir = Vector2(cos(ang), sin(ang))
		var is_major = (spd % 40 == 0)
		var p_outer = dial_c + dir * (dial_r - 2.0)
		var p_inner = dial_c + dir * (dial_r - 2.0 - (7.0 if is_major else 4.5))
		draw_line(p_inner, p_outer, Color(1.0, 0.80, 0.12), 2.0 if is_major else 1.2)
		
		if is_major:
			var p_text = dial_c + dir * (dial_r - 14.0) + Vector2(-6, 3.5)
			draw_string(ThemeDB.fallback_font, p_text, str(spd), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(1.0, 0.80, 0.12))
			
	var val_t = clamp(smoothed_val / 260.0, 0.0, 1.0)
	var needle_ang = lerp(start_angle, end_angle, val_t)
	var needle_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	draw_line(dial_c + Vector2(1.5, 1.5), dial_c + needle_dir * (dial_r - 2.0) + Vector2(1.5, 1.5), Color(0, 0, 0, 0.55), 3.0)
	draw_line(dial_c - needle_dir * 5.0, dial_c + needle_dir * (dial_r - 3.0), Color(0.95, 0.15, 0.12), 2.8)
	draw_circle(dial_c, 4.5, Color(0.12, 0.12, 0.14))
	draw_circle(dial_c, 2.0, Color(0.95, 0.15, 0.12))
	
	# --- AUTHENTIC VEGLIA CORSE MECHANICAL ROLLING TRIP & TOTAL ODOMETER ---
	var odo_w = 44.0
	var odo_h = 12.0
	var odo_pos = Vector2(dial_c.x - odo_w * 0.5, dial_c.y + 11.0)
	draw_rect(Rect2(odo_pos, Vector2(odo_w, odo_h)), Color(0.02, 0.02, 0.02), true)
	draw_rect(Rect2(odo_pos, Vector2(odo_w, odo_h)), Color(0.50, 0.40, 0.15), false, 1.0)
	var trip_km = fmod(odometer_km, 1000.0)
	draw_string(ThemeDB.fallback_font, Vector2(odo_pos.x + 2.0, odo_pos.y + 9.5), "%05.1f" % trip_km, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(1.0, 0.85, 0.15))
	
	# Dial sub-badge
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 14, dial_c.y - 12), "km/h", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(1.0, 0.80, 0.20))
	
	# Right Section: Authentic Lancia Martini Auxiliary Analog Gauges
	var right_x = dial_c.x + dial_r + 14.0
	var right_w = max(45.0, rect.size.x - right_x - 10.0)
	
	# 1. Fuel Gauge (57L tank)
	var fuel_y = 26.0
	draw_string(ThemeDB.fallback_font, Vector2(right_x, fuel_y), "BENZINA (L)", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.82, 0.20))
	draw_line(Vector2(right_x, fuel_y + 12), Vector2(right_x + right_w, fuel_y + 12), Color(0.35, 0.28, 0.12), 2.0)
	var fuel_pct = clamp(aux_value / 57.0, 0.0, 1.0)
	var fuel_needle_x = right_x + fuel_pct * right_w
	draw_line(Vector2(fuel_needle_x, fuel_y + 5), Vector2(fuel_needle_x, fuel_y + 16), Color(0.95, 0.20, 0.15), 2.5)
	draw_string(ThemeDB.fallback_font, Vector2(right_x, fuel_y + 24), "0", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.30, 0.20))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w * 0.5 - 6, fuel_y + 24), "30", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.82, 0.20))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w - 10, fuel_y + 24), "57", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.82, 0.20))
	
	# 2. Water Temperature Gauge
	var temp_y = 56.0
	draw_string(ThemeDB.fallback_font, Vector2(right_x, temp_y), "ACQUA (°C)", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.82, 0.20))
	draw_line(Vector2(right_x, temp_y + 12), Vector2(right_x + right_w, temp_y + 12), Color(0.35, 0.28, 0.12), 2.0)
	var temp_pct = clamp((smoothed_temp - 40.0) / 80.0, 0.0, 1.0)
	var temp_needle_x = right_x + temp_pct * right_w
	draw_line(Vector2(temp_needle_x, temp_y + 5), Vector2(temp_needle_x, temp_y + 16), Color(0.95, 0.20, 0.15), 2.5)
	draw_string(ThemeDB.fallback_font, Vector2(right_x, temp_y + 24), "40", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.40, 0.75, 0.95))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w * 0.5 - 6, temp_y + 24), "90", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.82, 0.20))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w - 14, temp_y + 24), "120", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.25, 0.20))
	
	# 3. Torsen AWD Status Badge
	var badge_y = 88.0
	var torsen_rect = Rect2(right_x, badge_y - 2, right_w, 14.0)
	draw_rect(torsen_rect, Color(0.12, 0.25, 0.14), true)
	draw_rect(torsen_rect, Color(0.25, 0.85, 0.40), false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(right_x + 6, badge_y + 9), "TORSEN AWD PERMANENTE 47:53", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.40, 0.95, 0.55))

func draw_delta_tacho(rect: Rect2, center: Vector2, radius: float):
	draw_rect(rect, Color(0.06, 0.06, 0.07, 0.96), true)
	draw_rect(rect, Color(0.45, 0.36, 0.14, 0.85), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "CONTAGIRI 16V", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.82, 0.15))
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 55, 16), "x1000 RPM", HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.95, 0.45, 0.25))
	
	var dial_r = min(radius - 6.0, 42.0)
	var dial_c = Vector2(center.x, center.y + 4.0)
	
	draw_circle(dial_c, dial_r + 3.0, Color(0.12, 0.12, 0.14))
	draw_circle(dial_c, dial_r, Color(0.04, 0.04, 0.05))
	
	var start_ang = deg_to_rad(135.0)
	var end_ang = deg_to_rad(405.0)
	draw_arc(dial_c, dial_r - 2.0, start_ang, end_ang, 32, Color(0.40, 0.32, 0.15), 1.5)
	
	# Redline arc from 6.8k to 8.0k
	var red_start = lerp(start_ang, end_ang, 6.8 / 8.0)
	draw_arc(dial_c, dial_r - 4.0, red_start, end_ang, 12, Color(0.95, 0.15, 0.12), 4.0)
	
	for rpm_k in range(0, 9):
		var t = float(rpm_k) / 8.0
		var ang = lerp(start_ang, end_ang, t)
		var dir = Vector2(cos(ang), sin(ang))
		var is_red = (rpm_k >= 7)
		var col = Color(0.95, 0.15, 0.12) if is_red else (Color(1.0, 0.75, 0.15) if rpm_k == 6 else Color(1.0, 0.85, 0.18))
		
		var p_out = dial_c + dir * (dial_r - 2.0)
		var p_in = dial_c + dir * (dial_r - 8.0)
		draw_line(p_in, p_out, col, 2.0)
		
		var p_txt = dial_c + dir * (dial_r - 16.0) + Vector2(-4, 3.5)
		draw_string(ThemeDB.fallback_font, p_txt, str(rpm_k), HORIZONTAL_ALIGNMENT_CENTER, -1, 9, col)
		
	# RPM needle
	var rpm_val = smoothed_val # 950 to 6800+
	var rpm_t = clamp(rpm_val / 8000.0, 0.0, 1.0)
	var needle_ang = lerp(start_ang, end_ang, rpm_t)
	var n_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	draw_line(dial_c - n_dir * 5.0, dial_c + n_dir * (dial_r - 3.0), Color(0.95, 0.15, 0.12), 2.8)
	draw_circle(dial_c, 4.5, Color(0.12, 0.12, 0.14))
	draw_circle(dial_c, 2.0, Color(0.95, 0.15, 0.12))
	
	# Center HF badge
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 18, dial_c.y + 16), "HF TURBO", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(1.0, 0.85, 0.2))

func draw_delta_turbo(rect: Rect2, center: Vector2, radius: float):
	draw_rect(rect, Color(0.06, 0.06, 0.07, 0.96), true)
	draw_rect(rect, Color(0.45, 0.36, 0.14, 0.85), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "TURBO GARRETT T3", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.35, 0.2))
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 38, 16), "BAR", HORIZONTAL_ALIGNMENT_RIGHT, -1, 10, Color(1.0, 0.82, 0.15))
	
	var gauge_c = Vector2(center.x, center.y + 4.0)
	var start_angle = deg_to_rad(140.0)
	var end_angle = deg_to_rad(400.0)
	var r = min(radius - 8.0, 42.0)
	
	for b_idx in range(-5, 16, 5):
		var b_val = float(b_idx) * 0.1
		var t = (b_val + 0.5) / 2.0
		var ang = lerp(start_angle, end_angle, t)
		var dir = Vector2(cos(ang), sin(ang))
		var p_outer = gauge_c + dir * r
		var p_inner = gauge_c + dir * (r - 7.0)
		var col = Color(1.0, 0.25, 0.2) if b_val > 1.0 else Color(1.0, 0.80, 0.15)
		draw_line(p_inner, p_outer, col, 2.0)
		
		var p_text = gauge_c + dir * (r - 18.0) + Vector2(-6, 4)
		draw_string(ThemeDB.fallback_font, p_text, "%.1f" % b_val, HORIZONTAL_ALIGNMENT_CENTER, -1, 9, col)
		
	var val_t = clamp((smoothed_val + 0.5) / 2.0, 0.0, 1.0)
	var needle_ang = lerp(start_angle, end_angle, val_t)
	var needle_dir = Vector2(cos(needle_ang), sin(needle_ang))
	draw_line(gauge_c, gauge_c + needle_dir * (r - 4.0), Color(0.95, 0.15, 0.12), 2.5)
	draw_circle(gauge_c, 4.0, Color(0.95, 0.15, 0.12))
	
	var is_overboost = smoothed_val > 1.05
	var lamp_col = Color(1.0, 0.15, 0.15, 1.0) if is_overboost else Color(0.30, 0.10, 0.10, 0.6)
	draw_rect(Rect2(center.x - 36, rect.size.y - 18, 72, 12), lamp_col, true)
	draw_string(ThemeDB.fallback_font, Vector2(center.x - 32, rect.size.y - 8), "OVERBOOST", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color.WHITE if is_overboost else Color(0.65, 0.55, 0.55))

func draw_delta_check_panel(rect: Rect2, center: Vector2):
	draw_rect(rect, Color(0.06, 0.06, 0.07, 0.96), true)
	draw_rect(rect, Color(0.45, 0.36, 0.14, 0.85), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 14), "CHECK CONTROL WRC", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(1.0, 0.82, 0.15))
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 55, 14), "MARTINI", HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.85, 0.35, 0.25))
	
	var led_names = ["OLIO", "FRENI", "ACQUA", "TORSEN", "BATT", "BENZ"]
	var grid_w = rect.size.x - 24.0
	var col_w = grid_w / 3.0
	
	for idx in range(6):
		var row = idx / 3
		var col = idx % 3
		var lx = 12.0 + float(col) * col_w
		var ly = 24.0 + float(row) * 26.0
		
		var lamp_rect = Rect2(lx + 2, ly, col_w - 4, 20)
		var is_active_led = (idx == 3) # Torsen active green
		var led_bg = Color(0.12, 0.85, 0.25, 0.9) if is_active_led else Color(0.14, 0.14, 0.16)
		draw_rect(lamp_rect, led_bg, true)
		draw_rect(lamp_rect, Color(0.35, 0.35, 0.38), false, 1.0)
		
		var t_col = Color.BLACK if is_active_led else Color(0.7, 0.72, 0.75)
		draw_string(ThemeDB.fallback_font, Vector2(lamp_rect.position.x + 3, lamp_rect.position.y + 14), led_names[idx], HORIZONTAL_ALIGNMENT_CENTER, -1, 8, t_col)

func draw_delta_aux(rect: Rect2, center: Vector2, radius: float):
	draw_rect(rect, Color(0.06, 0.06, 0.07, 0.96), true)
	draw_rect(rect, Color(0.45, 0.36, 0.14, 0.85), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "BENZINA & PRESS. OLIO", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.82, 0.15))
	
	var half_w = rect.size.x * 0.5
	var left_c = Vector2(half_w * 0.5, center.y + 6.0)
	var right_c = Vector2(half_w * 1.5, center.y + 6.0)
	var sub_r = min(half_w * 0.44, radius - 8.0)
	
	# Left: FUEL
	draw_circle(left_c, sub_r, Color(0.04, 0.04, 0.05))
	draw_arc(left_c, sub_r, deg_to_rad(140.0), deg_to_rad(400.0), 24, Color(0.40, 0.32, 0.15), 1.5)
	var fuel_t = clamp(smoothed_aux / 57.0, 0.0, 1.0)
	var f_ang = lerp(deg_to_rad(140.0), deg_to_rad(400.0), fuel_t)
	var f_dir = Vector2(cos(f_ang), sin(f_ang))
	draw_line(left_c, left_c + f_dir * (sub_r - 3.0), Color(0.95, 0.15, 0.12), 2.2)
	draw_circle(left_c, 3.0, Color(0.95, 0.15, 0.12))
	draw_string(ThemeDB.fallback_font, Vector2(left_c.x - 20, rect.size.y - 6), "%d L BENZ" % int(round(smoothed_aux)), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(1.0, 0.85, 0.2))
	
	# Right: OIL PRESSURE (0-8 bar)
	draw_circle(right_c, sub_r, Color(0.04, 0.04, 0.05))
	draw_arc(right_c, sub_r, deg_to_rad(140.0), deg_to_rad(400.0), 24, Color(0.40, 0.32, 0.15), 1.5)
	var oil_t = clamp(smoothed_oil / 8.0, 0.0, 1.0)
	var o_ang = lerp(deg_to_rad(140.0), deg_to_rad(400.0), oil_t)
	var o_dir = Vector2(cos(o_ang), sin(o_ang))
	draw_line(right_c, right_c + o_dir * (sub_r - 3.0), Color(0.95, 0.15, 0.12), 2.2)
	draw_circle(right_c, 3.0, Color(0.95, 0.15, 0.12))
	draw_string(ThemeDB.fallback_font, Vector2(right_c.x - 22, rect.size.y - 6), "%.1f BAR OLIO" % smoothed_oil, HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(1.0, 0.85, 0.2))

# ==============================================================================
# 3. MERCEDES-BENZ G-KLASSE W460 (1979) - VDO STUTTGART
# ==============================================================================
func draw_gwagen_speedo(rect: Rect2, _center: Vector2, _radius: float):
	draw_rect(rect, Color(0.07, 0.08, 0.09, 0.96), true)
	draw_rect(rect, Color(0.32, 0.38, 0.42, 0.85), false, 2.0)
	
	var gear_label = ("[" + gear_text + "]") if gear_text != "" else "W460 GELÄNDE"
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "VDO STUTTGART", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.85, 0.90, 0.95))
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 70, 16), gear_label, HORIZONTAL_ALIGNMENT_RIGHT, -1, 10, Color(0.70, 0.78, 0.82))
	
	var dial_r = clamp(rect.size.y * 0.38, 32.0, 42.0)
	var dial_c = Vector2(dial_r + 14.0, rect.size.y * 0.54)
	
	draw_circle(dial_c, dial_r + 3.0, Color(0.12, 0.14, 0.16))
	draw_circle(dial_c, dial_r, Color(0.04, 0.05, 0.06))
	draw_arc(dial_c, dial_r, 0.0, TAU, 36, Color(0.35, 0.40, 0.45), 1.5)
	
	var start_angle = deg_to_rad(135.0)
	var end_angle = deg_to_rad(405.0)
	draw_arc(dial_c, dial_r - 2.0, start_angle, end_angle, 32, Color(0.45, 0.50, 0.55), 1.5)
	
	for spd in range(0, 201, 20):
		var t = float(spd) / 200.0
		var ang = lerp(start_angle, end_angle, t)
		var dir = Vector2(cos(ang), sin(ang))
		var is_major = (spd % 40 == 0)
		var p_outer = dial_c + dir * (dial_r - 2.0)
		var p_inner = dial_c + dir * (dial_r - 2.0 - (7.0 if is_major else 4.0))
		draw_line(p_inner, p_outer, Color(0.92, 0.94, 0.96), 1.8 if is_major else 1.0)
		
		if is_major:
			var p_text = dial_c + dir * (dial_r - 14.0) + Vector2(-6, 3.5)
			draw_string(ThemeDB.fallback_font, p_text, str(spd), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.92, 0.94, 0.96))
			
	var val_t = clamp(smoothed_val / 200.0, 0.0, 1.0)
	var needle_ang = lerp(start_angle, end_angle, val_t)
	var needle_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	draw_line(dial_c + Vector2(1.5, 1.5), dial_c + needle_dir * (dial_r - 2.0) + Vector2(1.5, 1.5), Color(0, 0, 0, 0.55), 3.0)
	draw_line(dial_c - needle_dir * 5.0, dial_c + needle_dir * (dial_r - 3.0), Color(1.0, 0.45, 0.05), 2.8)
	draw_circle(dial_c, 4.5, Color(0.18, 0.20, 0.22))
	draw_circle(dial_c, 2.0, Color(1.0, 0.45, 0.05))
	
	# --- AUTHENTIC VDO MECHANICAL ROLLER DRUM ODOMETERS (Inside dial) ---
	var odo_w = 44.0
	var odo_h = 11.0
	var odo_pos = Vector2(dial_c.x - odo_w * 0.5, dial_c.y + 10.0)
	draw_rect(Rect2(odo_pos, Vector2(odo_w, odo_h)), Color(0.01, 0.01, 0.01), true)
	draw_rect(Rect2(odo_pos, Vector2(odo_w, odo_h)), Color(0.35, 0.40, 0.45), false, 1.0)
	
	var whole_km = int(odometer_km)
	var tenth_km = int(fmod(odometer_km * 10.0, 10.0))
	var km_str = "%05d" % (whole_km % 100000)
	for d_i in range(5):
		var drum_x = odo_pos.x + float(d_i) * 7.2
		draw_rect(Rect2(drum_x, odo_pos.y, 6.8, odo_h), Color(0.05, 0.06, 0.07), true)
		draw_string(ThemeDB.fallback_font, Vector2(drum_x + 1.2, odo_pos.y + 9.0), km_str[d_i], HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.92, 0.94, 0.96))
	var red_drum_x = odo_pos.x + 36.0
	draw_rect(Rect2(red_drum_x, odo_pos.y, 7.2, odo_h), Color(0.75, 0.15, 0.12), true)
	draw_string(ThemeDB.fallback_font, Vector2(red_drum_x + 1.5, odo_pos.y + 9.0), str(tenth_km), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)
	
	# Trip meter (Tageskilometerzähler)
	var trip_pos = Vector2(dial_c.x - 22.0, dial_c.y + 24.0)
	draw_rect(Rect2(trip_pos, Vector2(44.0, 10.0)), Color(0.02, 0.02, 0.02), true)
	draw_rect(Rect2(trip_pos, Vector2(44.0, 10.0)), Color(0.30, 0.35, 0.40), false, 1.0)
	var trip_km = fmod(odometer_km, 1000.0)
	draw_string(ThemeDB.fallback_font, Vector2(trip_pos.x + 4.0, trip_pos.y + 8.0), "TRIP %04.1f" % trip_km, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.85, 0.90, 0.95))
	
	# Dial label
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 14, dial_c.y - 12), "km/h", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.65, 0.72, 0.78))
	
	# --- RIGHT SECTION: AUTHENTIC VDO AUXILIARY OIL PRESSURE & WATER TEMP GAUGES ---
	var right_x = dial_c.x + dial_r + 14.0
	var right_w = max(45.0, rect.size.x - right_x - 10.0)
	
	# 1. Oil Pressure (Öldruck 0 - 3 bar)
	var oil_y = 26.0
	draw_string(ThemeDB.fallback_font, Vector2(right_x, oil_y), "ÖLDRUCK (BAR)", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.80, 0.88, 0.92))
	draw_line(Vector2(right_x, oil_y + 12), Vector2(right_x + right_w, oil_y + 12), Color(0.25, 0.30, 0.35), 2.0)
	var oil_pct = clamp(smoothed_oil / 3.0, 0.0, 1.0)
	var oil_needle_x = right_x + oil_pct * right_w
	draw_line(Vector2(oil_needle_x, oil_y + 5), Vector2(oil_needle_x, oil_y + 16), Color(1.0, 0.45, 0.05), 2.5)
	draw_string(ThemeDB.fallback_font, Vector2(right_x, oil_y + 24), "0", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.95, 0.30, 0.20))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w * 0.5 - 4, oil_y + 24), "1.5", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.80, 0.88, 0.92))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w - 6, oil_y + 24), "3", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.80, 0.88, 0.92))
	
	# 2. Coolant Temperature (Kühlwasser 40 - 120°C)
	var temp_y = 56.0
	draw_string(ThemeDB.fallback_font, Vector2(right_x, temp_y), "KÜHLWASSER (°C)", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.80, 0.88, 0.92))
	draw_line(Vector2(right_x, temp_y + 12), Vector2(right_x + right_w, temp_y + 12), Color(0.25, 0.30, 0.35), 2.0)
	var temp_pct = clamp((smoothed_temp - 40.0) / 80.0, 0.0, 1.0)
	var temp_needle_x = right_x + temp_pct * right_w
	draw_line(Vector2(temp_needle_x, temp_y + 5), Vector2(temp_needle_x, temp_y + 16), Color(1.0, 0.45, 0.05), 2.5)
	draw_string(ThemeDB.fallback_font, Vector2(right_x, temp_y + 24), "40", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.40, 0.75, 0.95))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w * 0.5 - 6, temp_y + 24), "80", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.80, 0.88, 0.92))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w - 14, temp_y + 24), "120", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.95, 0.25, 0.20))
	
	# 3. 4x4 Allrad & Sperren Status Lamp
	var lamp_y = 88.0
	var allrad_rect = Rect2(right_x, lamp_y - 2, right_w, 14.0)
	draw_rect(allrad_rect, Color(0.10, 0.20, 0.15) if is_active else Color(0.08, 0.10, 0.12), true)
	draw_rect(allrad_rect, Color(0.25, 0.85, 0.40) if is_active else Color(0.25, 0.32, 0.36), false, 1.0)
	var allrad_txt = "4x4 SA-ALLRAD AKTIV" if is_active else "HINTERRADANTRIEB (4x2)"
	var allrad_col = Color(0.35, 0.95, 0.50) if is_active else Color(0.65, 0.72, 0.76)
	draw_string(ThemeDB.fallback_font, Vector2(right_x + 6, lamp_y + 9), allrad_txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, allrad_col)
	
	draw_steering_wheel_rim(rect, Color(0.14, 0.15, 0.16, 0.40), Color(0.35, 0.38, 0.42, 0.40), smoothed_steer, false)

func draw_gwagen_tacho(rect: Rect2, center: Vector2, radius: float):
	draw_rect(rect, Color(0.07, 0.08, 0.09, 0.96), true)
	draw_rect(rect, Color(0.32, 0.38, 0.42, 0.85), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "DREHZAHLMESSER", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.85, 0.90, 0.95))
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 65, 16), "min⁻¹ x100", HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.70, 0.78, 0.82))
	
	var dial_r = min(radius - 6.0, 42.0)
	var dial_c = Vector2(center.x, center.y + 4.0)
	
	draw_circle(dial_c, dial_r + 3.0, Color(0.12, 0.14, 0.16))
	draw_circle(dial_c, dial_r, Color(0.04, 0.05, 0.06))
	
	var start_ang = deg_to_rad(135.0)
	var end_ang = deg_to_rad(405.0)
	draw_arc(dial_c, dial_r - 2.0, start_ang, end_ang, 32, Color(0.35, 0.40, 0.45), 1.5)
	
	# Redline arc 55-60
	var red_start = lerp(start_ang, end_ang, 5.5 / 6.0)
	draw_arc(dial_c, dial_r - 4.0, red_start, end_ang, 10, Color(0.95, 0.15, 0.15), 4.0)
	
	for rpm_10 in range(0, 61, 10):
		var t = float(rpm_10) / 60.0
		var ang = lerp(start_ang, end_ang, t)
		var dir = Vector2(cos(ang), sin(ang))
		var is_red = (rpm_10 >= 55)
		var col = Color(0.95, 0.15, 0.15) if is_red else Color(0.92, 0.94, 0.96)
		
		var p_out = dial_c + dir * (dial_r - 2.0)
		var p_in = dial_c + dir * (dial_r - 8.0)
		draw_line(p_in, p_out, col, 1.8)
		
		var p_txt = dial_c + dir * (dial_r - 16.0) + Vector2(-5, 3.5)
		draw_string(ThemeDB.fallback_font, p_txt, str(rpm_10), HORIZONTAL_ALIGNMENT_CENTER, -1, 9, col)
		
	var rpm_norm = smoothed_val # 0.8 to 6.0
	var rpm_t = clamp(rpm_norm / 6.0, 0.0, 1.0)
	var needle_ang = lerp(start_ang, end_ang, rpm_t)
	var n_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	draw_line(dial_c - n_dir * 5.0, dial_c + n_dir * (dial_r - 3.0), Color(1.0, 0.45, 0.05), 2.8)
	draw_circle(dial_c, 4.5, Color(0.18, 0.20, 0.22))
	draw_circle(dial_c, 2.0, Color(1.0, 0.45, 0.05))
	
	# Mercedes Star center
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 12, dial_c.y + 16), "★ 280GE", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.85, 0.90, 0.95))

func draw_gwagen_kombi(rect: Rect2, center: Vector2, radius: float):
	draw_rect(rect, Color(0.07, 0.08, 0.09, 0.96), true)
	draw_rect(rect, Color(0.32, 0.38, 0.42, 0.85), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "KOMBIINSTRUMENT", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.85, 0.90, 0.95))
	
	var half_w = rect.size.x * 0.5
	var left_c = Vector2(half_w * 0.5, center.y + 6.0)
	var right_c = Vector2(half_w * 1.5, center.y + 6.0)
	var sub_r = min(half_w * 0.44, radius - 8.0)
	
	# Left: FUEL TANK (R - 1/2 - 4/4)
	draw_circle(left_c, sub_r, Color(0.04, 0.05, 0.06))
	draw_arc(left_c, sub_r, deg_to_rad(140.0), deg_to_rad(400.0), 24, Color(0.35, 0.40, 0.45), 1.5)
	var f_t = clamp(smoothed_aux / 68.0, 0.0, 1.0)
	var f_ang = lerp(deg_to_rad(140.0), deg_to_rad(400.0), f_t)
	var f_dir = Vector2(cos(f_ang), sin(f_ang))
	draw_line(left_c, left_c + f_dir * (sub_r - 3.0), Color(1.0, 0.45, 0.05), 2.2)
	draw_circle(left_c, 3.0, Color(1.0, 0.45, 0.05))
	draw_string(ThemeDB.fallback_font, Vector2(left_c.x - 20, rect.size.y - 6), "%d L KRAFT" % int(round(smoothed_aux)), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.85, 0.90, 0.95))
	
	# Right: COOLANT TEMP (40-120°C)
	draw_circle(right_c, sub_r, Color(0.04, 0.05, 0.06))
	draw_arc(right_c, sub_r, deg_to_rad(140.0), deg_to_rad(400.0), 24, Color(0.35, 0.40, 0.45), 1.5)
	var t_t = clamp((smoothed_temp - 40.0) / 80.0, 0.0, 1.0)
	var t_ang = lerp(deg_to_rad(140.0), deg_to_rad(400.0), t_t)
	var t_dir = Vector2(cos(t_ang), sin(t_ang))
	draw_line(right_c, right_c + t_dir * (sub_r - 3.0), Color(1.0, 0.45, 0.05), 2.2)
	draw_circle(right_c, 3.0, Color(1.0, 0.45, 0.05))
	draw_string(ThemeDB.fallback_font, Vector2(right_c.x - 20, rect.size.y - 6), "%d°C WASSER" % int(round(smoothed_temp)), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.85, 0.90, 0.95))

func draw_gwagen_diffs(rect: Rect2, center: Vector2):
	draw_rect(rect, Color(0.07, 0.08, 0.09, 0.96), true)
	draw_rect(rect, Color(0.32, 0.38, 0.42, 0.85), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "DIFFERENTIALSPERREN", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.85, 0.90, 0.95))
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 65, 16), "STEYR-PUCH", HORIZONTAL_ALIGNMENT_RIGHT, -1, 10, Color(0.7, 0.75, 0.8))
	
	var diff_names = ["1. MITTE", "2. HINTEN", "3. VORN"]
	var slot_w = (rect.size.x - 30.0) / 3.0
	var is_locked = is_active
	
	for idx in range(3):
		var s_x = 15.0 + float(idx) * slot_w
		var s_y = center.y - 12.0
		
		var knob_rect = Rect2(s_x + 4.0, s_y, slot_w - 8.0, 34.0)
		draw_rect(knob_rect, Color(0.12, 0.14, 0.16), true)
		draw_rect(knob_rect, Color(0.40, 0.45, 0.50), false, 1.5)
		
		var lamp_rect = Rect2(knob_rect.position.x + knob_rect.size.x * 0.5 - 6, knob_rect.position.y + 5, 12, 10)
		var lamp_col = Color(0.95, 0.15, 0.15, 1.0) if is_locked else Color(0.25, 0.10, 0.10, 0.8)
		draw_rect(lamp_rect, lamp_col, true)
		
		var txt_col = Color(0.95, 0.95, 0.95) if is_locked else Color(0.55, 0.60, 0.65)
		draw_string(ThemeDB.fallback_font, Vector2(knob_rect.position.x + 2, knob_rect.position.y + 28), diff_names[idx], HORIZONTAL_ALIGNMENT_CENTER, -1, 8, txt_col)
		
	var status_str = "● 4x4 ALLRAD 100% SPERRE AKTIV" if is_locked else "○ HECKTRIEB [RWD 2WD]"
	var status_col = Color(0.2, 0.95, 0.4) if is_locked else Color(0.95, 0.7, 0.2)
	draw_string(ThemeDB.fallback_font, Vector2(15, rect.size.y - 6), status_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 9, status_col)

func draw_gwagen_console(rect: Rect2, center: Vector2):
	draw_rect(rect, Color(0.07, 0.08, 0.09, 0.96), true)
	draw_rect(rect, Color(0.32, 0.38, 0.42, 0.85), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "HALTEGRIFF / ANGSTGRIFF", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.85, 0.90, 0.95))
	
	var bar_y = center.y - 2.0
	var bar_w = rect.size.x - 36.0
	draw_rect(Rect2(16, bar_y - 12, 10, 24), Color(0.40, 0.45, 0.50), true)
	draw_rect(Rect2(16 + bar_w - 10, bar_y - 12, 10, 24), Color(0.40, 0.45, 0.50), true)
	draw_rect(Rect2(24, bar_y - 6, bar_w - 16, 12), Color(0.12, 0.13, 0.14), true)
	draw_rect(Rect2(24, bar_y - 6, bar_w - 16, 12), Color(0.5, 0.55, 0.6), false, 1.0)
	for gx in range(32, int(16 + bar_w - 16), 8):
		draw_line(Vector2(gx, bar_y - 5), Vector2(gx, bar_y + 5), Color(0.22, 0.24, 0.26), 2.0)
		
	draw_string(ThemeDB.fallback_font, Vector2(16, rect.size.y - 6), "GELÄNDE ASSISTENZ W460", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.65, 0.70, 0.75))

# ==============================================================================
# 4. FIAT 127 SPECIAL (1974) - VEGLIA BORLETTI TORINO
# ==============================================================================
func draw_fiat127_speedo(rect: Rect2, _center: Vector2, _radius: float):
	# 1. Hooded Veglia Borletti Binnacle Casing (Sculpted Italian housing with bevel & drop shadow)
	draw_rect(Rect2(rect.position + Vector2(2, 4), rect.size), Color(0.0, 0.0, 0.0, 0.55), true) # Drop shadow
	draw_rect(rect, Color(0.07, 0.07, 0.08, 0.98), true) # Dark textured Bakelite casing
	
	# Top hooded overhang brow highlight
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, 5)), Color(0.20, 0.22, 0.24, 0.90), true)
	
	# Brushed satin aluminum / chrome perimeter bead
	draw_rect(rect, Color(0.68, 0.72, 0.76, 0.90), false, 2.0)
	draw_rect(Rect2(rect.position + Vector2(3, 3), rect.size - Vector2(6, 6)), Color(0.03, 0.03, 0.04, 0.95), false, 1.2)
	
	# Header brand badge and gear indicator
	var gear_label = ("[" + gear_text + "]") if gear_text != "" else "4 MARCE"
	draw_string(ThemeDB.fallback_font, Vector2(14, 17), "VEGLIA BORLETTI TORINO", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.94, 0.92, 0.86))
	draw_rect(Rect2(rect.size.x - 76, 5, 68, 16), Color(0.12, 0.12, 0.14), true)
	draw_rect(Rect2(rect.size.x - 76, 5, 68, 16), Color(0.85, 0.70, 0.25), false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 74, 17), gear_label, HORIZONTAL_ALIGNMENT_CENTER, 64, 10, Color(0.98, 0.82, 0.28))
	
	# 2. Main Speedometer: Veglia Borletti Circular Instrument
	var dial_r = clamp(rect.size.y * 0.42, 38.0, 46.0)
	var dial_c = Vector2(dial_r + 16.0, rect.size.y * 0.54)
	
	# Machined concentric chrome bezel (outer shadow, bright chrome ring, inner bevel)
	draw_circle(dial_c, dial_r + 4.5, Color(0.16, 0.16, 0.18))
	draw_circle(dial_c, dial_r + 3.0, Color(0.88, 0.90, 0.94))
	draw_circle(dial_c, dial_r + 1.2, Color(0.42, 0.45, 0.48))
	draw_circle(dial_c, dial_r, Color(0.03, 0.03, 0.04)) # Matte black dial face
	draw_arc(dial_c, dial_r, 0.0, TAU, 40, Color(0.55, 0.58, 0.62), 1.2)
	
	# Dial graduation arc (140° to 400°)
	var start_angle = deg_to_rad(140.0)
	var end_angle = deg_to_rad(400.0)
	draw_arc(dial_c, dial_r - 2.5, start_angle, end_angle, 36, Color(0.50, 0.54, 0.58), 1.0)
	
	for spd in range(0, 161, 5):
		var t = float(spd) / 160.0
		var ang = lerp(start_angle, end_angle, t)
		var dir = Vector2(cos(ang), sin(ang))
		var is_major = (spd % 20 == 0)
		var is_mid = (spd % 10 == 0) and not is_major
		var tick_len = 7.0 if is_major else (4.5 if is_mid else 2.5)
		
		# Characteristic Veglia colors: orange at 50 km/h (urban limit), red at 130 km/h (autostrada)
		var tick_col = Color(0.94, 0.95, 0.92)
		if spd == 50: tick_col = Color(1.0, 0.45, 0.08)
		elif spd == 130: tick_col = Color(1.0, 0.20, 0.15)
			
		var p_outer = dial_c + dir * (dial_r - 2.5)
		var p_inner = dial_c + dir * (dial_r - 2.5 - tick_len)
		var tick_width = 2.2 if is_major else (1.4 if is_mid else 0.9)
		draw_line(p_inner, p_outer, tick_col, tick_width)
		
		if is_major:
			var p_text = dial_c + dir * (dial_r - 14.5) + Vector2(-7, 3.5)
			draw_string(ThemeDB.fallback_font, p_text, str(spd), HORIZONTAL_ALIGNMENT_CENTER, 14, 8, Color(0.95, 0.95, 0.90))
			
	# Vintage cursive sub-label
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 16, dial_c.y - 13), "km/h", HORIZONTAL_ALIGNMENT_CENTER, 32, 8, Color(0.72, 0.75, 0.78))
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 18, dial_c.y - 21), "VEGLIA", HORIZONTAL_ALIGNMENT_CENTER, 36, 7, Color(0.55, 0.58, 0.62))
	
	# Rolling Mechanical Drum Odometer
	var odo_w = 48.0
	var odo_h = 13.0
	var odo_pos = Vector2(dial_c.x - odo_w * 0.5, dial_c.y + 11.0)
	draw_rect(Rect2(odo_pos - Vector2(1, 1), Vector2(odo_w + 2, odo_h + 2)), Color(0.45, 0.48, 0.52), true) # Chrome bezel
	draw_rect(Rect2(odo_pos, Vector2(odo_w, odo_h)), Color(0.01, 0.01, 0.01), true)
	
	var whole_km = int(odometer_km)
	var tenth_km = int(fmod(odometer_km * 10.0, 10.0))
	var km_str = "%05d" % (whole_km % 100000)
	for d_i in range(5):
		var drum_x = odo_pos.x + float(d_i) * 7.8
		draw_rect(Rect2(drum_x, odo_pos.y, 7.2, odo_h), Color(0.05, 0.05, 0.06), true)
		draw_line(Vector2(drum_x, odo_pos.y), Vector2(drum_x, odo_pos.y + odo_h), Color(0.18, 0.18, 0.20), 0.8)
		draw_string(ThemeDB.fallback_font, Vector2(drum_x + 1.2, odo_pos.y + 10.0), km_str[d_i], HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.95, 0.95, 0.92))
		
	var red_drum_x = odo_pos.x + 39.0
	draw_rect(Rect2(red_drum_x, odo_pos.y, 8.0, odo_h), Color(0.80, 0.14, 0.10), true) # Red tenth drum
	draw_string(ThemeDB.fallback_font, Vector2(red_drum_x + 1.8, odo_pos.y + 10.0), str(tenth_km), HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color.WHITE)
	
	# Convex Curved Glass Sheen Reflection Arc
	draw_arc(dial_c, dial_r - 5.0, deg_to_rad(200.0), deg_to_rad(340.0), 24, Color(1.0, 1.0, 1.0, 0.12), 2.5)
	
	# Speedometer Needle: Vibrant Italian Fluorescent Orange with Drop Shadow
	var val_t = clamp(smoothed_val / 160.0, 0.0, 1.0)
	var needle_ang = lerp(start_angle, end_angle, val_t)
	var needle_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	# Cast needle shadow
	draw_line(dial_c + Vector2(2.0, 2.0), dial_c + needle_dir * (dial_r - 2.5) + Vector2(2.0, 2.0), Color(0, 0, 0, 0.65), 3.0)
	# Needle counter-balance tail
	draw_line(dial_c - needle_dir * 7.0, dial_c, Color(0.10, 0.10, 0.11), 3.0)
	# Tapered fluorescent orange needle blade
	draw_line(dial_c, dial_c + needle_dir * (dial_r - 3.5), Color(1.0, 0.36, 0.05), 2.6)
	draw_line(dial_c + needle_dir * 8.0, dial_c + needle_dir * (dial_r - 5.0), Color(1.0, 0.60, 0.20), 1.2) # Highlight spine
	
	# Central machined rivet hub cap
	draw_circle(dial_c, 5.5, Color(0.12, 0.12, 0.14))
	draw_circle(dial_c, 4.2, Color(0.85, 0.88, 0.92))
	draw_circle(dial_c, 2.2, Color(0.20, 0.22, 0.24))
	
	# 3. Middle Section: Authentic Recessed Auxiliary Gauges & Jeweled Warning Lamps
	var right_x = dial_c.x + dial_r + 14.0
	var right_w = clamp(rect.size.x - right_x - 14.0, 160.0, 210.0)
	
	# Recessed aux tray
	draw_rect(Rect2(right_x - 4, 22, right_w + 8, rect.size.y - 28), Color(0.04, 0.04, 0.05, 0.90), true)
	draw_rect(Rect2(right_x - 4, 22, right_w + 8, rect.size.y - 28), Color(0.35, 0.38, 0.42, 0.80), false, 1.2)
	
	# --- A. BENZINA (Fuel Level) ---
	var fuel_y = 26.0
	draw_string(ThemeDB.fallback_font, Vector2(right_x, fuel_y), "⛽ BENZINA", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.82, 0.85, 0.88))
	draw_rect(Rect2(right_x, fuel_y + 11, right_w, 4), Color(0.10, 0.11, 0.12), true) # Beveled track
	draw_rect(Rect2(right_x, fuel_y + 11, right_w * 0.22, 4), Color(0.75, 0.18, 0.12, 0.85), true) # Reserve red zone
	draw_rect(Rect2(right_x, fuel_y + 11, right_w, 4), Color(0.40, 0.44, 0.48), false, 1.0)
	
	var fuel_pct = clamp(aux_value / 30.0, 0.0, 1.0)
	var fuel_needle_x = right_x + fuel_pct * right_w
	draw_line(Vector2(fuel_needle_x + 1, fuel_y + 4), Vector2(fuel_needle_x + 1, fuel_y + 18), Color(0, 0, 0, 0.55), 3.0)
	draw_line(Vector2(fuel_needle_x, fuel_y + 3), Vector2(fuel_needle_x, fuel_y + 17), Color(1.0, 0.42, 0.08), 2.5)
	draw_string(ThemeDB.fallback_font, Vector2(right_x, fuel_y + 25), "0", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.35, 0.20))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w * 0.5 - 4, fuel_y + 25), "½", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.80, 0.82, 0.86))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w - 14, fuel_y + 25), "4/4", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.80, 0.82, 0.86))
	
	# Fuel reserve warning lamp jewel
	var is_reserve = (aux_value < 5.5)
	var res_col = Color(1.0, 0.45, 0.08) if is_reserve else Color(0.25, 0.10, 0.05)
	draw_circle(Vector2(right_x + right_w - 6, fuel_y - 2), 3.2, res_col)
	if is_reserve:
		draw_circle(Vector2(right_x + right_w - 6, fuel_y - 2), 1.5, Color.WHITE)
	
	# --- B. ACQUA (Coolant Temp) ---
	var temp_y = 56.0
	draw_string(ThemeDB.fallback_font, Vector2(right_x, temp_y), "🌡️ ACQUA", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.82, 0.85, 0.88))
	draw_rect(Rect2(right_x, temp_y + 11, right_w, 4), Color(0.10, 0.11, 0.12), true)
	draw_rect(Rect2(right_x, temp_y + 11, right_w * 0.22, 4), Color(0.25, 0.65, 0.90, 0.85), true) # Cold blue zone
	draw_rect(Rect2(right_x + right_w * 0.78, temp_y + 11, right_w * 0.22, 4), Color(0.85, 0.15, 0.10, 0.85), true) # Hot red zone
	draw_rect(Rect2(right_x, temp_y + 11, right_w, 4), Color(0.40, 0.44, 0.48), false, 1.0)
	
	var temp_pct = clamp((smoothed_temp - 40.0) / 80.0, 0.0, 1.0)
	var temp_needle_x = right_x + temp_pct * right_w
	draw_line(Vector2(temp_needle_x + 1, temp_y + 4), Vector2(temp_needle_x + 1, temp_y + 18), Color(0, 0, 0, 0.55), 3.0)
	draw_line(Vector2(temp_needle_x, temp_y + 3), Vector2(temp_needle_x, temp_y + 17), Color(1.0, 0.42, 0.08), 2.5)
	draw_string(ThemeDB.fallback_font, Vector2(right_x, temp_y + 25), "C", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.35, 0.75, 0.95))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w * 0.5 - 6, temp_y + 25), "90°", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.80, 0.82, 0.86))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w - 10, temp_y + 25), "H", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.25, 0.20))
	
	# --- C. Jeweled Italian Warning Lamps Strip ---
	var lamp_y = 86.0
	var lamps_127 = [
		{ "label": "GEN", "col": Color(1.0, 0.18, 0.12) if smoothed_val < 3.0 else Color(0.24, 0.06, 0.06), "active": smoothed_val < 3.0 },
		{ "label": "OLIO", "col": Color(1.0, 0.18, 0.12) if smoothed_val < 3.0 else Color(0.24, 0.06, 0.06), "active": smoothed_val < 3.0 },
		{ "label": "LUCI", "col": Color(0.20, 0.95, 0.40), "active": true },
		{ "label": "FRECCE", "col": Color(0.20, 0.95, 0.40), "active": true },
		{ "label": "ABB", "col": Color(0.25, 0.65, 1.0), "active": false }
	]
	var lamp_w = 20.0
	for l_idx in range(lamps_127.size()):
		var lx = right_x + float(l_idx) * (lamp_w + 3.0)
		var lamp = lamps_127[l_idx]
		draw_rect(Rect2(lx - 1, lamp_y - 1, lamp_w + 2, 13), Color(0.55, 0.58, 0.62), false, 1.0)
		draw_rect(Rect2(lx, lamp_y, lamp_w, 11), lamp.col * 0.35, true)
		if lamp.active:
			draw_rect(Rect2(lx + 2, lamp_y + 2, lamp_w - 4, 7), lamp.col, true)
			draw_circle(Vector2(lx + lamp_w * 0.5, lamp_y + 5.5), 1.8, Color.WHITE)
		draw_string(ThemeDB.fallback_font, Vector2(lx + 1.5, lamp_y + 9), lamp.label, HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color.WHITE if lamp.active else Color(0.5, 0.5, 0.5))

	# 4. Far Right: Technical Heritage Badge (Fills wide cards with authentic period car specs)
	var plaque_x = right_x + right_w + 14.0
	var plaque_w = rect.size.x - plaque_x - 12.0
	if plaque_w > 70.0:
		var p_box = Rect2(plaque_x, 22.0, plaque_w, rect.size.y - 28.0)
		draw_rect(p_box, Color(0.05, 0.05, 0.06, 0.95), true)
		draw_rect(p_box, Color(0.40, 0.44, 0.48), false, 1.0)
		draw_rect(Rect2(plaque_x + 2, 24, plaque_w - 4, 14), Color(0.14, 0.15, 0.16), true)
		draw_string(ThemeDB.fallback_font, Vector2(plaque_x + 6, 35), "SCHEDA TECNICA", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.95, 0.82, 0.28))
		draw_string(ThemeDB.fallback_font, Vector2(plaque_x + 6, 52), "MOTORE: 903 cm³ ASTE & BIL.", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.85, 0.88, 0.90))
		draw_string(ThemeDB.fallback_font, Vector2(plaque_x + 6, 66), "POTENZA: 47 CV DIN @ 6200", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.85, 0.88, 0.90))
		draw_string(ThemeDB.fallback_font, Vector2(plaque_x + 6, 80), "CARB.: WEBER 32 IBA 20", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.75, 0.80, 0.85))
		draw_string(ThemeDB.fallback_font, Vector2(plaque_x + 6, 94), "IMPIANTO: 12V VEGLIA TORINO", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.40, 0.88, 0.98))

	draw_steering_wheel_rim(rect, Color(0.12, 0.12, 0.14, 0.40), Color(0.55, 0.58, 0.60, 0.40), smoothed_steer, false)

func draw_fiat127_console(rect: Rect2, center: Vector2):
	# 1. Console Housing with Italian Special 1974 Walnut Wood Trim
	draw_rect(Rect2(rect.position + Vector2(2, 4), rect.size), Color(0.0, 0.0, 0.0, 0.55), true)
	draw_rect(rect, Color(0.08, 0.08, 0.09, 0.98), true)
	
	# Walnut wood veneer fascia across the top with grain striations
	var wood_rect = Rect2(rect.position.x, rect.position.y, rect.size.x, 22)
	draw_rect(wood_rect, Color(0.36, 0.20, 0.11, 0.98), true)
	for wx_line in range(int(rect.position.x) + 4, int(rect.position.x + rect.size.x), 12):
		draw_line(Vector2(wx_line, rect.position.y + 2), Vector2(wx_line + 8, rect.position.y + 20), Color(0.24, 0.13, 0.07, 0.65), 1.0)
	
	# Polished chrome dividing bead
	draw_line(Vector2(rect.position.x, rect.position.y + 22), Vector2(rect.position.x + rect.size.x, rect.position.y + 22), Color(0.85, 0.88, 0.92), 1.8)
	draw_rect(rect, Color(0.50, 0.54, 0.58, 0.85), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(12, 16), "CONSOLLE FIAT 127 SPECIAL (1974) - PIO MANZÙ", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.96, 0.94, 0.88))
	
	# 2. Left: Machined Stainless Steel H-Pattern Shift Gate Plate
	var gate_box = Rect2(14, 28, 76, rect.size.y - 36)
	draw_rect(gate_box, Color(0.24, 0.26, 0.28), true)
	draw_rect(gate_box, Color(0.75, 0.78, 0.82), false, 1.4)
	
	var diag_x = 32.0
	var diag_y = gate_box.position.y + gate_box.size.y * 0.5
	var track_w = 4.0
	
	# Engraved H-pattern tracks (1-2, 3-4, crossbar, R)
	draw_line(Vector2(diag_x, diag_y - 14), Vector2(diag_x, diag_y + 14), Color(0.06, 0.06, 0.07), track_w)
	draw_line(Vector2(diag_x + 20, diag_y - 14), Vector2(diag_x + 20, diag_y + 14), Color(0.06, 0.06, 0.07), track_w)
	draw_line(Vector2(diag_x, diag_y), Vector2(diag_x + 40, diag_y), Color(0.06, 0.06, 0.07), track_w)
	draw_line(Vector2(diag_x + 40, diag_y), Vector2(diag_x + 40, diag_y + 14), Color(0.06, 0.06, 0.07), track_w)
	
	# Metallic track inner bevel highlights
	draw_line(Vector2(diag_x - 2, diag_y - 14), Vector2(diag_x - 2, diag_y + 14), Color(0.65, 0.68, 0.72), 1.0)
	draw_line(Vector2(diag_x + 18, diag_y - 14), Vector2(diag_x + 18, diag_y + 14), Color(0.65, 0.68, 0.72), 1.0)
	
	# Gear numerals stamped on gate
	draw_string(ThemeDB.fallback_font, Vector2(diag_x - 3, diag_y - 16), "1", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(diag_x - 3, diag_y + 24), "2", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(diag_x + 17, diag_y - 16), "3", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(diag_x + 17, diag_y + 24), "4", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(diag_x + 37, diag_y + 24), "R", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(1.0, 0.35, 0.25))
	
	# Dynamic Active Gear Selector Ball with Glowing Amber Core
	var ball_pos = Vector2(diag_x + 10, diag_y) # Neutral
	if gear_text in ["1", "1ª"]: ball_pos = Vector2(diag_x, diag_y - 12)
	elif gear_text in ["2", "2ª"]: ball_pos = Vector2(diag_x, diag_y + 12)
	elif gear_text in ["3", "3ª"]: ball_pos = Vector2(diag_x + 20, diag_y - 12)
	elif gear_text in ["4", "4ª"]: ball_pos = Vector2(diag_x + 20, diag_y + 12)
	elif gear_text in ["R", "RETRO"]: ball_pos = Vector2(diag_x + 40, diag_y + 12)
	
	draw_circle(ball_pos + Vector2(1, 1), 5.5, Color(0, 0, 0, 0.6))
	draw_circle(ball_pos, 5.0, Color(1.0, 0.65, 0.15))
	draw_circle(ball_pos, 3.0, Color(1.0, 0.88, 0.40))
	draw_circle(ball_pos - Vector2(1.2, 1.2), 1.4, Color.WHITE) # Specular highlight
	
	# 3. Center Section: Authentic Vintage Voxson "Sebring Stereo" Autoradio
	var rad_x = 100.0
	var rad_right_limit = rect.size.x - 110.0
	var rad_w = max(60.0, rad_right_limit - rad_x)
	var rad_y = 28.0
	var rad_h = rect.size.y - 36.0
	
	# Radio Chrome Chassis Box
	draw_rect(Rect2(rad_x, rad_y, rad_w, rad_h), Color(0.12, 0.13, 0.14), true)
	draw_rect(Rect2(rad_x, rad_y, rad_w, rad_h), Color(0.75, 0.78, 0.82), false, 1.4)
	
	# Radio Header & Brand Badge
	draw_rect(Rect2(rad_x + 2, rad_y + 2, rad_w - 4, 12), Color(0.04, 0.04, 0.05), true)
	draw_string(ThemeDB.fallback_font, Vector2(rad_x + 6, rad_y + 11), "VOXSON SEBRING STEREO 8", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.95, 0.85, 0.35))
	draw_string(ThemeDB.fallback_font, Vector2(rad_x + rad_w - 42, rad_y + 11), "FM / OM", HORIZONTAL_ALIGNMENT_RIGHT, -1, 7, Color(0.75, 0.80, 0.85))
	
	# Illuminated Amber Frequency Scale Display
	var disp_x = rad_x + 26.0
	var disp_w = max(20.0, rad_w - 52.0)
	var disp_y = rad_y + 16.0
	var disp_h = 24.0
	draw_rect(Rect2(disp_x, disp_y, disp_w, disp_h), Color(0.02, 0.02, 0.02), true)
	draw_rect(Rect2(disp_x, disp_y, disp_w, disp_h), Color(0.85, 0.55, 0.12, 0.30), true) # Warm backlit amber glow
	draw_rect(Rect2(disp_x, disp_y, disp_w, disp_h), Color(0.55, 0.58, 0.62), false, 1.0)
	
	# Frequency graduation lines & text
	draw_string(ThemeDB.fallback_font, Vector2(disp_x + 4, disp_y + 10), "FM  88   92   96   100  104  108 MHz", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color(0.95, 0.90, 0.80))
	draw_string(ThemeDB.fallback_font, Vector2(disp_x + 4, disp_y + 21), "OM  54   70   90   120  140  160 kHz", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color(0.95, 0.75, 0.30))
	
	# Moving Frequency Tuning Needle (Tuned to RAI Radio 1 / 102.5 FM)
	var freq_t = 0.68
	var needle_fx = disp_x + freq_t * disp_w
	draw_line(Vector2(needle_fx, disp_y + 1), Vector2(needle_fx, disp_y + disp_h - 1), Color(1.0, 0.30, 0.10), 1.6)
	draw_circle(Vector2(needle_fx, disp_y + disp_h * 0.5), 2.0, Color.WHITE)
	
	# Knurled Chrome Volume & Tuning Knobs on radio sides
	var knob_rad_l_pos = Vector2(rad_x + 13.0, rad_y + 28.0)
	var knob_rad_r_pos = Vector2(rad_x + rad_w - 13.0, rad_y + 28.0)
	draw_circle(knob_rad_l_pos, 8.5, Color(0.78, 0.82, 0.86))
	draw_circle(knob_rad_l_pos, 6.0, Color(0.18, 0.19, 0.20))
	draw_circle(knob_rad_r_pos, 8.5, Color(0.78, 0.82, 0.86))
	draw_circle(knob_rad_r_pos, 6.0, Color(0.18, 0.19, 0.20))
	draw_string(ThemeDB.fallback_font, Vector2(rad_x + 2, rad_y + 44), "VOL", HORIZONTAL_ALIGNMENT_CENTER, 22, 6, Color(0.75, 0.8, 0.85))
	draw_string(ThemeDB.fallback_font, Vector2(rad_x + rad_w - 24, rad_y + 44), "SINT", HORIZONTAL_ALIGNMENT_CENTER, 22, 6, Color(0.75, 0.8, 0.85))
	
	# 5 Mechanical Station Preset Buttons
	var btn_y = rad_y + disp_h + 18.0
	var btn_count = 5
	var btn_w = clamp((disp_w - 16.0) / float(btn_count), 8.0, 18.0)
	for b_i in range(btn_count):
		var bx = disp_x + float(b_i) * (btn_w + 3.0)
		draw_rect(Rect2(bx, btn_y, btn_w, 10), Color(0.20, 0.22, 0.24), true)
		draw_rect(Rect2(bx, btn_y, btn_w, 10), Color(0.75, 0.78, 0.82), false, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(bx, btn_y + 8), str(b_i + 1), HORIZONTAL_ALIGNMENT_CENTER, int(btn_w), 6, Color.WHITE)
	
	# 4. Right Section: Pio Manzù Choke, Hazard Switch & Climate Levers
	var knob_x = rect.size.x - 52.0
	var knob_y = center.y - 8.0
	
	# Knurled Bakelite Choke Knob ("ARIA")
	draw_circle(Vector2(knob_x, knob_y) + Vector2(1, 2), 11.0, Color(0, 0, 0, 0.55))
	draw_circle(Vector2(knob_x, knob_y), 11.0, Color(0.18, 0.19, 0.21))
	for kr in range(12):
		var k_ang = float(kr) * TAU / 12.0
		var k_dir = Vector2(cos(k_ang), sin(k_ang))
		draw_line(Vector2(knob_x, knob_y) + k_dir * 8.0, Vector2(knob_x, knob_y) + k_dir * 11.0, Color(0.40, 0.44, 0.48), 1.2)
	draw_circle(Vector2(knob_x, knob_y), 7.5, Color(0.08, 0.08, 0.09))
	draw_string(ThemeDB.fallback_font, Vector2(knob_x - 14, knob_y - 2), "ARIA", HORIZONTAL_ALIGNMENT_CENTER, 28, 7, Color(0.92, 0.94, 0.96))
	
	# Hazard Emergency Rocker Switch
	var haz_rect = Rect2(knob_x - 10, knob_y + 16, 20, 15)
	draw_rect(Rect2(haz_rect.position + Vector2(1, 1), haz_rect.size), Color(0, 0, 0, 0.6), true)
	draw_rect(haz_rect, Color(0.80, 0.14, 0.10), true)
	draw_rect(haz_rect, Color(0.95, 0.40, 0.35), false, 1.2)
	draw_string(ThemeDB.fallback_font, Vector2(knob_x - 6, knob_y + 28), "▲", HORIZONTAL_ALIGNMENT_CENTER, 12, 8, Color.WHITE)
	
	# Dual Sliding Climate Levers
	var slider_x = knob_x - 42.0
	var slider_y = center.y - 10.0
	draw_rect(Rect2(slider_x, slider_y, 32, 5), Color(0.05, 0.05, 0.06), true)
	draw_rect(Rect2(slider_x, slider_y, 16, 5), Color(0.2, 0.5, 0.85, 0.85), true) # Cold
	draw_rect(Rect2(slider_x + 16, slider_y, 16, 5), Color(0.85, 0.25, 0.2, 0.85), true) # Warm
	draw_rect(Rect2(slider_x, slider_y, 32, 5), Color(0.4, 0.44, 0.48), false, 1.0)
	draw_rect(Rect2(slider_x + 12, slider_y - 2, 5, 9), Color(0.85, 0.88, 0.92), true) # Chrome lever knob
	draw_string(ThemeDB.fallback_font, Vector2(slider_x, slider_y + 14), "CLIMA", HORIZONTAL_ALIGNMENT_LEFT, 32, 7, Color(0.7, 0.75, 0.8))
	
	# Subscript signature
	draw_string(ThemeDB.fallback_font, Vector2(14, rect.size.y - 5), "TRAZIONE ANTERIORE [FWD] · PROGETTO DANTE GIACOSA · STILE PIO MANZÙ", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.40, 0.88, 0.98))

# ==============================================================================
# 5. VOLKSWAGEN GOLF GTI 16V Mk2 (1990) - VDO WOLFSBURG & MFA
# ==============================================================================
func draw_golf_speedo(rect: Rect2, _center: Vector2, _radius: float):
	draw_rect(rect, Color(0.06, 0.07, 0.07, 0.96), true)
	draw_rect(rect, Color(0.24, 0.32, 0.26, 0.85), false, 2.0)
	
	var gear_label = ("[" + gear_text + "]") if gear_text != "" else "GTI 16V"
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "VDO WOLFSBURG", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.92, 0.95, 0.92))
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 70, 16), gear_label, HORIZONTAL_ALIGNMENT_RIGHT, -1, 10, Color(0.95, 0.15, 0.15))
	
	var dial_r = clamp(rect.size.y * 0.38, 32.0, 42.0)
	var dial_c = Vector2(dial_r + 14.0, rect.size.y * 0.54)
	
	draw_circle(dial_c, dial_r + 3.0, Color(0.12, 0.14, 0.13))
	draw_circle(dial_c, dial_r, Color(0.03, 0.04, 0.04))
	draw_arc(dial_c, dial_r, 0.0, TAU, 36, Color(0.28, 0.38, 0.30), 1.5)
	
	var start_angle = deg_to_rad(135.0)
	var end_angle = deg_to_rad(405.0)
	draw_arc(dial_c, dial_r - 2.0, start_angle, end_angle, 32, Color(0.35, 0.48, 0.38), 1.5)
	
	for spd in range(0, 261, 20):
		var t = float(spd) / 260.0
		var ang = lerp(start_angle, end_angle, t)
		var dir = Vector2(cos(ang), sin(ang))
		var is_major = (spd % 40 == 0)
		var p_outer = dial_c + dir * (dial_r - 2.0)
		var p_inner = dial_c + dir * (dial_r - 2.0 - (7.0 if is_major else 4.0))
		draw_line(p_inner, p_outer, Color(0.92, 0.96, 0.92), 1.8 if is_major else 1.0)
		
		if is_major:
			var p_text = dial_c + dir * (dial_r - 14.0) + Vector2(-6, 3.5)
			draw_string(ThemeDB.fallback_font, p_text, str(spd), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.92, 0.96, 0.92))
			
	var val_t = clamp(smoothed_val / 260.0, 0.0, 1.0)
	var needle_ang = lerp(start_angle, end_angle, val_t)
	var needle_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	draw_line(dial_c + Vector2(1.5, 1.5), dial_c + needle_dir * (dial_r - 2.0) + Vector2(1.5, 1.5), Color(0, 0, 0, 0.55), 3.0)
	draw_line(dial_c - needle_dir * 5.0, dial_c + needle_dir * (dial_r - 3.0), Color(0.95, 0.15, 0.12), 2.8)
	draw_circle(dial_c, 4.5, Color(0.14, 0.15, 0.14))
	draw_circle(dial_c, 2.0, Color(0.95, 0.15, 0.12))
	
	var odo_w = 44.0
	var odo_h = 11.0
	var odo_pos = Vector2(dial_c.x - odo_w * 0.5, dial_c.y + 10.0)
	draw_rect(Rect2(odo_pos, Vector2(odo_w, odo_h)), Color(0.01, 0.01, 0.01), true)
	draw_rect(Rect2(odo_pos, Vector2(odo_w, odo_h)), Color(0.30, 0.40, 0.32), false, 1.0)
	
	var whole_km = int(odometer_km)
	var tenth_km = int(fmod(odometer_km * 10.0, 10.0))
	var km_str = "%05d" % (whole_km % 100000)
	for d_i in range(5):
		var drum_x = odo_pos.x + float(d_i) * 7.2
		draw_rect(Rect2(drum_x, odo_pos.y, 6.8, odo_h), Color(0.05, 0.06, 0.06), true)
		draw_string(ThemeDB.fallback_font, Vector2(drum_x + 1.2, odo_pos.y + 9.0), km_str[d_i], HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.92, 0.95, 0.92))
	var red_drum_x = odo_pos.x + 36.0
	draw_rect(Rect2(red_drum_x, odo_pos.y, 7.2, odo_h), Color(0.75, 0.15, 0.12), true)
	draw_string(ThemeDB.fallback_font, Vector2(red_drum_x + 1.5, odo_pos.y + 9.0), str(tenth_km), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)
	
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 14, dial_c.y - 12), "km/h", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.70, 0.85, 0.72))
	
	var right_x = dial_c.x + dial_r + 14.0
	var right_w = max(45.0, rect.size.x - right_x - 10.0)
	
	var fuel_y = 26.0
	draw_string(ThemeDB.fallback_font, Vector2(right_x, fuel_y), "KRAFTSTOFF (55L)", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.85, 0.92, 0.88))
	draw_line(Vector2(right_x, fuel_y + 12), Vector2(right_x + right_w, fuel_y + 12), Color(0.25, 0.35, 0.28), 2.0)
	var fuel_pct = clamp(aux_value / 55.0, 0.0, 1.0)
	var fuel_needle_x = right_x + fuel_pct * right_w
	draw_line(Vector2(fuel_needle_x, fuel_y + 5), Vector2(fuel_needle_x, fuel_y + 16), Color(0.95, 0.15, 0.12), 2.5)
	draw_string(ThemeDB.fallback_font, Vector2(right_x, fuel_y + 24), "R", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.35, 0.20))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w * 0.5 - 4, fuel_y + 24), "½", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.85, 0.92, 0.88))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w - 8, fuel_y + 24), "1/1", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.85, 0.92, 0.88))
	
	var temp_y = 56.0
	draw_string(ThemeDB.fallback_font, Vector2(right_x, temp_y), "KÜHLMITTEL (°C)", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.85, 0.92, 0.88))
	draw_line(Vector2(right_x, temp_y + 12), Vector2(right_x + right_w, temp_y + 12), Color(0.25, 0.35, 0.28), 2.0)
	var temp_pct = clamp((smoothed_temp - 40.0) / 80.0, 0.0, 1.0)
	var temp_needle_x = right_x + temp_pct * right_w
	draw_line(Vector2(temp_needle_x, temp_y + 5), Vector2(temp_needle_x, temp_y + 16), Color(0.95, 0.15, 0.12), 2.5)
	draw_string(ThemeDB.fallback_font, Vector2(right_x, temp_y + 24), "70", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.40, 0.75, 0.95))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w * 0.5 - 6, temp_y + 24), "90", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.85, 0.92, 0.88))
	draw_string(ThemeDB.fallback_font, Vector2(right_x + right_w - 14, temp_y + 24), "110", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.25, 0.20))
	
	var led_y = 88.0
	var golf_leds = [
		{ "label": "BLIK", "col": Color(0.20, 0.95, 0.40) },
		{ "label": "FERN", "col": Color(0.25, 0.55, 1.0) },
		{ "label": "ÖL", "col": Color(1.0, 0.15, 0.15) if smoothed_val < 3.0 else Color(0.25, 0.08, 0.08) },
		{ "label": "BATT", "col": Color(1.0, 0.15, 0.15) if smoothed_val < 3.0 else Color(0.25, 0.08, 0.08) }
	]
	var g_led_w = 22.0
	for gi in range(golf_leds.size()):
		var gx = right_x + float(gi) * (g_led_w + 3.0)
		var led = golf_leds[gi]
		draw_rect(Rect2(gx, led_y, g_led_w, 11), led.col * 0.4, true)
		draw_rect(Rect2(gx, led_y, g_led_w, 11), led.col, false, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(gx + 2.0, led_y + 9), led.label, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, led.col)

func draw_golf_tacho(rect: Rect2, center: Vector2, radius: float):
	draw_rect(rect, Color(0.06, 0.07, 0.07, 0.96), true)
	draw_rect(rect, Color(0.24, 0.32, 0.26, 0.85), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "DREHZAHLMESSER 16V", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.92, 0.95, 0.92))
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 55, 16), "1/min x1000", HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.70, 0.85, 0.72))
	
	var dial_r = min(radius - 6.0, 42.0)
	var dial_c = Vector2(center.x, center.y + 2.0)
	
	draw_circle(dial_c, dial_r + 3.0, Color(0.12, 0.14, 0.13))
	draw_circle(dial_c, dial_r, Color(0.03, 0.04, 0.04))
	
	var start_ang = deg_to_rad(135.0)
	var end_ang = deg_to_rad(405.0)
	draw_arc(dial_c, dial_r - 2.0, start_ang, end_ang, 32, Color(0.35, 0.48, 0.38), 1.5)
	
	var red_start = lerp(start_ang, end_ang, 7.2 / 8.0)
	draw_arc(dial_c, dial_r - 4.0, red_start, end_ang, 10, Color(0.95, 0.15, 0.12), 4.0)
	
	for rpm_k in range(0, 9):
		var t = float(rpm_k) / 8.0
		var ang = lerp(start_ang, end_ang, t)
		var dir = Vector2(cos(ang), sin(ang))
		var is_red = (rpm_k >= 7)
		var col = Color(0.95, 0.15, 0.12) if is_red else Color(0.92, 0.96, 0.92)
		
		var p_out = dial_c + dir * (dial_r - 2.0)
		var p_in = dial_c + dir * (dial_r - 8.0)
		draw_line(p_in, p_out, col, 1.8)
		
		var p_txt = dial_c + dir * (dial_r - 16.0) + Vector2(-4, 3.5)
		draw_string(ThemeDB.fallback_font, p_txt, str(rpm_k), HORIZONTAL_ALIGNMENT_CENTER, -1, 9, col)
		
	var rpm_val = smoothed_val
	var rpm_t = clamp(rpm_val / 8000.0, 0.0, 1.0)
	var needle_ang = lerp(start_ang, end_ang, rpm_t)
	var n_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	draw_line(dial_c - n_dir * 5.0, dial_c + n_dir * (dial_r - 3.0), Color(0.95, 0.15, 0.12), 2.8)
	draw_circle(dial_c, 4.5, Color(0.14, 0.15, 0.14))
	draw_circle(dial_c, 2.0, Color(0.95, 0.15, 0.12))
	
	var mfa_box = Rect2(dial_c.x - 22, dial_c.y + 16, 44, 13)
	draw_rect(mfa_box, Color(0.08, 0.16, 0.10), true)
	draw_rect(mfa_box, Color(0.20, 0.40, 0.25), false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(mfa_box.position.x + 4.0, mfa_box.position.y + 10.0), "MFA 12:48", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.35, 0.95, 0.45))

func draw_golf_mfa_aux(rect: Rect2, center: Vector2, _radius: float):
	draw_rect(rect, Color(0.06, 0.07, 0.07, 0.96), true)
	draw_rect(rect, Color(0.24, 0.32, 0.26, 0.85), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "MFA BOARDCOMPUTER", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.92, 0.95, 0.92))
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 65, 16), "BOSCH K-JET", HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.35, 0.95, 0.45))
	
	var lcd_rect = Rect2(16, 28, rect.size.x - 32, 42)
	draw_rect(lcd_rect, Color(0.06, 0.16, 0.08), true)
	draw_rect(lcd_rect, Color(0.30, 0.65, 0.35), false, 1.2)
	
	var oil_temp = int(round(smoothed_temp + 6.0))
	draw_string(ThemeDB.fallback_font, Vector2(22, 44), "ÖLTEMPERATUR: %d °C" % oil_temp, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.40, 1.0, 0.50))
	draw_string(ThemeDB.fallback_font, Vector2(22, 60), "DURCHSCHNITT: 8.2 L/100km", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.40, 1.0, 0.50))
	
	var bottom_rect = Rect2(16, 76, rect.size.x - 32, 22)
	draw_rect(bottom_rect, Color(0.10, 0.12, 0.11), true)
	draw_rect(bottom_rect, Color(0.25, 0.35, 0.28), false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(20, 91), "1.8 16V DOHC (139 CV / 102 kW)", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.95, 0.85, 0.30))

func draw_golf_console(rect: Rect2, center: Vector2):
	draw_rect(rect, Color(0.06, 0.07, 0.07, 0.96), true)
	draw_rect(rect, Color(0.24, 0.32, 0.26, 0.85), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "GOLF GTI 16V COCKPIT", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.92, 0.95, 0.92))
	
	var ball_c = Vector2(40.0, center.y + 4.0)
	draw_circle(ball_c, 16.0, Color(0.12, 0.13, 0.14))
	draw_circle(ball_c, 14.5, Color(0.05, 0.06, 0.06))
	for a in range(8):
		var ang = float(a) * TAU / 8.0
		draw_circle(ball_c + Vector2(cos(ang), sin(ang)) * 9.0, 1.8, Color(0.20, 0.22, 0.20))
	draw_circle(ball_c, 2.2, Color(0.20, 0.22, 0.20))
	draw_string(ThemeDB.fallback_font, Vector2(ball_c.x - 12, ball_c.y + 3), "16V", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.95, 0.15, 0.15))
	
	var sp_x = rect.size.x * 0.45
	var sp_y = center.y + 4.0
	draw_line(Vector2(sp_x, sp_y - 12), Vector2(sp_x, sp_y + 12), Color(0.7, 0.75, 0.7), 2.0)
	draw_line(Vector2(sp_x + 18, sp_y - 12), Vector2(sp_x + 18, sp_y + 12), Color(0.7, 0.75, 0.7), 2.0)
	draw_line(Vector2(sp_x + 36, sp_y - 12), Vector2(sp_x + 36, sp_y), Color(0.7, 0.75, 0.7), 2.0)
	draw_line(Vector2(sp_x - 16, sp_y - 12), Vector2(sp_x - 16, sp_y), Color(0.95, 0.4, 0.3), 2.0)
	draw_line(Vector2(sp_x - 16, sp_y), Vector2(sp_x + 36, sp_y), Color(0.7, 0.75, 0.7), 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(sp_x - 19, sp_y - 14), "R", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.95, 0.4, 0.3))
	draw_string(ThemeDB.fallback_font, Vector2(sp_x - 3, sp_y - 14), "1", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(sp_x - 3, sp_y + 20), "2", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(sp_x + 15, sp_y - 14), "3", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(sp_x + 15, sp_y + 20), "4", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(sp_x + 33, sp_y - 14), "5", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color.WHITE)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, rect.size.y - 6), "FRONT-WHEEL DRIVE HOT-HATCH (FWD)", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.95, 0.25, 0.25))

# ==============================================================================
# INTERACTIVE STEERING WHEEL RIM RENDERING
# ==============================================================================
func draw_steering_wheel_rim(rect: Rect2, rim_color: Color, stripe_color: Color, steer_val: float, is_rally: bool):
	var wheel_c = Vector2(rect.size.x * 0.15, rect.size.y + 40.0)
	var wheel_r = 52.0
	var steer_rot = steer_val * 0.45
	
	var arc_start = deg_to_rad(-135.0) + steer_rot
	var arc_end = deg_to_rad(-45.0) + steer_rot
	
	draw_arc(wheel_c, wheel_r, arc_start, arc_end, 24, rim_color, 7.0)
	draw_arc(wheel_c, wheel_r, arc_start, arc_end, 24, Color(0.04, 0.05, 0.05, 0.5), 1.5)
	
	if is_rally:
		var stripe_ang = deg_to_rad(-90.0) + steer_rot
		var s_dir = Vector2(cos(stripe_ang), sin(stripe_ang))
		var p1 = wheel_c + s_dir * (wheel_r - 4.0)
		var p2 = wheel_c + s_dir * (wheel_r + 4.0)
		draw_line(p1, p2, stripe_color, 4.0)

# ==============================================================================
# 5. RENAULT 4 GTL (1980) - JAEGER & LEVA A MANICO D'OMBRELLO
# ==============================================================================
func draw_renault4_speedo(rect: Rect2, _center: Vector2, _radius: float):
	# Authentic Jaeger Quatrelle textured matte grey bezel
	draw_rect(rect, Color(0.12, 0.13, 0.14, 0.96), true)
	draw_rect(rect, Color(0.30, 0.32, 0.34, 0.90), false, 2.0)
	draw_rect(Rect2(rect.position + Vector2(3, 3), rect.size - Vector2(6, 6)), Color(0.06, 0.07, 0.08, 0.95), false, 1.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "JAEGER FRANCE", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.85, 0.88, 0.90))
	var gear_lbl = ("[" + gear_text + "]") if gear_text != "" else "4 MARCE"
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 70, 16), gear_lbl, HORIZONTAL_ALIGNMENT_RIGHT, -1, 10, Color(0.95, 0.75, 0.25))
	
	# Circular Speedometer dial
	var dial_r = clamp(rect.size.y * 0.40, 36.0, 44.0)
	var dial_c = Vector2(rect.size.x * 0.22, rect.size.y * 0.58)
	draw_circle(dial_c, dial_r, Color(0.08, 0.09, 0.10))
	draw_arc(dial_c, dial_r, 0, TAU, 32, Color(0.24, 0.26, 0.28), 1.5)
	
	# Speedometer scale 0-140 km/h
	var ang_start = deg_to_rad(135.0)
	var ang_sweep = deg_to_rad(270.0)
	for spd in range(0, 141, 10):
		var frac = float(spd) / 140.0
		var a = ang_start + frac * ang_sweep
		var v_dir = Vector2(cos(a), sin(a))
		var is_major = (spd % 20 == 0)
		var p_in = dial_c + v_dir * (dial_r - (8.0 if is_major else 4.0))
		var p_out = dial_c + v_dir * (dial_r - 1.0)
		draw_line(p_in, p_out, Color(0.92, 0.88, 0.55) if is_major else Color(0.65, 0.65, 0.60), 2.0 if is_major else 1.0)
		if is_major and dial_r >= 38.0:
			var p_txt = dial_c + v_dir * (dial_r - 15.0) - Vector2(10, -3)
			draw_string(ThemeDB.fallback_font, p_txt, str(spd), HORIZONTAL_ALIGNMENT_CENTER, 20, 7, Color(0.92, 0.88, 0.55))
			
	# Speedometer Needle
	var spd_val = clamp(smoothed_val, 0.0, 140.0)
	var needle_a = ang_start + (spd_val / 140.0) * ang_sweep
	var n_dir = Vector2(cos(needle_a), sin(needle_a))
	draw_line(dial_c, dial_c + n_dir * (dial_r - 4.0), Color(0.95, 0.40, 0.10), 2.2)
	draw_circle(dial_c, 4.0, Color(0.18, 0.18, 0.18))
	draw_circle(dial_c, 2.0, Color(0.95, 0.40, 0.10))
	
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 14, dial_c.y + 16), "km/h", HORIZONTAL_ALIGNMENT_CENTER, 28, 8, Color(0.8, 0.8, 0.75))
	
	# Odometer rolling drums
	var odo_w = 48.0
	var odo_h = 10.0
	var odo_pos = Vector2(dial_c.x - odo_w * 0.5, dial_c.y - 14.0)
	draw_rect(Rect2(odo_pos, Vector2(odo_w, odo_h)), Color(0.04, 0.04, 0.04), true)
	var odo_str = "%06d" % int(odometer_km)
	draw_string(ThemeDB.fallback_font, odo_pos + Vector2(2, 8), odo_str, HORIZONTAL_ALIGNMENT_CENTER, int(odo_w - 4), 7, Color(0.95, 0.95, 0.90))
	
	# Secondary Drum: Linear Fuel Bar (34L tank)
	var fuel_x = rect.size.x * 0.48
	var fuel_w = rect.size.x * 0.46
	var fuel_y = rect.size.y * 0.40
	draw_string(ThemeDB.fallback_font, Vector2(fuel_x, fuel_y - 8), "CARBURANT (34L)", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.85, 0.88, 0.90))
	draw_rect(Rect2(Vector2(fuel_x, fuel_y), Vector2(fuel_w, 8)), Color(0.05, 0.05, 0.06), true)
	draw_rect(Rect2(Vector2(fuel_x, fuel_y), Vector2(fuel_w, 8)), Color(0.3, 0.35, 0.4), false, 1.0)
	var f_pct = clamp(smoothed_aux / 34.0, 0.0, 1.0)
	var f_fill_w = fuel_w * f_pct
	var f_col = Color(0.95, 0.25, 0.20) if f_pct < 0.18 else Color(0.90, 0.75, 0.25)
	draw_rect(Rect2(Vector2(fuel_x + 1, fuel_y + 1), Vector2(f_fill_w, 6)), f_col, true)
	draw_string(ThemeDB.fallback_font, Vector2(fuel_x, fuel_y + 18), "R", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.95, 0.3, 0.2))
	draw_string(ThemeDB.fallback_font, Vector2(fuel_x + fuel_w * 0.5 - 4, fuel_y + 18), "1/2", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(fuel_x + fuel_w - 6, fuel_y + 18), "4/4", HORIZONTAL_ALIGNMENT_RIGHT, -1, 7, Color.WHITE)
	
	# Vintage Telltale Warning Lamps: HUILE, EAU, CHARGE, CLIGNOTANT
	var lamps_y = rect.size.y * 0.72
	var lamp_data = [
		{"txt": "HUILE", "col": Color(0.95, 0.15, 0.15)},
		{"txt": "EAU", "col": Color(0.95, 0.15, 0.15) if smoothed_temp > 100.0 else Color(0.3, 0.1, 0.1)},
		{"txt": "CHARGE", "col": Color(0.95, 0.20, 0.20)},
		{"txt": "CLIGNOT.", "col": Color(0.20, 0.85, 0.30)}
	]
	for i in range(lamp_data.size()):
		var lx = fuel_x + float(i) * (fuel_w * 0.25)
		var ld = lamp_data[i]
		draw_rect(Rect2(Vector2(lx, lamps_y), Vector2(fuel_w * 0.22, 14)), Color(0.06, 0.07, 0.08), true)
		draw_rect(Rect2(Vector2(lx, lamps_y), Vector2(fuel_w * 0.22, 14)), ld.col, false, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(lx + 2, lamps_y + 10), ld.txt, HORIZONTAL_ALIGNMENT_CENTER, int(fuel_w * 0.22 - 4), 6, ld.col)
		
	draw_steering_wheel_rim(rect, Color(0.14, 0.14, 0.15), Color.TRANSPARENT, smoothed_steer, false)

func draw_renault4_console(rect: Rect2, _center: Vector2):
	# Graphic reproduction of the dash-mounted umbrella horizontal shifter
	draw_rect(rect, Color(0.10, 0.11, 0.12, 0.96), true)
	draw_rect(rect, Color(0.30, 0.32, 0.34, 0.90), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "COMMANDE DE BOÎTE CRUSCOTTO (TYPE 354)", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.85, 0.88, 0.90))
	
	# Horizontal umbrella rod graphic
	var rx = rect.size.x * 0.30
	var ry = rect.size.y * 0.50
	# Dashboard grommet
	draw_circle(Vector2(rx - 30, ry), 12.0, Color(0.20, 0.22, 0.24))
	draw_circle(Vector2(rx - 30, ry), 8.0, Color(0.05, 0.05, 0.06))
	# Horizontal chrome rod
	draw_line(Vector2(rx - 30, ry), Vector2(rx + 25, ry), Color(0.85, 0.88, 0.90), 5.0)
	# Vertical handle bend
	draw_line(Vector2(rx + 25, ry), Vector2(rx + 25, ry - 22), Color(0.85, 0.88, 0.90), 5.0)
	# Black ball knob
	draw_circle(Vector2(rx + 25, ry - 25), 8.0, Color(0.12, 0.12, 0.12))
	draw_circle(Vector2(rx + 24, ry - 26), 2.5, Color(0.4, 0.4, 0.4))
	
	# 4-Speed Shift Pattern diagram
	var gx = rect.size.x * 0.72
	var gy = rect.size.y * 0.52
	draw_line(Vector2(gx - 20, gy - 16), Vector2(gx - 20, gy + 16), Color(0.7, 0.75, 0.7), 2.0)
	draw_line(Vector2(gx + 20, gy - 16), Vector2(gx + 20, gy + 16), Color(0.7, 0.75, 0.7), 2.0)
	draw_line(Vector2(gx - 20, gy), Vector2(gx + 20, gy), Color(0.7, 0.75, 0.7), 2.0)
	draw_line(Vector2(gx - 20, gy - 16), Vector2(gx - 35, gy - 16), Color(0.95, 0.4, 0.3), 2.0) # Reverse
	
	draw_string(ThemeDB.fallback_font, Vector2(gx - 40, gy - 18), "R", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.95, 0.4, 0.3))
	draw_string(ThemeDB.fallback_font, Vector2(gx - 24, gy - 18), "1", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(gx - 24, gy + 26), "2", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(gx + 16, gy - 18), "3", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(gx + 16, gy + 26), "4", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color.WHITE)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, rect.size.y - 8), "TRACTION AVANT [FWD] | BARRES DE TORSION INDÉPENDANTES", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.95, 0.85, 0.30))

# ==============================================================================
# 6. BMW 320i E30 (1990) - VDO TACHO & ECONOMETRO BAVARESE
# ==============================================================================
func draw_bmw_speedo(rect: Rect2, _center: Vector2, _radius: float):
	# Authentic BMW E30 VDO twin-dial cluster in dark anthracite
	draw_rect(rect, Color(0.06, 0.06, 0.07, 0.98), true)
	draw_rect(rect, Color(0.25, 0.26, 0.28, 0.90), false, 2.0)
	draw_rect(Rect2(rect.position + Vector2(3, 3), rect.size - Vector2(6, 6)), Color(0.03, 0.03, 0.04, 0.95), false, 1.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "VDO BMW AG", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.85, 0.88, 0.92))
	var gear_lbl = ("[" + gear_text + "]") if gear_text != "" else "GETRAG"
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 70, 16), gear_lbl, HORIZONTAL_ALIGNMENT_RIGHT, -1, 10, Color(0.98, 0.60, 0.15))
	
	# Circular Speedometer dial 0-240 km/h
	var dial_r = clamp(rect.size.y * 0.41, 38.0, 46.0)
	var dial_c = Vector2(rect.size.x * 0.36, rect.size.y * 0.58)
	draw_circle(dial_c, dial_r, Color(0.05, 0.05, 0.06))
	draw_arc(dial_c, dial_r, 0, TAU, 36, Color(0.20, 0.22, 0.24), 1.5)
	
	var ang_start = deg_to_rad(135.0)
	var ang_sweep = deg_to_rad(270.0)
	for spd in range(0, 241, 20):
		var frac = float(spd) / 240.0
		var a = ang_start + frac * ang_sweep
		var v_dir = Vector2(cos(a), sin(a))
		var p_in = dial_c + v_dir * (dial_r - 8.0)
		var p_out = dial_c + v_dir * (dial_r - 1.0)
		draw_line(p_in, p_out, Color(0.95, 0.95, 0.95), 2.0)
		if dial_r >= 40.0:
			var p_txt = dial_c + v_dir * (dial_r - 15.0) - Vector2(10, -3)
			draw_string(ThemeDB.fallback_font, p_txt, str(spd), HORIZONTAL_ALIGNMENT_CENTER, 20, 6, Color.WHITE)
			
	# BMW Bright Red Needle with white hub
	var spd_val = clamp(smoothed_val, 0.0, 240.0)
	var needle_a = ang_start + (spd_val / 240.0) * ang_sweep
	var n_dir = Vector2(cos(needle_a), sin(needle_a))
	draw_line(dial_c, dial_c + n_dir * (dial_r - 4.0), Color(0.96, 0.18, 0.12), 2.2)
	draw_circle(dial_c, 4.5, Color(0.15, 0.15, 0.16))
	draw_circle(dial_c, 2.0, Color(0.96, 0.18, 0.12))
	
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 14, dial_c.y + 16), "km/h", HORIZONTAL_ALIGNMENT_CENTER, 28, 8, Color(0.7, 0.7, 0.7))
	
	# Fuel auxiliary gauge on the right (55L tank)
	var fuel_c = Vector2(rect.size.x * 0.82, rect.size.y * 0.58)
	var fuel_r = dial_r * 0.55
	draw_circle(fuel_c, fuel_r, Color(0.05, 0.05, 0.06))
	draw_arc(fuel_c, fuel_r, deg_to_rad(135.0), deg_to_rad(45.0), 18, Color(0.2, 0.2, 0.2), 1.0)
	var f_frac = clamp(smoothed_aux / 55.0, 0.0, 1.0)
	var f_a = deg_to_rad(135.0) + f_frac * deg_to_rad(270.0)
	draw_line(fuel_c, fuel_c + Vector2(cos(f_a), sin(f_a)) * (fuel_r - 3.0), Color(0.96, 0.18, 0.12), 1.8)
	draw_circle(fuel_c, 3.0, Color(0.2, 0.2, 0.2))
	draw_string(ThemeDB.fallback_font, Vector2(fuel_c.x - 15, fuel_c.y - fuel_r - 2), "KRAFTSTOFF", HORIZONTAL_ALIGNMENT_CENTER, 30, 6, Color(0.8, 0.8, 0.8))
	draw_string(ThemeDB.fallback_font, Vector2(fuel_c.x - fuel_r - 2, fuel_c.y + 12), "R", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color(0.95, 0.3, 0.2))
	draw_string(ThemeDB.fallback_font, Vector2(fuel_c.x + fuel_r - 4, fuel_c.y + 12), "1/1", HORIZONTAL_ALIGNMENT_RIGHT, -1, 6, Color.WHITE)
	
	draw_steering_wheel_rim(rect, Color(0.12, 0.12, 0.13), Color.TRANSPARENT, smoothed_steer, false)

func draw_bmw_tacho_econo(rect: Rect2, _center: Vector2, _radius: float):
	# Authentic BMW 7.000 RPM tachometer + crescent Econometer (Verbrauch L/100km)
	draw_rect(rect, Color(0.06, 0.06, 0.07, 0.98), true)
	draw_rect(rect, Color(0.25, 0.26, 0.28, 0.90), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "DREHZAHLMESSER 1/min x1000", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.85, 0.88, 0.92))
	
	var dial_r = clamp(rect.size.y * 0.41, 38.0, 46.0)
	var dial_c = Vector2(rect.size.x * 0.38, rect.size.y * 0.54)
	draw_circle(dial_c, dial_r, Color(0.05, 0.05, 0.06))
	
	var ang_start = deg_to_rad(135.0)
	var ang_sweep = deg_to_rad(270.0)
	# Ticks 0 to 7 (thousands)
	for rpm_k in range(0, 8):
		var frac = float(rpm_k) / 7.0
		var a = ang_start + frac * ang_sweep
		var v_dir = Vector2(cos(a), sin(a))
		var is_red = (rpm_k >= 6)
		draw_line(dial_c + v_dir * (dial_r - 7.0), dial_c + v_dir * (dial_r - 1.0), Color(0.95, 0.2, 0.2) if is_red else Color.WHITE, 2.0)
		var p_txt = dial_c + v_dir * (dial_r - 14.0) - Vector2(8, -3)
		draw_string(ThemeDB.fallback_font, p_txt, str(rpm_k), HORIZONTAL_ALIGNMENT_CENTER, 16, 7, Color(0.95, 0.2, 0.2) if is_red else Color.WHITE)
		
	# Red Needle
	var rpm_disp = clamp(smoothed_val, 800.0, 7000.0)
	var r_frac = (rpm_disp - 0.0) / 7000.0
	var needle_a = ang_start + r_frac * ang_sweep
	draw_line(dial_c, dial_c + Vector2(cos(needle_a), sin(needle_a)) * (dial_r - 4.0), Color(0.96, 0.18, 0.12), 2.2)
	draw_circle(dial_c, 4.5, Color(0.15, 0.15, 0.16))
	
	# THE LEGENDARY BMW ECONOMETER (L/100km) CRESCENT GAUGE
	var eco_y = dial_c.y + 18.0
	var eco_w = dial_r * 1.10
	draw_arc(dial_c, dial_r * 0.52, deg_to_rad(30.0), deg_to_rad(150.0), 16, Color(0.35, 0.35, 0.35), 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 16, eco_y + 12), "L/100km", HORIZONTAL_ALIGNMENT_CENTER, 32, 6, Color(0.95, 0.60, 0.15))
	# Econometer needle swinging with consumption (simulated from RPM & throttle)
	var eco_val = clamp(8.5 + (rpm_disp / 7000.0) * 16.0, 0.0, 30.0)
	var eco_frac = eco_val / 30.0
	var eco_ang = deg_to_rad(150.0) - eco_frac * deg_to_rad(120.0)
	draw_line(dial_c, dial_c + Vector2(cos(eco_ang), sin(eco_ang)) * (dial_r * 0.48), Color(0.96, 0.18, 0.12), 1.6)
	
	# Coolant temperature gauge on the right
	var temp_c = Vector2(rect.size.x * 0.82, rect.size.y * 0.56)
	var temp_r = dial_r * 0.55
	draw_circle(temp_c, temp_r, Color(0.05, 0.05, 0.06))
	draw_arc(temp_c, temp_r, deg_to_rad(135.0), deg_to_rad(45.0), 18, Color(0.2, 0.2, 0.2), 1.0)
	var t_frac = clamp((smoothed_temp - 50.0) / 70.0, 0.0, 1.0)
	var t_a = deg_to_rad(135.0) + t_frac * deg_to_rad(270.0)
	draw_line(temp_c, temp_c + Vector2(cos(t_a), sin(t_a)) * (temp_r - 3.0), Color(0.96, 0.18, 0.12), 1.8)
	draw_circle(temp_c, 3.0, Color(0.2, 0.2, 0.2))
	draw_string(ThemeDB.fallback_font, Vector2(temp_c.x - 14, temp_c.y - temp_r - 2), "TEMPERATUR", HORIZONTAL_ALIGNMENT_CENTER, 28, 6, Color(0.8, 0.8, 0.8))
	draw_string(ThemeDB.fallback_font, Vector2(temp_c.x - temp_r - 2, temp_c.y + 12), "C", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color(0.3, 0.6, 0.95))
	draw_string(ThemeDB.fallback_font, Vector2(temp_c.x + temp_r - 4, temp_c.y + 12), "H", HORIZONTAL_ALIGNMENT_RIGHT, -1, 6, Color(0.95, 0.2, 0.2))

func draw_bmw_console(rect: Rect2, _center: Vector2):
	# Center console oriented towards driver & 5-speed Getrag shift gate
	draw_rect(rect, Color(0.08, 0.08, 0.09, 0.96), true)
	draw_rect(rect, Color(0.25, 0.26, 0.28, 0.90), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "BAYERISCHE MOTOREN WERKE AG", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.85, 0.88, 0.92))
	
	# BMW M-Technik Tricolor badge (Light Blue, Dark Blue, Red)
	var mx = rect.size.x * 0.22
	var my = rect.size.y * 0.48
	draw_rect(Rect2(Vector2(mx, my), Vector2(6, 18)), Color(0.05, 0.65, 0.95), true) # Light blue
	draw_rect(Rect2(Vector2(mx + 7, my), Vector2(6, 18)), Color(0.05, 0.15, 0.65), true) # Dark blue
	draw_rect(Rect2(Vector2(mx + 14, my), Vector2(6, 18)), Color(0.95, 0.10, 0.10), true) # Red
	draw_string(ThemeDB.fallback_font, Vector2(mx + 24, my + 14), "M", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	
	# 5-Speed H-pattern shift gate
	var sx = rect.size.x * 0.70
	var sy = rect.size.y * 0.50
	draw_line(Vector2(sx - 20, sy - 14), Vector2(sx - 20, sy + 14), Color(0.7, 0.75, 0.7), 2.0)
	draw_line(Vector2(sx, sy - 14), Vector2(sx, sy + 14), Color(0.7, 0.75, 0.7), 2.0)
	draw_line(Vector2(sx + 20, sy - 14), Vector2(sx + 20, sy + 14), Color(0.7, 0.75, 0.7), 2.0)
	draw_line(Vector2(sx - 20, sy), Vector2(sx + 20, sy), Color(0.7, 0.75, 0.7), 2.0)
	draw_line(Vector2(sx - 20, sy - 14), Vector2(sx - 34, sy - 14), Color(0.95, 0.4, 0.3), 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(sx - 38, sy - 16), "R", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.95, 0.4, 0.3))
	draw_string(ThemeDB.fallback_font, Vector2(sx - 24, sy - 16), "1", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(sx - 24, sy + 22), "2", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(sx - 4, sy - 16), "3", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(sx - 4, sy + 22), "4", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(sx + 16, sy - 16), "5", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color.WHITE)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, rect.size.y - 8), "KLASSISCHER HECKANTRIEB [RWD] | 2.0L M20B20 REIHE-6", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.98, 0.60, 0.15))

# ==============================================================================
# 7. MERCEDES-BENZ A 250 SPORT (2016) - TWIN-TUBE & COMAND SCREEN
# ==============================================================================
func draw_a250_cluster(rect: Rect2, _center: Vector2, _radius: float):
	# Modern Twin-Tube Sport Binnacle in brushed dark metal with silver bezels
	draw_rect(rect, Color(0.04, 0.05, 0.06, 0.98), true)
	draw_rect(rect, Color(0.20, 0.22, 0.26, 0.90), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "MERCEDES-BENZ SPORT INSTRUMENTS", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.85, 0.88, 0.92))
	var gear_lbl = ("[" + gear_text + "]") if gear_text != "" else "7G-DCT"
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 70, 16), gear_lbl, HORIZONTAL_ALIGNMENT_RIGHT, -1, 10, Color(0.95, 0.25, 0.25))
	
	# Left Tube: Speedometer 0-260 km/h with chequered flag texture
	var tube_r = clamp(rect.size.y * 0.40, 38.0, 45.0)
	var spd_c = Vector2(rect.size.x * 0.28, rect.size.y * 0.58)
	draw_circle(spd_c, tube_r, Color(0.08, 0.09, 0.10))
	draw_arc(spd_c, tube_r, 0, TAU, 32, Color(0.75, 0.78, 0.82), 2.0) # Chrome ring
	
	var ang_start = deg_to_rad(135.0)
	var ang_sweep = deg_to_rad(270.0)
	for spd in range(0, 261, 30):
		var frac = float(spd) / 260.0
		var a = ang_start + frac * ang_sweep
		var v_dir = Vector2(cos(a), sin(a))
		draw_line(spd_c + v_dir * (tube_r - 7.0), spd_c + v_dir * (tube_r - 2.0), Color.WHITE, 1.8)
		if tube_r >= 40.0:
			var p_txt = spd_c + v_dir * (tube_r - 14.0) - Vector2(10, -3)
			draw_string(ThemeDB.fallback_font, p_txt, str(spd), HORIZONTAL_ALIGNMENT_CENTER, 20, 6, Color.WHITE)
			
	var spd_val = clamp(smoothed_val, 0.0, 260.0)
	var needle_a = ang_start + (spd_val / 260.0) * ang_sweep
	draw_line(spd_c, spd_c + Vector2(cos(needle_a), sin(needle_a)) * (tube_r - 4.0), Color(0.95, 0.20, 0.20), 2.2)
	draw_circle(spd_c, 4.0, Color(0.75, 0.78, 0.82))
	
	# Right Tube: Tachometer 0-7000 rpm
	var tach_c = Vector2(rect.size.x * 0.72, rect.size.y * 0.58)
	draw_circle(tach_c, tube_r, Color(0.08, 0.09, 0.10))
	draw_arc(tach_c, tube_r, 0, TAU, 32, Color(0.75, 0.78, 0.82), 2.0)
	
	for r_k in range(0, 8):
		var frac = float(r_k) / 7.0
		var a = ang_start + frac * ang_sweep
		var v_dir = Vector2(cos(a), sin(a))
		var is_red = (r_k >= 6)
		draw_line(tach_c + v_dir * (tube_r - 7.0), tach_c + v_dir * (tube_r - 2.0), Color(0.95, 0.2, 0.2) if is_red else Color.WHITE, 1.8)
		var p_txt = tach_c + v_dir * (tube_r - 14.0) - Vector2(8, -3)
		draw_string(ThemeDB.fallback_font, p_txt, str(r_k), HORIZONTAL_ALIGNMENT_CENTER, 16, 6, Color(0.95, 0.2, 0.2) if is_red else Color.WHITE)
		
	var rpm_disp = clamp(smoothed_oil, 700.0, 6500.0)
	var t_needle_a = ang_start + (rpm_disp / 7000.0) * ang_sweep
	draw_line(tach_c, tach_c + Vector2(cos(t_needle_a), sin(t_needle_a)) * (tube_r - 4.0), Color(0.95, 0.20, 0.20), 2.2)
	draw_circle(tach_c, 4.0, Color(0.75, 0.78, 0.82))
	
	# Center TFT Digital Display: Gear & Speed readout
	var mid_x = rect.size.x * 0.50
	var mid_y = rect.size.y * 0.58
	draw_rect(Rect2(Vector2(mid_x - 22, mid_y - 20), Vector2(44, 40)), Color(0.02, 0.03, 0.04), true)
	draw_rect(Rect2(Vector2(mid_x - 22, mid_y - 20), Vector2(44, 40)), Color(0.2, 0.3, 0.4), false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(mid_x - 20, mid_y - 6), str(int(smoothed_val)), HORIZONTAL_ALIGNMENT_CENTER, 40, 11, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(mid_x - 20, mid_y + 4), "km/h", HORIZONTAL_ALIGNMENT_CENTER, 40, 6, Color(0.6, 0.7, 0.8))
	draw_string(ThemeDB.fallback_font, Vector2(mid_x - 20, mid_y + 14), gear_text, HORIZONTAL_ALIGNMENT_CENTER, 40, 8, Color(0.95, 0.25, 0.25))

func draw_a250_screen(rect: Rect2, _center: Vector2):
	# 8-inch COMAND Infotainment Tablet Display: Turbo Boost & Telemetry
	draw_rect(rect, Color(0.03, 0.04, 0.05, 0.98), true)
	draw_rect(rect, Color(0.18, 0.22, 0.28, 0.95), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "DYNAMIC SELECT | SPORT MODE", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.95, 0.25, 0.25))
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 70, 16), "AMG DISPLAY", HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.7, 0.8, 0.9))
	
	# TURBO BOOST BAR (0.0 - 1.2 BAR)
	var bx = 16.0
	var by = rect.size.y * 0.38
	var bw = rect.size.x - 32.0
	draw_string(ThemeDB.fallback_font, Vector2(bx, by - 6), "LADEDRUCK (TURBO BOOST): " + str(snappedf(smoothed_val, 0.05)) + " BAR", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.85, 0.90, 0.95))
	draw_rect(Rect2(Vector2(bx, by), Vector2(bw, 10)), Color(0.06, 0.07, 0.08), true)
	var boost_pct = clamp(smoothed_val / 1.20, 0.0, 1.0)
	var b_col = Color(0.2, 0.75, 1.0) if boost_pct < 0.75 else Color(0.95, 0.3, 0.2)
	draw_rect(Rect2(Vector2(bx + 1, by + 1), Vector2(bw * boost_pct, 8)), b_col, true)
	
	# INSTANT ENGINE TORQUE & POWER TELEMETRY
	var tx = 16.0
	var ty = rect.size.y * 0.68
	var nm_val = int(clamp(120.0 + boost_pct * 230.0, 80.0, 350.0))
	draw_string(ThemeDB.fallback_font, Vector2(tx, ty), "MOTORLEISTUNG: 211 PS (155 kW) @ 5500 RPM", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.8, 0.85, 0.9))
	draw_string(ThemeDB.fallback_font, Vector2(tx, ty + 14), "DREHMOMENT: " + str(nm_val) + " Nm (MAX 350 Nm)", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.95, 0.80, 0.25))
	
	draw_string(ThemeDB.fallback_font, Vector2(10, rect.size.y - 6), "REIFENDRUCK: 2.4 BAR [OK] | ESP: SPORT ON", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.3, 0.9, 0.5))

func draw_a250_console(rect: Rect2, _center: Vector2):
	# 3 Aviation turbine air vents & AMG Flat-Bottom Steering Wheel graphic
	draw_rect(rect, Color(0.05, 0.06, 0.07, 0.96), true)
	draw_rect(rect, Color(0.20, 0.22, 0.26, 0.90), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "AMG LINE SPORTLENKRAD & 7G-DCT PADDLES", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.85, 0.88, 0.92))
	
	# 3 Aviation turbine air vents
	var vx_base = rect.size.x * 0.28
	var vy = rect.size.y * 0.48
	for i in range(3):
		var vx = vx_base + float(i) * 36.0
		draw_circle(Vector2(vx, vy), 14.0, Color(0.08, 0.09, 0.10))
		draw_arc(Vector2(vx, vy), 14.0, 0, TAU, 24, Color(0.75, 0.78, 0.82), 1.8) # Chrome bezel
		# Cross turbine blades
		draw_line(Vector2(vx - 9, vy), Vector2(vx + 9, vy), Color(0.4, 0.45, 0.5), 1.5)
		draw_line(Vector2(vx, vy - 9), Vector2(vx, vy + 9), Color(0.4, 0.45, 0.5), 1.5)
		draw_circle(Vector2(vx, vy), 3.0, Color(0.75, 0.78, 0.82))
		
	# Dual-clutch Paddle Shifter indicators
	var px = rect.size.x * 0.75
	draw_rect(Rect2(Vector2(px - 18, vy - 14), Vector2(12, 28)), Color(0.75, 0.78, 0.82), false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(px - 15, vy + 4), "-", HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color.WHITE)
	draw_rect(Rect2(Vector2(px + 6, vy - 14), Vector2(12, 28)), Color(0.75, 0.78, 0.82), false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(px + 8, vy + 4), "+", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color.WHITE)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, rect.size.y - 8), "2.0L TURBO M270 BlueDIRECT | 7G-DCT DOPPIA FRIZIONE", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.95, 0.30, 0.30))

# ==============================================================================
# 9. ALFA ROMEO 8C 2900B / MONZA (1931) - JAEGER MILANO & PERLAGE ALLOY
# ==============================================================================
func draw_alfa8c_speedo(rect: Rect2, center: Vector2, radius: float):
	draw_rect(rect, Color(0.18, 0.08, 0.05, 0.98), true) # Walnut / leather surround
	draw_rect(rect, Color(0.72, 0.58, 0.28, 0.95), false, 2.0) # Polished brass bezel
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "JAEGER MILANO (1931)", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.85, 0.75, 0.45))
	var g_lbl = ("[" + gear_text + "]") if gear_text != "" else "8C MONZA"
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 70, 16), g_lbl, HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.95, 0.85, 0.50))
	
	var dial_r = min(radius - 6.0, 44.0)
	var dial_c = Vector2(center.x, center.y + 4.0)
	
	draw_circle(dial_c, dial_r + 4.0, Color(0.68, 0.54, 0.24)) # Brass ring
	draw_circle(dial_c, dial_r, Color(0.92, 0.88, 0.78)) # Aged parchment dial
	draw_arc(dial_c, dial_r - 2.0, 0, TAU, 36, Color(0.25, 0.20, 0.14), 1.5)
	
	var start_ang = deg_to_rad(135.0)
	var end_ang = deg_to_rad(405.0)
	
	for spd in range(0, 201, 20):
		var t = float(spd) / 200.0
		var ang = lerp(start_ang, end_ang, t)
		var dir = Vector2(cos(ang), sin(ang))
		var is_major = (spd % 40 == 0)
		var p_out = dial_c + dir * (dial_r - 2.0)
		var p_in = dial_c + dir * (dial_r - (8.0 if is_major else 4.0))
		draw_line(p_in, p_out, Color(0.15, 0.12, 0.08), 2.0 if is_major else 1.0)
		if is_major:
			var p_txt = dial_c + dir * (dial_r - 14.0) + Vector2(-6, 3.5)
			draw_string(ThemeDB.fallback_font, p_txt, str(spd), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.12, 0.10, 0.06))
			
	var spd_t = clamp(smoothed_val / 200.0, 0.0, 1.0)
	var needle_ang = lerp(start_ang, end_ang, spd_t)
	var n_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	draw_line(dial_c - n_dir * 6.0, dial_c + n_dir * (dial_r - 3.0), Color(0.78, 0.12, 0.12), 2.8)
	draw_circle(dial_c, 4.5, Color(0.68, 0.54, 0.24))
	draw_circle(dial_c, 2.0, Color(0.78, 0.12, 0.12))
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 14, dial_c.y + 14), "KM/H", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.25, 0.20, 0.14))

func draw_alfa8c_tacho(rect: Rect2, center: Vector2, radius: float):
	draw_rect(rect, Color(0.18, 0.08, 0.05, 0.98), true)
	draw_rect(rect, Color(0.72, 0.58, 0.28, 0.95), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "GIRI MOTORE x100", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.85, 0.75, 0.45))
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 75, 16), "2.9L ROOTS", HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.95, 0.45, 0.25))
	
	var dial_r = min(radius - 6.0, 44.0)
	var dial_c = Vector2(center.x, center.y + 4.0)
	
	draw_circle(dial_c, dial_r + 4.0, Color(0.68, 0.54, 0.24))
	draw_circle(dial_c, dial_r, Color(0.92, 0.88, 0.78))
	draw_arc(dial_c, dial_r - 2.0, 0, TAU, 36, Color(0.25, 0.20, 0.14), 1.5)
	
	var start_ang = deg_to_rad(135.0)
	var end_ang = deg_to_rad(405.0)
	
	# Red sector from 5000 to 6000
	var red_start = lerp(start_ang, end_ang, 5.0 / 6.0)
	draw_arc(dial_c, dial_r - 4.0, red_start, end_ang, 12, Color(0.85, 0.15, 0.12), 4.0)
	
	for rpm_k in range(0, 7):
		var t = float(rpm_k) / 6.0
		var ang = lerp(start_ang, end_ang, t)
		var dir = Vector2(cos(ang), sin(ang))
		var is_red = (rpm_k >= 5)
		var col = Color(0.85, 0.15, 0.12) if is_red else Color(0.15, 0.12, 0.08)
		draw_line(dial_c + dir * (dial_r - 8.0), dial_c + dir * (dial_r - 2.0), col, 2.0)
		var p_txt = dial_c + dir * (dial_r - 14.0) + Vector2(-4, 3.5)
		draw_string(ThemeDB.fallback_font, p_txt, str(rpm_k * 10), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, col)
		
	var rpm_t = clamp(smoothed_val / 6000.0, 0.0, 1.0)
	var needle_ang = lerp(start_ang, end_ang, rpm_t)
	var n_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	draw_line(dial_c - n_dir * 6.0, dial_c + n_dir * (dial_r - 3.0), Color(0.78, 0.12, 0.12), 2.8)
	draw_circle(dial_c, 4.5, Color(0.68, 0.54, 0.24))
	draw_circle(dial_c, 2.0, Color(0.78, 0.12, 0.12))
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 22, dial_c.y + 14), "ALFA ROMEO", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.70, 0.12, 0.14))

func draw_alfa8c_console(rect: Rect2, center: Vector2):
	# Hand-hammered machine-turned aluminum dash (perlage)
	draw_rect(rect, Color(0.65, 0.68, 0.72, 0.98), true)
	draw_rect(rect, Color(0.45, 0.48, 0.52), false, 2.0)
	
	# Perlage circles texture
	for row in range(3):
		for col in range(8):
			var cx = 16.0 + float(col) * 26.0
			var cy = 16.0 + float(row) * 24.0
			draw_arc(Vector2(cx, cy), 12.0, 0, TAU, 16, Color(0.78, 0.82, 0.86, 0.45), 1.0)
			
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "CRUSCOTTO IN ALLUMINIO BOCIELLATO", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.12, 0.14, 0.18))
	
	# Magneto levers & Oil pressure
	var lx = rect.size.x * 0.28
	var ly = rect.size.y * 0.65
	draw_rect(Rect2(Vector2(lx - 12, ly - 16), Vector2(24, 32)), Color(0.75, 0.62, 0.30), true)
	draw_line(Vector2(lx, ly + 14), Vector2(lx, ly - 12), Color(0.2, 0.2, 0.2), 3.0)
	draw_string(ThemeDB.fallback_font, Vector2(lx - 14, ly + 26), "MAG 1-2", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.1, 0.1, 0.1))
	
	# 4-spoke Vintage Steering Wheel
	var sx = rect.size.x * 0.72
	var sy = rect.size.y * 0.55
	var sw_r = 30.0
	draw_circle(Vector2(sx, sy), sw_r, Color(0.38, 0.20, 0.10)) # Wood rim
	draw_circle(Vector2(sx, sy), sw_r - 5.0, Color(0.65, 0.68, 0.72))
	var s_ang = smoothed_steer * PI * 0.85
	for spk in [0.0, PI * 0.5, PI, PI * 1.5]:
		var dir = Vector2(cos(s_ang + spk), sin(s_ang + spk))
		draw_line(Vector2(sx, sy), Vector2(sx, sy) + dir * (sw_r - 2.0), Color(0.85, 0.88, 0.92), 2.5)
	draw_circle(Vector2(sx, sy), 6.0, Color(0.72, 0.15, 0.15)) # Alfa center
	draw_string(ThemeDB.fallback_font, Vector2(10, rect.size.y - 8), "DOPPIO COMPRESSORE VOLUMETRICO ROOTS | FRENI A TAMBURO ALETTATI", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.2, 0.2, 0.25))

# ==============================================================================
# 10. FIAT 500 TOPOLINO (1936) - QUADRANTE A GOCCIA & BAKELITE
# ==============================================================================
func draw_topolino_speedo(rect: Rect2, center: Vector2, radius: float):
	draw_rect(rect, Color(0.15, 0.08, 0.06, 0.98), true)
	draw_rect(rect, Color(0.65, 0.55, 0.35, 0.90), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "FIAT 500 'TOPOLINO' (1936)", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.92, 0.85, 0.65))
	var g_lbl = ("[" + gear_text + "]") if gear_text != "" else "4 MARCE"
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 65, 16), g_lbl, HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.85, 0.80, 0.60))
	
	var dial_r = min(radius - 6.0, 42.0)
	var dial_c = Vector2(center.x, center.y + 4.0)
	
	draw_circle(dial_c, dial_r + 3.0, Color(0.45, 0.40, 0.32)) # Bakelite ring
	draw_circle(dial_c, dial_r, Color(0.90, 0.86, 0.74)) # Sepia face
	
	var start_ang = deg_to_rad(140.0)
	var end_ang = deg_to_rad(400.0)
	
	for spd in range(0, 111, 10):
		var t = float(spd) / 110.0
		var ang = lerp(start_ang, end_ang, t)
		var dir = Vector2(cos(ang), sin(ang))
		var is_major = (spd % 20 == 0)
		draw_line(dial_c + dir * (dial_r - (7.0 if is_major else 4.0)), dial_c + dir * (dial_r - 2.0), Color(0.2, 0.16, 0.10), 2.0 if is_major else 1.0)
		if is_major:
			var p_txt = dial_c + dir * (dial_r - 13.0) + Vector2(-5, 3.5)
			draw_string(ThemeDB.fallback_font, p_txt, str(spd), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.2, 0.16, 0.10))
			
	var spd_t = clamp(smoothed_val / 110.0, 0.0, 1.0)
	var needle_ang = lerp(start_ang, end_ang, spd_t)
	var n_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	draw_line(dial_c - n_dir * 5.0, dial_c + n_dir * (dial_r - 3.0), Color(0.75, 0.15, 0.12), 2.8)
	draw_circle(dial_c, 4.0, Color(0.3, 0.25, 0.20))
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 12, dial_c.y + 14), "KM/H", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.3, 0.25, 0.15))

func draw_topolino_console(rect: Rect2, center: Vector2):
	draw_rect(rect, Color(0.18, 0.14, 0.12, 0.98), true)
	draw_rect(rect, Color(0.45, 0.38, 0.30), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "COMANDI A TIRANTE & ARIA MANUALE", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.85, 0.80, 0.70))
	
	# Choke and manual starter knobs
	var kx1 = rect.size.x * 0.25
	var kx2 = rect.size.x * 0.42
	var ky = rect.size.y * 0.52
	draw_circle(Vector2(kx1, ky), 9.0, Color(0.08, 0.08, 0.08))
	draw_string(ThemeDB.fallback_font, Vector2(kx1 - 10, ky + 18), "ARIA", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.85, 0.85, 0.85))
	draw_circle(Vector2(kx2, ky), 9.0, Color(0.08, 0.08, 0.08))
	draw_string(ThemeDB.fallback_font, Vector2(kx2 - 12, ky + 18), "AVVIO", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.85, 0.85, 0.85))
	
	# 3-spoke Thin Bakelite Steering Wheel
	var sx = rect.size.x * 0.75
	var sy = rect.size.y * 0.52
	var sw_r = 28.0
	draw_circle(Vector2(sx, sy), sw_r, Color(0.05, 0.05, 0.05)) # Black bakelite
	draw_circle(Vector2(sx, sy), sw_r - 4.0, Color(0.18, 0.14, 0.12))
	var s_ang = smoothed_steer * PI * 0.85
	for spk in [0.0, PI * 0.66, PI * 1.33]:
		var dir = Vector2(cos(s_ang + spk), sin(s_ang + spk))
		draw_line(Vector2(sx, sy), Vector2(sx, sy) + dir * (sw_r - 2.0), Color(0.2, 0.2, 0.2), 2.0)
	draw_circle(Vector2(sx, sy), 5.0, Color(0.65, 0.12, 0.12)) # Red horn button
	draw_string(ThemeDB.fallback_font, Vector2(10, rect.size.y - 8), "569 CM³ 4 CILINDRI VALVOLE LATERALI | RADIATORE POSTERIORE", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.6, 0.6, 0.65))

# ==============================================================================
# 11. LANCIA AURELIA B20 GT (1950) - JAEGER GRAN TURISMO & NARDI STEERING
# ==============================================================================
func draw_aurelia_speedo(rect: Rect2, center: Vector2, radius: float):
	draw_rect(rect, Color(0.06, 0.08, 0.14, 0.98), true) # Navy blue GT
	draw_rect(rect, Color(0.75, 0.78, 0.82), false, 2.0) # Chrome trim
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "JAEGER - LANCIA AURELIA B20 GT", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.85, 0.88, 0.95))
	var g_lbl = ("[" + gear_text + "]") if gear_text != "" else "TRANSAXLE"
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 75, 16), g_lbl, HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.95, 0.80, 0.30))
	
	var dial_r = min(radius - 6.0, 44.0)
	var dial_c = Vector2(center.x, center.y + 4.0)
	
	draw_circle(dial_c, dial_r + 3.0, Color(0.85, 0.88, 0.92)) # Chrome bezel
	draw_circle(dial_c, dial_r, Color(0.05, 0.06, 0.08)) # Black face
	
	var start_ang = deg_to_rad(135.0)
	var end_ang = deg_to_rad(405.0)
	
	for spd in range(0, 181, 20):
		var t = float(spd) / 180.0
		var ang = lerp(start_ang, end_ang, t)
		var dir = Vector2(cos(ang), sin(ang))
		var is_major = (spd % 40 == 0)
		draw_line(dial_c + dir * (dial_r - (7.0 if is_major else 4.0)), dial_c + dir * (dial_r - 2.0), Color(0.90, 0.82, 0.45), 2.0 if is_major else 1.0)
		if is_major:
			var p_txt = dial_c + dir * (dial_r - 14.0) + Vector2(-6, 3.5)
			draw_string(ThemeDB.fallback_font, p_txt, str(spd), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.95, 0.90, 0.70))
			
	var spd_t = clamp(smoothed_val / 180.0, 0.0, 1.0)
	var needle_ang = lerp(start_ang, end_ang, spd_t)
	var n_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	draw_line(dial_c - n_dir * 5.0, dial_c + n_dir * (dial_r - 3.0), Color(0.95, 0.95, 0.98), 2.6)
	draw_circle(dial_c, 4.0, Color(0.85, 0.88, 0.92))
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 14, dial_c.y + 14), "KM/H", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.7, 0.7, 0.75))

func draw_aurelia_tacho(rect: Rect2, center: Vector2, radius: float):
	draw_rect(rect, Color(0.06, 0.08, 0.14, 0.98), true)
	draw_rect(rect, Color(0.75, 0.78, 0.82), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "GIRI MOTORE V6 (60°)", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.85, 0.88, 0.95))
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 70, 16), "x1000 RPM", HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.95, 0.80, 0.30))
	
	var dial_r = min(radius - 6.0, 44.0)
	var dial_c = Vector2(center.x, center.y + 4.0)
	
	draw_circle(dial_c, dial_r + 3.0, Color(0.85, 0.88, 0.92))
	draw_circle(dial_c, dial_r, Color(0.05, 0.06, 0.08))
	
	var start_ang = deg_to_rad(135.0)
	var end_ang = deg_to_rad(405.0)
	
	# Redline at 5300
	var red_start = lerp(start_ang, end_ang, 5.3 / 6.0)
	draw_arc(dial_c, dial_r - 3.0, red_start, end_ang, 12, Color(0.90, 0.15, 0.12), 3.5)
	
	for rpm_k in range(0, 7):
		var t = float(rpm_k) / 6.0
		var ang = lerp(start_ang, end_ang, t)
		var dir = Vector2(cos(ang), sin(ang))
		draw_line(dial_c + dir * (dial_r - 7.0), dial_c + dir * (dial_r - 2.0), Color(0.90, 0.82, 0.45), 2.0)
		var p_txt = dial_c + dir * (dial_r - 14.0) + Vector2(-4, 3.5)
		draw_string(ThemeDB.fallback_font, p_txt, str(rpm_k), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.95, 0.90, 0.70))
		
	var rpm_t = clamp(smoothed_val / 6000.0, 0.0, 1.0)
	var needle_ang = lerp(start_ang, end_ang, rpm_t)
	var n_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	draw_line(dial_c - n_dir * 5.0, dial_c + n_dir * (dial_r - 3.0), Color(0.95, 0.95, 0.98), 2.6)
	draw_circle(dial_c, 4.0, Color(0.85, 0.88, 0.92))
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 18, dial_c.y + 14), "LANCIA", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.4, 0.6, 0.9))

func draw_aurelia_console(rect: Rect2, center: Vector2):
	draw_rect(rect, Color(0.08, 0.10, 0.16, 0.98), true)
	draw_rect(rect, Color(0.75, 0.78, 0.82), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "VOLANTE NARDI IN MOGANO & COMANDI", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.85, 0.88, 0.95))
	
	# Fuel & Water mini-gauges
	var gx1 = rect.size.x * 0.25
	var gx2 = rect.size.x * 0.45
	var gy = rect.size.y * 0.52
	draw_circle(Vector2(gx1, gy), 14.0, Color(0.04, 0.05, 0.06))
	draw_arc(Vector2(gx1, gy), 14.0, 0, TAU, 20, Color(0.75, 0.78, 0.82), 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(gx1 - 14, gy + 18), "BENZINA", HORIZONTAL_ALIGNMENT_CENTER, -1, 6, Color(0.8, 0.8, 0.85))
	
	draw_circle(Vector2(gx2, gy), 14.0, Color(0.04, 0.05, 0.06))
	draw_arc(Vector2(gx2, gy), 14.0, 0, TAU, 20, Color(0.75, 0.78, 0.82), 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(gx2 - 12, gy + 18), "ACQUA", HORIZONTAL_ALIGNMENT_CENTER, -1, 6, Color(0.8, 0.8, 0.85))
	
	# Nardi Wood Steering Wheel
	var sx = rect.size.x * 0.75
	var sy = rect.size.y * 0.52
	var sw_r = 29.0
	draw_circle(Vector2(sx, sy), sw_r, Color(0.48, 0.26, 0.12)) # Mahogany
	draw_circle(Vector2(sx, sy), sw_r - 4.5, Color(0.08, 0.10, 0.16))
	var s_ang = smoothed_steer * PI * 0.85
	for spk in [0.0, PI * 0.66, PI * 1.33]:
		var dir = Vector2(cos(s_ang + spk), sin(s_ang + spk))
		draw_line(Vector2(sx, sy), Vector2(sx, sy) + dir * (sw_r - 2.0), Color(0.85, 0.88, 0.92), 2.2)
	draw_circle(Vector2(sx, sy), 5.0, Color(0.12, 0.35, 0.75)) # Lancia Blue Shield
	draw_string(ThemeDB.fallback_font, Vector2(10, rect.size.y - 8), "PRIMO MOTORE V6 DI SERIE | SOSPENSIONI INDIPENDENTI E FRENI INBOARD", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.7, 0.75, 0.85))

# ==============================================================================
# 12. ALFA ROMEO GIULIA SPRINT GTA (1965) - AUTODELTA CORSE
# ==============================================================================
func draw_alfagta_speedo(rect: Rect2, center: Vector2, radius: float):
	draw_rect(rect, Color(0.08, 0.08, 0.09, 0.98), true) # Matt racing black
	draw_rect(rect, Color(0.65, 0.15, 0.15, 0.85), false, 2.0) # Autodelta red trim
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "VEGLIA BORLETTI COMPETIZIONE", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.95, 0.85, 0.30))
	var g_lbl = ("[" + gear_text + "]") if gear_text != "" else "5 MARCE CORTE"
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 75, 16), g_lbl, HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.95, 0.45, 0.25))
	
	var dial_r = min(radius - 6.0, 44.0)
	var dial_c = Vector2(center.x, center.y + 4.0)
	
	draw_circle(dial_c, dial_r + 3.0, Color(0.18, 0.18, 0.20))
	draw_circle(dial_c, dial_r, Color(0.04, 0.04, 0.05))
	
	var start_ang = deg_to_rad(135.0)
	var end_ang = deg_to_rad(405.0)
	
	for spd in range(0, 221, 20):
		var t = float(spd) / 220.0
		var ang = lerp(start_ang, end_ang, t)
		var dir = Vector2(cos(ang), sin(ang))
		var is_major = (spd % 40 == 0)
		draw_line(dial_c + dir * (dial_r - (7.0 if is_major else 4.0)), dial_c + dir * (dial_r - 2.0), Color.WHITE, 2.0 if is_major else 1.0)
		if is_major:
			var p_txt = dial_c + dir * (dial_r - 14.0) + Vector2(-6, 3.5)
			draw_string(ThemeDB.fallback_font, p_txt, str(spd), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color.WHITE)
			
	var spd_t = clamp(smoothed_val / 220.0, 0.0, 1.0)
	var needle_ang = lerp(start_ang, end_ang, spd_t)
	var n_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	draw_line(dial_c - n_dir * 5.0, dial_c + n_dir * (dial_r - 3.0), Color(1.0, 0.45, 0.10), 2.8)
	draw_circle(dial_c, 4.0, Color(0.2, 0.2, 0.25))
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 14, dial_c.y + 14), "KM/H", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.7, 0.7, 0.75))

func draw_alfagta_tacho(rect: Rect2, center: Vector2, radius: float):
	draw_rect(rect, Color(0.08, 0.08, 0.09, 0.98), true)
	draw_rect(rect, Color(0.65, 0.15, 0.15, 0.85), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "AUTODELTA 8000 RPM (ORIENTATO GARA)", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.95, 0.85, 0.30))
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 70, 16), "TWIN SPARK", HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.95, 0.35, 0.25))
	
	var dial_r = min(radius - 6.0, 44.0)
	var dial_c = Vector2(center.x, center.y + 4.0)
	
	draw_circle(dial_c, dial_r + 3.0, Color(0.18, 0.18, 0.20))
	draw_circle(dial_c, dial_r, Color(0.04, 0.04, 0.05))
	
	# Canted dial: 7000 RPM at top 12 o'clock
	var start_ang = deg_to_rad(120.0)
	var end_ang = deg_to_rad(390.0)
	
	# Redline arc from 7.0k to 8.0k
	var red_start = lerp(start_ang, end_ang, 7.0 / 8.0)
	draw_arc(dial_c, dial_r - 3.0, red_start, end_ang, 12, Color(0.95, 0.15, 0.12), 4.0)
	
	for rpm_k in range(0, 9):
		var t = float(rpm_k) / 8.0
		var ang = lerp(start_ang, end_ang, t)
		var dir = Vector2(cos(ang), sin(ang))
		var is_red = (rpm_k >= 7)
		var col = Color(0.95, 0.15, 0.12) if is_red else Color.WHITE
		draw_line(dial_c + dir * (dial_r - 7.0), dial_c + dir * (dial_r - 2.0), col, 2.0)
		var p_txt = dial_c + dir * (dial_r - 14.0) + Vector2(-4, 3.5)
		draw_string(ThemeDB.fallback_font, p_txt, str(rpm_k), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, col)
		
	var rpm_t = clamp(smoothed_val / 8000.0, 0.0, 1.0)
	var needle_ang = lerp(start_ang, end_ang, rpm_t)
	var n_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	draw_line(dial_c - n_dir * 5.0, dial_c + n_dir * (dial_r - 3.0), Color(1.0, 0.45, 0.10), 2.8)
	draw_circle(dial_c, 4.0, Color(0.2, 0.2, 0.25))
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 22, dial_c.y + 14), "AUTODELTA", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.95, 0.2, 0.2))

func draw_alfagta_console(rect: Rect2, center: Vector2):
	draw_rect(rect, Color(0.07, 0.07, 0.08, 0.98), true)
	draw_rect(rect, Color(0.65, 0.15, 0.15), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "VOLANTE HELLEBORE FORATO & INTERRUTTORI GARA", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.95, 0.85, 0.30))
	
	# Competition toggle switches
	var tx = rect.size.x * 0.32
	var ty = rect.size.y * 0.52
	for i in range(3):
		var sw_x = tx + float(i) * 22.0
		draw_rect(Rect2(Vector2(sw_x - 6, ty - 12), Vector2(12, 24)), Color(0.18, 0.18, 0.20), true)
		draw_line(Vector2(sw_x, ty + 10), Vector2(sw_x, ty - 8), Color(0.85, 0.88, 0.92), 2.5)
	draw_string(ThemeDB.fallback_font, Vector2(tx - 6, ty + 18), "POMPA", HORIZONTAL_ALIGNMENT_CENTER, -1, 6, Color(0.7, 0.7, 0.7))
	
	# Hellebore 3-spoke slotted aluminum racing wheel
	var sx = rect.size.x * 0.75
	var sy = rect.size.y * 0.52
	var sw_r = 29.0
	draw_circle(Vector2(sx, sy), sw_r, Color(0.38, 0.20, 0.10)) # Wood outer
	draw_circle(Vector2(sx, sy), sw_r - 4.5, Color(0.07, 0.07, 0.08))
	var s_ang = smoothed_steer * PI * 0.85
	for spk in [0.0, PI * 0.66, PI * 1.33]:
		var dir = Vector2(cos(s_ang + spk), sin(s_ang + spk))
		draw_line(Vector2(sx, sy), Vector2(sx, sy) + dir * (sw_r - 2.0), Color(0.85, 0.88, 0.92), 3.0)
	draw_circle(Vector2(sx, sy), 5.5, Color(0.75, 0.12, 0.15)) # Alfa Quadrifoglio badge
	draw_string(ThemeDB.fallback_font, Vector2(10, rect.size.y - 8), "CARROZZERIA PERALLUMAN (745 KG) | DOPPIA ACCENSIONE TWIN SPARK", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.85, 0.4, 0.4))

# ==============================================================================
# 13. LANCIA STRATOS HF STRADALE (1973) - BERTONE WEDGE & MOMO CORSE
# ==============================================================================
func draw_stratos_speedo(rect: Rect2, center: Vector2, radius: float):
	draw_rect(rect, Color(0.08, 0.09, 0.08, 0.98), true) # Bertone dark green/black
	draw_rect(rect, Color(0.65, 0.80, 0.15, 0.85), false, 2.0) # Stratos lime trim
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "STRATOS HF TACHIMETRO 250 KM/H", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.85, 0.95, 0.25))
	var g_lbl = ("[" + gear_text + "]") if gear_text != "" else "DINO V6"
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 70, 16), g_lbl, HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.95, 0.85, 0.25))
	
	var dial_r = min(radius - 6.0, 44.0)
	var dial_c = Vector2(center.x, center.y + 4.0)
	
	draw_circle(dial_c, dial_r + 3.0, Color(0.16, 0.18, 0.16))
	draw_circle(dial_c, dial_r, Color(0.04, 0.05, 0.04))
	
	var start_ang = deg_to_rad(135.0)
	var end_ang = deg_to_rad(405.0)
	
	for spd in range(0, 251, 25):
		var t = float(spd) / 250.0
		var ang = lerp(start_ang, end_ang, t)
		var dir = Vector2(cos(ang), sin(ang))
		var is_major = (spd % 50 == 0)
		draw_line(dial_c + dir * (dial_r - (7.0 if is_major else 4.0)), dial_c + dir * (dial_r - 2.0), Color(0.55, 0.95, 0.45), 2.0 if is_major else 1.0)
		if is_major:
			var p_txt = dial_c + dir * (dial_r - 14.0) + Vector2(-6, 3.5)
			draw_string(ThemeDB.fallback_font, p_txt, str(spd), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.65, 0.95, 0.55))
			
	var spd_t = clamp(smoothed_val / 250.0, 0.0, 1.0)
	var needle_ang = lerp(start_ang, end_ang, spd_t)
	var n_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	draw_line(dial_c - n_dir * 5.0, dial_c + n_dir * (dial_r - 3.0), Color(1.0, 0.45, 0.08), 2.8)
	draw_circle(dial_c, 4.0, Color(0.2, 0.25, 0.2))
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 14, dial_c.y + 14), "KM/H", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.6, 0.9, 0.5))

func draw_stratos_tacho(rect: Rect2, center: Vector2, radius: float):
	draw_rect(rect, Color(0.08, 0.09, 0.08, 0.98), true)
	draw_rect(rect, Color(0.65, 0.80, 0.15, 0.85), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "DINO 2.4L V6 (9000 RPM)", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.85, 0.95, 0.25))
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 70, 16), "BERTONE", HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.95, 0.85, 0.25))
	
	var dial_r = min(radius - 6.0, 44.0)
	var dial_c = Vector2(center.x, center.y + 4.0)
	
	draw_circle(dial_c, dial_r + 3.0, Color(0.16, 0.18, 0.16))
	draw_circle(dial_c, dial_r, Color(0.04, 0.05, 0.04))
	
	var start_ang = deg_to_rad(135.0)
	var end_ang = deg_to_rad(405.0)
	
	# Yellow warning 7500-8200, redline 8200-9000
	var yel_start = lerp(start_ang, end_ang, 7.5 / 9.0)
	var red_start = lerp(start_ang, end_ang, 8.2 / 9.0)
	draw_arc(dial_c, dial_r - 3.0, yel_start, red_start, 8, Color(0.95, 0.85, 0.15), 3.5)
	draw_arc(dial_c, dial_r - 3.0, red_start, end_ang, 8, Color(0.95, 0.15, 0.12), 4.0)
	
	for rpm_k in range(0, 10):
		var t = float(rpm_k) / 9.0
		var ang = lerp(start_ang, end_ang, t)
		var dir = Vector2(cos(ang), sin(ang))
		var is_red = (rpm_k >= 8)
		var col = Color(0.95, 0.15, 0.12) if is_red else Color(0.55, 0.95, 0.45)
		draw_line(dial_c + dir * (dial_r - 7.0), dial_c + dir * (dial_r - 2.0), col, 2.0)
		var p_txt = dial_c + dir * (dial_r - 14.0) + Vector2(-4, 3.5)
		draw_string(ThemeDB.fallback_font, p_txt, str(rpm_k), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, col)
		
	var rpm_t = clamp(smoothed_val / 9000.0, 0.0, 1.0)
	var needle_ang = lerp(start_ang, end_ang, rpm_t)
	var n_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	draw_line(dial_c - n_dir * 5.0, dial_c + n_dir * (dial_r - 3.0), Color(1.0, 0.45, 0.08), 2.8)
	draw_circle(dial_c, 4.0, Color(0.2, 0.25, 0.2))
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 18, dial_c.y + 14), "STRATOS", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.85, 0.95, 0.2))

func draw_stratos_console(rect: Rect2, center: Vector2):
	draw_rect(rect, Color(0.07, 0.08, 0.07, 0.98), true)
	draw_rect(rect, Color(0.65, 0.80, 0.15), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "VOLANTE MOMO CORSE STRATOS & CASCO INTEGRATO", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.85, 0.95, 0.25))
	
	# Auxiliary oil and water gauges
	var gx1 = rect.size.x * 0.28
	var gx2 = rect.size.x * 0.46
	var gy = rect.size.y * 0.52
	draw_circle(Vector2(gx1, gy), 14.0, Color(0.04, 0.05, 0.04))
	draw_arc(Vector2(gx1, gy), 14.0, 0, TAU, 20, Color(0.4, 0.8, 0.3), 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(gx1 - 12, gy + 18), "OLIO", HORIZONTAL_ALIGNMENT_CENTER, -1, 6, Color(0.7, 0.9, 0.6))
	
	draw_circle(Vector2(gx2, gy), 14.0, Color(0.04, 0.05, 0.04))
	draw_arc(Vector2(gx2, gy), 14.0, 0, TAU, 20, Color(0.4, 0.8, 0.3), 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(gx2 - 12, gy + 18), "ACQUA", HORIZONTAL_ALIGNMENT_CENTER, -1, 6, Color(0.7, 0.9, 0.6))
	
	# Momo Stratos Steering Wheel
	var sx = rect.size.x * 0.75
	var sy = rect.size.y * 0.52
	var sw_r = 28.0
	draw_circle(Vector2(sx, sy), sw_r, Color(0.12, 0.12, 0.12)) # Black leather
	draw_circle(Vector2(sx, sy), sw_r - 4.5, Color(0.07, 0.08, 0.07))
	var s_ang = smoothed_steer * PI * 0.85
	for spk in [0.0, PI * 0.66, PI * 1.33]:
		var dir = Vector2(cos(s_ang + spk), sin(s_ang + spk))
		draw_line(Vector2(sx, sy), Vector2(sx, sy) + dir * (sw_r - 2.0), Color(0.25, 0.25, 0.28), 2.8)
	draw_circle(Vector2(sx, sy), 6.0, Color(0.85, 0.90, 0.15)) # Yellow Stratos HF horn button
	draw_string(ThemeDB.fallback_font, Vector2(10, rect.size.y - 8), "MOTORE CENTRALE TRASVERSALE DINO | TELAIO SCATOLATO MONOSCOCCA", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.75, 0.85, 0.35))

# ==============================================================================
# 14. FIAT 131 ABARTH RALLY (1976) - VEGLIA CORSE & GRUPPO 4
# ==============================================================================
func draw_fiat131_speedo(rect: Rect2, center: Vector2, radius: float):
	draw_rect(rect, Color(0.07, 0.08, 0.10, 0.98), true) # Navy dark rally
	draw_rect(rect, Color(0.85, 0.70, 0.15, 0.85), false, 2.0) # Abarth yellow trim
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "VEGLIA CORSE - FIAT 131 ABARTH RALLY", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.95, 0.82, 0.20))
	var g_lbl = ("[" + gear_text + "]") if gear_text != "" else "GRUPPO 4"
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 70, 16), g_lbl, HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.95, 0.45, 0.20))
	
	var dial_r = min(radius - 6.0, 44.0)
	var dial_c = Vector2(center.x, center.y + 4.0)
	
	draw_circle(dial_c, dial_r + 3.0, Color(0.18, 0.19, 0.22))
	draw_circle(dial_c, dial_r, Color(0.04, 0.04, 0.05))
	
	var start_ang = deg_to_rad(135.0)
	var end_ang = deg_to_rad(405.0)
	
	for spd in range(0, 241, 20):
		var t = float(spd) / 240.0
		var ang = lerp(start_ang, end_ang, t)
		var dir = Vector2(cos(ang), sin(ang))
		var is_major = (spd % 40 == 0)
		draw_line(dial_c + dir * (dial_r - (7.0 if is_major else 4.0)), dial_c + dir * (dial_r - 2.0), Color.WHITE, 2.0 if is_major else 1.0)
		if is_major:
			var p_txt = dial_c + dir * (dial_r - 14.0) + Vector2(-6, 3.5)
			draw_string(ThemeDB.fallback_font, p_txt, str(spd), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color.WHITE)
			
	var spd_t = clamp(smoothed_val / 240.0, 0.0, 1.0)
	var needle_ang = lerp(start_ang, end_ang, spd_t)
	var n_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	draw_line(dial_c - n_dir * 5.0, dial_c + n_dir * (dial_r - 3.0), Color(0.95, 0.20, 0.15), 2.8)
	draw_circle(dial_c, 4.0, Color(0.2, 0.2, 0.25))
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 14, dial_c.y + 14), "KM/H", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.8, 0.8, 0.85))

func draw_fiat131_tacho(rect: Rect2, center: Vector2, radius: float):
	draw_rect(rect, Color(0.07, 0.08, 0.10, 0.98), true)
	draw_rect(rect, Color(0.85, 0.70, 0.15, 0.85), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "LAMPREDI 16V (8000 RPM)", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.95, 0.82, 0.20))
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x - 70, 16), "x1000 RPM", HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.95, 0.45, 0.20))
	
	var dial_r = min(radius - 6.0, 44.0)
	var dial_c = Vector2(center.x, center.y + 4.0)
	
	draw_circle(dial_c, dial_r + 3.0, Color(0.18, 0.19, 0.22))
	draw_circle(dial_c, dial_r, Color(0.04, 0.04, 0.05))
	
	var start_ang = deg_to_rad(135.0)
	var end_ang = deg_to_rad(405.0)
	
	var red_start = lerp(start_ang, end_ang, 7.2 / 8.0)
	draw_arc(dial_c, dial_r - 3.0, red_start, end_ang, 10, Color(0.95, 0.15, 0.12), 4.0)
	
	for rpm_k in range(0, 9):
		var t = float(rpm_k) / 8.0
		var ang = lerp(start_ang, end_ang, t)
		var dir = Vector2(cos(ang), sin(ang))
		var is_red = (rpm_k >= 7)
		var col = Color(0.95, 0.15, 0.12) if is_red else Color.WHITE
		draw_line(dial_c + dir * (dial_r - 7.0), dial_c + dir * (dial_r - 2.0), col, 2.0)
		var p_txt = dial_c + dir * (dial_r - 14.0) + Vector2(-4, 3.5)
		draw_string(ThemeDB.fallback_font, p_txt, str(rpm_k), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, col)
		
	var rpm_t = clamp(smoothed_val / 8000.0, 0.0, 1.0)
	var needle_ang = lerp(start_ang, end_ang, rpm_t)
	var n_dir = Vector2(cos(needle_ang), sin(needle_ang))
	
	draw_line(dial_c - n_dir * 5.0, dial_c + n_dir * (dial_r - 3.0), Color(0.95, 0.20, 0.15), 2.8)
	draw_circle(dial_c, 4.0, Color(0.2, 0.2, 0.25))
	draw_string(ThemeDB.fallback_font, Vector2(dial_c.x - 18, dial_c.y + 14), "ABARTH", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.95, 0.8, 0.2))

func draw_fiat131_console(rect: Rect2, center: Vector2):
	draw_rect(rect, Color(0.06, 0.07, 0.08, 0.98), true) # Flocked anti-glare
	draw_rect(rect, Color(0.85, 0.70, 0.15), false, 2.0)
	
	draw_string(ThemeDB.fallback_font, Vector2(10, 16), "VOLANTE ABARTH A 2 RAZZE FORATE & FUSIBILI RALLY", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.95, 0.82, 0.20))
	
	# Rally Fuse Box & Halda Twinmaster prompt
	var bx = rect.size.x * 0.26
	var by = rect.size.y * 0.52
	draw_rect(Rect2(Vector2(bx - 18, by - 12), Vector2(36, 24)), Color(0.12, 0.13, 0.15), true)
	draw_rect(Rect2(Vector2(bx - 18, by - 12), Vector2(36, 24)), Color(0.35, 0.38, 0.42), false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(bx - 16, by + 4), "FUSIBILI", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.85, 0.85, 0.90))
	
	# Abarth 2-spoke perforated racing wheel
	var sx = rect.size.x * 0.75
	var sy = rect.size.y * 0.52
	var sw_r = 28.0
	draw_circle(Vector2(sx, sy), sw_r, Color(0.10, 0.10, 0.12)) # Black suede
	draw_circle(Vector2(sx, sy), sw_r - 4.5, Color(0.06, 0.07, 0.08))
	var s_ang = smoothed_steer * PI * 0.85
	for spk in [0.0, PI]:
		var dir = Vector2(cos(s_ang + spk), sin(s_ang + spk))
		draw_line(Vector2(sx, sy), Vector2(sx, sy) + dir * (sw_r - 2.0), Color(0.85, 0.88, 0.92), 3.2)
	draw_circle(Vector2(sx, sy), 6.0, Color(0.85, 0.72, 0.18)) # Abarth Scorpion Yellow
	draw_string(ThemeDB.fallback_font, Vector2(10, rect.size.y - 8), "CAMPIONE DEL MONDO RALLY 1977, 1978, 1980 | INIEZIONE MECCANICA KUGLFASCHER", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.95, 0.75, 0.25))

