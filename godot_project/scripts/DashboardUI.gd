extends Control
class_name DashboardUI

# THE LONG MERIDIAN - Authentic Multi-Vehicle Cockpit Dashboard & Expedition HUD (Godot 4)
# Faithfully renders 3 distinct vintage European cockpits with 100% Analog Instruments:
# 1. VEGLIA BORLETTI & MARSUPIO (1983): Fiat Panda 4x4 Steyr canvas, 2-spoke wheel, dual clino, A112 tacho
# 2. VEGLIA CORSE & CHECK CONTROL (1991): Lancia Delta WRC, Momo Corse wheel, Garrett T3 turbo, 8k tacho, fuel/oil aux
# 3. VDO STUTTGART & ANGSTGRIFF (1979): Mercedes-Benz G-Klasse W460, 4-spoke wheel, 3x diff locks, Kombiinstrument
#
# PLUS Overarching Expedition Gameplay HUD:
# - Trans-Meridian Stages & Progression PK Odometer
# - Active Geographic Mission Objectives
# - Milestone Discovery Fanfare & Atmospheric Lore Cards
# - Real-Time Low Fuel & Overheat Cockpit Warnings
# - Interactive Expedition Logbook & Route Map ([M] / [TAB])

signal change_vehicle_requested
signal change_camera_requested
signal open_street_rod_requested

# Clusters
@onready var cluster_panda: Control = $Panel/PandaCluster
@onready var cluster_delta: Control = $Panel/DeltaCluster
@onready var cluster_gwagen: Control = $Panel/GwagenCluster
@onready var cluster_127: Control = get_node_or_null("Panel/Fiat127Cluster")
@onready var cluster_golf: Control = get_node_or_null("Panel/GolfCluster")
@onready var cluster_r4: Control = get_node_or_null("Panel/Renault4Cluster")
@onready var cluster_bmw: Control = get_node_or_null("Panel/BmwCluster")
@onready var cluster_a250: Control = get_node_or_null("Panel/MercedesA250Cluster")

# Header bar
@onready var label_region: Label = $Panel/HeaderBar/LabelRegion
@onready var label_vehicle_name: Label = $Panel/HeaderBar/LabelVehicleName
@onready var btn_change_car: Button = $Panel/HeaderBar/Buttons/BtnChangeCar
@onready var btn_camera: Button = $Panel/HeaderBar/Buttons/BtnCamera
@onready var btn_fs: Button = $Panel/HeaderBar/Buttons/BtnFullscreen

# 1. PANDA 4x4 VEGLIA BORLETTI & MARSUPIO
@onready var p_speed_gauge: Control = $Panel/PandaCluster/Cards/SpeedGauge
@onready var p_tacho_gauge: Control = $Panel/PandaCluster/Cards/TachoGauge
@onready var p_console_gauge: Control = $Panel/PandaCluster/Cards/ConsoleGauge
@onready var p_clino_gauge: Control = $Panel/PandaCluster/Cards/ClinoGauge

# 2. LANCIA DELTA HF INTEGRALE VEGLIA CORSE & CHECK CONTROL
@onready var d_speed_gauge: Control = $Panel/DeltaCluster/Cards/SpeedGauge
@onready var d_tacho_gauge: Control = $Panel/DeltaCluster/Cards/TachoGauge
@onready var d_turbo_gauge: Control = $Panel/DeltaCluster/Cards/TurboGauge
@onready var d_aux_gauge: Control = $Panel/DeltaCluster/Cards/AuxGauge
@onready var d_check_gauge: Control = $Panel/DeltaCluster/Cards/CheckPanelGauge

# 3. MERCEDES-BENZ G-KLASSE VDO STUTTGART & ANGSTGRIFF
@onready var g_speed_gauge: Control = $Panel/GwagenCluster/Cards/SpeedGauge
@onready var g_tacho_gauge: Control = $Panel/GwagenCluster/Cards/TachoGauge
@onready var g_kombi_gauge: Control = $Panel/GwagenCluster/Cards/KombiGauge
@onready var g_diffs_gauge: Control = $Panel/GwagenCluster/Cards/DiffsGauge
@onready var g_console_gauge: Control = $Panel/GwagenCluster/Cards/ConsoleGauge

# 4. FIAT 127 VEGLIA BORLETTI & PIO MANZU CONSOLE
@onready var f_speed_gauge: Control = get_node_or_null("Panel/Fiat127Cluster/Cards/SpeedGauge")
@onready var f_console_gauge: Control = get_node_or_null("Panel/Fiat127Cluster/Cards/ConsoleGauge")

# 5. VOLKSWAGEN GOLF GTI 16V VDO & MFA BOARDCOMPUTER
@onready var golf_speed_gauge: Control = get_node_or_null("Panel/GolfCluster/Cards/SpeedGauge")
@onready var golf_tacho_gauge: Control = get_node_or_null("Panel/GolfCluster/Cards/TachoGauge")
@onready var golf_mfa_gauge: Control = get_node_or_null("Panel/GolfCluster/Cards/MfaGauge")
@onready var golf_console_gauge: Control = get_node_or_null("Panel/GolfCluster/Cards/ConsoleGauge")

# 6. RENAULT 4 GTL (1980) JAEGER & LEVA A MANICO D'OMBRELLO
@onready var r4_speed_gauge: Control = get_node_or_null("Panel/Renault4Cluster/Cards/SpeedGauge")
@onready var r4_console_gauge: Control = get_node_or_null("Panel/Renault4Cluster/Cards/ConsoleGauge")

# 7. BMW 320i E30 (1990) VDO & ECONOMETRO BAVARESE
@onready var bmw_speed_gauge: Control = get_node_or_null("Panel/BmwCluster/Cards/SpeedGauge")
@onready var bmw_tacho_gauge: Control = get_node_or_null("Panel/BmwCluster/Cards/TachoGauge")
@onready var bmw_console_gauge: Control = get_node_or_null("Panel/BmwCluster/Cards/ConsoleGauge")

# 8. MERCEDES-BENZ A 250 SPORT (2016) TWIN-TUBE & COMAND SCREEN
@onready var a250_cluster_gauge: Control = get_node_or_null("Panel/MercedesA250Cluster/Cards/ClusterGauge")
@onready var a250_screen_gauge: Control = get_node_or_null("Panel/MercedesA250Cluster/Cards/ScreenGauge")
@onready var a250_console_gauge: Control = get_node_or_null("Panel/MercedesA250Cluster/Cards/ConsoleGauge")

# 9. ALFA ROMEO 8C 2900B / MONZA (1931)
var cluster_alfa8c: Control = null
var alfa8c_speed_gauge: Control = null
var alfa8c_tacho_gauge: Control = null
var alfa8c_console_gauge: Control = null

# 10. FIAT 500 TOPOLINO (1936)
var cluster_topolino: Control = null
var topolino_speed_gauge: Control = null
var topolino_console_gauge: Control = null

# 11. LANCIA AURELIA B20 GT (1950)
var cluster_aurelia: Control = null
var aurelia_speed_gauge: Control = null
var aurelia_tacho_gauge: Control = null
var aurelia_console_gauge: Control = null

# 12. ALFA ROMEO GIULIA SPRINT GTA (1965)
var cluster_gta: Control = null
var gta_speed_gauge: Control = null
var gta_tacho_gauge: Control = null
var gta_console_gauge: Control = null

# 13. LANCIA STRATOS HF STRADALE (1973)
var cluster_stratos: Control = null
var stratos_speed_gauge: Control = null
var stratos_tacho_gauge: Control = null
var stratos_console_gauge: Control = null

# 14. FIAT 131 ABARTH RALLY (1976)
var cluster_131: Control = null
var f131_speed_gauge: Control = null
var f131_tacho_gauge: Control = null
var f131_console_gauge: Control = null

var current_model_id: String = ""
var windshield_weather_overlay: Control = null

# Floating Interactive Service Area Prompt
var service_prompt_panel: PanelContainer = null
var service_prompt_label: Label = null

# Top Expedition HUD Bar Elements
var hud_top_panel: PanelContainer = null
var label_hud_stage: Label = null
var label_hud_pk: Label = null
var hud_progress_bar: ProgressBar = null
var label_hud_next: Label = null
var label_hud_objective: Label = null
var label_hud_score: Label = null
var label_hud_cash: Label = null
var btn_hud_logbook: Button = null
var btn_hud_street_rod: Button = null

# Milestone Discovery & Fanfare Elements
var milestone_panel: PanelContainer = null
var milestone_title_label: Label = null
var milestone_lore_label: Label = null
var milestone_pts_label: Label = null
var milestone_timer: float = 0.0

# Stage Cleared Banner
var stage_clear_panel: PanelContainer = null
var stage_clear_label: Label = null
var stage_clear_timer: float = 0.0

# Resource Warning Elements
var warning_panel: PanelContainer = null
var warning_label: Label = null
var warning_blink_timer: float = 0.0

# Logbook Modal Overlay
var logbook_overlay: Control = null
var logbook_modal_box: PanelContainer = null
var logbook_stages_container: VBoxContainer = null
var logbook_milestones_container: VBoxContainer = null
var logbook_stats_label: Label = null

# 80s/90s Roadside Bar & Building Modal
var bar_service_overlay: Control = null
var bar_modal_box: PanelContainer = null
var bar_title_label: Label = null
var bar_subtitle_label: Label = null
var bar_backdrop_rect: TextureRect = null
var bar_lore_label: Label = null
var bar_char1_img: TextureRect = null
var bar_char1_name: Label = null
var bar_char1_role: Label = null
var bar_char2_img: TextureRect = null
var bar_char2_name: Label = null
var bar_char2_role: Label = null
var bar_gianni_dialogue: Label = null
var bar_sandra_dialogue: Label = null
var bar_gianni_btn: Button = null
var bar_sandra_btn: Button = null
var bar_gazzetta_head: Label = null
var bar_gazzetta_label: Label = null
var bar_status_label: Label = null
var bar_coffee_consumed: bool = false
var bar_service_performed: bool = false
var current_bar_building_type: String = "autogrill_bar"

# Audio Mixer & Radio Modal
var audio_mixer_overlay: Control = null
var audio_mixer_modal_box: PanelContainer = null
var slider_master: HSlider = null
var slider_engine: HSlider = null
var slider_ambient: HSlider = null
var slider_radio: HSlider = null
var lbl_val_master: Label = null
var lbl_val_engine: Label = null
var lbl_val_ambient: Label = null
var lbl_val_radio: Label = null
var lbl_radio_track_info: Label = null
var lbl_radio_mp3_count: Label = null
var btn_hud_mixer: Button = null
var btn_hud_radio: Button = null

# Cached Journey & Vehicle State
var last_journey_info: Dictionary = {}
var discovered_milestones: Array = []
var current_fuel_val: float = 40.0
var current_temp_val: float = 85.0
var current_tank_max: float = 45.0

func _ready():
	if btn_fs:
		btn_fs.pressed.connect(_on_fullscreen_pressed)
	if btn_change_car:
		btn_change_car.pressed.connect(_on_change_vehicle_pressed)
	if btn_camera:
		btn_camera.pressed.connect(_on_camera_pressed)
		btn_camera.tooltip_text = "[V] Cambia Vista | Trascina Mouse (SX/DX) per Ruotare | Rotella Zoom | [R] Ricentra"

	setup_windshield_weather_overlay()
	setup_expedition_hud()
	setup_service_prompt()
	setup_milestone_banner()
	setup_stage_clear_banner()
	setup_resource_warnings()
	setup_logbook_modal()
	setup_bar_service_modal()
	setup_audio_mixer_modal()
	setup_historic_clusters()

func _process(delta: float):
	# Position update for floating centered panels
	var vp_size = get_viewport_rect().size
	var banner_y = 62.0
	
	if windshield_weather_overlay and windshield_weather_overlay.has_method("update_weather"):
		var p_z = 0.0
		var p_spd = 0.0
		var v_node = get_tree().root.find_child("Vehicle", true, false)
		if v_node:
			p_z = v_node.global_position.z
			p_spd = v_node.current_speed_kmh
		windshield_weather_overlay.update_weather(p_z, p_spd, delta)
		
	if service_prompt_panel and service_prompt_panel.visible:
		service_prompt_panel.position = Vector2(max(20.0, (vp_size.x - service_prompt_panel.size.x) * 0.5), banner_y)
		banner_y += service_prompt_panel.size.y + 6.0
		
	if stage_clear_panel and stage_clear_panel.visible:
		stage_clear_panel.position = Vector2(max(20.0, (vp_size.x - stage_clear_panel.size.x) * 0.5), banner_y)
		banner_y += stage_clear_panel.size.y + 6.0
		stage_clear_timer -= delta
		if stage_clear_timer <= 0.0:
			stage_clear_panel.visible = false

	if milestone_panel and milestone_panel.visible:
		# If stage clear is already showing, dismiss or stack milestone cleanly below
		if stage_clear_panel and stage_clear_panel.visible:
			milestone_panel.position = Vector2(max(20.0, (vp_size.x - milestone_panel.size.x) * 0.5), banner_y)
		else:
			milestone_panel.position = Vector2(max(20.0, (vp_size.x - milestone_panel.size.x) * 0.5), 62.0)
		milestone_timer -= delta
		if milestone_timer <= 0.0:
			milestone_panel.visible = false
			
	if warning_panel and warning_panel.visible:
		warning_panel.position = Vector2(max(20.0, (vp_size.x - warning_panel.size.x) * 0.5), 118.0)
		warning_blink_timer += delta * 4.0
		var blink_alpha = 0.55 + sin(warning_blink_timer) * 0.45
		warning_panel.modulate = Color(1.0, 1.0, 1.0, blink_alpha)

	if logbook_overlay and logbook_overlay.visible and logbook_modal_box:
		var vp = get_viewport_rect().size
		logbook_overlay.size = vp
		logbook_modal_box.size = Vector2(min(960.0, vp.x - 40.0), min(540.0, vp.y - 80.0))
		logbook_modal_box.position = (vp - logbook_modal_box.size) * 0.5

	if bar_service_overlay and bar_service_overlay.visible and bar_modal_box:
		var vp = get_viewport_rect().size
		bar_service_overlay.size = vp
		bar_modal_box.size = Vector2(min(1080.0, vp.x - 40.0), min(640.0, vp.y - 60.0))
		bar_modal_box.position = (vp - bar_modal_box.size) * 0.5

	if audio_mixer_overlay and audio_mixer_overlay.visible and audio_mixer_modal_box:
		var vp = get_viewport_rect().size
		audio_mixer_overlay.size = vp
		audio_mixer_modal_box.size = Vector2(min(740.0, vp.x - 40.0), min(500.0, vp.y - 60.0))
		audio_mixer_modal_box.position = (vp - audio_mixer_modal_box.size) * 0.5

# =========================================================================
# 1. EXPEDITION TOP HUD BAR
# =========================================================================
func setup_expedition_hud():
	hud_top_panel = PanelContainer.new()
	hud_top_panel.anchors_preset = Control.PRESET_TOP_WIDE
	hud_top_panel.offset_left = 14.0
	hud_top_panel.offset_top = 8.0
	hud_top_panel.offset_right = -14.0
	hud_top_panel.offset_bottom = 54.0
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.06, 0.08, 0.94)
	sb.border_color = Color(0.24, 0.32, 0.42, 0.85)
	sb.set_border_width_all(1)
	sb.border_width_bottom = 2
	sb.border_color = Color(0.85, 0.70, 0.22, 0.90)
	sb.set_corner_radius_all(6)
	sb.shadow_size = 12
	sb.shadow_color = Color(0, 0, 0, 0.65)
	hud_top_panel.add_theme_stylebox_override("panel", sb)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	hud_top_panel.add_child(hbox)
	
	# Margin inside hbox
	var margin_left = Control.new()
	margin_left.custom_minimum_size = Vector2(4, 0)
	hbox.add_child(margin_left)
	
	# 1. Stage Info
	var stage_box = VBoxContainer.new()
	stage_box.alignment = BoxContainer.ALIGNMENT_CENTER
	label_hud_stage = Label.new()
	label_hud_stage.text = "🧭 TAPPA 1 / 4: PASSO DELLE ALPI"
	label_hud_stage.add_theme_font_size_override("font_size", 12)
	label_hud_stage.add_theme_color_override("font_color", Color(0.96, 0.82, 0.28))
	stage_box.add_child(label_hud_stage)
	hbox.add_child(stage_box)
	
	hbox.add_child(create_hud_separator())
	
	# 2. Progression & PK Odometer
	var prog_box = VBoxContainer.new()
	prog_box.alignment = BoxContainer.ALIGNMENT_CENTER
	prog_box.custom_minimum_size = Vector2(210, 0)
	
	var pk_hbox = HBoxContainer.new()
	label_hud_pk = Label.new()
	label_hud_pk.text = "PK 0.00 / 5.20 KM"
	label_hud_pk.add_theme_font_size_override("font_size", 11)
	label_hud_pk.add_theme_color_override("font_color", Color(0.85, 0.90, 0.95))
	pk_hbox.add_child(label_hud_pk)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pk_hbox.add_child(spacer)
	
	label_hud_next = Label.new()
	label_hud_next.text = "📍 PROSSIMO: AGIP 1840M [780m]"
	label_hud_next.add_theme_font_size_override("font_size", 10)
	label_hud_next.add_theme_color_override("font_color", Color(0.55, 0.85, 1.0))
	pk_hbox.add_child(label_hud_next)
	prog_box.add_child(pk_hbox)
	
	hud_progress_bar = ProgressBar.new()
	hud_progress_bar.custom_minimum_size = Vector2(210, 6)
	hud_progress_bar.show_percentage = false
	hud_progress_bar.min_value = 0.0
	hud_progress_bar.max_value = 100.0
	hud_progress_bar.value = 0.0
	var sb_bg = StyleBoxFlat.new()
	sb_bg.bg_color = Color(0.12, 0.15, 0.18, 1.0)
	sb_bg.set_corner_radius_all(3)
	var sb_fill = StyleBoxFlat.new()
	sb_fill.bg_color = Color(0.95, 0.76, 0.20, 1.0)
	sb_fill.set_corner_radius_all(3)
	hud_progress_bar.add_theme_stylebox_override("background", sb_bg)
	hud_progress_bar.add_theme_stylebox_override("fill", sb_fill)
	prog_box.add_child(hud_progress_bar)
	hbox.add_child(prog_box)
	
	hbox.add_child(create_hud_separator())
	
	# 3. Active Mission Objective
	var obj_box = VBoxContainer.new()
	obj_box.alignment = BoxContainer.ALIGNMENT_CENTER
	obj_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_hud_objective = Label.new()
	label_hud_objective.text = "🎯 OBIETTIVO: Supera i tornanti alpini e fai rifornimento prima della riserva!"
	label_hud_objective.add_theme_font_size_override("font_size", 11)
	label_hud_objective.add_theme_color_override("font_color", Color(0.92, 0.95, 0.85))
	label_hud_objective.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	obj_box.add_child(label_hud_objective)
	hbox.add_child(obj_box)
	
	hbox.add_child(create_hud_separator())
	
	# 4. Score & Street Rod Cash
	var score_box = VBoxContainer.new()
	score_box.alignment = BoxContainer.ALIGNMENT_CENTER
	label_hud_score = Label.new()
	label_hud_score.text = "⭐ 40 REP"
	label_hud_score.add_theme_font_size_override("font_size", 11)
	label_hud_score.add_theme_color_override("font_color", Color(1.0, 0.85, 0.30))
	score_box.add_child(label_hud_score)
	hbox.add_child(score_box)
	
	hbox.add_child(create_hud_separator())
	
	var cash_box = VBoxContainer.new()
	cash_box.alignment = BoxContainer.ALIGNMENT_CENTER
	label_hud_cash = Label.new()
	label_hud_cash.text = "💰 L. 3.500.000"
	label_hud_cash.add_theme_font_size_override("font_size", 11)
	label_hud_cash.add_theme_color_override("font_color", Color(0.40, 1.0, 0.50))
	cash_box.add_child(label_hud_cash)
	hbox.add_child(cash_box)
	
	hbox.add_child(create_hud_separator())
	
	# 5. Street Rod Button
	btn_hud_street_rod = Button.new()
	btn_hud_street_rod.text = " [G] 🏠 GARAGE PAOLO "
	btn_hud_street_rod.custom_minimum_size = Vector2(150, 26)
	btn_hud_street_rod.add_theme_font_size_override("font_size", 10)
	var sb_sr = StyleBoxFlat.new()
	sb_sr.bg_color = Color(0.0, 0.32, 0.65, 0.92) # Amiga Blue
	sb_sr.border_color = Color(0.95, 0.75, 0.15, 0.90) # Gold
	sb_sr.set_border_width_all(1)
	sb_sr.set_corner_radius_all(4)
	btn_hud_street_rod.add_theme_stylebox_override("normal", sb_sr)
	btn_hud_street_rod.tooltip_text = "[G] Apri Garage, Gestione Auto & Contratti Pilota Street Rod '93"
	btn_hud_street_rod.pressed.connect(func(): emit_signal("open_street_rod_requested"))
	hbox.add_child(btn_hud_street_rod)
	
	# 6. Logbook Button
	btn_hud_logbook = Button.new()
	btn_hud_logbook.text = " [M] DIARIO & MAPPA "
	btn_hud_logbook.custom_minimum_size = Vector2(130, 26)
	btn_hud_logbook.add_theme_font_size_override("font_size", 10)
	var sb_btn = StyleBoxFlat.new()
	sb_btn.bg_color = Color(0.14, 0.18, 0.22, 0.90)
	sb_btn.border_color = Color(0.40, 0.50, 0.62, 0.80)
	sb_btn.set_border_width_all(1)
	sb_btn.set_corner_radius_all(4)
	btn_hud_logbook.add_theme_stylebox_override("normal", sb_btn)
	btn_hud_logbook.pressed.connect(toggle_logbook)
	hbox.add_child(btn_hud_logbook)
	
	# 7. Vintage Car Radio Button
	btn_hud_radio = Button.new()
	btn_hud_radio.text = " [R] 📻 RADIO '93 "
	btn_hud_radio.custom_minimum_size = Vector2(115, 26)
	btn_hud_radio.add_theme_font_size_override("font_size", 10)
	var sb_rad = StyleBoxFlat.new()
	sb_rad.bg_color = Color(0.12, 0.18, 0.14, 0.90)
	sb_rad.border_color = Color(0.35, 0.85, 0.45, 0.90)
	sb_rad.set_border_width_all(1)
	sb_rad.set_corner_radius_all(4)
	btn_hud_radio.add_theme_stylebox_override("normal", sb_rad)
	btn_hud_radio.pressed.connect(func():
		var tree = get_tree()
		if tree and tree.root:
			var main_node = tree.root.get_node_or_null("Main")
			if main_node and main_node.get("vehicle") and main_node.vehicle.get("audio_engine"):
				var st_name = main_node.vehicle.audio_engine.cycle_radio_station()
				btn_hud_radio.text = " [R] 📻 " + st_name.split("(")[0].strip_edges()
				if main_node.get("street_rod_manager"):
					main_node.street_rod_manager.post_notification("AUTORADIO D'EPOCA '93", st_name, "📻", "wrench")
	)
	hbox.add_child(btn_hud_radio)
	
	# 8. Audio Mixer Button
	btn_hud_mixer = Button.new()
	btn_hud_mixer.text = " [O] 🎚️ MIXER "
	btn_hud_mixer.custom_minimum_size = Vector2(95, 26)
	btn_hud_mixer.add_theme_font_size_override("font_size", 10)
	var sb_mix = StyleBoxFlat.new()
	sb_mix.bg_color = Color(0.18, 0.14, 0.24, 0.90)
	sb_mix.border_color = Color(0.75, 0.45, 0.95, 0.90)
	sb_mix.set_border_width_all(1)
	sb_mix.set_corner_radius_all(4)
	btn_hud_mixer.add_theme_stylebox_override("normal", sb_mix)
	btn_hud_mixer.tooltip_text = "[O] Apri Mixer Audio (Regolazione volumi motore, ambientali, radio e file MP3)"
	btn_hud_mixer.pressed.connect(toggle_audio_mixer_modal)
	hbox.add_child(btn_hud_mixer)
	
	var margin_right = Control.new()
	margin_right.custom_minimum_size = Vector2(4, 0)
	hbox.add_child(margin_right)
	
	add_child(hud_top_panel)

func create_hud_separator() -> VSeparator:
	var sep = VSeparator.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.24, 0.30, 0.38, 0.6)
	sb.set_border_width_all(1)
	sep.add_theme_stylebox_override("separator", sb)
	return sep

# =========================================================================
# WINDSHIELD DYNAMIC WEATHER OVERLAY (RAIN, MIST & HIGH-ALTITUDE FROST)
# =========================================================================
func setup_windshield_weather_overlay():
	windshield_weather_overlay = WindshieldWeatherOverlay.new()
	windshield_weather_overlay.name = "WindshieldWeatherOverlay"
	add_child(windshield_weather_overlay)
	move_child(windshield_weather_overlay, 0)

class WindshieldWeatherOverlay extends Control:
	var droplets: Array = []
	var rain_intensity: float = 0.0 # Starts completely clear on sunny alpine passes
	var frost_intensity: float = 0.0
	var current_speed: float = 0.0
	var wiper_timer: float = 0.0
	var wiper_arc_phase: float = -1.0 # -1 = resting, 0.0 to 1.0 = sweeping
	var ice_crystals: Array = []
	
	func _ready():
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		anchors_preset = Control.PRESET_FULL_RECT
		init_ice_crystals()
		init_rain_droplets()
		
	func init_ice_crystals():
		ice_crystals.clear()
		for i in range(36):
			var t = float(i) / 35.0
			var length = randf_range(35.0, 85.0)
			var angle = randf_range(-0.45, 0.45)
			ice_crystals.append({ "t": t, "len": length, "angle": angle })
			
	func init_rain_droplets():
		droplets.clear()
		if rain_intensity > 0.05:
			for i in range(int(40.0 * rain_intensity)):
				spawn_droplet(true)
			
	func spawn_droplet(random_y: bool = false):
		var vp = get_viewport_rect().size
		var x = randf_range(10.0, vp.x - 10.0)
		var y = randf_range(10.0, vp.y * 0.72) if random_y else randf_range(-20.0, 5.0)
		var spd = randf_range(120.0, 260.0)
		var length = randf_range(10.0, 24.0)
		var alpha = randf_range(0.40, 0.85)
		droplets.append({
			"pos": Vector2(x, y),
			"spd": spd,
			"len": length,
			"alpha": alpha
		})
		
	func update_weather(player_z: float, speed_kmh: float, delta: float):
		current_speed = speed_kmh
		
		# Coherent Biome Weather Model:
		# Rain ONLY occurs in stormy canyon/gorge biomes with dense overcast cloud cover.
		# Sunny alpine passes, glacial lakes, villages, and golden plateaus have ZERO rain.
		# Polar tundra has sub-zero frost and ice crystals on windshield.
		var is_rainy_biome = false
		var is_polar_biome = false
		
		var r_gen = get_tree().root.find_child("RoadGenerator", true, false)
		if r_gen and r_gen.has_method("get_biome_at"):
			var b_info = r_gen.get_biome_at(player_z)
			var b_type = b_info.get("type", -1)
			is_rainy_biome = (b_type == 4) or b_info.get("has_gorge", false) or b_info.get("is_rainy", false)
			is_polar_biome = (b_type == 7) or b_info.get("has_polar", false) or b_info.get("has_snow", false)
		else:
			is_rainy_biome = (player_z >= 1440.0 and player_z < 3000.0)
			is_polar_biome = (player_z >= 5600.0)
			
		var target_rain = 0.85 if is_rainy_biome else 0.0
		var target_frost = 0.90 if is_polar_biome else 0.0
		
		rain_intensity = move_toward(rain_intensity, target_rain, delta * 0.40)
		frost_intensity = move_toward(frost_intensity, target_frost, delta * 0.30)
			
		if rain_intensity > 0.15:
			wiper_timer += delta
			if wiper_timer >= 4.2:
				wiper_timer = 0.0
				wiper_arc_phase = 0.0
				
		if wiper_arc_phase >= 0.0:
			wiper_arc_phase += delta * 1.5
			if wiper_arc_phase > 1.0:
				wiper_arc_phase = -1.0
				
		var vp = get_viewport_rect().size
		for i in range(droplets.size() - 1, -1, -1):
			var d = droplets[i]
			d.pos.y += (d.spd + current_speed * 1.2) * delta
			d.pos.x += randf_range(-15.0, 15.0) * delta
			
			if wiper_arc_phase >= 0.0:
				var wiper_x = vp.x * (0.2 + wiper_arc_phase * 0.6)
				if abs(d.pos.x - wiper_x) < 45.0:
					d.alpha = max(0.0, d.alpha - delta * 4.0)
					
			if d.pos.y > vp.y * 0.75 or d.alpha <= 0.05:
				droplets.remove_at(i)
				if droplets.size() < int(45.0 * rain_intensity):
					spawn_droplet(false)
					
		while droplets.size() < int(40.0 * rain_intensity):
			spawn_droplet(false)
			
		queue_redraw()
		
	func _draw():
		var vp = get_viewport_rect().size
		
		if frost_intensity > 0.02:
			var frost_alpha = clamp(frost_intensity * 0.85, 0.0, 0.90)
			var ice_col = Color(0.92, 0.96, 1.0, frost_alpha)
			var ice_rim_col = Color(0.80, 0.90, 1.0, frost_alpha * 0.5)
			
			draw_rect(Rect2(0, 0, vp.x, 28.0 * frost_intensity), ice_rim_col, true)
			draw_rect(Rect2(0, 0, 32.0 * frost_intensity, vp.y * 0.75), ice_rim_col, true)
			draw_rect(Rect2(vp.x - 32.0 * frost_intensity, 0, 32.0 * frost_intensity, vp.y * 0.75), ice_rim_col, true)
			
			for c in ice_crystals:
				var start_pt = Vector2(c.t * vp.x, 0)
				var cur_len = c.len * frost_intensity
				var end_pt = start_pt + Vector2(sin(c.angle) * cur_len, cos(c.angle) * cur_len)
				draw_line(start_pt, end_pt, ice_col, 1.6)
				var mid_pt = start_pt.lerp(end_pt, 0.55)
				var branch_pt = mid_pt + Vector2(cos(c.angle) * 14.0 * frost_intensity, -sin(c.angle) * 8.0)
				draw_line(mid_pt, branch_pt, Color(0.85, 0.94, 1.0, frost_alpha * 0.7), 1.2)
				
		if rain_intensity > 0.02:
			for d in droplets:
				var drop_col = Color(0.88, 0.94, 1.0, d.alpha * rain_intensity)
				var streak_end = d.pos - Vector2(0, d.len * (1.0 + current_speed / 60.0))
				draw_line(d.pos, streak_end, drop_col, 1.6)
				draw_circle(d.pos, 2.0, Color(0.95, 0.98, 1.0, d.alpha * 0.85 * rain_intensity))
				
		# Note: Wiper blade cleans raindrops via wiper_arc_phase without drawing visual line obstruction in 3rd person chase view

# =========================================================================
# 2. FLOATING SERVICE BAY PROMPT
# =========================================================================
func setup_service_prompt():
	service_prompt_panel = PanelContainer.new()
	service_prompt_panel.position = Vector2(160, 62)
	service_prompt_panel.size = Vector2(640, 36)
	service_prompt_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	service_prompt_panel.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			var main_node = get_tree().root.get_node_or_null("Main") if get_tree() and get_tree().root else null
			var s_type = "autogrill_bar"
			var s_name = ""
			if main_node and main_node.get("vehicle"):
				s_name = main_node.vehicle.get("service_station_name")
				s_type = main_node.vehicle.get("service_station_type", "autogrill_bar")
			open_bar_service_modal(s_type, { "name": s_name })
	)
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.08, 0.10, 0.94)
	sb.border_color = Color(0.96, 0.74, 0.16, 0.95)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.shadow_size = 10
	sb.shadow_color = Color(0, 0, 0, 0.65)
	service_prompt_panel.add_theme_stylebox_override("panel", sb)
	
	service_prompt_label = Label.new()
	service_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	service_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	service_prompt_label.add_theme_font_size_override("font_size", 12)
	service_prompt_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.35))
	service_prompt_panel.add_child(service_prompt_label)
	service_prompt_panel.visible = false
	add_child(service_prompt_panel)

# =========================================================================
# 3. MILESTONE DISCOVERY BANNER (ANIMATED FANFARE)
# =========================================================================
func setup_milestone_banner():
	milestone_panel = PanelContainer.new()
	milestone_panel.position = Vector2(160, 62)
	milestone_panel.size = Vector2(680, 56)
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.07, 0.10, 0.96)
	sb.border_color = Color(1.0, 0.82, 0.20, 0.98)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.shadow_size = 14
	sb.shadow_color = Color(0, 0, 0, 0.80)
	milestone_panel.add_theme_stylebox_override("panel", sb)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	
	var top_h = HBoxContainer.new()
	milestone_title_label = Label.new()
	milestone_title_label.text = "✨ NUOVO TRAGUARDO SUL MERIDIANO: MALGA PASSO ALPI (QUOTA 1720M)"
	milestone_title_label.add_theme_font_size_override("font_size", 13)
	milestone_title_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.25))
	top_h.add_child(milestone_title_label)
	
	var sp = Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_h.add_child(sp)
	
	milestone_pts_label = Label.new()
	milestone_pts_label.text = "+250 PT SPEDIZIONE"
	milestone_pts_label.add_theme_font_size_override("font_size", 12)
	milestone_pts_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55))
	top_h.add_child(milestone_pts_label)
	vbox.add_child(top_h)
	
	milestone_lore_label = Label.new()
	milestone_lore_label.text = "Primo avamposto alpino. Il silenzio delle vette saluta la spedizione."
	milestone_lore_label.add_theme_font_size_override("font_size", 11)
	milestone_lore_label.add_theme_color_override("font_color", Color(0.85, 0.88, 0.92))
	vbox.add_child(milestone_lore_label)
	
	milestone_panel.add_child(vbox)
	milestone_panel.visible = false
	add_child(milestone_panel)

# =========================================================================
# 4. STAGE CLEAR BANNER
# =========================================================================
func setup_stage_clear_banner():
	stage_clear_panel = PanelContainer.new()
	stage_clear_panel.position = Vector2(160, 62)
	stage_clear_panel.size = Vector2(640, 46)
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.08, 0.96)
	sb.border_color = Color(0.35, 1.0, 0.55, 0.95)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.shadow_size = 14
	stage_clear_panel.add_theme_stylebox_override("panel", sb)
	
	stage_clear_label = Label.new()
	stage_clear_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stage_clear_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stage_clear_label.add_theme_font_size_override("font_size", 13)
	stage_clear_label.add_theme_color_override("font_color", Color(0.40, 1.0, 0.60))
	stage_clear_panel.add_child(stage_clear_label)
	stage_clear_panel.visible = false
	add_child(stage_clear_panel)

# =========================================================================
# 5. RESOURCE WARNING BANNER (LOW FUEL / OVERHEAT)
# =========================================================================
func setup_resource_warnings():
	warning_panel = PanelContainer.new()
	warning_panel.position = Vector2(200, 118)
	warning_panel.size = Vector2(520, 32)
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.18, 0.04, 0.04, 0.92)
	sb.border_color = Color(1.0, 0.25, 0.25, 0.95)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	warning_panel.add_theme_stylebox_override("panel", sb)
	
	warning_label = Label.new()
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	warning_label.add_theme_font_size_override("font_size", 12)
	warning_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
	warning_panel.add_child(warning_label)
	warning_panel.visible = false
	add_child(warning_panel)

# =========================================================================
# 6. EXPEDITION LOGBOOK & ROUTE MAP MODAL
# =========================================================================
func setup_logbook_modal():
	logbook_overlay = Control.new()
	logbook_overlay.anchors_preset = Control.PRESET_FULL_RECT
	logbook_overlay.visible = false
	
	# Dark semi-transparent background
	var bg_dim = ColorRect.new()
	bg_dim.anchors_preset = Control.PRESET_FULL_RECT
	bg_dim.color = Color(0.02, 0.03, 0.04, 0.78)
	logbook_overlay.add_child(bg_dim)
	
	logbook_modal_box = PanelContainer.new()
	var sb_modal = StyleBoxFlat.new()
	sb_modal.bg_color = Color(0.06, 0.08, 0.10, 0.98)
	sb_modal.border_color = Color(0.85, 0.70, 0.22, 0.90)
	sb_modal.set_border_width_all(2)
	sb_modal.set_corner_radius_all(10)
	sb_modal.shadow_size = 24
	sb_modal.shadow_color = Color(0, 0, 0, 0.85)
	logbook_modal_box.add_theme_stylebox_override("panel", sb_modal)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 12)
	logbook_modal_box.add_child(main_vbox)
	
	# Modal Header
	var m_head = HBoxContainer.new()
	var lbl_title = Label.new()
	lbl_title.text = "🧭 DIARIO DI BORDO | SPEDIZIONE DEL GRANDE MERIDIANO"
	lbl_title.add_theme_font_size_override("font_size", 16)
	lbl_title.add_theme_color_override("font_color", Color(0.96, 0.82, 0.28))
	m_head.add_child(lbl_title)
	
	var sp_m = Control.new()
	sp_m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	m_head.add_child(sp_m)
	
	var btn_close = Button.new()
	btn_close.text = " [X] CHIUDI DIARIO (ESC / M) "
	btn_close.add_theme_font_size_override("font_size", 11)
	btn_close.pressed.connect(toggle_logbook)
	m_head.add_child(btn_close)
	main_vbox.add_child(m_head)
	
	var h_div = HSeparator.new()
	main_vbox.add_child(h_div)
	
	# Content Split into Columns
	var cols = HBoxContainer.new()
	cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cols.add_theme_constant_override("separation", 16)
	main_vbox.add_child(cols)
	
	# Column 1: Stages
	var col1_panel = PanelContainer.new()
	col1_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col1_panel.size_flags_stretch_ratio = 1.05
	var col1_v = VBoxContainer.new()
	var lbl_c1 = Label.new()
	lbl_c1.text = "🏁 4 TAPPE DELLA SPEDIZIONE"
	lbl_c1.add_theme_font_size_override("font_size", 12)
	lbl_c1.add_theme_color_override("font_color", Color(0.85, 0.90, 0.95))
	col1_v.add_child(lbl_c1)
	
	var scroll_s = ScrollContainer.new()
	scroll_s.size_flags_vertical = Control.SIZE_EXPAND_FILL
	logbook_stages_container = VBoxContainer.new()
	logbook_stages_container.add_theme_constant_override("separation", 8)
	scroll_s.add_child(logbook_stages_container)
	col1_v.add_child(scroll_s)
	col1_panel.add_child(col1_v)
	cols.add_child(col1_panel)
	
	# Column 2: Milestones & Lore
	var col2_panel = PanelContainer.new()
	col2_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col2_panel.size_flags_stretch_ratio = 1.25
	var col2_v = VBoxContainer.new()
	var lbl_c2 = Label.new()
	lbl_c2.text = "📍 TRAGUARDI & LORE RAGGIUNTI"
	lbl_c2.add_theme_font_size_override("font_size", 12)
	lbl_c2.add_theme_color_override("font_color", Color(0.85, 0.90, 0.95))
	col2_v.add_child(lbl_c2)
	
	var scroll_m = ScrollContainer.new()
	scroll_m.size_flags_vertical = Control.SIZE_EXPAND_FILL
	logbook_milestones_container = VBoxContainer.new()
	logbook_milestones_container.add_theme_constant_override("separation", 6)
	scroll_m.add_child(logbook_milestones_container)
	col2_v.add_child(scroll_m)
	col2_panel.add_child(col2_v)
	cols.add_child(col2_panel)
	
	# Column 3: Live Stats
	var col3_panel = PanelContainer.new()
	col3_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col3_panel.size_flags_stretch_ratio = 0.85
	var col3_v = VBoxContainer.new()
	var lbl_c3 = Label.new()
	lbl_c3.text = "📊 STATO SPEDIZIONE"
	lbl_c3.add_theme_font_size_override("font_size", 12)
	lbl_c3.add_theme_color_override("font_color", Color(0.85, 0.90, 0.95))
	col3_v.add_child(lbl_c3)
	
	logbook_stats_label = Label.new()
	logbook_stats_label.add_theme_font_size_override("font_size", 11)
	logbook_stats_label.add_theme_color_override("font_color", Color(0.80, 0.88, 0.92))
	col3_v.add_child(logbook_stats_label)
	col3_panel.add_child(col3_v)
	cols.add_child(col3_panel)
	
	logbook_overlay.add_child(logbook_modal_box)
	add_child(logbook_overlay)

func toggle_logbook():
	if not logbook_overlay: return
	logbook_overlay.visible = not logbook_overlay.visible
	if logbook_overlay.visible:
		var vp = get_viewport_rect().size
		logbook_overlay.size = vp
		if logbook_modal_box:
			logbook_modal_box.size = Vector2(min(960.0, vp.x - 40.0), min(540.0, vp.y - 80.0))
			logbook_modal_box.position = (vp - logbook_modal_box.size) * 0.5
		refresh_logbook_contents()

func is_logbook_open() -> bool:
	return logbook_overlay != null and logbook_overlay.visible

# =========================================================================
# 6b. 1980s / 1990s AUTOGRILL & SOSTA TECNICA MODAL (GIANNI & SANDRA)
# =========================================================================
func load_art_texture(res_path: String) -> Texture2D:
	if ResourceLoader.exists(res_path):
		var t = load(res_path)
		if t is Texture2D:
			return t
	var global_p = ProjectSettings.globalize_path(res_path)
	if FileAccess.file_exists(global_p):
		var img = Image.new()
		var err = img.load(global_p)
		if err == OK:
			return ImageTexture.create_from_image(img)
	return null

func setup_bar_service_modal():
	bar_service_overlay = Control.new()
	bar_service_overlay.name = "BarServiceOverlay"
	bar_service_overlay.anchors_preset = Control.PRESET_FULL_RECT
	bar_service_overlay.visible = false
	
	# Semi-transparent dark ambient backdrop
	var bg_dim = ColorRect.new()
	bg_dim.anchors_preset = Control.PRESET_FULL_RECT
	bg_dim.color = Color(0.02, 0.03, 0.05, 0.88)
	bg_dim.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed:
			close_bar_service_modal()
	)
	bar_service_overlay.add_child(bg_dim)
	
	bar_modal_box = PanelContainer.new()
	var sb_modal = StyleBoxFlat.new()
	sb_modal.bg_color = Color(0.07, 0.09, 0.12, 0.98)
	sb_modal.border_color = Color(0.96, 0.74, 0.16, 0.95) # Agip Gold
	sb_modal.set_border_width_all(2)
	sb_modal.set_corner_radius_all(10)
	sb_modal.shadow_size = 28
	sb_modal.shadow_color = Color(0, 0, 0, 0.85)
	bar_modal_box.add_theme_stylebox_override("panel", sb_modal)
	
	var margin_c = MarginContainer.new()
	margin_c.add_theme_constant_override("margin_left", 16)
	margin_c.add_theme_constant_override("margin_right", 16)
	margin_c.add_theme_constant_override("margin_top", 14)
	margin_c.add_theme_constant_override("margin_bottom", 14)
	bar_modal_box.add_child(margin_c)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 10)
	margin_c.add_child(main_vbox)
	
	# 1. Header
	var head_hbox = HBoxContainer.new()
	head_hbox.add_theme_constant_override("separation", 8)
	
	bar_title_label = Label.new()
	bar_title_label.text = "☕ AUTOGRILL & BAR RISTORO DEL MERIDIANO '89"
	bar_title_label.add_theme_font_size_override("font_size", 16)
	bar_title_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.25))
	head_hbox.add_child(bar_title_label)
	
	bar_subtitle_label = Label.new()
	bar_subtitle_label.text = " | Sosta Tecnica Agip KM 0.78 - Passo delle Alpi"
	bar_subtitle_label.add_theme_font_size_override("font_size", 12)
	bar_subtitle_label.add_theme_color_override("font_color", Color(0.80, 0.88, 0.95))
	head_hbox.add_child(bar_subtitle_label)
	
	var sp_head = Control.new()
	sp_head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head_hbox.add_child(sp_head)
	
	var btn_close = Button.new()
	btn_close.text = " [X] RIPARTI SUL MERIDIANO (ESC / E) "
	btn_close.add_theme_font_size_override("font_size", 11)
	var sb_close = StyleBoxFlat.new()
	sb_close.bg_color = Color(0.18, 0.22, 0.28, 0.90)
	sb_close.border_color = Color(0.85, 0.70, 0.25, 0.80)
	sb_close.set_border_width_all(1)
	sb_close.set_corner_radius_all(4)
	btn_close.add_theme_stylebox_override("normal", sb_close)
	btn_close.pressed.connect(close_bar_service_modal)
	head_hbox.add_child(btn_close)
	main_vbox.add_child(head_hbox)
	
	var h_sep = HSeparator.new()
	main_vbox.add_child(h_sep)
	
	# 2. Body: Left Image & Right Character Columns
	var body_hbox = HBoxContainer.new()
	body_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_hbox.add_theme_constant_override("separation", 14)
	main_vbox.add_child(body_hbox)
	
	# Left: Autogrill Backdrop Photo Panel
	var left_panel = PanelContainer.new()
	left_panel.custom_minimum_size = Vector2(360, 360)
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_panel.size_flags_stretch_ratio = 1.05
	var sb_left = StyleBoxFlat.new()
	sb_left.bg_color = Color(0.04, 0.05, 0.07, 1.0)
	sb_left.border_color = Color(0.35, 0.42, 0.50, 0.80)
	sb_left.set_border_width_all(1)
	sb_left.set_corner_radius_all(6)
	left_panel.add_theme_stylebox_override("panel", sb_left)
	
	var left_vbox = VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 4)
	left_panel.add_child(left_vbox)
	
	bar_backdrop_rect = TextureRect.new()
	bar_backdrop_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bar_backdrop_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bar_backdrop_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bar_backdrop_rect.texture = load_art_texture("res://resources/art/autogrill_bar_80s.jpg")
	left_vbox.add_child(bar_backdrop_rect)
	
	var lore_p = PanelContainer.new()
	var sb_lore = StyleBoxFlat.new()
	sb_lore.bg_color = Color(0.05, 0.06, 0.08, 0.95)
	sb_lore.set_corner_radius_all(4)
	lore_p.add_theme_stylebox_override("panel", sb_lore)
	bar_lore_label = Label.new()
	bar_lore_label.text = "📍 Autogrill Pavesi & Stazione Agip - Icona della sosta italiana anni '80/'90. Macchina espresso Faema E61 a leva, cornetti caldi, banco arancio e profumo di caffè macinato fresco prima dei tornanti alpini."
	bar_lore_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bar_lore_label.add_theme_font_size_override("font_size", 10)
	bar_lore_label.add_theme_color_override("font_color", Color(0.82, 0.86, 0.92))
	lore_p.add_child(bar_lore_label)
	left_vbox.add_child(lore_p)
	body_hbox.add_child(left_panel)
	
	# Right: 2 Characters + Gazzetta Lore
	var right_vbox = VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.size_flags_stretch_ratio = 1.35
	right_vbox.add_theme_constant_override("separation", 10)
	body_hbox.add_child(right_vbox)
	
	# Cards row
	var cards_hbox = HBoxContainer.new()
	cards_hbox.add_theme_constant_override("separation", 10)
	cards_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.add_child(cards_hbox)
	
	# Character 1
	var gianni_panel = PanelContainer.new()
	gianni_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb_g = StyleBoxFlat.new()
	sb_g.bg_color = Color(0.09, 0.07, 0.05, 0.95)
	sb_g.border_color = Color(0.85, 0.58, 0.22, 0.90)
	sb_g.set_border_width_all(1)
	sb_g.set_corner_radius_all(6)
	gianni_panel.add_theme_stylebox_override("panel", sb_g)
	
	var g_vbox = VBoxContainer.new()
	g_vbox.add_theme_constant_override("separation", 6)
	
	var g_top = HBoxContainer.new()
	g_top.add_theme_constant_override("separation", 8)
	bar_char1_img = TextureRect.new()
	bar_char1_img.custom_minimum_size = Vector2(80, 80)
	bar_char1_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bar_char1_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bar_char1_img.texture = load_art_texture("res://resources/art/barista_gianni.jpg")
	g_top.add_child(bar_char1_img)
	
	var g_txt = VBoxContainer.new()
	bar_char1_name = Label.new()
	bar_char1_name.text = "☕ GIANNI"
	bar_char1_name.add_theme_font_size_override("font_size", 13)
	bar_char1_name.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	g_txt.add_child(bar_char1_name)
	bar_char1_role = Label.new()
	bar_char1_role.text = "Barista Storico Autogrill"
	bar_char1_role.add_theme_font_size_override("font_size", 10)
	bar_char1_role.add_theme_color_override("font_color", Color(0.75, 0.82, 0.90))
	g_txt.add_child(bar_char1_role)
	g_top.add_child(g_txt)
	g_vbox.add_child(g_top)
	
	bar_gianni_dialogue = Label.new()
	bar_gianni_dialogue.text = "«Benvenuto al passo! Macchina Faema pronta a 9 bar, brioche calde e la mitica Rustichella Camogli appena sfornata. Un goccio di caffè e riparti con grinta!»"
	bar_gianni_dialogue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bar_gianni_dialogue.add_theme_font_size_override("font_size", 10)
	bar_gianni_dialogue.add_theme_color_override("font_color", Color(0.90, 0.92, 0.95))
	g_vbox.add_child(bar_gianni_dialogue)
	
	var g_sp = Control.new()
	g_sp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	g_vbox.add_child(g_sp)
	
	bar_gianni_btn = Button.new()
	bar_gianni_btn.text = "☕ UN ESPRESSO & RUSTICHELLA (+150 PT)"
	bar_gianni_btn.add_theme_font_size_override("font_size", 10)
	var sb_gb = StyleBoxFlat.new()
	sb_gb.bg_color = Color(0.35, 0.22, 0.10, 0.95)
	sb_gb.border_color = Color(0.95, 0.72, 0.25, 0.90)
	sb_gb.set_border_width_all(1)
	sb_gb.set_corner_radius_all(4)
	bar_gianni_btn.add_theme_stylebox_override("normal", sb_gb)
	bar_gianni_btn.pressed.connect(_on_order_coffee_pressed)
	g_vbox.add_child(bar_gianni_btn)
	
	gianni_panel.add_child(g_vbox)
	cards_hbox.add_child(gianni_panel)
	
	# Character 2
	var sandra_panel = PanelContainer.new()
	sandra_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb_s = StyleBoxFlat.new()
	sb_s.bg_color = Color(0.06, 0.08, 0.10, 0.95)
	sb_s.border_color = Color(0.96, 0.74, 0.16, 0.95)
	sb_s.set_border_width_all(1)
	sb_s.set_corner_radius_all(6)
	sandra_panel.add_theme_stylebox_override("panel", sb_s)
	
	var s_vbox = VBoxContainer.new()
	s_vbox.add_theme_constant_override("separation", 6)
	
	var s_top = HBoxContainer.new()
	s_top.add_theme_constant_override("separation", 8)
	bar_char2_img = TextureRect.new()
	bar_char2_img.custom_minimum_size = Vector2(80, 80)
	bar_char2_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bar_char2_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bar_char2_img.texture = load_art_texture("res://resources/art/mechanic_sandra.jpg")
	s_top.add_child(bar_char2_img)
	
	var s_txt = VBoxContainer.new()
	bar_char2_name = Label.new()
	bar_char2_name.text = "⛽ SANDRA"
	bar_char2_name.add_theme_font_size_override("font_size", 13)
	bar_char2_name.add_theme_color_override("font_color", Color(0.96, 0.74, 0.16))
	s_txt.add_child(bar_char2_name)
	bar_char2_role = Label.new()
	bar_char2_role.text = "Capo Meccanico Agip Sint 2000"
	bar_char2_role.add_theme_font_size_override("font_size", 10)
	bar_char2_role.add_theme_color_override("font_color", Color(0.75, 0.82, 0.90))
	s_txt.add_child(bar_char2_role)
	s_top.add_child(s_txt)
	s_vbox.add_child(s_top)
	
	bar_sandra_dialogue = Label.new()
	bar_sandra_dialogue.text = "«Ho controllato il motore all'arrivo. Mettiti qui sulla piazzola: facciamo il pieno di Super, controllo pressione gomme e azzeramento temperatura radiatore!»"
	bar_sandra_dialogue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bar_sandra_dialogue.add_theme_font_size_override("font_size", 10)
	bar_sandra_dialogue.add_theme_color_override("font_color", Color(0.90, 0.92, 0.95))
	s_vbox.add_child(bar_sandra_dialogue)
	
	var s_sp = Control.new()
	s_sp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	s_vbox.add_child(s_sp)
	
	bar_sandra_btn = Button.new()
	bar_sandra_btn.text = "⛽ PIENO SUPER & TAGLIANDO (+250 PT)"
	bar_sandra_btn.add_theme_font_size_override("font_size", 10)
	var sb_sb = StyleBoxFlat.new()
	sb_sb.bg_color = Color(0.12, 0.28, 0.14, 0.95)
	sb_sb.border_color = Color(0.35, 0.85, 0.45, 0.90)
	sb_sb.set_border_width_all(1)
	sb_sb.set_corner_radius_all(4)
	bar_sandra_btn.add_theme_stylebox_override("normal", sb_sb)
	bar_sandra_btn.pressed.connect(_on_service_car_pressed)
	s_vbox.add_child(bar_sandra_btn)
	
	sandra_panel.add_child(s_vbox)
	cards_hbox.add_child(sandra_panel)
	
	# Lore Box
	var gazzetta_panel = PanelContainer.new()
	var sb_gaz = StyleBoxFlat.new()
	sb_gaz.bg_color = Color(0.08, 0.12, 0.16, 0.95)
	sb_gaz.border_color = Color(0.40, 0.70, 0.90, 0.80)
	sb_gaz.set_border_width_all(1)
	sb_gaz.set_corner_radius_all(6)
	gazzetta_panel.add_theme_stylebox_override("panel", sb_gaz)
	
	var gaz_vbox = VBoxContainer.new()
	gaz_vbox.add_theme_constant_override("separation", 4)
	
	bar_gazzetta_head = Label.new()
	bar_gazzetta_head.text = "📰 GAZZETTA DELLO SPORT & BOLLETTINO METEO '93"
	bar_gazzetta_head.add_theme_font_size_override("font_size", 11)
	bar_gazzetta_head.add_theme_color_override("font_color", Color(0.35, 1.0, 0.65))
	gaz_vbox.add_child(bar_gazzetta_head)
	
	bar_gazzetta_label = Label.new()
	bar_gazzetta_label.text = "«BOLLETTINO PASSI: Fondo asciutto e sole splendente sul Passo Alpi. Attenzione alla Forra dell'Appennino: segnalato forte temporale estivo tra il KM 1.4 e il KM 3.0 con pioggia e nebbia fitta. Mantenere distanza di sicurezza e fari accesi!»"
	bar_gazzetta_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bar_gazzetta_label.add_theme_font_size_override("font_size", 10)
	bar_gazzetta_label.add_theme_color_override("font_color", Color(0.85, 0.88, 0.92))
	gaz_vbox.add_child(bar_gazzetta_label)
	
	bar_status_label = Label.new()
	bar_status_label.text = "✨ Pronti alla sosta tecnica. Scegli un'opzione o premi [ESC] per ripartire."
	bar_status_label.add_theme_font_size_override("font_size", 10)
	bar_status_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.30))
	gaz_vbox.add_child(bar_status_label)
	
	gazzetta_panel.add_child(gaz_vbox)
	right_vbox.add_child(gazzetta_panel)
	
	bar_service_overlay.add_child(bar_modal_box)
	add_child(bar_service_overlay)

func open_bar_service_modal(building_type: String = "autogrill_bar", info: Dictionary = {}):
	if not bar_service_overlay: return
	bar_service_overlay.visible = true
	var vp = get_viewport_rect().size
	bar_service_overlay.size = vp
	if bar_modal_box:
		bar_modal_box.size = Vector2(min(1080.0, vp.x - 40.0), min(640.0, vp.y - 60.0))
		bar_modal_box.position = (vp - bar_modal_box.size) * 0.5
		
	if current_bar_building_type != building_type:
		current_bar_building_type = building_type
		bar_coffee_consumed = false
		bar_service_performed = false
		if bar_gianni_btn: bar_gianni_btn.disabled = false
		if bar_sandra_btn: bar_sandra_btn.disabled = false
		
	# Dynamic 80s/90s Building Aesthetics & Characters
	if building_type == "chalet_malga":
		if bar_title_label: bar_title_label.text = "🧀 MALGA PASSO DELLE ALPI '89"
		if bar_subtitle_label: bar_subtitle_label.text = " | Degustazione Tipica & Sorgente d'Alpeggio"
		if bar_backdrop_rect: bar_backdrop_rect.texture = load_art_texture("res://resources/art/malga_alpina_80s.jpg")
		if bar_lore_label: bar_lore_label.text = "📍 Malga Alpina d'Alta Quota - Baita in pietra e tronchi dove si affina la Fontina e si batte il burro fresco. Calore del focolare, rintocco dei campanacci e profumo di erbe d'alpeggio."
		if bar_char1_img: bar_char1_img.texture = load_art_texture("res://resources/art/casaro_bepi.jpg")
		if bar_char1_name: bar_char1_name.text = "🧀 BEPI"
		if bar_char1_role: bar_char1_role.text = "Casaro & Custode dell'Alpeggio"
		if bar_gianni_dialogue: bar_gianni_dialogue.text = "«Benvenuto in malga! Accomodati vicino al focolare. Assaggia una fetta di Fontina d'Alpeggio e bevi una scodella di latte fresco: è l'energia dei pascoli alti per affrontare il valico!»"
		if bar_gianni_btn and not bar_coffee_consumed: bar_gianni_btn.text = "🧀 ASSAGGIO FONTINA & LATTE (+150 PT)"
		if bar_char2_img: bar_char2_img.texture = load_art_texture("res://resources/art/mechanic_sandra.jpg")
		if bar_char2_name: bar_char2_name.text = "💧 SORGENTE"
		if bar_char2_role: bar_char2_role.text = "Rabbocco & Spurgo Radiatore"
		if bar_sandra_dialogue: bar_sandra_dialogue.text = "«Abbiamo attinto l'acqua gelida dalla cascata alpina per spurgare il circuito radiatore e qui c'è una tanica di Super per il pieno. La vettura è pronta per i tornanti a gomito!»"
		if bar_sandra_btn and not bar_service_performed: bar_sandra_btn.text = "💧 ACQUA SORGIVA & REVISIONE (+250 PT)"
		if bar_gazzetta_head: bar_gazzetta_head.text = "🏔️ ALMANACCO DEI PASTORI & BOLLETTINO ALPINO"
		if bar_gazzetta_label: bar_gazzetta_label.text = "«BOLLETTINO ALPI: Pascoli soleggiati e asfalto asciutto sul passo. Attenzione: discesa verso la Forra con asfalto viscido e nebbia fitta. Usare marce basse per frenare con il motore!»"
		if bar_status_label and not bar_coffee_consumed and not bar_service_performed:
			bar_status_label.text = "✨ Malga alpina aperta. Degusta i prodotti o riparti verso il valico."
	elif building_type == "bar_sport":
		if bar_title_label: bar_title_label.text = "☕ BAR DELLO SPORT 'DA ROBERTO' '93"
		if bar_subtitle_label: bar_subtitle_label.text = " | Borgo San Cristoforo - Caffè Espresso & Grappe"
		if bar_backdrop_rect: bar_backdrop_rect.texture = load_art_texture("res://resources/art/village_bar_80s.jpg")
		if bar_lore_label: bar_lore_label.text = "📍 Bar dello Sport 'Da Roberto' - Cuore pulsante del borgo tra flipper a gettoni, biliardo, Gazzetta dello Sport sul banco di marmo e vivaci discussioni sportive tra appassionati."
		if bar_char1_img: bar_char1_img.texture = load_art_texture("res://resources/art/barista_roberto.jpg")
		if bar_char1_name: bar_char1_name.text = "☕ ROBERTO"
		if bar_char1_role: bar_char1_role.text = "Titolare Bar dello Sport"
		if bar_gianni_dialogue: bar_gianni_dialogue.text = "«Mettiti comodo! Un bell'espresso tirato a leva con la Faema e un cornetto caldo appena sfornato. Se vuoi sfogliare la Gazzetta con il Milan campione, è tutta tua!»"
		if bar_gianni_btn and not bar_coffee_consumed: bar_gianni_btn.text = "☕ ESPRESSO A LEVA & GAZZETTA (+150 PT)"
		if bar_char2_img: bar_char2_img.texture = load_art_texture("res://resources/art/barista_gianni.jpg")
		if bar_char2_name: bar_char2_name.text = "🃏 SILVIO"
		if bar_char2_role: bar_char2_role.text = "Campione di Briscola & Memoria Storica"
		if bar_sandra_dialogue: bar_sandra_dialogue.text = "«Ai tempi d'oro affrontavamo il Ponte dei Ciclopi in controsterzo con la Giulia GTA! Tieni i tergicristalli pronti e scala in seconda marcia sui ciottoli bagnati!»"
		if bar_sandra_btn and not bar_service_performed: bar_sandra_btn.text = "🃏 SEGRETI DEI TORNANTI & ASSETTO (+250 PT)"
		if bar_gazzetta_head: bar_gazzetta_head.text = "📰 LA GAZZETTA DELLO SPORT - EDIZIONE SPECIALE '93"
		if bar_gazzetta_label: bar_gazzetta_label.text = "«CALCIO & MOTORI: Milan trionfatore, Lancia Delta regina dei rally. Dalla prefettura: moderare la velocità lungo la Forra dell'Appennino per asfalto viscido.»"
		if bar_status_label and not bar_coffee_consumed and not bar_service_performed:
			bar_status_label.text = "✨ Bar dello Sport animato. Scambia due chiacchiere o riprendi il viaggio."
	else:
		if bar_title_label: bar_title_label.text = "☕ AUTOGRILL & BAR RISTORO DEL MERIDIANO '89"
		var st_name = info.get("name", "Stazione Agip KM 0.78 - Passo delle Alpi")
		if bar_subtitle_label: bar_subtitle_label.text = " | %s" % st_name
		if bar_backdrop_rect: bar_backdrop_rect.texture = load_art_texture("res://resources/art/autogrill_bar_80s.jpg")
		if bar_lore_label: bar_lore_label.text = "📍 Autogrill Pavesi & Stazione Agip - Icona della sosta italiana anni '80/'90. Macchina espresso Faema E61 a leva, cornetti caldi, banco arancio e profumo di caffè macinato fresco prima dei tornanti alpini."
		if bar_char1_img: bar_char1_img.texture = load_art_texture("res://resources/art/barista_gianni.jpg")
		if bar_char1_name: bar_char1_name.text = "☕ GIANNI"
		if bar_char1_role: bar_char1_role.text = "Barista Storico Autogrill"
		if bar_gianni_dialogue: bar_gianni_dialogue.text = "«Benvenuto al passo! Macchina Faema pronta a 9 bar, brioche calde e la mitica Rustichella Camogli appena sfornata. Un goccio di caffè e riparti con grinta!»"
		if bar_gianni_btn and not bar_coffee_consumed: bar_gianni_btn.text = "☕ UN ESPRESSO & RUSTICHELLA (+150 PT)"
		if bar_char2_img: bar_char2_img.texture = load_art_texture("res://resources/art/mechanic_sandra.jpg")
		if bar_char2_name: bar_char2_name.text = "⛽ SANDRA"
		if bar_char2_role: bar_char2_role.text = "Capo Meccanico Agip Sint 2000"
		if bar_sandra_dialogue: bar_sandra_dialogue.text = "«Ho controllato il motore all'arrivo. Mettiti qui sulla piazzola: facciamo il pieno di Super, controllo pressione gomme e azzeramento temperatura radiatore!»"
		if bar_sandra_btn and not bar_service_performed: bar_sandra_btn.text = "⛽ PIENO SUPER & TAGLIANDO (+250 PT)"
		if bar_gazzetta_head: bar_gazzetta_head.text = "📰 GAZZETTA DELLO SPORT & BOLLETTINO METEO '93"
		if bar_gazzetta_label: bar_gazzetta_label.text = "«BOLLETTINO PASSI: Fondo asciutto e sole splendente sul Passo Alpi. Attenzione alla Forra dell'Appennino: segnalato forte temporale estivo tra il KM 1.4 e il KM 3.0 con pioggia e nebbia fitta. Mantenere distanza di sicurezza e fari accesi!»"
		if bar_status_label and not bar_coffee_consumed and not bar_service_performed:
			bar_status_label.text = "✨ Pronti alla sosta tecnica. Scegli un'opzione o premi [ESC] per ripartire."

func close_bar_service_modal():
	if bar_service_overlay:
		bar_service_overlay.visible = false

func toggle_bar_service_modal():
	if is_bar_modal_open():
		close_bar_service_modal()
	else:
		open_bar_service_modal()

func is_bar_modal_open() -> bool:
	return bar_service_overlay != null and bar_service_overlay.visible

func _on_order_coffee_pressed():
	if bar_coffee_consumed: return
	bar_coffee_consumed = true
	if bar_gianni_btn:
		bar_gianni_btn.disabled = true
		if current_bar_building_type == "chalet_malga":
			bar_gianni_btn.text = "✅ FONTINA E LATTE GUSTATI (+150 PT)"
		elif current_bar_building_type == "bar_sport":
			bar_gianni_btn.text = "✅ ESPRESSO AL BANCO GUSTATO (+150 PT)"
		else:
			bar_gianni_btn.text = "✅ ESPRESSO E RUSTICHELLA GUSTATI (+150 PT)"
	if bar_gianni_dialogue:
		if current_bar_building_type == "chalet_malga":
			bar_gianni_dialogue.text = "«Ottima scelta! Il latte appena munto e la Fontina stagionata ti daranno tutta l'energia per dominare i tornanti del valico alpino!»"
		elif current_bar_building_type == "bar_sport":
			bar_gianni_dialogue.text = "«Ecco fatto! Caffè ristretto cremoso alla napoletana e cornetto caldo. Buona lettura della Gazzetta e occhio ai tornanti!»"
		else:
			bar_gianni_dialogue.text = "«Ottima scelta! Ecco un espresso Faema fatto a regola d'arte e la Rustichella fumante. Energia pura per i tornanti del valico!»"
	if bar_status_label:
		bar_status_label.text = "☕ Ristoro completato! +150 Punti Spedizione aggiunti al diario di viaggio!"
		bar_status_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55))
		
	var main_node = get_tree().root.get_node_or_null("Main") if get_tree() and get_tree().root else null
	if main_node and main_node.get("journey_director"):
		main_node.journey_director.score += 150
	if main_node and main_node.get("street_rod_manager"):
		var title_msg = "☕ RISTORO MALGA ALPINA" if current_bar_building_type == "chalet_malga" else ("☕ BAR DELLO SPORT 'DA ROBERTO'" if current_bar_building_type == "bar_sport" else "☕ SOSTA RISTORO AUTOGRILL")
		var body_msg = "Degustazione completata! (+150 PT)"
		main_node.street_rod_manager.post_notification(title_msg, body_msg, "☕", "cup")

func _on_service_car_pressed():
	if bar_service_performed: return
	bar_service_performed = true
	if bar_sandra_btn:
		bar_sandra_btn.disabled = true
		if current_bar_building_type == "chalet_malga":
			bar_sandra_btn.text = "✅ ACQUA SORGIVA E RABBOCCO COMPLETATI (+250 PT)"
		elif current_bar_building_type == "bar_sport":
			bar_sandra_btn.text = "✅ SEGRETI E ASSETTO COMPLETATI (+250 PT)"
		else:
			bar_sandra_btn.text = "✅ PIENO E TAGLIANDO COMPLETATI (+250 PT)"
	if bar_sandra_dialogue:
		if current_bar_building_type == "chalet_malga":
			bar_sandra_dialogue.text = "«Circuito radiatore spurgato e freddo a 85°C con l'acqua sorgiva del ghiacciaio, serbatoio rabboccato al massimo e scocca controllata. Sei pronto per la vetta!»"
		elif current_bar_building_type == "bar_sport":
			bar_sandra_dialogue.text = "«Ho controllato i tiranti dello sterzo e la pressione delle gomme come ai rally di Sanremo. Pieno raso di carburante e temperatura ottimale!»"
		else:
			bar_sandra_dialogue.text = "«Fatto! Pieno raso di Super, livello olio Sint 2000 impeccabile e radiatore freddo a 85°C. La macchina è un gioiello, pronta per affrontare qualsiasi pendenza!»"
	if bar_status_label:
		bar_status_label.text = "⛽ Sosta tecnica completata! Serbatoio al 100%, temperatura ottimale e +250 Punti Spedizione!"
		bar_status_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55))
		
	var main_node = get_tree().root.get_node_or_null("Main") if get_tree() and get_tree().root else null
	if main_node and main_node.get("vehicle"):
		var v = main_node.vehicle
		var cur_cfg = v.VEHICLE_CATALOG.get(v.current_model_id, {})
		v.perform_service(cur_cfg)
		if v.has_method("repair_chassis_deformation"):
			v.repair_chassis_deformation()
	elif main_node and main_node.get("journey_director"):
		main_node.journey_director.score += 250
	if main_node and main_node.get("street_rod_manager"):
		var title_msg = "💧 ASSISTENZA MALGA ALPINA" if current_bar_building_type == "chalet_malga" else ("🃏 CONSIGLI & TAGLIANDO DEL BORGO" if current_bar_building_type == "bar_sport" else "⛽ OFFICINA AGIP SINT 2000")
		var body_msg = "Intervento tecnico completato con successo (+250 PT)"
		main_node.street_rod_manager.post_notification(title_msg, body_msg, "⛽", "wrench")

# =========================================================================
# 6c. AUDIO MIXER & VINTAGE MP3 AUTORADIO MODAL
# =========================================================================
func setup_audio_mixer_modal():
	audio_mixer_overlay = Control.new()
	audio_mixer_overlay.name = "AudioMixerOverlay"
	audio_mixer_overlay.anchors_preset = Control.PRESET_FULL_RECT
	audio_mixer_overlay.visible = false
	
	# Sfondo oscurato semi-trasparente
	var bg_dim = ColorRect.new()
	bg_dim.anchors_preset = Control.PRESET_FULL_RECT
	bg_dim.color = Color(0.02, 0.03, 0.05, 0.82)
	bg_dim.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed:
			toggle_audio_mixer_modal()
	)
	audio_mixer_overlay.add_child(bg_dim)
	
	audio_mixer_modal_box = PanelContainer.new()
	var sb_modal = StyleBoxFlat.new()
	sb_modal.bg_color = Color(0.07, 0.09, 0.12, 0.98) # Dark Amiga/Vintage charcoal
	sb_modal.border_color = Color(0.92, 0.72, 0.20, 0.95) # Gold frame
	sb_modal.set_border_width_all(2)
	sb_modal.set_corner_radius_all(8)
	sb_modal.shadow_size = 28
	sb_modal.shadow_color = Color(0, 0, 0, 0.85)
	audio_mixer_modal_box.add_theme_stylebox_override("panel", sb_modal)
	
	var margin_c = MarginContainer.new()
	margin_c.add_theme_constant_override("margin_left", 22)
	margin_c.add_theme_constant_override("margin_top", 18)
	margin_c.add_theme_constant_override("margin_right", 22)
	margin_c.add_theme_constant_override("margin_bottom", 18)
	audio_mixer_modal_box.add_child(margin_c)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 14)
	margin_c.add_child(main_vbox)
	
	# Header
	var head_hbox = HBoxContainer.new()
	var title_lbl = Label.new()
	title_lbl.text = "🎚️ MIXER AUDIO & AUTORADIO MP3 '93"
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.30))
	head_hbox.add_child(title_lbl)
	
	var sp_head = Control.new()
	sp_head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head_hbox.add_child(sp_head)
	
	var btn_close = Button.new()
	btn_close.text = " ✕ CHIUDI [ESC / O] "
	btn_close.add_theme_font_size_override("font_size", 11)
	btn_close.pressed.connect(toggle_audio_mixer_modal)
	head_hbox.add_child(btn_close)
	main_vbox.add_child(head_hbox)
	
	main_vbox.add_child(HSeparator.new())
	
	# SEZIONE 1: CONTROLLO VOLUMI
	var vol_sec_title = Label.new()
	vol_sec_title.text = "🎛️ REGOLAZIONE VOLUMI PER SEZIONE"
	vol_sec_title.add_theme_font_size_override("font_size", 12)
	vol_sec_title.add_theme_color_override("font_color", Color(0.45, 0.85, 1.0))
	main_vbox.add_child(vol_sec_title)
	
	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 10)
	
	# Master Volume
	var lbl_m = Label.new()
	lbl_m.text = "🔊 Volume Generale (Master):"
	lbl_m.custom_minimum_size = Vector2(240, 0)
	lbl_m.add_theme_font_size_override("font_size", 12)
	grid.add_child(lbl_m)
	slider_master = HSlider.new()
	slider_master.min_value = 0.0
	slider_master.max_value = 1.5
	slider_master.step = 0.05
	slider_master.value = 1.0
	slider_master.custom_minimum_size = Vector2(250, 24)
	grid.add_child(slider_master)
	lbl_val_master = Label.new()
	lbl_val_master.text = "100%"
	lbl_val_master.custom_minimum_size = Vector2(45, 0)
	lbl_val_master.add_theme_font_size_override("font_size", 12)
	grid.add_child(lbl_val_master)
	
	# Engine Volume
	var lbl_e = Label.new()
	lbl_e.text = "🏎️ Suono Motore (Scarico & Punterie):"
	lbl_e.add_theme_font_size_override("font_size", 12)
	grid.add_child(lbl_e)
	slider_engine = HSlider.new()
	slider_engine.min_value = 0.0
	slider_engine.max_value = 1.5
	slider_engine.step = 0.05
	slider_engine.value = 1.0
	slider_engine.custom_minimum_size = Vector2(250, 24)
	grid.add_child(slider_engine)
	lbl_val_engine = Label.new()
	lbl_val_engine.text = "100%"
	lbl_val_engine.add_theme_font_size_override("font_size", 12)
	grid.add_child(lbl_val_engine)
	
	# Ambient Volume
	var lbl_a = Label.new()
	lbl_a.text = "🌲 Suoni Ambientali (Vento, Asfalto, Urti):"
	lbl_a.add_theme_font_size_override("font_size", 12)
	grid.add_child(lbl_a)
	slider_ambient = HSlider.new()
	slider_ambient.min_value = 0.0
	slider_ambient.max_value = 1.5
	slider_ambient.step = 0.05
	slider_ambient.value = 1.0
	slider_ambient.custom_minimum_size = Vector2(250, 24)
	grid.add_child(slider_ambient)
	lbl_val_ambient = Label.new()
	lbl_val_ambient.text = "100%"
	lbl_val_ambient.add_theme_font_size_override("font_size", 12)
	grid.add_child(lbl_val_ambient)
	
	# Radio Volume
	var lbl_r = Label.new()
	lbl_r.text = "📻 Volume Autoradio (Brani MP3 & FM):"
	lbl_r.add_theme_font_size_override("font_size", 12)
	grid.add_child(lbl_r)
	slider_radio = HSlider.new()
	slider_radio.min_value = 0.0
	slider_radio.max_value = 1.5
	slider_radio.step = 0.05
	slider_radio.value = 1.0
	slider_radio.custom_minimum_size = Vector2(250, 24)
	grid.add_child(slider_radio)
	lbl_val_radio = Label.new()
	lbl_val_radio.text = "100%"
	lbl_val_radio.add_theme_font_size_override("font_size", 12)
	grid.add_child(lbl_val_radio)
	
	main_vbox.add_child(grid)
	
	# Connessioni Slider
	slider_master.value_changed.connect(func(val):
		lbl_val_master.text = "%d%%" % int(val * 100.0)
		var va = get_active_audio_engine()
		if va and va.has_method("set_master_volume"):
			va.set_master_volume(val)
	)
	slider_engine.value_changed.connect(func(val):
		lbl_val_engine.text = "%d%%" % int(val * 100.0)
		var va = get_active_audio_engine()
		if va and va.has_method("set_engine_volume"):
			va.set_engine_volume(val)
	)
	slider_ambient.value_changed.connect(func(val):
		lbl_val_ambient.text = "%d%%" % int(val * 100.0)
		var va = get_active_audio_engine()
		if va and va.has_method("set_ambient_volume"):
			va.set_ambient_volume(val)
	)
	slider_radio.value_changed.connect(func(val):
		lbl_val_radio.text = "%d%%" % int(val * 100.0)
		var va = get_active_audio_engine()
		if va and va.has_method("set_radio_volume"):
			va.set_radio_volume(val)
	)
	
	main_vbox.add_child(HSeparator.new())
	
	# SEZIONE 2: AUTORADIO & GESTIONE FILE MP3
	var rad_sec_title = Label.new()
	rad_sec_title.text = "📻 AUTORADIO D'EPOCA & GESTORE BRANI MP3"
	rad_sec_title.add_theme_font_size_override("font_size", 12)
	rad_sec_title.add_theme_color_override("font_color", Color(0.40, 1.0, 0.50))
	main_vbox.add_child(rad_sec_title)
	
	var rad_panel = PanelContainer.new()
	var sb_rad_box = StyleBoxFlat.new()
	sb_rad_box.bg_color = Color(0.04, 0.05, 0.07, 0.90)
	sb_rad_box.border_color = Color(0.25, 0.35, 0.45, 0.70)
	sb_rad_box.set_border_width_all(1)
	sb_rad_box.set_corner_radius_all(6)
	rad_panel.add_theme_stylebox_override("panel", sb_rad_box)
	
	var rad_vbox = VBoxContainer.new()
	rad_vbox.add_theme_constant_override("separation", 8)
	var m_inner = MarginContainer.new()
	m_inner.add_theme_constant_override("margin_left", 14)
	m_inner.add_theme_constant_override("margin_top", 10)
	m_inner.add_theme_constant_override("margin_right", 14)
	m_inner.add_theme_constant_override("margin_bottom", 10)
	m_inner.add_child(rad_vbox)
	rad_panel.add_child(m_inner)
	
	lbl_radio_track_info = Label.new()
	lbl_radio_track_info.text = "📻 Canale: AUTORADIO SPENTA (---)"
	lbl_radio_track_info.add_theme_font_size_override("font_size", 13)
	lbl_radio_track_info.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
	rad_vbox.add_child(lbl_radio_track_info)
	
	lbl_radio_mp3_count = Label.new()
	lbl_radio_mp3_count.text = "📁 Brani MP3 rilevati: 0 brani in user://radio/"
	lbl_radio_mp3_count.add_theme_font_size_override("font_size", 11)
	lbl_radio_mp3_count.add_theme_color_override("font_color", Color(0.70, 0.85, 0.75))
	rad_vbox.add_child(lbl_radio_mp3_count)
	
	var transport_hbox = HBoxContainer.new()
	transport_hbox.add_theme_constant_override("separation", 8)
	
	var btn_prev = Button.new()
	btn_prev.text = "⏮️ PREC"
	btn_prev.custom_minimum_size = Vector2(90, 28)
	btn_prev.pressed.connect(func():
		var va = get_active_audio_engine()
		if va and va.has_method("prev_radio_station"):
			va.prev_radio_station()
			refresh_audio_mixer_ui()
	)
	transport_hbox.add_child(btn_prev)
	
	var btn_toggle = Button.new()
	btn_toggle.text = "⏹️ SPEGNI / ▶️ ACCENDI"
	btn_toggle.custom_minimum_size = Vector2(150, 28)
	btn_toggle.pressed.connect(func():
		var va = get_active_audio_engine()
		if va and va.has_method("toggle_radio_power"):
			va.toggle_radio_power()
			refresh_audio_mixer_ui()
	)
	transport_hbox.add_child(btn_toggle)
	
	var btn_next = Button.new()
	btn_next.text = "⏭️ SUCC [R]"
	btn_next.custom_minimum_size = Vector2(100, 28)
	btn_next.pressed.connect(func():
		var va = get_active_audio_engine()
		if va and va.has_method("cycle_radio_station"):
			va.cycle_radio_station()
			refresh_audio_mixer_ui()
	)
	transport_hbox.add_child(btn_next)
	
	var sp_act = Control.new()
	sp_act.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	transport_hbox.add_child(sp_act)
	
	var btn_open_folder = Button.new()
	btn_open_folder.text = "📁 APRI CARTELLA MP3"
	btn_open_folder.tooltip_text = "Apri la cartella di sistema in cui incollare i tuoi file MP3"
	btn_open_folder.pressed.connect(func():
		var va = get_active_audio_engine()
		if va and va.has_method("open_user_radio_folder"):
			va.open_user_radio_folder()
	)
	transport_hbox.add_child(btn_open_folder)
	
	var btn_rescan = Button.new()
	btn_rescan.text = "🔄 RICARICA BRANI"
	btn_rescan.tooltip_text = "Esegui di nuovo la scansione per caricare i nuovi file MP3 aggiunti"
	btn_rescan.pressed.connect(func():
		var va = get_active_audio_engine()
		if va and va.has_method("scan_and_load_mp3_tracks"):
			va.scan_and_load_mp3_tracks()
			va.build_radio_stations_list()
			refresh_audio_mixer_ui()
	)
	transport_hbox.add_child(btn_rescan)
	
	rad_vbox.add_child(transport_hbox)
	main_vbox.add_child(rad_panel)
	
	audio_mixer_overlay.add_child(audio_mixer_modal_box)
	add_child(audio_mixer_overlay)

func get_active_audio_engine() -> VehicleAudio:
	var tree = get_tree()
	if tree and tree.root:
		var main_node = tree.root.get_node_or_null("Main")
		if main_node and main_node.get("vehicle") and main_node.vehicle.get("audio_engine"):
			return main_node.vehicle.audio_engine
		var va = tree.root.find_child("VehicleAudio", true, false)
		if va is VehicleAudio:
			return va
	return null

func is_audio_mixer_open() -> bool:
	return audio_mixer_overlay != null and audio_mixer_overlay.visible

func toggle_audio_mixer_modal():
	if not audio_mixer_overlay:
		setup_audio_mixer_modal()
	if audio_mixer_overlay.visible:
		close_audio_mixer_modal()
	else:
		open_audio_mixer_modal()

func open_audio_mixer_modal():
	if not audio_mixer_overlay:
		setup_audio_mixer_modal()
	refresh_audio_mixer_ui()
	audio_mixer_overlay.visible = true
	var vp = get_viewport_rect().size
	if audio_mixer_modal_box:
		audio_mixer_modal_box.size = Vector2(min(740.0, vp.x - 40.0), min(500.0, vp.y - 60.0))
		audio_mixer_modal_box.position = (vp - audio_mixer_modal_box.size) * 0.5

func close_audio_mixer_modal():
	if audio_mixer_overlay:
		audio_mixer_overlay.visible = false

func refresh_audio_mixer_ui():
	var va = get_active_audio_engine()
	if not va:
		return
	if slider_master:
		slider_master.set_value_no_signal(va.get_master_volume())
		if lbl_val_master: lbl_val_master.text = "%d%%" % int(va.get_master_volume() * 100.0)
	if slider_engine:
		slider_engine.set_value_no_signal(va.get_engine_volume())
		if lbl_val_engine: lbl_val_engine.text = "%d%%" % int(va.get_engine_volume() * 100.0)
	if slider_ambient:
		slider_ambient.set_value_no_signal(va.get_ambient_volume())
		if lbl_val_ambient: lbl_val_ambient.text = "%d%%" % int(va.get_ambient_volume() * 100.0)
	if slider_radio:
		slider_radio.set_value_no_signal(va.get_radio_volume())
		if lbl_val_radio: lbl_val_radio.text = "%d%%" % int(va.get_radio_volume() * 100.0)
	if lbl_radio_track_info:
		lbl_radio_track_info.text = "📻 Canale: " + va.get_current_radio_name()
	if lbl_radio_mp3_count:
		var mp3_cnt = va.get_custom_mp3_count()
		lbl_radio_mp3_count.text = "📁 Brani MP3 personalizzati rilevati: %d brani in user://radio/" % mp3_cnt
	if btn_hud_radio:
		btn_hud_radio.text = " [R] 📻 " + va.get_current_radio_name().split("(")[0].strip_edges()

func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		if is_audio_mixer_open():
			if event.keycode == KEY_ESCAPE or event.keycode == KEY_O:
				toggle_audio_mixer_modal()
				get_viewport().set_input_as_handled()
		elif is_bar_modal_open():
			if event.keycode == KEY_ESCAPE or event.keycode == KEY_E:
				close_bar_service_modal()
				get_viewport().set_input_as_handled()
		elif is_logbook_open():
			if event.keycode == KEY_ESCAPE or event.keycode == KEY_M or event.keycode == KEY_TAB:
				toggle_logbook()
				get_viewport().set_input_as_handled()
		elif event.keycode == KEY_O:
			toggle_audio_mixer_modal()
			get_viewport().set_input_as_handled()

func refresh_logbook_contents():
	# 1. Update Stages list
	if logbook_stages_container:
		for c in logbook_stages_container.get_children():
			c.queue_free()
			
		var stages_info = [
			{ "n": 1, "name": "PASSO DELLE ALPI & DOLOMITI", "pk": "0.0 - 1.4 km", "obj": "Supera i tornanti alpini delle Dolomiti e fai rifornimento all'Agip prima della riserva!", "pts": 500 },
			{ "n": 2, "name": "FORRA DELL'APPENNINO & BORGO STORICO", "pk": "1.4 - 3.0 km", "obj": "Attraversa il Ponte dei Ciclopi e raggiungi la piazza di Borgo San Cristoforo!", "pts": 750 },
			{ "n": 3, "name": "COLLINE TOSCANE & VAL D'ORCIA", "pk": "3.0 - 4.8 km", "obj": "Percorri le colline della Val d'Orcia e fermati all'Autogrill sul valico!", "pts": 1000 },
			{ "n": 4, "name": "VALICO GLACIALE DEL DUCA - QUOTA 2650M", "pk": "4.8 - 5.6 km", "obj": "Sfida il valico alpino con 4WD e taglia il traguardo al rifugio contro la Delta!", "pts": 2000 }
		]
		
		var cur_st_idx = last_journey_info.get("stage_idx", 1)
		for s in stages_info:
			var s_box = VBoxContainer.new()
			var status_str = "[✓ COMPLETATA]" if s.n < cur_st_idx else ("[▶ IN CORSO]" if s.n == cur_st_idx else "[🔒 BLOCCATA]")
			var status_col = Color(0.35, 1.0, 0.55) if s.n < cur_st_idx else (Color(1.0, 0.85, 0.25) if s.n == cur_st_idx else Color(0.5, 0.5, 0.5))
			
			var l_head = Label.new()
			l_head.text = "TAPPA %d: %s (%s) %s" % [s.n, s.name, s.pk, status_str]
			l_head.add_theme_font_size_override("font_size", 11)
			l_head.add_theme_color_override("font_color", status_col)
			s_box.add_child(l_head)
			
			var l_obj = Label.new()
			l_obj.text = "🎯 %s\n🏆 Ricompensa: +%d PT" % [s.obj, s.pts]
			l_obj.add_theme_font_size_override("font_size", 10)
			l_obj.add_theme_color_override("font_color", Color(0.75, 0.80, 0.85))
			s_box.add_child(l_obj)
			
			logbook_stages_container.add_child(s_box)
			logbook_stages_container.add_child(HSeparator.new())
			
	# 2. Update Milestones list
	if logbook_milestones_container:
		for c in logbook_milestones_container.get_children():
			c.queue_free()
			
		if discovered_milestones.is_empty():
			var l_empty = Label.new()
			l_empty.text = "Nessun traguardo ancora raggiunto.\nGuida lungo il tracciato per scoprire i punti notevoli!"
			l_empty.add_theme_font_size_override("font_size", 10)
			l_empty.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7))
			logbook_milestones_container.add_child(l_empty)
		else:
			for m in discovered_milestones:
				var m_box = VBoxContainer.new()
				var l_t = Label.new()
				l_t.text = "%s %s (QUOTA %s) | +%d PT" % [m.get("icon", "📍"), m.get("title", ""), m.get("alt", ""), m.get("pts", 0)]
				l_t.add_theme_font_size_override("font_size", 11)
				l_t.add_theme_color_override("font_color", Color(0.96, 0.82, 0.28))
				m_box.add_child(l_t)
				
				var l_l = Label.new()
				l_l.text = m.get("lore", "")
				l_l.add_theme_font_size_override("font_size", 10)
				l_l.add_theme_color_override("font_color", Color(0.80, 0.85, 0.90))
				m_box.add_child(l_l)
				
				logbook_milestones_container.add_child(m_box)
				logbook_milestones_container.add_child(HSeparator.new())

	# 3. Update Stats
	if logbook_stats_label:
		var dist_km = last_journey_info.get("pk_km", 0.0)
		var score = last_journey_info.get("score", 0)
		var pct = last_journey_info.get("progress_pct", 0.0)
		var exp_seed = last_journey_info.get("seed", 1991)
		logbook_stats_label.text = """
DISTANZA PERCORSA:
%.2f KM / 5.20 KM (%.1f%%)

SEED MONDO PROCEDURALE:
#%d

PUNTEGGIO SPEDIZIONE:
%d PUNTI

CARBURANTE ATTUALE:
%.1f L / %.1f L

TEMPERATURA MOTORE:
%.1f °C (Ottimale: 85-92°C)

COMANDI SPEDIZIONE:
[E] : Rifornimento in Stazione
[C] : Cambio Veicolo
[V] : Ciclo Inquadratura Camera
[B] : Sfocatura Tilt-Shift ON/OFF
[Z] / [4] : Trazione 4WD / Blocchi
[M] : Apri / Chiudi Questo Diario
""" % [dist_km, pct, exp_seed, score, current_fuel_val, current_tank_max, current_temp_val]

# =========================================================================
# 7. JOURNEY DIRECTOR SIGNALS
# =========================================================================
func update_journey(info: Dictionary):
	last_journey_info = info
	var exp_seed = info.get("seed", 1991)
	
	if label_hud_stage:
		label_hud_stage.text = "🧭 TAPPA %d/%d [#%d]: %s" % [info.get("stage_idx", 1), info.get("total_stages", 4), exp_seed, info.get("stage_name", "")]
	if label_hud_pk:
		label_hud_pk.text = "PK %.2f / 5.20 KM" % info.get("pk_km", 0.0)
	if hud_progress_bar:
		hud_progress_bar.value = info.get("progress_pct", 0.0)
	if label_hud_next:
		var next_name = info.get("next_milestone", "")
		var dist_m = info.get("dist_to_next_m", 0.0)
		label_hud_next.text = "📍 %s [%.0fm]" % [next_name, dist_m]
	if label_hud_objective:
		label_hud_objective.text = "🎯 OBIETTIVO: %s" % info.get("objective", "")
	if label_hud_score:
		label_hud_score.text = "🏆 %d PT" % info.get("score", 0)

func on_milestone_reached(milestone: Dictionary):
	discovered_milestones.append(milestone)
	if milestone_panel and milestone_title_label and milestone_lore_label and milestone_pts_label:
		milestone_title_label.text = "✨ TRAGUARDO SUL MERIDIANO: %s %s (QUOTA %s)" % [milestone.get("icon", ""), milestone.get("title", ""), milestone.get("alt", "")]
		milestone_lore_label.text = milestone.get("lore", "")
		milestone_pts_label.text = "+%d PT SPEDIZIONE" % milestone.get("pts", 0)
		milestone_panel.visible = true
		milestone_timer = 5.5

func on_stage_cleared(stage_data: Dictionary):
	if milestone_panel:
		milestone_panel.visible = false
	if stage_clear_panel and stage_clear_label:
		stage_clear_label.text = "🏁 TAPPA %d SUPERATA: %s! (+%d PT BONUS SPEDIZIONE)" % [stage_data.get("stage_num", 1), stage_data.get("stage_name", ""), stage_data.get("reward", 500)]
		stage_clear_panel.visible = true
		stage_clear_timer = 6.0

func on_expedition_completed(final_stats: Dictionary):
	if milestone_panel:
		milestone_panel.visible = false
	if stage_clear_panel and stage_clear_label:
		stage_clear_label.text = "🏆 SPEDIZIONE DEL GRANDE MERIDIANO COMPIUTA! PUNTEGGIO TOTALE: %d PT" % final_stats.get("final_score", 0)
		stage_clear_panel.visible = true
		stage_clear_timer = 15.0

# =========================================================================
# 8. REGION & CAMERA TELEMETRY
# =========================================================================
func update_region(region_name: String):
	if label_region:
		label_region.text = region_name

func update_camera_mode(mode_name: String, _height: float, _dist: float):
	if btn_camera:
		btn_camera.text = " [V] VISTA: %s " % mode_name.to_upper()

func update_telemetry(speed_kmh: float, rpm_norm: float, gear_str: String, fuel_l: float, temp_c: float, pitch_deg: float, roll_deg: float, is_4wd: bool, boost_bar: float, model_info: Dictionary):
	var m_id = model_info.get("id", "panda_4x4")
	var steer_norm = model_info.get("steer_norm", 0.0)
	var tank_max = model_info.get("tank_l", 45.0)
	current_fuel_val = fuel_l
	current_temp_val = temp_c
	current_tank_max = tank_max
	
	if m_id != current_model_id:
		current_model_id = m_id
		if cluster_panda: cluster_panda.visible = (m_id == "panda_4x4")
		if cluster_delta: cluster_delta.visible = (m_id == "delta_integrale")
		if cluster_gwagen: cluster_gwagen.visible = (m_id == "mercedes_gwagen")
		if cluster_127: cluster_127.visible = (m_id == "fiat_127")
		if cluster_golf: cluster_golf.visible = (m_id == "golf_gti_1990")
		if cluster_r4: cluster_r4.visible = (m_id == "renault_4")
		if cluster_bmw: cluster_bmw.visible = (m_id == "bmw_320_e30")
		if cluster_a250: cluster_a250.visible = (m_id == "mercedes_a250")
		if cluster_alfa8c: cluster_alfa8c.visible = (m_id == "alfa_8c")
		if cluster_topolino: cluster_topolino.visible = (m_id == "fiat_topolino")
		if cluster_aurelia: cluster_aurelia.visible = (m_id == "lancia_aurelia")
		if cluster_gta: cluster_gta.visible = (m_id == "alfa_gta")
		if cluster_stratos: cluster_stratos.visible = (m_id == "lancia_stratos")
		if cluster_131: cluster_131.visible = (m_id == "fiat_131_abarth")
		
		# Robust universal fallback: if no specific cluster was matched, default to Fiat 127
		var any_active = (cluster_panda and cluster_panda.visible) or (cluster_delta and cluster_delta.visible) or \
			(cluster_gwagen and cluster_gwagen.visible) or (cluster_127 and cluster_127.visible) or \
			(cluster_golf and cluster_golf.visible) or (cluster_r4 and cluster_r4.visible) or \
			(cluster_bmw and cluster_bmw.visible) or (cluster_a250 and cluster_a250.visible) or \
			(cluster_alfa8c and cluster_alfa8c.visible) or (cluster_topolino and cluster_topolino.visible) or \
			(cluster_aurelia and cluster_aurelia.visible) or (cluster_gta and cluster_gta.visible) or \
			(cluster_stratos and cluster_stratos.visible) or (cluster_131 and cluster_131.visible)
		if not any_active and cluster_127:
			cluster_127.visible = true
		
		if btn_change_car:
			btn_change_car.text = " [C] " + model_info.get("short_name", "AUTO") + " "
			
	# Update Vehicle & Live Surface Adhesion Telemetry
	if label_vehicle_name:
		var v_name = model_info.get("name", "").to_upper()
		var s_surface = model_info.get("surface_name", "ASFALTO")
		var grip_pct = model_info.get("grip_pct", 100)
		label_vehicle_name.text = "%s | FONDO: %s (%d%% ADERENZA)" % [v_name, s_surface, grip_pct]
		
	# Interactive Service Area Prompt Banner
	var in_service_bay = model_info.get("is_in_service_bay", false)
	var s_msg = model_info.get("service_message", "")
	var s_name = model_info.get("service_station_name", "AREA DI SERVIZIO")
	
	if service_prompt_panel and service_prompt_label:
		if s_msg != "":
			service_prompt_panel.visible = true
			service_prompt_label.text = "🔧 " + s_msg
			service_prompt_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55))
		elif in_service_bay:
			service_prompt_panel.visible = true
			service_prompt_label.text = "⛽ %s | PREMI [E] O CLICCA PER RISTORO & TAGLIANDO" % s_name
			service_prompt_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.25))
		else:
			service_prompt_panel.visible = false
			
	# Resource warnings check (Low Fuel or Overheat)
	var is_low_fuel = fuel_l < (tank_max * 0.18)
	var is_overheat = temp_c > 105.0
	if warning_panel and warning_label:
		if is_overheat:
			warning_panel.visible = true
			warning_label.text = "🔥 PERICOLO SURRISCALDAMENTO MOTORE (%.0f°C)! Rallenta o fai sosta tecnica!" % temp_c
		elif is_low_fuel:
			warning_panel.visible = true
			warning_label.text = "⚠️ RISERVA CARBURANTE (%.1f L rimasti)! Raggiungi la stazione Agip / Autogrill!" % fuel_l
		else:
			warning_panel.visible = false
			
	if m_id == "fiat_127":
		update_fiat127_cluster(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, steer_norm, model_info)
	elif m_id == "golf_gti_1990":
		update_golf_cluster(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, steer_norm, model_info)
	elif m_id == "renault_4":
		update_r4_cluster(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, steer_norm, model_info)
	elif m_id == "bmw_320_e30":
		update_bmw_cluster(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, steer_norm, model_info)
	elif m_id == "mercedes_a250":
		update_a250_cluster(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, boost_bar, steer_norm, model_info)
	elif m_id == "delta_integrale":
		update_delta_cluster(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, boost_bar, steer_norm, model_info)
	elif m_id == "mercedes_gwagen":
		update_gwagen_cluster(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, pitch_deg, roll_deg, is_4wd, steer_norm, model_info)
	elif m_id == "alfa_8c":
		update_alfa8c_cluster(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, steer_norm, model_info)
	elif m_id == "fiat_topolino":
		update_topolino_cluster(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, steer_norm, model_info)
	elif m_id == "lancia_aurelia":
		update_aurelia_cluster(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, steer_norm, model_info)
	elif m_id == "alfa_gta":
		update_gta_cluster(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, steer_norm, model_info)
	elif m_id == "lancia_stratos":
		update_stratos_cluster(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, steer_norm, model_info)
	elif m_id == "fiat_131_abarth":
		update_131_cluster(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, steer_norm, model_info)
	elif m_id == "panda_4x4":
		update_panda_cluster(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, pitch_deg, roll_deg, is_4wd, steer_norm, model_info)
	else:
		update_fiat127_cluster(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, steer_norm, model_info)

func update_r4_cluster(speed_kmh: float, _rpm_norm: float, gear_str: String, fuel_l: float, temp_c: float, steer_n: float, _info: Dictionary):
	if r4_speed_gauge:
		r4_speed_gauge.current_value = speed_kmh
		r4_speed_gauge.steer_norm = steer_n
		r4_speed_gauge.gear_text = gear_str
		r4_speed_gauge.aux_value = fuel_l
		r4_speed_gauge.temp_value = temp_c
	if r4_console_gauge:
		r4_console_gauge.gear_text = gear_str

func update_bmw_cluster(speed_kmh: float, rpm_norm: float, gear_str: String, fuel_l: float, temp_c: float, steer_n: float, _info: Dictionary):
	if bmw_speed_gauge:
		bmw_speed_gauge.current_value = speed_kmh
		bmw_speed_gauge.steer_norm = steer_n
		bmw_speed_gauge.gear_text = gear_str
		bmw_speed_gauge.aux_value = fuel_l
		bmw_speed_gauge.temp_value = temp_c
	if bmw_tacho_gauge:
		var rpm_disp = 800.0 + rpm_norm * 6200.0
		bmw_tacho_gauge.current_value = rpm_disp
		bmw_tacho_gauge.temp_value = temp_c
		bmw_tacho_gauge.gear_text = gear_str
	if bmw_console_gauge:
		bmw_console_gauge.gear_text = gear_str

func update_a250_cluster(speed_kmh: float, rpm_norm: float, gear_str: String, fuel_l: float, temp_c: float, boost_bar: float, steer_n: float, _info: Dictionary):
	if a250_cluster_gauge:
		a250_cluster_gauge.current_value = speed_kmh
		a250_cluster_gauge.steer_norm = steer_n
		a250_cluster_gauge.gear_text = gear_str
		a250_cluster_gauge.aux_value = fuel_l
		a250_cluster_gauge.temp_value = temp_c
		a250_cluster_gauge.oil_value = 750.0 + rpm_norm * 5750.0
	if a250_screen_gauge:
		a250_screen_gauge.current_value = boost_bar
		a250_screen_gauge.gear_text = gear_str
	if a250_console_gauge:
		a250_console_gauge.gear_text = gear_str

func update_fiat127_cluster(speed_kmh: float, _rpm_norm: float, gear_str: String, fuel_l: float, temp_c: float, steer_n: float, _info: Dictionary):
	if f_speed_gauge:
		f_speed_gauge.current_value = speed_kmh
		f_speed_gauge.steer_norm = steer_n
		f_speed_gauge.gear_text = gear_str
		f_speed_gauge.aux_value = fuel_l
		f_speed_gauge.temp_value = temp_c
	if f_console_gauge:
		f_console_gauge.gear_text = gear_str

func update_golf_cluster(speed_kmh: float, rpm_norm: float, gear_str: String, fuel_l: float, temp_c: float, steer_n: float, _info: Dictionary):
	if golf_speed_gauge:
		golf_speed_gauge.current_value = speed_kmh
		golf_speed_gauge.steer_norm = steer_n
		golf_speed_gauge.gear_text = gear_str
		golf_speed_gauge.aux_value = fuel_l
		golf_speed_gauge.temp_value = temp_c
	if golf_tacho_gauge:
		var rpm_disp = 950.0 + rpm_norm * 6250.0
		golf_tacho_gauge.current_value = rpm_disp
	if golf_mfa_gauge:
		golf_mfa_gauge.aux_value = fuel_l
		golf_mfa_gauge.temp_value = temp_c
		golf_mfa_gauge.current_value = speed_kmh
	if golf_console_gauge:
		golf_console_gauge.gear_text = gear_str

func update_panda_cluster(speed_kmh: float, rpm_norm: float, gear_str: String, fuel_l: float, _temp_c: float, pitch_deg: float, roll_deg: float, is_4wd: bool, steer_n: float, _info: Dictionary):
	if p_speed_gauge:
		p_speed_gauge.current_value = speed_kmh
		p_speed_gauge.steer_norm = steer_n
		p_speed_gauge.gear_text = gear_str
		p_speed_gauge.aux_value = fuel_l
	if p_tacho_gauge:
		var rpm_disp = 0.85 + rpm_norm * 5.15
		p_tacho_gauge.current_value = rpm_disp
		p_tacho_gauge.is_active = is_4wd
	if p_console_gauge:
		p_console_gauge.is_active = is_4wd
	if p_clino_gauge:
		p_clino_gauge.current_value = pitch_deg
		p_clino_gauge.aux_value = roll_deg

func update_delta_cluster(speed_kmh: float, rpm_norm: float, gear_str: String, fuel_l: float, temp_c: float, boost_bar: float, steer_n: float, _info: Dictionary):
	if d_speed_gauge:
		d_speed_gauge.current_value = speed_kmh
		d_speed_gauge.steer_norm = steer_n
		d_speed_gauge.gear_text = gear_str
		d_speed_gauge.aux_value = fuel_l
		d_speed_gauge.temp_value = temp_c
	if d_tacho_gauge:
		var rpm_actual = 950.0 + rpm_norm * 5850.0
		d_tacho_gauge.current_value = rpm_actual
	if d_turbo_gauge:
		d_turbo_gauge.current_value = boost_bar
	if d_aux_gauge:
		d_aux_gauge.aux_value = fuel_l
		d_aux_gauge.oil_value = 3.8 + (rpm_norm * 3.2)
	if d_check_gauge:
		d_check_gauge.is_active = true

func update_gwagen_cluster(speed_kmh: float, rpm_norm: float, gear_str: String, fuel_l: float, temp_c: float, _pitch_deg: float, _roll_deg: float, is_4wd: bool, steer_n: float, _info: Dictionary):
	if g_speed_gauge:
		g_speed_gauge.current_value = speed_kmh
		g_speed_gauge.steer_norm = steer_n
		g_speed_gauge.gear_text = gear_str
		g_speed_gauge.aux_value = fuel_l
		g_speed_gauge.temp_value = temp_c
	if g_tacho_gauge:
		var rpm_disp = 8.0 + rpm_norm * 52.0
		g_tacho_gauge.current_value = rpm_disp
	if g_kombi_gauge:
		g_kombi_gauge.aux_value = fuel_l
		g_kombi_gauge.temp_value = temp_c
	if g_diffs_gauge:
		g_diffs_gauge.is_active = is_4wd

func _on_change_vehicle_pressed():
	emit_signal("change_vehicle_requested")

func _on_camera_pressed():
	emit_signal("change_camera_requested")

func _on_fullscreen_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func update_street_rod_hud(cash_str: String, rep_val: int):
	if label_hud_cash:
		label_hud_cash.text = "💰 L. " + cash_str
	if label_hud_score:
		label_hud_score.text = "⭐ %d REP" % rep_val

func update_street_rod_mission(mission_info: Dictionary):
	if label_hud_objective:
		if mission_info.is_empty():
			label_hud_objective.text = "🎯 NESSUNA MISSIONE ATTIVA: Scegli un contratto al Garage [G] o Diner [F4]"
		else:
			var tit = mission_info.get("title", "")
			var dst = mission_info.get("destination", "")
			label_hud_objective.text = "🎯 %s | %s" % [tit, dst]

# ==============================================================================
# HISTORIC FLEET CLUSTERS (ALFA 8C, TOPOLINO, AURELIA, ALFA GTA, STRATOS, 131)
# ==============================================================================
func setup_historic_clusters():
	var panel = $Panel
	if not panel: return
	
	var analog_gauge_script = preload("res://scripts/AnalogGauge.gd")
	var g_enum = analog_gauge_script.GaugeType
	
	var build_cluster = func(c_name: String, s_type: int, t_type: int, con_type: int) -> Dictionary:
		var cl = Control.new()
		cl.name = c_name
		cl.visible = false
		cl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		cl.offset_top = 28.0
		cl.offset_bottom = -6.0
		cl.grow_horizontal = 2
		cl.grow_vertical = 2
		panel.add_child(cl)
		
		var cards = HBoxContainer.new()
		cards.name = "Cards"
		cards.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		cards.offset_left = 16.0
		cards.offset_top = 4.0
		cards.offset_right = -16.0
		cards.offset_bottom = -4.0
		cards.grow_horizontal = 2
		cards.grow_vertical = 2
		cards.add_theme_constant_override("separation", 14)
		cards.alignment = BoxContainer.ALIGNMENT_CENTER
		cl.add_child(cards)
		
		var s_gauge = Control.new()
		s_gauge.name = "SpeedGauge"
		s_gauge.set_script(analog_gauge_script)
		s_gauge.set("gauge_type", s_type)
		s_gauge.custom_minimum_size = Vector2(240, 0)
		s_gauge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		s_gauge.size_flags_stretch_ratio = 1.35
		cards.add_child(s_gauge)
		
		var t_gauge = null
		if t_type >= 0:
			t_gauge = Control.new()
			t_gauge.name = "TachoGauge"
			t_gauge.set_script(analog_gauge_script)
			t_gauge.set("gauge_type", t_type)
			t_gauge.custom_minimum_size = Vector2(220, 0)
			t_gauge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			t_gauge.size_flags_stretch_ratio = 1.25
			cards.add_child(t_gauge)
			
		var c_gauge = Control.new()
		c_gauge.name = "ConsoleGauge"
		c_gauge.set_script(analog_gauge_script)
		c_gauge.set("gauge_type", con_type)
		c_gauge.custom_minimum_size = Vector2(200, 0)
		c_gauge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c_gauge.size_flags_stretch_ratio = 1.15
		cards.add_child(c_gauge)
		
		return {"cluster": cl, "speed": s_gauge, "tacho": t_gauge, "console": c_gauge}

	# 9. Alfa 8C 2900B (1931)
	var d8c = build_cluster.call("Alfa8CCluster", g_enum.ALFA8C_SPEEDO, g_enum.ALFA8C_TACHO, g_enum.ALFA8C_CONSOLE)
	cluster_alfa8c = d8c.cluster
	alfa8c_speed_gauge = d8c.speed
	alfa8c_tacho_gauge = d8c.tacho
	alfa8c_console_gauge = d8c.console
	
	# 10. Fiat 500 Topolino (1936)
	var dtop = build_cluster.call("TopolinoCluster", g_enum.TOPOLINO_SPEEDO, -1, g_enum.TOPOLINO_CONSOLE)
	cluster_topolino = dtop.cluster
	topolino_speed_gauge = dtop.speed
	topolino_console_gauge = dtop.console
	
	# 11. Lancia Aurelia B20 GT (1950)
	var daur = build_cluster.call("AureliaCluster", g_enum.AURELIA_SPEEDO, g_enum.AURELIA_TACHO, g_enum.AURELIA_CONSOLE)
	cluster_aurelia = daur.cluster
	aurelia_speed_gauge = daur.speed
	aurelia_tacho_gauge = daur.tacho
	aurelia_console_gauge = daur.console
	
	# 12. Alfa Romeo Giulia Sprint GTA (1965)
	var dgta = build_cluster.call("AlfaGtaCluster", g_enum.ALFAGTA_SPEEDO, g_enum.ALFAGTA_TACHO, g_enum.ALFAGTA_CONSOLE)
	cluster_gta = dgta.cluster
	gta_speed_gauge = dgta.speed
	gta_tacho_gauge = dgta.tacho
	gta_console_gauge = dgta.console
	
	# 13. Lancia Stratos HF Stradale (1973)
	var dstr = build_cluster.call("StratosCluster", g_enum.STRATOS_SPEEDO, g_enum.STRATOS_TACHO, g_enum.STRATOS_CONSOLE)
	cluster_stratos = dstr.cluster
	stratos_speed_gauge = dstr.speed
	stratos_tacho_gauge = dstr.tacho
	stratos_console_gauge = dstr.console
	
	# 14. Fiat 131 Abarth Rally (1976)
	var d131 = build_cluster.call("Fiat131Cluster", g_enum.FIAT131_SPEEDO, g_enum.FIAT131_TACHO, g_enum.FIAT131_CONSOLE)
	cluster_131 = d131.cluster
	f131_speed_gauge = d131.speed
	f131_tacho_gauge = d131.tacho
	f131_console_gauge = d131.console

func update_alfa8c_cluster(speed_kmh: float, rpm_norm: float, gear_str: String, fuel_l: float, temp_c: float, steer_n: float, _info: Dictionary):
	if alfa8c_speed_gauge:
		alfa8c_speed_gauge.current_value = speed_kmh
		alfa8c_speed_gauge.gear_text = gear_str
		alfa8c_speed_gauge.aux_value = fuel_l
		alfa8c_speed_gauge.temp_value = temp_c
		alfa8c_speed_gauge.steer_norm = steer_n
		alfa8c_speed_gauge.queue_redraw()
	if alfa8c_tacho_gauge:
		alfa8c_tacho_gauge.current_value = 850.0 + rpm_norm * 5150.0
		alfa8c_tacho_gauge.queue_redraw()
	if alfa8c_console_gauge:
		alfa8c_console_gauge.steer_norm = steer_n
		alfa8c_console_gauge.queue_redraw()

func update_topolino_cluster(speed_kmh: float, _rpm_norm: float, gear_str: String, fuel_l: float, temp_c: float, steer_n: float, _info: Dictionary):
	if topolino_speed_gauge:
		topolino_speed_gauge.current_value = speed_kmh
		topolino_speed_gauge.gear_text = gear_str
		topolino_speed_gauge.aux_value = fuel_l
		topolino_speed_gauge.temp_value = temp_c
		topolino_speed_gauge.queue_redraw()
	if topolino_console_gauge:
		topolino_console_gauge.steer_norm = steer_n
		topolino_console_gauge.queue_redraw()

func update_aurelia_cluster(speed_kmh: float, rpm_norm: float, gear_str: String, fuel_l: float, temp_c: float, steer_n: float, _info: Dictionary):
	if aurelia_speed_gauge:
		aurelia_speed_gauge.current_value = speed_kmh
		aurelia_speed_gauge.gear_text = gear_str
		aurelia_speed_gauge.aux_value = fuel_l
		aurelia_speed_gauge.temp_value = temp_c
		aurelia_speed_gauge.queue_redraw()
	if aurelia_tacho_gauge:
		aurelia_tacho_gauge.current_value = 800.0 + rpm_norm * 4500.0
		aurelia_tacho_gauge.queue_redraw()
	if aurelia_console_gauge:
		aurelia_console_gauge.steer_norm = steer_n
		aurelia_console_gauge.queue_redraw()

func update_gta_cluster(speed_kmh: float, rpm_norm: float, gear_str: String, fuel_l: float, temp_c: float, steer_n: float, _info: Dictionary):
	if gta_speed_gauge:
		gta_speed_gauge.current_value = speed_kmh
		gta_speed_gauge.gear_text = gear_str
		gta_speed_gauge.aux_value = fuel_l
		gta_speed_gauge.temp_value = temp_c
		gta_speed_gauge.queue_redraw()
	if gta_tacho_gauge:
		gta_tacho_gauge.current_value = 950.0 + rpm_norm * 6850.0
		gta_tacho_gauge.queue_redraw()
	if gta_console_gauge:
		gta_console_gauge.steer_norm = steer_n
		gta_console_gauge.queue_redraw()

func update_stratos_cluster(speed_kmh: float, rpm_norm: float, gear_str: String, fuel_l: float, temp_c: float, steer_n: float, _info: Dictionary):
	if stratos_speed_gauge:
		stratos_speed_gauge.current_value = speed_kmh
		stratos_speed_gauge.gear_text = gear_str
		stratos_speed_gauge.aux_value = fuel_l
		stratos_speed_gauge.temp_value = temp_c
		stratos_speed_gauge.queue_redraw()
	if stratos_tacho_gauge:
		stratos_tacho_gauge.current_value = 1000.0 + rpm_norm * 7500.0
		stratos_tacho_gauge.queue_redraw()
	if stratos_console_gauge:
		stratos_console_gauge.steer_norm = steer_n
		stratos_console_gauge.queue_redraw()

func update_131_cluster(speed_kmh: float, rpm_norm: float, gear_str: String, fuel_l: float, temp_c: float, steer_n: float, _info: Dictionary):
	if f131_speed_gauge:
		f131_speed_gauge.current_value = speed_kmh
		f131_speed_gauge.gear_text = gear_str
		f131_speed_gauge.aux_value = fuel_l
		f131_speed_gauge.temp_value = temp_c
		f131_speed_gauge.queue_redraw()
	if f131_tacho_gauge:
		f131_tacho_gauge.current_value = 950.0 + rpm_norm * 6850.0
		f131_tacho_gauge.queue_redraw()
	if f131_console_gauge:
		f131_console_gauge.steer_norm = steer_n
		f131_console_gauge.queue_redraw()


