extends Control
class_name StreetRodUI

# ==============================================================================
# VALICO DEI MOTORI '93 - STREET ROD AMIGA 500 RETRO INTERFACE
# ==============================================================================
# Distinctive Commodore Amiga 500 / Deluxe Paint aesthetic:
# - Beveled metallic borders, deep workbench slate & parchment tones
# - High-contrast retro typography with glowing gold & amber accents
# - 5 Distinct Full-Feature Screens:
#   1. [F1] Il Mercatino '93 (Newspaper classifieds, buying & selling cars)
#   2. [F2] Officina & Tuning (Car slots, repairs, tires, engine tuning, paint)
#   3. [F3] Diner "Da Bepi" (Hangout, characters, dialogue, story lore)
#   4. [F4] Drag Strip (1/4 mile start lights, reaction timing, bets & pink slips)
#   5. [F5/M] Contratti & Mappa (Travel missions, deliveries, barn finds)
# ==============================================================================

signal request_close
signal car_model_changed(model_id: String)
signal upgrades_applied(upgrades: Dictionary)
signal race_start_requested(rival_id: String, is_pink_slip: bool)
signal garage_inspection_view_requested(view_type: String)

var street_rod_manager: Node = null
var vehicle: Node = null

# Dynamic Responsive Styling
var bg_dim: ColorRect = null
var sb_amiga_panel: StyleBoxFlat = null
var sb_content_panel: StyleBoxFlat = null

func play_click_sfx():
	if vehicle and vehicle.get("audio_engine"):
		var ae = vehicle.audio_engine
		if ae and ae.has_method("play_ui_click"):
			ae.play_ui_click()

func play_ratchet_sfx():
	if vehicle and vehicle.get("audio_engine"):
		var ae = vehicle.audio_engine
		if ae and ae.has_method("play_ratchet_wrench"):
			ae.play_ratchet_wrench()

func play_cash_sfx():
	if vehicle and vehicle.get("audio_engine"):
		var ae = vehicle.audio_engine
		if ae and ae.has_method("play_cash_register"):
			ae.play_cash_register()

# Dyno Bench Live Vector Graph (Banco Prova a Rulli)
var dyno_graph: DynoGraphControl = null

class DynoGraphControl extends Control:
	var peak_power_cv: float = 47.0
	var peak_power_rpm: float = 5600.0
	var peak_torque_nm: float = 65.0
	var peak_torque_rpm: float = 3000.0
	var max_rpm: float = 7500.0
	var is_sweeping: bool = false
	var sweep_rpm: float = 1000.0
	var sweep_time: float = 0.0
	var live_cv: float = 0.0
	var live_nm: float = 0.0

	func _init():
		custom_minimum_size = Vector2(380, 190)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL

	func update_from_car(car_data: Dictionary):
		var parts = car_data.get("tuning_parts", [])
		var base_p = 47.0
		var base_t = 65.0
		var p_rpm = 5600.0
		var t_rpm = 3000.0
		
		var car_id = car_data.get("car_id", "fiat_127")
		match car_id:
			"fiat_127": base_p = 47.0; base_t = 65.0; p_rpm = 5600.0; t_rpm = 3000.0
			"panda_4x4": base_p = 50.0; base_t = 70.0; p_rpm = 5500.0; t_rpm = 3200.0
			"renault_4": base_p = 34.0; base_t = 58.0; p_rpm = 4500.0; t_rpm = 2500.0
			"delta_hf": base_p = 210.0; base_t = 304.0; p_rpm = 5750.0; t_rpm = 3500.0
			"golf_gti": base_p = 112.0; base_t = 155.0; p_rpm = 6100.0; t_rpm = 3800.0
			"alfa_giulia": base_p = 115.0; base_t = 142.0; p_rpm = 6000.0; t_rpm = 3000.0
			_: base_p = 50.0; base_t = 70.0
			
		var add_hp = 0.0
		var add_tq = 0.0
		if parts.has("carburatori_doppi"): add_hp += 8.0; add_tq += 10.0
		if parts.has("scarico_sport"): add_hp += 5.0; add_tq += 7.0
		if parts.has("accensione_corsa"): add_hp += 2.0; add_tq += 3.0
		if parts.has("overboost_turbo"): add_hp += 35.0; add_tq += 45.0
		if parts.has("camme_spinte"): add_hp += 12.0; add_tq += 8.0; p_rpm += 500.0
		
		peak_power_cv = base_p + add_hp
		peak_torque_nm = base_t + add_tq
		peak_power_rpm = p_rpm
		peak_torque_rpm = t_rpm
		max_rpm = max(7000.0, peak_power_rpm + 1500.0)
		queue_redraw()

	func start_sweep():
		is_sweeping = true
		sweep_time = 0.0
		sweep_rpm = 1000.0

	func _process(delta: float):
		if is_sweeping:
			sweep_time += delta
			sweep_rpm = lerp(1000.0, max_rpm, sweep_time / 2.2)
			live_cv = calculate_cv_at(sweep_rpm)
			live_nm = calculate_nm_at(sweep_rpm)
			if sweep_time >= 2.2:
				is_sweeping = false
			queue_redraw()

	func calculate_cv_at(rpm: float) -> float:
		var factor = 0.0
		if rpm < 1000.0: factor = 0.2
		elif rpm <= peak_power_rpm:
			factor = 0.2 + 0.8 * pow((rpm - 1000.0) / (peak_power_rpm - 1000.0), 1.25)
		else:
			factor = 1.0 - 0.35 * ((rpm - peak_power_rpm) / (max_rpm - peak_power_rpm))
		return clamp(factor * peak_power_cv, 5.0, peak_power_cv * 1.05)

	func calculate_nm_at(rpm: float) -> float:
		var factor = 0.0
		if rpm < 1000.0: factor = 0.45
		elif rpm <= peak_torque_rpm:
			factor = 0.45 + 0.55 * ((rpm - 1000.0) / (peak_torque_rpm - 1000.0))
		else:
			factor = 1.0 - 0.40 * ((rpm - peak_torque_rpm) / (max_rpm - peak_torque_rpm))
		return clamp(factor * peak_torque_nm, 10.0, peak_torque_nm * 1.05)

	func _draw():
		var w = size.x
		var h = size.y
		var m_left = 38.0
		var m_right = 16.0
		var m_top = 22.0
		var m_bottom = 24.0
		var gw = w - m_left - m_right
		var gh = h - m_top - m_bottom
		if gw <= 10 or gh <= 10: return
		
		# Beveled CRT Outer & Inner Screen
		draw_rect(Rect2(0, 0, w, h), Color(0.04, 0.06, 0.09, 0.95))
		draw_rect(Rect2(m_left, m_top, gw, gh), Color(0.02, 0.03, 0.05, 1.0))
		
		var max_disp_val = max(peak_power_cv, peak_torque_nm) * 1.25
		max_disp_val = max(max_disp_val, 80.0)
		
		var font = ThemeDB.fallback_font
		var font_size = 8
		
		# Horizontal grid lines (Power/Torque)
		for i in range(5):
			var frac = float(i) / 4.0
			var y_pos = m_top + gh * (1.0 - frac)
			draw_line(Vector2(m_left, y_pos), Vector2(m_left + gw, y_pos), Color(0.12, 0.20, 0.28, 0.65), 1.0)
			var val_str = "%d" % int(frac * max_disp_val)
			draw_string(font, Vector2(4, y_pos + 3), val_str, HORIZONTAL_ALIGNMENT_RIGHT, 30, font_size, Color(0.55, 0.68, 0.78))
			
		# Vertical grid lines (RPM)
		var num_rpm_steps = int(max_rpm / 1000.0)
		for r in range(1, num_rpm_steps + 1):
			var rpm_val = float(r) * 1000.0
			var x_pos = m_left + ((rpm_val - 1000.0) / (max_rpm - 1000.0)) * gw
			if x_pos >= m_left and x_pos <= m_left + gw:
				draw_line(Vector2(x_pos, m_top), Vector2(x_pos, m_top + gh), Color(0.12, 0.20, 0.28, 0.65), 1.0)
				draw_string(font, Vector2(x_pos - 12, m_top + gh + 13), "%dk" % r, HORIZONTAL_ALIGNMENT_CENTER, 24, font_size, Color(0.55, 0.68, 0.78))
				
		# Plot Torque Curve (Cyan) & Power Curve (Orange/Red)
		var pts_torque: PackedVector2Array = []
		var pts_power: PackedVector2Array = []
		var steps = 50
		for s in range(steps + 1):
			var rpm = 1000.0 + (max_rpm - 1000.0) * (float(s) / float(steps))
			var x_p = m_left + (float(s) / float(steps)) * gw
			
			var tq = calculate_nm_at(rpm)
			var y_tq = m_top + gh * (1.0 - (tq / max_disp_val))
			pts_torque.append(Vector2(x_p, clamp(y_tq, m_top, m_top + gh)))
			
			var hp = calculate_cv_at(rpm)
			var y_hp = m_top + gh * (1.0 - (hp / max_disp_val))
			pts_power.append(Vector2(x_p, clamp(y_hp, m_top, m_top + gh)))
			
		if pts_torque.size() >= 2:
			draw_polyline(pts_torque, Color(0.20, 0.80, 1.00, 0.95), 2.2, true)
		if pts_power.size() >= 2:
			draw_polyline(pts_power, Color(1.00, 0.40, 0.15, 0.95), 2.5, true)
			
		# Header & Peak Readouts
		var head_text = "BANCO RULLI DYNO: 🔴 POTENZA: %d CV @ %d RPM | 🔵 COPPIA: %d Nm @ %d RPM" % [
			int(peak_power_cv), int(peak_power_rpm), int(peak_torque_nm), int(peak_torque_rpm)
		]
		draw_string(font, Vector2(m_left, 15), head_text, HORIZONTAL_ALIGNMENT_LEFT, gw, 9, Color(1.0, 0.90, 0.35))
		
		# If sweeping, draw vertical scanner needle
		if is_sweeping:
			var sweep_x = m_left + ((sweep_rpm - 1000.0) / (max_rpm - 1000.0)) * gw
			draw_line(Vector2(sweep_x, m_top), Vector2(sweep_x, m_top + gh), Color(1.0, 1.0, 0.3, 0.90), 1.5)
			var sweep_tag = "%d RPM | %.0f CV | %.0f Nm" % [int(sweep_rpm), live_cv, live_nm]
			draw_string(font, Vector2(clamp(sweep_x - 35, m_left, m_left + gw - 85), m_top + 16), sweep_tag, HORIZONTAL_ALIGNMENT_LEFT, 120, 8, Color.YELLOW)

# Main Overlay Container
var is_open: bool = false
var current_tab: int = 0 # 0=Hub/Garage, 1=Workshop, 2=Market, 3=Diner, 4=Drag, 5=Map

# Interactive Workshop Hotspot State (Street Rod Style)
var current_workshop_bay: String = "engine" # "engine", "wheels", "body", "cockpit"
var workshop_workbench_vbox: VBoxContainer = null
var workshop_hotspot_buttons: Dictionary = {}
var onboarding_modal: PanelContainer = null
var has_seen_onboarding: bool = false
var workshop_bay_title_label: Label = null

# UI References
var modal_panel: PanelContainer
var top_banner_label: Label
var stats_cash_label: Label
var stats_rep_label: Label
var stats_car_label: Label

var tab_buttons: Array = []
var tab_containers: Array = []

# Hub & Character View references
var hub_profile_name_label: Label
var hub_profile_role_label: Label
var hub_profile_license_label: Label
var hub_profile_rank_label: Label
var hub_profile_rep_bar: ProgressBar
var hub_profile_cash_label: Label
var hub_skill_mech_bar: ProgressBar
var hub_skill_handling_bar: ProgressBar
var hub_skill_altitude_bar: ProgressBar
var hub_stats_km_label: Label
var hub_stats_races_label: Label
var hub_stats_missions_label: Label
var hub_stats_top_speed_label: Label

var hub_garage_slots_hbox: HBoxContainer
var hub_car_name_label: Label
var hub_car_plate_label: Label
var hub_car_specs_label: Label
var hub_car_tuning_label: Label
var hub_car_eng_bar: ProgressBar
var hub_car_body_bar: ProgressBar
var hub_car_tire_bar: ProgressBar
var hub_car_fuel_bar: ProgressBar
var hub_btn_drive_car: Button

var hub_active_mission_title: Label
var hub_active_mission_client: Label
var hub_active_mission_desc: Label
var hub_active_mission_dest: Label
var hub_active_mission_reward: Label
var hub_active_mission_badge: Label
var hub_other_missions_vbox: VBoxContainer
var hub_selected_car_idx: int = 0

# Notification Toast Box
var toast_panel: PanelContainer
var toast_label: Label
var toast_timer: float = 0.0

# Drag Race Interactive State
var drag_state: String = "idle" # "idle", "countdown", "racing", "finished"
var drag_timer: float = 0.0
var drag_light_idx: int = 0
var drag_rival_id: String = "gino"
var drag_is_pink_slip: bool = false
var drag_reaction_start: float = 0.0
var drag_player_reaction: float = 0.0
var drag_lights_rects: Array = []
var drag_log_label: Label

func _ready():
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	setup_amiga_interface()
	
	if street_rod_manager:
		street_rod_manager.career_updated.connect(on_career_updated)
		street_rod_manager.notification_posted.connect(show_toast)
		street_rod_manager.car_switched.connect(on_car_switched)

func _process(delta: float):
	if toast_timer > 0.0:
		toast_timer -= delta
		if toast_timer <= 0.0 and toast_panel:
			toast_panel.visible = false
			
	if is_open and current_tab == 4 and drag_state == "countdown":
		update_drag_countdown(delta)

func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if is_open:
				close_screen()
		elif event.keycode == KEY_F1 or event.keycode == KEY_G:
			open_screen(0)
		elif event.keycode == KEY_F2:
			open_screen(1)
		elif event.keycode == KEY_F3:
			open_screen(2)
		elif event.keycode == KEY_F4:
			open_screen(3)
		elif event.keycode == KEY_F5:
			open_screen(4)
		elif event.keycode == KEY_F6 or event.keycode == KEY_M:
			open_screen(5)
		elif event.keycode == KEY_SPACE and is_open and current_tab == 0:
			close_screen()
		elif event.keycode == KEY_SPACE and is_open and current_tab == 4 and drag_state == "racing":
			on_drag_launch_trigger()

var is_interface_setup: bool = false

func setup_amiga_interface():
	if is_interface_setup: return
	is_interface_setup = true
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Full screen dim: trasparente in officina 3D, scuro negli altri menu
	bg_dim = ColorRect.new()
	bg_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg_dim.color = Color(0.0, 0.0, 0.0, 0.0)
	add_child(bg_dim)
	
	# Full-Viewport Responsive Master Panel (Adattabile a qualsiasi risoluzione!)
	modal_panel = PanelContainer.new()
	modal_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal_panel.offset_left = 12.0
	modal_panel.offset_top = 8.0
	modal_panel.offset_right = -12.0
	modal_panel.offset_bottom = -8.0
	modal_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Beveled Amiga StyleBox (Dinamico)
	sb_amiga_panel = StyleBoxFlat.new()
	sb_amiga_panel.bg_color = Color(0.0, 0.0, 0.0, 0.0) # Trasparente in garage per vedere l'auto 3D
	sb_amiga_panel.border_color = Color(0.12, 0.45, 0.85, 0.90)
	sb_amiga_panel.set_border_width_all(0)
	sb_amiga_panel.set_corner_radius_all(8)
	modal_panel.add_theme_stylebox_override("panel", sb_amiga_panel)
	add_child(modal_panel)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_theme_constant_override("separation", 6)
	modal_panel.add_child(main_vbox)
	
	# --- 1. AMIGA TOP TITLE & CAREER BANNER ---
	var banner_box = PanelContainer.new()
	var sb_banner = StyleBoxFlat.new()
	sb_banner.bg_color = Color(0.0, 0.32, 0.65, 0.95) # Royal Amiga Header Blue
	sb_banner.border_color = Color(0.95, 0.75, 0.15, 0.90) # Gold pinstripe
	sb_banner.border_width_bottom = 2
	sb_banner.set_corner_radius_all(4)
	banner_box.add_theme_stylebox_override("panel", sb_banner)
	main_vbox.add_child(banner_box)
	
	var banner_hbox = HBoxContainer.new()
	banner_hbox.add_theme_constant_override("separation", 16)
	banner_box.add_child(banner_hbox)
	
	top_banner_label = Label.new()
	top_banner_label.text = " [COMMODORE AMIGA 500] 🚗 IL VALICO DEI MOTORI '93 - STREET ROD ITALIA"
	top_banner_label.add_theme_font_size_override("font_size", 14)
	top_banner_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	banner_hbox.add_child(top_banner_label)
	
	var sp_b = Control.new()
	sp_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	banner_hbox.add_child(sp_b)
	
	var btn_close = Button.new()
	btn_close.text = " [X] ESCI ALLA GUIDA [SPAZIO] "
	btn_close.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
	btn_close.pressed.connect(close_screen)
	banner_hbox.add_child(btn_close)
	
	# --- 2. CAREER METRICS HUD BAR ---
	var metrics_panel = PanelContainer.new()
	var sb_met = StyleBoxFlat.new()
	sb_met.bg_color = Color(0.04, 0.05, 0.07, 0.90)
	sb_met.border_color = Color(0.20, 0.25, 0.35)
	sb_met.set_border_width_all(1)
	metrics_panel.add_theme_stylebox_override("panel", sb_met)
	main_vbox.add_child(metrics_panel)
	
	var met_hbox = HBoxContainer.new()
	met_hbox.add_theme_constant_override("separation", 24)
	metrics_panel.add_child(met_hbox)
	
	stats_cash_label = Label.new()
	stats_cash_label.text = " 💰 LIRE: L. 3.500.000"
	stats_cash_label.add_theme_font_size_override("font_size", 13)
	stats_cash_label.add_theme_color_override("font_color", Color(0.40, 1.0, 0.50))
	met_hbox.add_child(stats_cash_label)
	
	stats_rep_label = Label.new()
	stats_rep_label.text = " ⭐ RISPETTO: 40 [Novellino dei Fondovalle]"
	stats_rep_label.add_theme_font_size_override("font_size", 13)
	stats_rep_label.add_theme_color_override("font_color", Color(1.0, 0.75, 0.20))
	met_hbox.add_child(stats_rep_label)
	
	stats_car_label = Label.new()
	stats_car_label.text = " 🏎️ IN USO: Fiat 127 Special"
	stats_car_label.add_theme_font_size_override("font_size", 13)
	stats_car_label.add_theme_color_override("font_color", Color(0.85, 0.90, 0.95))
	met_hbox.add_child(stats_car_label)
	
	# --- 3. AMIGA NAVIGATION TABS BAR ---
	var tabs_hbox = HBoxContainer.new()
	tabs_hbox.add_theme_constant_override("separation", 6)
	main_vbox.add_child(tabs_hbox)
	
	var tab_names = [
		" [F1] 🏠 IL TUO GARAGE & CARRIERA ",
		" [F2] 🔧 OFFICINA & TUNING ",
		" [F3] 📰 IL MERCATINO '93 ",
		" [F4] 🍔 DINER 'DA BEPI' ",
		" [F5] 🏁 RETTIFILO DRAG ",
		" [F6] 🗺️ CARTA TOPOGRAFICA "
	]
	
	for i in range(tab_names.size()):
		var btn = Button.new()
		btn.text = tab_names[i]
		btn.add_theme_font_size_override("font_size", 11)
		var t_idx = i
		btn.pressed.connect(func(): switch_tab(t_idx))
		tabs_hbox.add_child(btn)
		tab_buttons.append(btn)
		
	# --- 4. CONTENT AREA (SWITCHABLE PANELS) ---
	var content_holder = PanelContainer.new()
	content_holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sb_content_panel = StyleBoxFlat.new()
	sb_content_panel.bg_color = Color(0.0, 0.0, 0.0, 0.0) # Trasparente in garage per vedere la scena 3D
	sb_content_panel.border_color = Color(0.20, 0.35, 0.55)
	sb_content_panel.set_border_width_all(0)
	sb_content_panel.set_corner_radius_all(6)
	content_holder.add_theme_stylebox_override("panel", sb_content_panel)
	main_vbox.add_child(content_holder)
	
	# Build the 6 views (Tab 0 is the Hub!)
	var view_hub = build_hub_view()
	var view_garage = build_garage_view()
	var view_market = build_market_view()
	var view_diner = build_diner_view()
	var view_drag = build_drag_view()
	var view_missions = build_missions_view()
	
	content_holder.add_child(view_hub)
	content_holder.add_child(view_garage)
	content_holder.add_child(view_market)
	content_holder.add_child(view_diner)
	content_holder.add_child(view_drag)
	content_holder.add_child(view_missions)
	
	tab_containers = [view_hub, view_garage, view_market, view_diner, view_drag, view_missions]
	
	# --- 5. TOAST NOTIFICATION & ONBOARDING CONTAINERS ---
	setup_toast_panel()
	setup_onboarding_modal()
	
	switch_tab(0)

# ==============================================================================
# TAB 0: 🏠 IL TUO GARAGE & CARRIERA (HUB DI ACCOGLIENZA STREET ROD)
# ==============================================================================
func build_hub_view() -> Control:
	var root_vbox = VBoxContainer.new()
	root_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.add_theme_constant_override("separation", 6)
	
	# 1. Top Welcome Header & Enamel Sign
	var welcome_panel = PanelContainer.new()
	var sb_w = StyleBoxFlat.new()
	sb_w.bg_color = Color(0.08, 0.12, 0.18, 0.95)
	sb_w.border_color = Color(0.95, 0.75, 0.20, 0.90)
	sb_w.border_width_bottom = 2
	sb_w.set_corner_radius_all(4)
	welcome_panel.add_theme_stylebox_override("panel", sb_w)
	root_vbox.add_child(welcome_panel)
	
	var w_hbox = HBoxContainer.new()
	w_hbox.add_theme_constant_override("separation", 12)
	welcome_panel.add_child(w_hbox)
	
	var lbl_w_title = Label.new()
	lbl_w_title.text = " 🇮🇹 OFFICINA MECCANICA PAOLO - VALICO DEI MOTORI '93"
	lbl_w_title.add_theme_font_size_override("font_size", 11)
	lbl_w_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	w_hbox.add_child(lbl_w_title)
	
	var btn_guide = Button.new()
	btn_guide.text = " 📖 GUIDA & MANUALE ACCOGLIENZA PILOTA "
	btn_guide.add_theme_font_size_override("font_size", 9)
	btn_guide.add_theme_color_override("font_color", Color(1.0, 0.90, 0.40))
	btn_guide.pressed.connect(show_onboarding_guide)
	w_hbox.add_child(btn_guide)
	
	var sp_w = Control.new()
	sp_w.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	w_hbox.add_child(sp_w)
	
	var lbl_w_date = Label.new()
	lbl_w_date.text = "Venerdì 8 Ottobre 1993 | Cielo Sereno al Passo delle Alpi ⛅"
	lbl_w_date.add_theme_font_size_override("font_size", 9)
	lbl_w_date.add_theme_color_override("font_color", Color(0.75, 0.85, 0.95))
	w_hbox.add_child(lbl_w_date)
	
	# 2. Main 2-Column Split: Left = Car Schematic & Hotspots | Right = Active Workbench & Tuning
	var cols_hbox = HBoxContainer.new()
	cols_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cols_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cols_hbox.add_theme_constant_override("separation", 10)
	root_vbox.add_child(cols_hbox)
	
	# =========================================================================
	# COLUMN 1: SCHEMA INTERATTIVO OFFICINA (HOTSPOTS STREET ROD) - DOCK SINISTRO
	# =========================================================================
	var col1_p = PanelContainer.new()
	col1_p.custom_minimum_size = Vector2(340, 0)
	col1_p.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	col1_p.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var sb_c1 = StyleBoxFlat.new()
	sb_c1.bg_color = Color(0.06, 0.08, 0.12, 0.95)
	sb_c1.border_color = Color(0.25, 0.38, 0.55)
	sb_c1.set_border_width_all(1)
	sb_c1.set_corner_radius_all(6)
	col1_p.add_theme_stylebox_override("panel", sb_c1)
	cols_hbox.add_child(col1_p)
	
	var col1_vb = VBoxContainer.new()
	col1_vb.add_theme_constant_override("separation", 5)
	col1_p.add_child(col1_vb)
	
	var hs_head = Label.new()
	hs_head.text = "🚘 SCHEMA MECCANICO - CLICCA IN UN PUNTO DELL'AUTO:"
	hs_head.add_theme_font_size_override("font_size", 10)
	hs_head.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	col1_vb.add_child(hs_head)
	
	# Scroll for Hotspot Cards
	var hs_scroll = ScrollContainer.new()
	hs_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col1_vb.add_child(hs_scroll)
	
	var hs_vb = VBoxContainer.new()
	hs_vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hs_vb.add_theme_constant_override("separation", 5)
	hs_scroll.add_child(hs_vb)
	
	# Hotspot 1: Vano Motore
	var btn_hs_eng = create_hotspot_card("engine", "🔧 VANO MOTORE & WEBER (Cofano)", "Doppi carburatori Weber DCOE, scarico 4-in-1, candele da corsa, tagliando Agip, turbo overboost.", Color(0.95, 0.55, 0.15))
	hs_vb.add_child(btn_hs_eng)
	workshop_hotspot_buttons["engine"] = btn_hs_eng
	
	# Hotspot 2: Ruote & Assetto
	var btn_hs_whl = create_hotspot_card("wheels", "🛞 PNEUMATICI, ASSETTO & FRENI (Ponte)", "Pirelli P7 Corsa, Chiodate da Neve, cerchi in lega Cromodora/BBS, pastiglie Brembo.", Color(0.25, 0.75, 1.0))
	hs_vb.add_child(btn_hs_whl)
	workshop_hotspot_buttons["wheels"] = btn_hs_whl
	
	# Hotspot 3: Carrozzeria & Cabina Forno
	var btn_hs_bod = create_hotspot_card("body", "🎨 CARROZZERIA & FORNO (Verniciatura)", "Tinte d'epoca italiane, alleggerimento Street Rod (togli paraurti -18kg), stuccatura ruggine.", Color(0.35, 1.0, 0.45))
	hs_vb.add_child(btn_hs_bod)
	workshop_hotspot_buttons["body"] = btn_hs_bod
	
	# Hotspot 4: Abitacolo & Cambio
	var btn_hs_cpt = create_hotspot_card("cockpit", "🕹️ ABITACOLO & TRASMISSIONE (Interni)", "Cambio 5 marce Bacci ravvicinato, frizione in rame, volante sportivo Momo, roll-bar.", Color(1.0, 0.85, 0.25))
	hs_vb.add_child(btn_hs_cpt)
	workshop_hotspot_buttons["cockpit"] = btn_hs_cpt
	
	# Hotspot 5: Giornale Usato
	var btn_hs_mkt = create_action_card("📰 IL MERCATINO DELLE RUOTE '93 (Giornale)", "Compra e vendi auto usate sul giornale del Valico (Panda 4x4, Delta HF, Golf GTI...).", func(): switch_tab(2))
	hs_vb.add_child(btn_hs_mkt)
	
	# Hotspot 6: Sfide Drag
	var btn_hs_drg = create_action_card("🏁 SFIDE AL RETTIFILO 400M & DINER", "Sfide di accelerazione contro Gino, Kurt o Bepi al semaforo a soldi o a libretto!", func(): switch_tab(4))
	hs_vb.add_child(btn_hs_drg)
	
	# Hotspot 7: Portone Uscita
	var btn_hs_drv = create_action_card("🚪 PORTONE GARAGE: ESCI E COLLAUDA", "Apri il portone scorrevole ed esci a collaudare l'auto sui tornanti delle Alpi!", func(): close_screen())
	hs_vb.add_child(btn_hs_drv)
	
	# Parco Auto Slots Bar in Bottom of Col 1
	var g_slots_lbl = Label.new()
	g_slots_lbl.text = "PARCO AUTO NEL BOX (SELEZIONA PER METTERE SUI CAVALLETTI):"
	g_slots_lbl.add_theme_font_size_override("font_size", 8)
	g_slots_lbl.add_theme_color_override("font_color", Color(0.70, 0.80, 0.90))
	col1_vb.add_child(g_slots_lbl)
	
	hub_garage_slots_hbox = HBoxContainer.new()
	hub_garage_slots_hbox.add_theme_constant_override("separation", 4)
	col1_vb.add_child(hub_garage_slots_hbox)
	
	# =========================================================================
	# CENTRO: VISTA 3D APERTA SULL'AUTO + HERO LAUNCH BUTTON IN BASSO
	# =========================================================================
	var center_open = VBoxContainer.new()
	center_open.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_open.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cols_hbox.add_child(center_open)
	
	var sp_c = Control.new()
	sp_c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_open.add_child(sp_c)
	
	# Hero Launch Button al centro in basso (Glow verde smeraldo)
	var launch_card = PanelContainer.new()
	var sb_lc = StyleBoxFlat.new()
	sb_lc.bg_color = Color(0.04, 0.08, 0.12, 0.88)
	sb_lc.border_color = Color(0.20, 0.90, 0.45, 0.95)
	sb_lc.set_border_width_all(2)
	sb_lc.set_corner_radius_all(8)
	sb_lc.shadow_size = 18
	sb_lc.shadow_color = Color(0.0, 0.8, 0.3, 0.35)
	launch_card.add_theme_stylebox_override("panel", sb_lc)
	center_open.add_child(launch_card)
	
	var lc_vb = VBoxContainer.new()
	lc_vb.add_theme_constant_override("separation", 4)
	launch_card.add_child(lc_vb)
	
	var btn_hero_start = Button.new()
	btn_hero_start.text = " 🟢 METTI IN MOTO ED ESCI SUL TRACCIATO [SPAZIO] "
	btn_hero_start.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_hero_start.add_theme_font_size_override("font_size", 13)
	btn_hero_start.add_theme_color_override("font_color", Color(0.25, 1.0, 0.45))
	btn_hero_start.pressed.connect(func(): close_screen())
	lc_vb.add_child(btn_hero_start)
	
	# =========================================================================
	# COLUMN 2: BANCO DI LAVORO ATTIVO & SCHEDA TECNICA - DOCK DESTRO
	# =========================================================================
	var col2_p = PanelContainer.new()
	col2_p.custom_minimum_size = Vector2(430, 0)
	col2_p.size_flags_horizontal = Control.SIZE_SHRINK_END
	col2_p.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var sb_c2 = StyleBoxFlat.new()
	sb_c2.bg_color = Color(0.06, 0.08, 0.12, 0.95)
	sb_c2.border_color = Color(0.25, 0.45, 0.65)
	sb_c2.set_border_width_all(1)
	sb_c2.set_corner_radius_all(6)
	col2_p.add_theme_stylebox_override("panel", sb_c2)
	cols_hbox.add_child(col2_p)
	
	var col2_vb = VBoxContainer.new()
	col2_vb.add_theme_constant_override("separation", 6)
	col2_p.add_child(col2_vb)
	
	workshop_bay_title_label = Label.new()
	workshop_bay_title_label.text = "⚡ BANCO DI LAVORO ATTIVO: VANO MOTORE"
	workshop_bay_title_label.add_theme_font_size_override("font_size", 11)
	workshop_bay_title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	col2_vb.add_child(workshop_bay_title_label)
	
	# Active Workbench Container (Dynamically Populated)
	var wb_scroll = ScrollContainer.new()
	wb_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col2_vb.add_child(wb_scroll)
	
	workshop_workbench_vbox = VBoxContainer.new()
	workshop_workbench_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	workshop_workbench_vbox.add_theme_constant_override("separation", 6)
	wb_scroll.add_child(workshop_workbench_vbox)
	
	# Bottom Summary Card: Selected Car & Pilot Credentials
	var summ_card = PanelContainer.new()
	var sb_sc = StyleBoxFlat.new()
	sb_sc.bg_color = Color(0.04, 0.05, 0.08)
	sb_sc.border_color = Color(0.20, 0.30, 0.45)
	sb_sc.set_border_width_all(1)
	sb_sc.set_corner_radius_all(4)
	summ_card.add_theme_stylebox_override("panel", sb_sc)
	col2_vb.add_child(summ_card)
	
	var sc_vb = VBoxContainer.new()
	sc_vb.add_theme_constant_override("separation", 2)
	summ_card.add_child(sc_vb)
	
	hub_car_name_label = Label.new()
	hub_car_name_label.text = "🚘 FIAT 127 SPECIAL (1974)"
	hub_car_name_label.add_theme_font_size_override("font_size", 10)
	hub_car_name_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	sc_vb.add_child(hub_car_name_label)
	
	hub_car_plate_label = Label.new()
	hub_car_plate_label.text = "Targa: VR-482104 | Colore: Verde Muschio"
	hub_car_plate_label.add_theme_font_size_override("font_size", 8)
	hub_car_plate_label.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
	sc_vb.add_child(hub_car_plate_label)
	
	hub_car_specs_label = Label.new()
	hub_car_specs_label.text = "Motore 903cc | Trazione Anteriore | Gomme Michelin Touring"
	hub_car_specs_label.add_theme_font_size_override("font_size", 8)
	hub_car_specs_label.add_theme_color_override("font_color", Color(0.65, 0.75, 0.85))
	sc_vb.add_child(hub_car_specs_label)
	
	hub_car_tuning_label = Label.new()
	hub_car_tuning_label.text = "Elaborazioni: Scarico Sportivo & Collettori 4-in-1"
	hub_car_tuning_label.add_theme_font_size_override("font_size", 8)
	hub_car_tuning_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
	sc_vb.add_child(hub_car_tuning_label)
	
	# Action buttons for active car
	var c_act_hb = HBoxContainer.new()
	c_act_hb.add_theme_constant_override("separation", 6)
	sc_vb.add_child(c_act_hb)
	
	hub_btn_drive_car = Button.new()
	hub_btn_drive_car.text = "🏎️ GUIDA QUESTA AUTO"
	hub_btn_drive_car.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hub_btn_drive_car.add_theme_font_size_override("font_size", 9)
	hub_btn_drive_car.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	hub_btn_drive_car.pressed.connect(func(): on_hub_drive_car_pressed())
	c_act_hb.add_child(hub_btn_drive_car)
	
	render_active_workbench()
	return root_vbox

func create_hotspot_card(bay_id: String, title: String, desc: String, accent_color: Color) -> PanelContainer:
	var card = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	var is_sel = (current_workshop_bay == bay_id)
	sb.bg_color = Color(0.12, 0.16, 0.22) if is_sel else Color(0.06, 0.08, 0.11)
	sb.border_color = accent_color if is_sel else Color(0.20, 0.28, 0.38)
	sb.set_border_width_all(2 if is_sel else 1)
	sb.set_corner_radius_all(4)
	card.add_theme_stylebox_override("panel", sb)
	
	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 2)
	card.add_child(vb)
	
	var btn = Button.new()
	btn.text = title
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.add_theme_font_size_override("font_size", 10)
	btn.add_theme_color_override("font_color", accent_color)
	btn.pressed.connect(func(): select_workshop_bay(bay_id))
	vb.add_child(btn)
	
	var l_desc = Label.new()
	l_desc.text = desc
	l_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l_desc.add_theme_font_size_override("font_size", 8)
	l_desc.add_theme_color_override("font_color", Color(0.72, 0.78, 0.85))
	vb.add_child(l_desc)
	
	return card

func create_action_card(title: String, desc: String, on_press: Callable) -> PanelContainer:
	var card = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.07, 0.10)
	sb.border_color = Color(0.20, 0.28, 0.38)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(4)
	card.add_theme_stylebox_override("panel", sb)
	
	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 2)
	card.add_child(vb)
	
	var btn = Button.new()
	btn.text = title
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.add_theme_font_size_override("font_size", 10)
	btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	btn.pressed.connect(on_press)
	vb.add_child(btn)
	
	var l_desc = Label.new()
	l_desc.text = desc
	l_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l_desc.add_theme_font_size_override("font_size", 8)
	l_desc.add_theme_color_override("font_color", Color(0.70, 0.75, 0.80))
	vb.add_child(l_desc)
	
	return card

func select_workshop_bay(bay_id: String):
	current_workshop_bay = bay_id
	emit_signal("garage_inspection_view_requested", bay_id)
	
	for b_key in workshop_hotspot_buttons.keys():
		var card = workshop_hotspot_buttons[b_key]
		if is_instance_valid(card):
			var sb = StyleBoxFlat.new()
			var is_sel = (b_key == bay_id)
			sb.bg_color = Color(0.12, 0.16, 0.22) if is_sel else Color(0.06, 0.08, 0.11)
			sb.border_color = Color(1.0, 0.85, 0.20) if is_sel else Color(0.20, 0.28, 0.38)
			sb.set_border_width_all(2 if is_sel else 1)
			sb.set_corner_radius_all(4)
			card.add_theme_stylebox_override("panel", sb)
			
	render_active_workbench()

func render_active_workbench():
	if not workshop_workbench_vbox or not street_rod_manager: return
	for c in workshop_workbench_vbox.get_children():
		c.queue_free()
		
	var active_car = street_rod_manager.get_active_car()
	if active_car.is_empty(): return
	
	match current_workshop_bay:
		"engine":
			if workshop_bay_title_label: workshop_bay_title_label.text = "⚡ BANCO DI LAVORO: 🔧 VANO MOTORE & CARBURATORI WEBER"
			# 1. Health & Maintenance
			var p_srv = PanelContainer.new()
			var sb_srv = StyleBoxFlat.new()
			sb_srv.bg_color = Color(0.08, 0.11, 0.15)
			sb_srv.border_color = Color(0.95, 0.55, 0.15)
			sb_srv.set_border_width_all(1)
			sb_srv.set_corner_radius_all(4)
			p_srv.add_theme_stylebox_override("panel", sb_srv)
			workshop_workbench_vbox.add_child(p_srv)
			
			var srv_vb = VBoxContainer.new()
			srv_vb.add_theme_constant_override("separation", 3)
			p_srv.add_child(srv_vb)
			
			var srv_hb = HBoxContainer.new()
			var l_eng_h = Label.new()
			l_eng_h.text = "Condizione Motore: %d%%" % int(active_car.get("engine_health", 0.8) * 100.0)
			l_eng_h.add_theme_font_size_override("font_size", 9)
			srv_hb.add_child(l_eng_h)
			var sp_srv = Control.new(); sp_srv.size_flags_horizontal = Control.SIZE_EXPAND_FILL; srv_hb.add_child(sp_srv)
			var btn_tagliando = Button.new()
			btn_tagliando.text = "TAGLIANDO AGIP SINT 2000 (L. 250.000)"
			btn_tagliando.add_theme_font_size_override("font_size", 9)
			btn_tagliando.pressed.connect(func():
				street_rod_manager.service_engine()
				render_active_workbench()
			)
			srv_hb.add_child(btn_tagliando)
			srv_vb.add_child(srv_hb)
			
			var bar_eng = ProgressBar.new()
			bar_eng.max_value = 100.0
			bar_eng.value = active_car.get("engine_health", 0.8) * 100.0
			bar_eng.custom_minimum_size.y = 6
			srv_vb.add_child(bar_eng)
			
			# 2. Engine Tuning Parts
			var eng_parts = [
				{ "id": "carburatori_doppi", "name": "Doppi Carburatori Weber 40 DCOE", "desc": "Tromboncini cromati aspirazione (+8 CV, rombo cupo)", "price": 850000 },
				{ "id": "scarico_sport", "name": "Scarico Sportivo 4-in-1 Abarth", "desc": "Collettori tubolari in acciaio inox (+5 CV, sound racing)", "price": 650000 },
				{ "id": "accensione_corsa", "name": "Kit Candele Magneti Marelli Corsa", "desc": "Cavi siliconici rossi & bobina potenziata (+2 CV, accensione istantanea)", "price": 280000 },
				{ "id": "overboost_turbo", "name": "Kit Turbocompressore Garrett T3", "desc": "Intercooler e wastegate regolabile (+35 CV, spinta formidabile)", "price": 1850000 }
			]
			for ep in eng_parts:
				add_part_tuning_row(ep, active_car)
				
		"wheels":
			if workshop_bay_title_label: workshop_bay_title_label.text = "⚡ BANCO DI LAVORO: 🛞 PNEUMATICI, ASSETTO & FRENI BREMBO"
			# Tire Health & Brakes
			var p_srv_w = PanelContainer.new()
			var sb_sw = StyleBoxFlat.new()
			sb_sw.bg_color = Color(0.08, 0.11, 0.15)
			sb_sw.border_color = Color(0.25, 0.75, 1.0)
			sb_sw.set_border_width_all(1)
			sb_sw.set_corner_radius_all(4)
			p_srv_w.add_theme_stylebox_override("panel", sb_sw)
			workshop_workbench_vbox.add_child(p_srv_w)
			
			var sw_vb = VBoxContainer.new()
			sw_vb.add_theme_constant_override("separation", 3)
			p_srv_w.add_child(sw_vb)
			
			var sw_hb = HBoxContainer.new()
			var l_tir_h = Label.new()
			var cur_type = active_car.get("tire_type", "touring").capitalize()
			l_tir_h.text = "Battistrada [%s]: %d%%" % [cur_type, int(active_car.get("tire_health", 0.8) * 100.0)]
			l_tir_h.add_theme_font_size_override("font_size", 9)
			sw_hb.add_child(l_tir_h)
			var sp_sw = Control.new(); sp_sw.size_flags_horizontal = Control.SIZE_EXPAND_FILL; sw_hb.add_child(sp_sw)
			var btn_brakes = Button.new()
			btn_brakes.text = "PASTIGLIE BREMBO CORSA (L. 150.000)"
			btn_brakes.add_theme_font_size_override("font_size", 9)
			btn_brakes.pressed.connect(func():
				play_ratchet_sfx()
				street_rod_manager.service_engine()
				render_active_workbench()
			)
			sw_hb.add_child(btn_brakes)
			sw_vb.add_child(sw_hb)
			
			var bar_tir = ProgressBar.new()
			bar_tir.max_value = 100.0
			bar_tir.value = active_car.get("tire_health", 0.8) * 100.0
			bar_tir.custom_minimum_size.y = 6
			sw_vb.add_child(bar_tir)
			
			# Tire options
			var tire_sets = [
				{ "id": "touring", "name": "Michelin Touring Stradali", "desc": "Pneumatici equilibrati, lunga durata per viaggiare (L. 280.000)", "price": 280000 },
				{ "id": "semislick", "name": "Pirelli P7 Corsa Semi-Slick", "desc": "Mescola morbida da pista: massima aderenza su asfalto asciutto (L. 680.000)", "price": 680000 },
				{ "id": "studded", "name": "Pirelli Winter Chiodate da Neve", "desc": "Chiodatura alpina: grip formidabile su ghiaccio, fango e neve (L. 580.000)", "price": 580000 }
			]
			for ts in tire_sets:
				var t_box = PanelContainer.new()
				var sb_t = StyleBoxFlat.new()
				var is_active_tire = (active_car.get("tire_type", "touring") == ts.id)
				sb_t.bg_color = Color(0.10, 0.16, 0.22) if is_active_tire else Color(0.07, 0.09, 0.12)
				sb_t.border_color = Color(0.25, 0.75, 1.0) if is_active_tire else Color(0.20, 0.28, 0.38)
				sb_t.set_border_width_all(1)
				sb_t.set_corner_radius_all(3)
				t_box.add_theme_stylebox_override("panel", sb_t)
				workshop_workbench_vbox.add_child(t_box)
				
				var t_hb = HBoxContainer.new()
				t_hb.add_theme_constant_override("separation", 6)
				t_box.add_child(t_hb)
				
				var l_tinfo = VBoxContainer.new()
				var l_tname = Label.new(); l_tname.text = ts.name; l_tname.add_theme_font_size_override("font_size", 9); l_tname.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20) if is_active_tire else Color.WHITE)
				var l_tdesc = Label.new(); l_tdesc.text = ts.desc; l_tdesc.add_theme_font_size_override("font_size", 8); l_tdesc.add_theme_color_override("font_color", Color(0.70, 0.75, 0.80))
				l_tinfo.add_child(l_tname); l_tinfo.add_child(l_tdesc)
				t_hb.add_child(l_tinfo)
				
				var sp_t = Control.new(); sp_t.size_flags_horizontal = Control.SIZE_EXPAND_FILL; t_hb.add_child(sp_t)
				
				var btn_tmount = Button.new()
				if is_active_tire:
					btn_tmount.text = "MONTATO ✓"
					btn_tmount.disabled = true
					btn_tmount.add_theme_color_override("font_color", Color(0.35, 1.0, 0.50))
				else:
					btn_tmount.text = "MONTA (L. %s)" % street_rod_manager.format_lire(ts.price)
					var tid = ts.id
					btn_tmount.pressed.connect(func():
						play_ratchet_sfx()
						play_cash_sfx()
						street_rod_manager.buy_tires(tid)
						render_active_workbench()
					)
				btn_tmount.add_theme_font_size_override("font_size", 9)
				t_hb.add_child(btn_tmount)
				
		"body":
			if workshop_bay_title_label: workshop_bay_title_label.text = "⚡ BANCO DI LAVORO: 🎨 CABINA VERNICIATURA & ALLEGGERIMENTO"
			# Body Health & Rust Repair
			var p_bod = PanelContainer.new()
			var sb_bd = StyleBoxFlat.new()
			sb_bd.bg_color = Color(0.08, 0.11, 0.15)
			sb_bd.border_color = Color(0.35, 1.0, 0.45)
			sb_bd.set_border_width_all(1)
			sb_bd.set_corner_radius_all(4)
			p_bod.add_theme_stylebox_override("panel", sb_bd)
			workshop_workbench_vbox.add_child(p_bod)
			
			var bd_vb = VBoxContainer.new()
			bd_vb.add_theme_constant_override("separation", 3)
			p_bod.add_child(bd_vb)
			
			var bd_hb = HBoxContainer.new()
			var l_bod_h = Label.new()
			l_bod_h.text = "Condizione Carrozzeria: %d%%" % int(active_car.get("body_health", 0.8) * 100.0)
			l_bod_h.add_theme_font_size_override("font_size", 9)
			bd_hb.add_child(l_bod_h)
			var sp_bd = Control.new(); sp_bd.size_flags_horizontal = Control.SIZE_EXPAND_FILL; bd_hb.add_child(sp_bd)
			var btn_rep_bod = Button.new()
			btn_rep_bod.text = "RIPARA LAMIERA & RUGGINE (L. 350.000)"
			btn_rep_bod.add_theme_font_size_override("font_size", 9)
			btn_rep_bod.pressed.connect(func():
				play_ratchet_sfx()
				street_rod_manager.repair_body()
				render_active_workbench()
			)
			bd_hb.add_child(btn_rep_bod)
			bd_vb.add_child(bd_hb)
			
			var bar_bod = ProgressBar.new()
			bar_bod.max_value = 100.0
			bar_bod.value = active_car.get("body_health", 0.8) * 100.0
			bar_bod.custom_minimum_size.y = 6
			bd_vb.add_child(bar_bod)
			
			# Street Rod Bumper Stripping (Weight reduction)
			var p_strip = PanelContainer.new()
			var sb_st = StyleBoxFlat.new()
			sb_st.bg_color = Color(0.07, 0.10, 0.14)
			sb_st.border_color = Color(0.85, 0.70, 0.20)
			sb_st.set_border_width_all(1)
			sb_st.set_corner_radius_all(3)
			p_strip.add_theme_stylebox_override("panel", sb_st)
			workshop_workbench_vbox.add_child(p_strip)
			
			var st_hb = HBoxContainer.new()
			st_hb.add_theme_constant_override("separation", 6)
			p_strip.add_child(st_hb)
			
			var l_strip_info = Label.new()
			l_strip_info.text = "🏁 ALLEGGERIMENTO STREET ROD: Rimozione Paraurti Anteriore & Posteriore (-18 kg di peso!)"
			l_strip_info.add_theme_font_size_override("font_size", 9)
			l_strip_info.add_theme_color_override("font_color", Color(1.0, 0.88, 0.30))
			st_hb.add_child(l_strip_info)
			var sp_st = Control.new(); sp_st.size_flags_horizontal = Control.SIZE_EXPAND_FILL; st_hb.add_child(sp_st)
			var btn_strip = Button.new()
			btn_strip.text = "SMONTA (L. 50.000)"
			btn_strip.add_theme_font_size_override("font_size", 9)
			btn_strip.pressed.connect(func():
				play_ratchet_sfx()
				street_rod_manager.install_tuning_part("paraurti_racing")
				render_active_workbench()
			)
			st_hb.add_child(btn_strip)
			
			# Paint booth palette
			var l_pnt = Label.new()
			l_pnt.text = "CABINA VERNICIATURA FORNO (L. 200.000) - SCEGLI LA TINTA STORICA:"
			l_pnt.add_theme_font_size_override("font_size", 9)
			l_pnt.add_theme_color_override("font_color", Color(0.85, 0.90, 0.95))
			workshop_workbench_vbox.add_child(l_pnt)
			
			var p_grid = GridContainer.new()
			p_grid.columns = 3
			p_grid.add_theme_constant_override("h_separation", 6)
			p_grid.add_theme_constant_override("v_separation", 4)
			workshop_workbench_vbox.add_child(p_grid)
			
			for p_col in street_rod_manager.paint_palette:
				var btn_c = Button.new()
				btn_c.text = p_col.name
				btn_c.add_theme_font_size_override("font_size", 8)
				var c_name = p_col.name
				btn_c.pressed.connect(func():
					play_click_sfx()
					street_rod_manager.paint_car(c_name)
					render_active_workbench()
				)
				p_grid.add_child(btn_c)
				
		"cockpit":
			if workshop_bay_title_label: workshop_bay_title_label.text = "⚡ BANCO DI LAVORO: 🕹️ ABITACOLO, TRASMISSIONE & CAMBIO BACCI"
			var trans_parts = [
				{ "id": "cambio_ravvicinato", "name": "Cambio 5 Marce Ravvicinato Bacci Romano", "desc": "Ingranaggi a denti dritti: cambiata fulminea per le salite ripide", "price": 1200000 },
				{ "id": "frizione_rame", "name": "Frizione Rinforzata in Rame & Volano Alleggerito", "desc": "Innesto granitico: zero slittamento in partenza bruciante", "price": 450000 },
				{ "id": "volante_corsa", "name": "Volante Sportivo Momo Corsa & Roll-bar Rally", "desc": "Gabbia tubolare di sicurezza e impugnatura in pelle scamosciata", "price": 350000 }
			]
			for tp in trans_parts:
				add_part_tuning_row(tp, active_car)

func add_part_tuning_row(part_info: Dictionary, active_car: Dictionary):
	var has_it = active_car.get("tuning_parts", []).has(part_info.id)
	var p_box = PanelContainer.new()
	var sb_p = StyleBoxFlat.new()
	sb_p.bg_color = Color(0.10, 0.14, 0.18) if not has_it else Color(0.10, 0.18, 0.14)
	sb_p.border_color = Color(0.25, 0.35, 0.45) if not has_it else Color(0.35, 0.85, 0.45)
	sb_p.set_border_width_all(1)
	sb_p.set_corner_radius_all(3)
	p_box.add_theme_stylebox_override("panel", sb_p)
	workshop_workbench_vbox.add_child(p_box)
	
	var hb = HBoxContainer.new()
	hb.add_theme_constant_override("separation", 6)
	p_box.add_child(hb)
	
	var vb = VBoxContainer.new()
	var l_t = Label.new(); l_t.text = part_info.name; l_t.add_theme_font_size_override("font_size", 9); l_t.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20) if has_it else Color.WHITE)
	var l_d = Label.new(); l_d.text = "%s (L. %s)" % [part_info.desc, street_rod_manager.format_lire(part_info.price)]; l_d.add_theme_font_size_override("font_size", 8); l_d.add_theme_color_override("font_color", Color(0.70, 0.75, 0.80))
	vb.add_child(l_t); vb.add_child(l_d)
	hb.add_child(vb)
	
	var sp = Control.new(); sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL; hb.add_child(sp)
	
	var btn = Button.new()
	if has_it:
		btn.text = "INSTALLATO ✓"
		btn.disabled = true
		btn.add_theme_color_override("font_color", Color(0.35, 1.0, 0.50))
	else:
		btn.text = "COMPRA & MONTA"
		var pid = part_info.id
		btn.pressed.connect(func():
			play_ratchet_sfx()
			play_cash_sfx()
			street_rod_manager.install_tuning_part(pid)
			render_active_workbench()
			if dyno_graph: dyno_graph.update_from_car(street_rod_manager.get_active_car())
		)
	btn.add_theme_font_size_override("font_size", 9)
	hb.add_child(btn)

func refresh_hub_view():
	if not street_rod_manager: return
	
	# 1. Update Profile & Skills
	var prof = street_rod_manager.get_player_profile()
	if hub_profile_name_label: hub_profile_name_label.text = "Ing. " + prof.get("name", "Paolo")
	if hub_profile_role_label: hub_profile_role_label.text = prof.get("role", "Collaudatore & Meccanico")
	if hub_profile_license_label: hub_profile_license_label.text = "Licenza: %s | %s" % [prof.get("license_code", "CSAI-1993-VR40"), prof.get("license_tier", "Cat. B")]
	if hub_profile_rank_label: hub_profile_rank_label.text = "⭐ Rango: %s (%d pt)" % [street_rod_manager.get_reputation_title(), street_rod_manager.reputation]
	if hub_profile_rep_bar: hub_profile_rep_bar.value = street_rod_manager.reputation
	if hub_profile_cash_label: hub_profile_cash_label.text = "💰 Cassa: L. " + street_rod_manager.format_lire(street_rod_manager.cash_lire)
	
	var sk = prof.get("skills", {})
	if hub_skill_mech_bar: hub_skill_mech_bar.value = sk.get("meccanica", 78)
	if hub_skill_handling_bar: hub_skill_handling_bar.value = sk.get("assetto_curve", 82)
	if hub_skill_altitude_bar: hub_skill_altitude_bar.value = sk.get("respiro_quota", 74)
	
	var st = prof.get("stats", {})
	if hub_stats_km_label: hub_stats_km_label.text = "• Km Guidati: %.1f km" % st.get("km_driven", 24.5)
	if hub_stats_races_label: hub_stats_races_label.text = "• Gare Vinte: %d" % st.get("races_won", 3)
	if hub_stats_missions_label: hub_stats_missions_label.text = "• Missioni Concluse: %d" % st.get("missions_completed", 1)
	if hub_stats_top_speed_label: hub_stats_top_speed_label.text = "• Velocità Record: %.0f km/h" % st.get("top_speed_kmh", 168.0)
	
	# 2. Update Garage slots and selected car card
	if hub_garage_slots_hbox:
		for c in hub_garage_slots_hbox.get_children(): c.queue_free()
		for i in range(street_rod_manager.garage.size()):
			var car = street_rod_manager.garage[i]
			var btn_slot = Button.new()
			var is_active = (i == street_rod_manager.current_car_idx)
			var is_selected = (i == hub_selected_car_idx)
			btn_slot.text = ("▶ " if is_active else "") + car.name + (" [IN USO]" if is_active else "")
			btn_slot.add_theme_font_size_override("font_size", 9)
			if is_active:
				btn_slot.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
			var idx = i
			btn_slot.pressed.connect(func():
				hub_selected_car_idx = idx
				refresh_hub_view()
			)
			hub_garage_slots_hbox.add_child(btn_slot)
			
	if hub_selected_car_idx >= street_rod_manager.garage.size():
		hub_selected_car_idx = clamp(street_rod_manager.current_car_idx, 0, street_rod_manager.garage.size() - 1)
		
	if hub_selected_car_idx >= 0 and hub_selected_car_idx < street_rod_manager.garage.size():
		var sel_car = street_rod_manager.garage[hub_selected_car_idx]
		var is_currently_active = (hub_selected_car_idx == street_rod_manager.current_car_idx)
		if hub_car_name_label: hub_car_name_label.text = "🚘 " + sel_car.name.to_upper() + (" - " + sel_car.get("nickname", ""))
		if hub_car_plate_label: hub_car_plate_label.text = "Colore: %s | Chilometraggio: %d km" % [sel_car.get("body_color", "Verde Muschio"), sel_car.get("mileage_km", 140000)]
		if hub_car_specs_label:
			var t_type = sel_car.get("tire_type", "touring").capitalize()
			hub_car_specs_label.text = "Assetto: %s | Treno Gomme: %s | Valore: L. %s" % [
				("Elaborato" if not sel_car.get("tuning_parts", []).is_empty() else "Standard Stradale"),
				t_type,
				street_rod_manager.format_lire(street_rod_manager.calculate_car_sale_value(sel_car))
			]
		if hub_car_tuning_label:
			var parts = sel_car.get("tuning_parts", [])
			if parts.is_empty():
				hub_car_tuning_label.text = "Elaborazioni: Nessuna (Motore originale)"
				hub_car_tuning_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8))
			else:
				hub_car_tuning_label.text = "Elaborazioni: " + ", ".join(parts).replace("_", " ").capitalize()
				hub_car_tuning_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.60))
				
		if hub_car_eng_bar: hub_car_eng_bar.value = sel_car.get("engine_health", 0.8) * 100.0
		if hub_car_body_bar: hub_car_body_bar.value = sel_car.get("body_health", 0.8) * 100.0
		if hub_car_tire_bar: hub_car_tire_bar.value = sel_car.get("tire_health", 0.8) * 100.0
		if hub_car_fuel_bar: hub_car_fuel_bar.value = 100.0
		
		if hub_btn_drive_car:
			if is_currently_active:
				hub_btn_drive_car.text = "🚦 ESCI DAL GARAGE ED ENTRA IN STRADA"
				hub_btn_drive_car.disabled = false
			else:
				hub_btn_drive_car.text = "🏎️ SELEZIONA QUESTA AUTO"
				hub_btn_drive_car.disabled = false
				
	# 3. Update Missions Board
	var act_c = street_rod_manager.get_active_contract()
	if not act_c.is_empty():
		if hub_active_mission_title: hub_active_mission_title.text = act_c.get("title", "")
		if hub_active_mission_client: hub_active_mission_client.text = "Committente: " + act_c.get("client", "Mastro Bepi")
		if hub_active_mission_desc: hub_active_mission_desc.text = act_c.get("lore", "")
		if hub_active_mission_dest: hub_active_mission_dest.text = "📍 Destinazione: " + act_c.get("destination", "")
		if hub_active_mission_reward: hub_active_mission_reward.text = "💰 L. %s | ⭐ +%d PT" % [street_rod_manager.format_lire(act_c.get("reward_lire", 500000)), act_c.get("reward_rep", 50)]
		if hub_active_mission_badge:
			hub_active_mission_badge.text = "✓ COMPLETATA!" if act_c.get("completed", false) else "▶ IN CORSO"
			hub_active_mission_badge.add_theme_color_override("font_color", (Color(0.4, 1.0, 0.5) if act_c.get("completed", false) else Color(1.0, 0.85, 0.2)))
			
	if hub_other_missions_vbox:
		for c in hub_other_missions_vbox.get_children(): c.queue_free()
		for c_data in street_rod_manager.contracts:
			var c_id = c_data.get("id", "")
			if c_id == act_c.get("id", ""): continue # Skip currently featured
			
			var m_row = PanelContainer.new()
			var sb_mr = StyleBoxFlat.new()
			sb_mr.bg_color = Color(0.08, 0.10, 0.14)
			sb_mr.border_color = Color(0.20, 0.28, 0.38)
			sb_mr.set_border_width_all(1)
			sb_mr.set_corner_radius_all(3)
			m_row.add_theme_stylebox_override("panel", sb_mr)
			
			var mr_vb = VBoxContainer.new()
			mr_vb.add_theme_constant_override("separation", 2)
			m_row.add_child(mr_vb)
			
			var mr_top = HBoxContainer.new()
			var l_mtit = Label.new()
			l_mtit.text = ("✓ " if c_data.get("completed", false) else "• ") + c_data.get("title", "")
			l_mtit.add_theme_font_size_override("font_size", 9)
			l_mtit.add_theme_color_override("font_color", (Color(0.4, 0.9, 0.5) if c_data.get("completed", false) else Color(0.85, 0.90, 0.95)))
			mr_top.add_child(l_mtit)
			
			var sp_mr = Control.new(); sp_mr.size_flags_horizontal = Control.SIZE_EXPAND_FILL; mr_top.add_child(sp_mr)
			
			if not c_data.get("completed", false):
				var btn_act = Button.new()
				btn_act.text = "ATTIVA"
				btn_act.add_theme_font_size_override("font_size", 8)
				var cid = c_id
				btn_act.pressed.connect(func():
					street_rod_manager.set_active_contract(cid)
					refresh_hub_view()
				)
				mr_top.add_child(btn_act)
			mr_vb.add_child(mr_top)
			
			var l_mdesc = Label.new()
			l_mdesc.text = "%s | Premio: L. %s" % [c_data.get("destination", ""), street_rod_manager.format_lire(c_data.get("reward_lire", 0))]
			l_mdesc.add_theme_font_size_override("font_size", 8)
			l_mdesc.add_theme_color_override("font_color", Color(0.65, 0.75, 0.85))
			mr_vb.add_child(l_mdesc)
			
			hub_other_missions_vbox.add_child(m_row)

func on_hub_drive_car_pressed():
	if street_rod_manager:
		if hub_selected_car_idx == street_rod_manager.current_car_idx:
			# L'auto è già attiva: esci dal garage ed entra in strada!
			close_screen()
		else:
			street_rod_manager.select_active_car(hub_selected_car_idx)
			refresh_hub_view()

# ==============================================================================
# TAB 1: IL MERCATINO '93 (CLASSIFIED ADS / NEWSPAPER)
# ==============================================================================
var market_cards_vbox: VBoxContainer
var my_cars_vbox: VBoxContainer

func build_market_view() -> Control:
	var root = HBoxContainer.new()
	root.add_theme_constant_override("separation", 14)
	
	# Left: Parchment Newspaper Ads (Il Mercatino delle Ruote)
	var left_panel = PanelContainer.new()
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_panel.size_flags_stretch_ratio = 1.3
	var sb_paper = StyleBoxFlat.new()
	sb_paper.bg_color = Color(0.92, 0.88, 0.80) # Retro parchment paper
	sb_paper.border_color = Color(0.35, 0.28, 0.18)
	sb_paper.set_border_width_all(2)
	left_panel.add_theme_stylebox_override("panel", sb_paper)
	root.add_child(left_panel)
	
	var paper_vbox = VBoxContainer.new()
	paper_vbox.add_theme_constant_override("separation", 6)
	left_panel.add_child(paper_vbox)
	
	# Period Newspaper Masthead
	var news_masthead = PanelContainer.new()
	var sb_nh = StyleBoxFlat.new()
	sb_nh.bg_color = Color(0.20, 0.15, 0.10)
	sb_nh.set_corner_radius_all(3)
	news_masthead.add_theme_stylebox_override("panel", sb_nh)
	paper_vbox.add_child(news_masthead)
	
	var news_vb = VBoxContainer.new()
	news_vb.add_theme_constant_override("separation", 2)
	news_masthead.add_child(news_vb)
	
	var paper_title = Label.new()
	paper_title.text = " 📰 LA GAZZETTA DEL VALICO '93 - EDIZIONE STRAORDINARIA"
	paper_title.add_theme_font_size_override("font_size", 12)
	paper_title.add_theme_color_override("font_color", Color(1.0, 0.90, 0.60))
	news_vb.add_child(paper_title)
	
	var paper_sub = Label.new()
	paper_sub.text = " Anno XXVII - N. 241 | Venerdì 8 Ottobre 1993 | Prezzo L. 1.500 | Cronaca, Motori & Annunci Economici"
	paper_sub.add_theme_font_size_override("font_size", 9)
	paper_sub.add_theme_color_override("font_color", Color(0.85, 0.80, 0.70))
	news_vb.add_child(paper_sub)
	
	var news_ticker = Label.new()
	news_ticker.name = "NewsTicker"
	var headlines = street_rod_manager.get_dynamic_news_headlines() if street_rod_manager else ["Prime sfide al Valico dei Motori!"]
	news_ticker.text = " PRIMA PAGINA: " + headlines[0]
	news_ticker.add_theme_font_size_override("font_size", 10)
	news_ticker.add_theme_color_override("font_color", Color(0.95, 0.85, 0.20))
	news_ticker.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	paper_vbox.add_child(news_ticker)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	paper_vbox.add_child(scroll)
	
	market_cards_vbox = VBoxContainer.new()
	market_cards_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	market_cards_vbox.add_theme_constant_override("separation", 8)
	scroll.add_child(market_cards_vbox)
	
	# Right: Sell Your Cars Box
	var right_panel = PanelContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.size_flags_stretch_ratio = 0.8
	var sb_right = StyleBoxFlat.new()
	sb_right.bg_color = Color(0.08, 0.10, 0.13, 0.95)
	sb_right.border_color = Color(0.20, 0.35, 0.50)
	sb_right.set_border_width_all(1)
	right_panel.add_theme_stylebox_override("panel", sb_right)
	root.add_child(right_panel)
	
	var right_vbox = VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 8)
	right_panel.add_child(right_vbox)
	
	var sell_title = Label.new()
	sell_title.text = "💼 VENDI LE TUE AUTO (MERCATINO PRIVATO)"
	sell_title.add_theme_font_size_override("font_size", 12)
	sell_title.add_theme_color_override("font_color", Color(0.85, 0.90, 0.95))
	right_vbox.add_child(sell_title)
	
	var my_scroll = ScrollContainer.new()
	my_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.add_child(my_scroll)
	
	my_cars_vbox = VBoxContainer.new()
	my_cars_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	my_cars_vbox.add_theme_constant_override("separation", 8)
	my_scroll.add_child(my_cars_vbox)
	
	return root

func refresh_market_view():
	if not market_cards_vbox or not street_rod_manager: return
	
	for c in market_cards_vbox.get_children():
		c.queue_free()
	for c in my_cars_vbox.get_children():
		c.queue_free()
		
	# 1. Newspaper ads
	for i in range(street_rod_manager.classified_ads.size()):
		var ad = street_rod_manager.classified_ads[i]
		var ad_box = PanelContainer.new()
		var sb_ad = StyleBoxFlat.new()
		sb_ad.bg_color = Color(0.98, 0.96, 0.92) # Newspaper slip
		sb_ad.border_color = Color(0.60, 0.50, 0.40)
		sb_ad.set_border_width_all(1)
		sb_ad.set_corner_radius_all(4)
		ad_box.add_theme_stylebox_override("panel", sb_ad)
		
		var ad_vbox = VBoxContainer.new()
		ad_vbox.add_theme_constant_override("separation", 4)
		ad_box.add_child(ad_vbox)
		
		var h_top = HBoxContainer.new()
		var lbl_name = Label.new()
		lbl_name.text = "🚘 " + ad.title
		lbl_name.add_theme_font_size_override("font_size", 12)
		lbl_name.add_theme_color_override("font_color", Color(0.12, 0.10, 0.08))
		h_top.add_child(lbl_name)
		
		var sp = Control.new()
		sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h_top.add_child(sp)
		
		var lbl_price = Label.new()
		lbl_price.text = "L. " + street_rod_manager.format_lire(ad.price_lire)
		lbl_price.add_theme_font_size_override("font_size", 12)
		lbl_price.add_theme_color_override("font_color", Color(0.70, 0.15, 0.10))
		h_top.add_child(lbl_price)
		ad_vbox.add_child(h_top)
		
		var lbl_desc = Label.new()
		lbl_desc.text = ad.desc
		lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_desc.add_theme_font_size_override("font_size", 10)
		lbl_desc.add_theme_color_override("font_color", Color(0.25, 0.22, 0.18))
		ad_vbox.add_child(lbl_desc)
		
		var h_bot = HBoxContainer.new()
		var lbl_cond = Label.new()
		lbl_cond.text = "Motore: %d%% | Carrozzeria: %d%% | Km: %d | Colore: %s" % [
			int(ad.engine_health * 100),
			int(ad.body_health * 100),
			ad.mileage_km,
			ad.color_name
		]
		lbl_cond.add_theme_font_size_override("font_size", 9)
		lbl_cond.add_theme_color_override("font_color", Color(0.40, 0.35, 0.30))
		h_bot.add_child(lbl_cond)
		
		var sp2 = Control.new()
		sp2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h_bot.add_child(sp2)
		
		var btn_buy = Button.new()
		btn_buy.text = "COMPRA"
		btn_buy.add_theme_font_size_override("font_size", 10)
		var ad_idx = i
		btn_buy.pressed.connect(func():
			play_cash_sfx()
			street_rod_manager.buy_car(ad_idx)
			refresh_market_view()
		)
		h_bot.add_child(btn_buy)
		ad_vbox.add_child(h_bot)
		
		market_cards_vbox.add_child(ad_box)
		
	# 2. My cars for sale
	for i in range(street_rod_manager.garage.size()):
		var car = street_rod_manager.garage[i]
		var val = street_rod_manager.calculate_car_sale_value(car)
		var c_box = PanelContainer.new()
		var sb_c = StyleBoxFlat.new()
		sb_c.bg_color = Color(0.12, 0.14, 0.18)
		sb_c.border_color = Color(0.30, 0.40, 0.55)
		sb_c.set_border_width_all(1)
		sb_c.set_corner_radius_all(4)
		c_box.add_theme_stylebox_override("panel", sb_c)
		
		var c_vbox = VBoxContainer.new()
		c_box.add_child(c_vbox)
		
		var lbl_c = Label.new()
		lbl_c.text = car.name
		lbl_c.add_theme_font_size_override("font_size", 11)
		lbl_c.add_theme_color_override("font_color", Color.WHITE)
		c_vbox.add_child(lbl_c)
		
		var h_sub = HBoxContainer.new()
		var lbl_v = Label.new()
		lbl_v.text = "Valore: L. " + street_rod_manager.format_lire(val)
		lbl_v.add_theme_font_size_override("font_size", 10)
		lbl_v.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5))
		h_sub.add_child(lbl_v)
		
		var sp = Control.new()
		sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h_sub.add_child(sp)
		
		var btn_sell = Button.new()
		btn_sell.text = "VENDI"
		btn_sell.add_theme_font_size_override("font_size", 10)
		var g_idx = i
		btn_sell.pressed.connect(func():
			play_cash_sfx()
			street_rod_manager.sell_car(g_idx)
			refresh_market_view()
		)
		h_sub.add_child(btn_sell)
		c_vbox.add_child(h_sub)
		
		my_cars_vbox.add_child(c_box)

# ==============================================================================
# TAB 2: OFFICINA & TUNING (GARAGE & WORKSHOP)
# ==============================================================================
var garage_slots_hbox: HBoxContainer
var active_car_header_label: Label
var bar_eng_health: ProgressBar
var bar_body_health: ProgressBar
var bar_tire_health: ProgressBar
var tuning_parts_vbox: VBoxContainer
var paint_buttons_hbox: HBoxContainer

func build_garage_view() -> Control:
	var root = VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	
	# Slot Selector Bar
	var slot_panel = PanelContainer.new()
	var sb_slot = StyleBoxFlat.new()
	sb_slot.bg_color = Color(0.08, 0.10, 0.14)
	sb_slot.set_border_width_all(1)
	sb_slot.border_color = Color(0.25, 0.35, 0.50)
	slot_panel.add_theme_stylebox_override("panel", sb_slot)
	root.add_child(slot_panel)
	
	var slot_vbox = VBoxContainer.new()
	slot_vbox.add_theme_constant_override("separation", 4)
	slot_panel.add_child(slot_vbox)
	
	var lbl_sl = Label.new()
	lbl_sl.text = "PARCO AUTO NEL BOX (SELEZIONA PER GUIDARE O METTERE SUL PONTE):"
	lbl_sl.add_theme_font_size_override("font_size", 10)
	lbl_sl.add_theme_color_override("font_color", Color(0.70, 0.80, 0.90))
	slot_vbox.add_child(lbl_sl)
	
	garage_slots_hbox = HBoxContainer.new()
	garage_slots_hbox.add_theme_constant_override("separation", 8)
	slot_vbox.add_child(garage_slots_hbox)
	
	# Two-column layout: Left = Mechanical Overhaul & Tires | Right = Tuning & Paint
	var split_hbox = HBoxContainer.new()
	split_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split_hbox.add_theme_constant_override("separation", 14)
	root.add_child(split_hbox)
	
	# Left Column: Car Specs & Maintenance
	var left_p = PanelContainer.new()
	left_p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb_lp = StyleBoxFlat.new()
	sb_lp.bg_color = Color(0.06, 0.08, 0.10)
	sb_lp.border_color = Color(0.20, 0.30, 0.40)
	sb_lp.set_border_width_all(1)
	left_p.add_theme_stylebox_override("panel", sb_lp)
	split_hbox.add_child(left_p)
	
	var left_vb = VBoxContainer.new()
	left_vb.add_theme_constant_override("separation", 8)
	left_p.add_child(left_vb)
	
	active_car_header_label = Label.new()
	active_car_header_label.text = "🚘 SCHEDA MECCANICA: FIAT 127 SPECIAL"
	active_car_header_label.add_theme_font_size_override("font_size", 12)
	active_car_header_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	left_vb.add_child(active_car_header_label)
	
	# Health Bars
	var h_eng = HBoxContainer.new()
	var l_e = Label.new(); l_e.text = "Salute Motore:"; l_e.custom_minimum_size.x = 100; l_e.add_theme_font_size_override("font_size", 10)
	bar_eng_health = ProgressBar.new(); bar_eng_health.size_flags_horizontal = Control.SIZE_EXPAND_FILL; bar_eng_health.max_value = 100
	var btn_rep_eng = Button.new(); btn_rep_eng.text = "TAGLIANDO (L. 250k)"; btn_rep_eng.add_theme_font_size_override("font_size", 10)
	btn_rep_eng.pressed.connect(func():
		play_ratchet_sfx()
		street_rod_manager.service_engine()
		refresh_garage_view()
	)
	h_eng.add_child(l_e); h_eng.add_child(bar_eng_health); h_eng.add_child(btn_rep_eng)
	left_vb.add_child(h_eng)
	
	var h_bod = HBoxContainer.new()
	var l_b = Label.new(); l_b.text = "Carrozzeria:"; l_b.custom_minimum_size.x = 100; l_b.add_theme_font_size_override("font_size", 10)
	bar_body_health = ProgressBar.new(); bar_body_health.size_flags_horizontal = Control.SIZE_EXPAND_FILL; bar_body_health.max_value = 100
	var btn_rep_bod = Button.new(); btn_rep_bod.text = "RIPARA (L. 350k)"; btn_rep_bod.add_theme_font_size_override("font_size", 10)
	btn_rep_bod.pressed.connect(func():
		play_ratchet_sfx()
		street_rod_manager.repair_body()
		refresh_garage_view()
	)
	h_bod.add_child(l_b); h_bod.add_child(bar_body_health); h_bod.add_child(btn_rep_bod)
	left_vb.add_child(h_bod)
	
	var h_tir = HBoxContainer.new()
	var l_t = Label.new(); l_t.text = "Battistrada Gomme:"; l_t.custom_minimum_size.x = 100; l_t.add_theme_font_size_override("font_size", 10)
	bar_tire_health = ProgressBar.new(); bar_tire_health.size_flags_horizontal = Control.SIZE_EXPAND_FILL; bar_tire_health.max_value = 100
	h_tir.add_child(l_t); h_tir.add_child(bar_tire_health)
	left_vb.add_child(h_tir)
	
	# Tire choices
	var l_t_type = Label.new()
	l_t_type.text = "TRENI GOMME DISPONIBILI SUL BANCO:"
	l_t_type.add_theme_font_size_override("font_size", 10)
	left_vb.add_child(l_t_type)
	
	var h_tires = HBoxContainer.new()
	h_tires.add_theme_constant_override("separation", 6)
	var btn_t_tour = Button.new(); btn_t_tour.text = "Touring (L. 280k)"; btn_t_tour.add_theme_font_size_override("font_size", 9)
	btn_t_tour.pressed.connect(func():
		play_ratchet_sfx(); play_cash_sfx()
		street_rod_manager.buy_tires("touring")
		refresh_garage_view()
	)
	var btn_t_semi = Button.new(); btn_t_semi.text = "Semi-Slick (L. 680k)"; btn_t_semi.add_theme_font_size_override("font_size", 9)
	btn_t_semi.pressed.connect(func():
		play_ratchet_sfx(); play_cash_sfx()
		street_rod_manager.buy_tires("semislick")
		refresh_garage_view()
	)
	var btn_t_stud = Button.new(); btn_t_stud.text = "Chiodate Neve (L. 580k)"; btn_t_stud.add_theme_font_size_override("font_size", 9)
	btn_t_stud.pressed.connect(func():
		play_ratchet_sfx(); play_cash_sfx()
		street_rod_manager.buy_tires("studded")
		refresh_garage_view()
	)
	h_tires.add_child(btn_t_tour); h_tires.add_child(btn_t_semi); h_tires.add_child(btn_t_stud)
	left_vb.add_child(h_tires)
	
	# Paint Booth
	var l_paint = Label.new()
	l_paint.text = "CABINA VERNICIATURA FORNO (L. 200.000):"
	l_paint.add_theme_font_size_override("font_size", 10)
	left_vb.add_child(l_paint)
	
	paint_buttons_hbox = HBoxContainer.new()
	paint_buttons_hbox.add_theme_constant_override("separation", 4)
	left_vb.add_child(paint_buttons_hbox)
	
	# Right Column: Dyno Graph & Tuning Parts Catalog
	var right_p = PanelContainer.new()
	right_p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb_rp = StyleBoxFlat.new()
	sb_rp.bg_color = Color(0.06, 0.08, 0.10)
	sb_rp.border_color = Color(0.20, 0.30, 0.40)
	sb_rp.set_border_width_all(1)
	right_p.add_theme_stylebox_override("panel", sb_rp)
	split_hbox.add_child(right_p)
	
	var right_vb = VBoxContainer.new()
	right_vb.add_theme_constant_override("separation", 6)
	right_p.add_child(right_vb)
	
	# Add Dyno Graph CRT Vector Display
	dyno_graph = DynoGraphControl.new()
	right_vb.add_child(dyno_graph)
	
	var dyno_ctrl_hb = HBoxContainer.new()
	dyno_ctrl_hb.add_theme_constant_override("separation", 8)
	right_vb.add_child(dyno_ctrl_hb)
	
	var btn_dyno_sweep = Button.new()
	btn_dyno_sweep.text = " ▶ AVVIA RULLI DYNO TEST [SWEEP POTENZA] "
	btn_dyno_sweep.add_theme_font_size_override("font_size", 9)
	btn_dyno_sweep.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	btn_dyno_sweep.pressed.connect(func():
		play_click_sfx()
		if dyno_graph: dyno_graph.start_sweep()
	)
	dyno_ctrl_hb.add_child(btn_dyno_sweep)
	
	var tune_head = Label.new()
	tune_head.text = "⚡ ELABORAZIONI & RICAMBI SPECIALI (STREET ROD):"
	tune_head.add_theme_font_size_override("font_size", 11)
	tune_head.add_theme_color_override("font_color", Color(0.35, 1.0, 0.60))
	right_vb.add_child(tune_head)
	
	var scroll_tune = ScrollContainer.new()
	scroll_tune.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vb.add_child(scroll_tune)
	
	tuning_parts_vbox = VBoxContainer.new()
	tuning_parts_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tuning_parts_vbox.add_theme_constant_override("separation", 6)
	scroll_tune.add_child(tuning_parts_vbox)
	
	return root

func refresh_garage_view():
	if not street_rod_manager or not garage_slots_hbox: return
	
	# 1. Garage slot buttons
	for c in garage_slots_hbox.get_children():
		c.queue_free()
	for i in range(street_rod_manager.garage.size()):
		var car = street_rod_manager.garage[i]
		var btn_slot = Button.new()
		var is_active = (i == street_rod_manager.current_car_idx)
		btn_slot.text = ("▶ " if is_active else "") + car.name + (" [IN USO]" if is_active else "")
		btn_slot.add_theme_font_size_override("font_size", 10)
		if is_active:
			btn_slot.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
		var idx = i
		btn_slot.pressed.connect(func():
			street_rod_manager.select_active_car(idx)
			refresh_garage_view()
		)
		garage_slots_hbox.add_child(btn_slot)
		
	# 2. Active car details & Dyno Graph
	var active_car = street_rod_manager.get_active_car()
	if not active_car.is_empty():
		active_car_header_label.text = "🚘 SCHEDA MECCANICA: %s [%s]" % [active_car.name, active_car.body_color]
		bar_eng_health.value = active_car.engine_health * 100.0
		bar_body_health.value = active_car.body_health * 100.0
		bar_tire_health.value = active_car.tire_health * 100.0
		if dyno_graph: dyno_graph.update_from_car(active_car)
		
	# 3. Tuning parts
	for c in tuning_parts_vbox.get_children():
		c.queue_free()
	for p_id in street_rod_manager.tuning_catalog.keys():
		var p_info = street_rod_manager.tuning_catalog[p_id]
		var has_it = active_car.get("tuning_parts", []).has(p_id)
		
		var p_row = PanelContainer.new()
		var sb_r = StyleBoxFlat.new()
		sb_r.bg_color = Color(0.10, 0.12, 0.15) if not has_it else Color(0.12, 0.20, 0.16)
		sb_r.border_color = Color(0.25, 0.35, 0.45) if not has_it else Color(0.35, 0.80, 0.45)
		sb_r.set_border_width_all(1)
		sb_r.set_corner_radius_all(4)
		p_row.add_theme_stylebox_override("panel", sb_r)
		
		var row_hbox = HBoxContainer.new()
		row_hbox.add_theme_constant_override("separation", 8)
		p_row.add_child(row_hbox)
		
		var l_info = VBoxContainer.new()
		var l_tit = Label.new()
		l_tit.text = "%s %s" % [p_info.icon, p_info.name]
		l_tit.add_theme_font_size_override("font_size", 10)
		l_tit.add_theme_color_override("font_color", Color.WHITE)
		var l_sub = Label.new()
		l_sub.text = "%s (L. %s)" % [p_info.desc, street_rod_manager.format_lire(p_info.price_lire)]
		l_sub.add_theme_font_size_override("font_size", 9)
		l_sub.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8))
		l_info.add_child(l_tit); l_info.add_child(l_sub)
		row_hbox.add_child(l_info)
		
		var sp = Control.new()
		sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_hbox.add_child(sp)
		
		var btn_install = Button.new()
		if has_it:
			btn_install.text = "INSTALLATO ✓"
			btn_install.disabled = true
			btn_install.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
		else:
			btn_install.text = "COMPRA"
			var part_key = p_id
			btn_install.pressed.connect(func():
				play_ratchet_sfx()
				play_cash_sfx()
				street_rod_manager.install_tuning_part(part_key)
				refresh_garage_view()
			)
		btn_install.add_theme_font_size_override("font_size", 10)
		row_hbox.add_child(btn_install)
		
		tuning_parts_vbox.add_child(p_row)
		
	# 4. Paint palette
	for c in paint_buttons_hbox.get_children():
		c.queue_free()
	for p in street_rod_manager.paint_palette:
		var btn_col = Button.new()
		btn_col.text = p.name.split(" ")[0]
		btn_col.add_theme_font_size_override("font_size", 9)
		var col_name = p.name
		btn_col.pressed.connect(func():
			play_click_sfx()
			street_rod_manager.paint_car(col_name)
			refresh_garage_view()
		)
		paint_buttons_hbox.add_child(btn_col)

# ==============================================================================
# TAB 3: DINER "DA BEPI" (CHARACTERS, AFFINITY & LIVING STORY DIALOGUE)
# ==============================================================================
var diner_dialogue_label: Label
var diner_character_name_label: Label
var diner_character_avatar: Label
var diner_affinity_bar: ProgressBar
var diner_affinity_label: Label
var diner_action_buttons_vbox: VBoxContainer
var current_diner_char: String = "bepi"

func build_diner_view() -> Control:
	var root = HBoxContainer.new()
	root.add_theme_constant_override("separation", 14)
	
	# Left: Complete Character roster in the diner
	var left_p = PanelContainer.new()
	left_p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_p.size_flags_stretch_ratio = 0.8
	var sb_l = StyleBoxFlat.new()
	sb_l.bg_color = Color(0.06, 0.08, 0.10)
	sb_l.border_color = Color(0.25, 0.35, 0.45)
	sb_l.set_border_width_all(1)
	left_p.add_theme_stylebox_override("panel", sb_l)
	root.add_child(left_p)
	
	var char_vbox = VBoxContainer.new()
	char_vbox.add_theme_constant_override("separation", 5)
	left_p.add_child(char_vbox)
	
	var l_head = Label.new()
	l_head.text = "☕ CLIENTI & RIVALI AL BANCONE:"
	l_head.add_theme_font_size_override("font_size", 11)
	l_head.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	char_vbox.add_child(l_head)
	
	var char_keys = ["bepi", "gino", "chiara", "kurt", "sandra", "don_attilio", "hans", "duca"]
	for k in char_keys:
		var btn_c = Button.new()
		var r = street_rod_manager.rivals.get(k, {}) if street_rod_manager else {}
		btn_c.text = "%s %s" % [r.get("avatar_icon", "👤"), r.get("name", k)]
		btn_c.add_theme_font_size_override("font_size", 10)
		var c_id = k
		btn_c.pressed.connect(func(): select_diner_character(c_id))
		char_vbox.add_child(btn_c)
		
	# Right: Conversation & Interaction Box
	var right_p = PanelContainer.new()
	right_p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_p.size_flags_stretch_ratio = 1.3
	var sb_r = StyleBoxFlat.new()
	sb_r.bg_color = Color(0.08, 0.10, 0.14)
	sb_r.border_color = Color(0.30, 0.45, 0.65)
	sb_r.set_border_width_all(2)
	right_p.add_theme_stylebox_override("panel", sb_r)
	root.add_child(right_p)
	
	var right_vbox = VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 8)
	right_p.add_child(right_vbox)
	
	# Character Header & Affinity Status
	var h_char = HBoxContainer.new()
	h_char.add_theme_constant_override("separation", 10)
	diner_character_avatar = Label.new()
	diner_character_avatar.text = "👨‍🦳"
	diner_character_avatar.add_theme_font_size_override("font_size", 28)
	h_char.add_child(diner_character_avatar)
	
	var name_aff_vb = VBoxContainer.new()
	name_aff_vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_aff_vb.add_theme_constant_override("separation", 2)
	
	diner_character_name_label = Label.new()
	diner_character_name_label.text = "MASTRO BEPI | OSTE MECCANICO"
	diner_character_name_label.add_theme_font_size_override("font_size", 12)
	diner_character_name_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	name_aff_vb.add_child(diner_character_name_label)
	
	var aff_hbox = HBoxContainer.new()
	aff_hbox.add_theme_constant_override("separation", 8)
	diner_affinity_label = Label.new()
	diner_affinity_label.text = "Affinità: 35% [Fidato Consigliere]"
	diner_affinity_label.add_theme_font_size_override("font_size", 9)
	diner_affinity_label.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0))
	aff_hbox.add_child(diner_affinity_label)
	
	diner_affinity_bar = ProgressBar.new()
	diner_affinity_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	diner_affinity_bar.custom_minimum_size.y = 8
	diner_affinity_bar.max_value = 100
	diner_affinity_bar.value = 35
	diner_affinity_bar.show_percentage = false
	aff_hbox.add_child(diner_affinity_bar)
	name_aff_vb.add_child(aff_hbox)
	
	h_char.add_child(name_aff_vb)
	right_vbox.add_child(h_char)
	
	# Speech Panel
	var speech_panel = PanelContainer.new()
	var sb_sp = StyleBoxFlat.new()
	sb_sp.bg_color = Color(0.03, 0.04, 0.05)
	sb_sp.set_border_width_all(1)
	sb_sp.border_color = Color(0.25, 0.35, 0.45)
	sb_sp.set_corner_radius_all(4)
	speech_panel.add_theme_stylebox_override("panel", sb_sp)
	right_vbox.add_child(speech_panel)
	
	diner_dialogue_label = Label.new()
	diner_dialogue_label.text = "Bevi questo espresso caldo, ragazzo. Su questa montagna il motore si tratta con rispetto."
	diner_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	diner_dialogue_label.add_theme_font_size_override("font_size", 10)
	diner_dialogue_label.add_theme_color_override("font_color", Color(0.92, 0.95, 0.95))
	speech_panel.add_child(diner_dialogue_label)
	
	# Dialogue Topic Options
	var topics_label = Label.new()
	topics_label.text = "🗨️ SELEZIONA ARGOMENTO DI CONVERSAZIONE:"
	topics_label.add_theme_font_size_override("font_size", 9)
	topics_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8))
	right_vbox.add_child(topics_label)
	
	diner_action_buttons_vbox = VBoxContainer.new()
	diner_action_buttons_vbox.add_theme_constant_override("separation", 5)
	right_vbox.add_child(diner_action_buttons_vbox)
	
	select_diner_character("bepi")
	return root

func select_diner_character(c_id: String):
	current_diner_char = c_id
	if not street_rod_manager: return
	if not diner_character_avatar: return
	var r = street_rod_manager.rivals.get(c_id, {})
	diner_character_avatar.text = r.get("avatar_icon", "👤")
	diner_character_name_label.text = "%s | %s" % [r.get("name", "").to_upper(), r.get("role", "").to_upper()]
	diner_dialogue_label.text = '"' + r.get("quote", "") + '"'
	
	var aff = r.get("affinity", 15)
	diner_affinity_bar.value = aff
	diner_affinity_label.text = "Affinità: %d%% [%s]" % [aff, get_affinity_title(aff)]
	
	for c in diner_action_buttons_vbox.get_children():
		c.queue_free()
		
	# 1. Ask Advice Button
	var btn_adv = Button.new()
	btn_adv.text = "💡 Chiedi Consigli Tecnici di Assetto & Guida"
	btn_adv.add_theme_font_size_override("font_size", 9)
	btn_adv.pressed.connect(func():
		var res = street_rod_manager.talk_to_character(c_id, "advice")
		diner_dialogue_label.text = '"' + res.text + '"'
		diner_affinity_bar.value = res.affinity
		diner_affinity_label.text = "Affinità: %d%% [%s]" % [res.affinity, get_affinity_title(res.affinity)]
	)
	diner_action_buttons_vbox.add_child(btn_adv)
	
	# 2. Ask Rumors Button
	var btn_rum = Button.new()
	btn_rum.text = "👂 Chiedi Voci sui Rivali & Segreti del Valico"
	btn_rum.add_theme_font_size_override("font_size", 9)
	btn_rum.pressed.connect(func():
		var res = street_rod_manager.talk_to_character(c_id, "rumors")
		diner_dialogue_label.text = '"' + res.text + '"'
		diner_affinity_bar.value = res.affinity
		diner_affinity_label.text = "Affinità: %d%% [%s]" % [res.affinity, get_affinity_title(res.affinity)]
	)
	diner_action_buttons_vbox.add_child(btn_rum)
	
	# 3. Contextual Special Actions
	if c_id == "bepi":
		var b_pkg = Button.new()
		b_pkg.text = "📦 Chiedi Incarichi & Consegne Urgenti del Fondovalle"
		b_pkg.add_theme_font_size_override("font_size", 9)
		b_pkg.pressed.connect(func(): open_screen(4))
		diner_action_buttons_vbox.add_child(b_pkg)
	elif c_id == "chiara":
		var b_barn = Button.new()
		b_barn.text = "🗺️ Apri Carta Topografica per la Cascina di San Rocco"
		b_barn.add_theme_font_size_override("font_size", 9)
		b_barn.pressed.connect(func(): open_screen(4))
		diner_action_buttons_vbox.add_child(b_barn)
	elif c_id == "sandra":
		var b_agip = Button.new()
		b_agip.text = "⛽ Vai all'Officina per acquistare Gomme & Manutenzione"
		b_agip.add_theme_font_size_override("font_size", 9)
		b_agip.pressed.connect(func(): open_screen(1))
		diner_action_buttons_vbox.add_child(b_agip)
	elif c_id == "don_attilio":
		var b_don = Button.new()
		b_don.text = "⛪ Ascolta la Cronaca del Rally delle Alpi 1974"
		b_don.add_theme_font_size_override("font_size", 9)
		b_don.pressed.connect(func():
			diner_dialogue_label.text = '"Vidi Sandro Munari su Lancia Stratos pennellare il tornante del campanile con un controsterzo magistrale. La folla applaudiva in ginocchio!"'
		)
		diner_action_buttons_vbox.add_child(b_don)
	elif r.has("bet_lire"):
		# Racing Rivals (Gino, Kurt, Hans, Duca)
		var riv_id = c_id
		var check_bet = street_rod_manager.can_challenge_rival(riv_id, false) if street_rod_manager and street_rod_manager.has_method("can_challenge_rival") else {"can_race": true}
		var b_drag = Button.new()
		b_drag.add_theme_font_size_override("font_size", 9)
		if check_bet.can_race:
			b_drag.text = "🏁 SFIDA AL RETTIFILO DEL LAGO (Scommessa: L. %s)" % street_rod_manager.format_lire(r.get("bet_lire", 500000))
			b_drag.pressed.connect(func(): start_drag_against_rival(riv_id, false))
		else:
			b_drag.text = "🔒 RETTIFILO: L. %s [BLOCCATA: %s]" % [
				street_rod_manager.format_lire(r.get("bet_lire", 500000)),
				check_bet.reason.split("!")[0] if "!" in check_bet.reason else check_bet.reason
			]
			b_drag.disabled = true
			b_drag.tooltip_text = check_bet.reason
		diner_action_buttons_vbox.add_child(b_drag)
		
		var check_pink = street_rod_manager.can_challenge_rival(riv_id, true) if street_rod_manager and street_rod_manager.has_method("can_challenge_rival") else {"can_race": true}
		var b_pink = Button.new()
		b_pink.add_theme_font_size_override("font_size", 9)
		if check_pink.can_race:
			b_pink.text = "📜 SFIDA A LIBRETTO (PINK SLIP: IN PALIO %s!)" % r.get("car_name", "L'AUTO")
			b_pink.add_theme_color_override("font_color", Color(1.0, 0.40, 0.35))
			b_pink.pressed.connect(func(): start_drag_against_rival(riv_id, true))
		else:
			b_pink.text = "🔒 SFIDA A LIBRETTO [BLOCCATA: %s]" % (check_pink.reason.split("!")[0] if "!" in check_pink.reason else check_pink.reason)
			b_pink.disabled = true
			b_pink.tooltip_text = check_pink.reason
		diner_action_buttons_vbox.add_child(b_pink)

func get_affinity_title(aff: int) -> String:
	if aff < 20: return "Diffidente"
	elif aff < 40: return "Conoscente"
	elif aff < 65: return "Amico del Diner"
	elif aff < 85: return "Fidato Consigliere"
	else: return "Fratello di Chiave Inglese 🤝"

# ==============================================================================
# TAB 4: RETTIFILO DRAG (1/4 MILE ACCELERATION & BETS)
# ==============================================================================
func build_drag_view() -> Control:
	var root = VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	
	var head = Label.new()
	head.text = "🏁 RETTIFILO DEL LAGO | SFIDA DI ACCELERAZIONE 1/4 DI MIGLIO (400M)"
	head.add_theme_font_size_override("font_size", 13)
	head.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	root.add_child(head)
	
	# Drag Start Christmas Tree Lights
	var lights_box = PanelContainer.new()
	var sb_l = StyleBoxFlat.new()
	sb_l.bg_color = Color(0.04, 0.04, 0.05)
	sb_l.border_color = Color(0.40, 0.45, 0.55)
	sb_l.set_border_width_all(2)
	sb_l.set_corner_radius_all(6)
	lights_box.add_theme_stylebox_override("panel", sb_l)
	root.add_child(lights_box)
	
	var lights_hbox = HBoxContainer.new()
	lights_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	lights_hbox.add_theme_constant_override("separation", 24)
	lights_box.add_child(lights_hbox)
	
	drag_lights_rects.clear()
	for i in range(4):
		var lamp = ColorRect.new()
		lamp.custom_minimum_size = Vector2(40, 40)
		lamp.color = Color(0.2, 0.2, 0.2) # Off
		lights_hbox.add_child(lamp)
		drag_lights_rects.append(lamp)
		
	# Race Telemetry / Log
	var log_panel = PanelContainer.new()
	log_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var sb_log = StyleBoxFlat.new()
	sb_log.bg_color = Color(0.02, 0.03, 0.04)
	sb_log.border_color = Color(0.18, 0.22, 0.28)
	sb_log.set_border_width_all(1)
	log_panel.add_theme_stylebox_override("panel", sb_log)
	root.add_child(log_panel)
	
	drag_log_label = Label.new()
	drag_log_label.text = "Seleziona un rivale al Diner, scalda le gomme e premi [AVVIA SEMAFORO].\nAl verde, premi [SPAZIO] all'istante per staccare la partenza!"
	drag_log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	drag_log_label.add_theme_font_size_override("font_size", 11)
	drag_log_label.add_theme_color_override("font_color", Color(0.85, 0.90, 0.95))
	log_panel.add_child(drag_log_label)
	
	var h_actions = HBoxContainer.new()
	h_actions.add_theme_constant_override("separation", 12)
	var btn_start_drag = Button.new()
	btn_start_drag.text = "🚦 AVVIA GARA 3D SUL RETTIFILO (CHIUDI ED ENTRA IN PISTA)"
	btn_start_drag.add_theme_font_size_override("font_size", 12)
	btn_start_drag.pressed.connect(start_drag_countdown)
	h_actions.add_child(btn_start_drag)
	root.add_child(h_actions)
	
	return root

func start_drag_against_rival(rival_id: String, is_pink_slip: bool):
	if street_rod_manager and street_rod_manager.has_method("can_challenge_rival"):
		var check = street_rod_manager.can_challenge_rival(rival_id, is_pink_slip)
		if not check.can_race:
			street_rod_manager.post_notification("SFIDA NON CONSENTITA", check.reason, "⚠️", "error")
			if diner_dialogue_label:
				diner_dialogue_label.text = "⚠️ REGOLE DI GARA NON SODDISFATTE: %s" % check.reason
			return
	drag_rival_id = rival_id
	drag_is_pink_slip = is_pink_slip
	# Chiude immediatamente la finestra per lasciare visuale libera e limpida sulla strada
	close_screen()
	emit_signal("race_start_requested", rival_id, is_pink_slip)

func start_drag_countdown():
	if street_rod_manager and street_rod_manager.has_method("can_challenge_rival"):
		var check = street_rod_manager.can_challenge_rival(drag_rival_id, drag_is_pink_slip)
		if not check.can_race:
			street_rod_manager.post_notification("SFIDA NON CONSENTITA", check.reason, "⚠️", "error")
			if drag_log_label:
				drag_log_label.text = "⚠️ REGOLE DI GARA NON SODDISFATTE:\n%s" % check.reason
			return
	# Chiude immediatamente la finestra ed entra nella gara 3D reale
	close_screen()
	emit_signal("race_start_requested", drag_rival_id, drag_is_pink_slip)

func update_drag_countdown(delta: float):
	drag_timer += delta
	if drag_timer >= 0.8:
		drag_timer = 0.0
		if drag_light_idx < 3:
			# Yellow light
			drag_lights_rects[drag_light_idx].color = Color(1.0, 0.80, 0.10)
			drag_light_idx += 1
		elif drag_light_idx == 3:
			# GREEN LIGHT!
			drag_lights_rects[3].color = Color(0.10, 1.0, 0.25)
			drag_state = "racing"
			drag_reaction_start = Time.get_ticks_msec() / 1000.0
			drag_log_label.text = "🟢 VERDE! VERDE! PREMI [SPAZIO] ORA!"

func on_drag_launch_trigger():
	if drag_state != "racing": return
	drag_state = "finished"
	var now = Time.get_ticks_msec() / 1000.0
	var reaction_sec = max(0.01, now - drag_reaction_start)
	
	# Calculate simulated 1/4 mile time based on current car performance & upgrades
	var car = street_rod_manager.get_active_car()
	var base_quarter_mile = 18.5
	match car.get("car_id", "fiat_127"):
		"fiat_127": base_quarter_mile = 19.8
		"panda_4x4": base_quarter_mile = 20.5
		"renault_4": base_quarter_mile = 21.0
		"fiat_topolino": base_quarter_mile = 24.5
		"alfa_8c": base_quarter_mile = 16.8
		"lancia_aurelia": base_quarter_mile = 17.5
		"alfa_gta": base_quarter_mile = 15.6
		"fiat_131_abarth": base_quarter_mile = 15.9
		"lancia_stratos": base_quarter_mile = 14.4
		"golf_gti_1990": base_quarter_mile = 15.8
		"bmw_320_e30": base_quarter_mile = 16.5
		"mercedes_gwagen": base_quarter_mile = 19.5
		"delta_integrale": base_quarter_mile = 13.9
		"mercedes_a250": base_quarter_mile = 14.1
		
	# Upgrade bonuses
	var parts = car.get("tuning_parts", [])
	if parts.has("scarico_sport"): base_quarter_mile -= 0.4
	if parts.has("carburatori_doppi"): base_quarter_mile -= 0.6
	if parts.has("camme_spinte"): base_quarter_mile -= 0.5
	if parts.has("overboost_turbo"): base_quarter_mile -= 0.7
	if car.get("tire_type") == "semislick": base_quarter_mile -= 0.5
	
	var final_player_time = base_quarter_mile + reaction_sec
	var res = street_rod_manager.resolve_drag_race(drag_rival_id, final_player_time, drag_is_pink_slip)
	
	drag_log_label.text = "🏁 GARA CONCLUSA!\nTempo di Reazione al Verde: %.3fs\nIl Tuo Tempo 1/4 Miglio: %.2fs\nTempo Rivale (%s): %.2fs\nRisultato: %s!" % [
		reaction_sec,
		final_player_time,
		street_rod_manager.rivals[drag_rival_id].name,
		res.rival_time,
		("VITTORIA SCHIACCIANTE! 🏆" if res.won else "SCONFITTA AL TRAGUARDO... 💨")
	]

# ==============================================================================
# TAB 5: CARTA TOPOGRAFICA IGM '93 & SPEDIZIONE DEL MERIDIANO
# ==============================================================================
const TopographicMapControl = preload("res://scripts/TopographicMapControl.gd")

var contracts_vbox: VBoxContainer
var map_waypoint_buttons_vbox: VBoxContainer
var map_detail_name: Label
var map_detail_stats: Label
var map_detail_weather: Label
var map_detail_surface: Label
var map_detail_chars: Label
var map_detail_services: Label
var map_detail_lore: Label
var map_player_marker_label: Label
var chapter_status_label: Label
var selected_map_idx: int = 0
var topographic_map: TopographicMapControl

func build_missions_view() -> Control:
	var root = HBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	
	# Left: Topographic Map Waypoints & Elevation Profile
	var left_p = PanelContainer.new()
	left_p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_p.size_flags_stretch_ratio = 1.05
	var sb_l = StyleBoxFlat.new()
	sb_l.bg_color = Color(0.04, 0.06, 0.07)
	sb_l.border_color = Color(0.18, 0.42, 0.32)
	sb_l.set_border_width_all(1)
	sb_l.set_corner_radius_all(4)
	left_p.add_theme_stylebox_override("panel", sb_l)
	root.add_child(left_p)
	
	var left_vb = VBoxContainer.new()
	left_vb.add_theme_constant_override("separation", 6)
	left_p.add_child(left_vb)
	
	var map_head = Label.new()
	map_head.text = "🗺️ CARTA TOPOGRAFICA DEL MERIDIANO (IGM / TOURING '83)"
	map_head.add_theme_font_size_override("font_size", 10)
	map_head.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	left_vb.add_child(map_head)
	
	map_player_marker_label = Label.new()
	map_player_marker_label.text = "📍 TU SEI QUI: Borgo San Cristoforo (Quota 420m s.l.m.)"
	map_player_marker_label.add_theme_font_size_override("font_size", 9)
	map_player_marker_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55))
	left_vb.add_child(map_player_marker_label)
	
	# Visual Topographic Map (Vector CRT 1980s IGM)
	topographic_map = TopographicMapControl.new()
	topographic_map.custom_minimum_size = Vector2(380, 240)
	topographic_map.size_flags_vertical = Control.SIZE_EXPAND_FILL
	topographic_map.waypoint_clicked.connect(func(idx): select_map_waypoint(idx))
	left_vb.add_child(topographic_map)
	
	var scroll_wp = ScrollContainer.new()
	scroll_wp.custom_minimum_size = Vector2(0, 110)
	left_vb.add_child(scroll_wp)
	
	map_waypoint_buttons_vbox = VBoxContainer.new()
	map_waypoint_buttons_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_waypoint_buttons_vbox.add_theme_constant_override("separation", 4)
	scroll_wp.add_child(map_waypoint_buttons_vbox)
	
	# Right: Waypoint Dossier & Narrative Chapter
	var right_p = PanelContainer.new()
	right_p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_p.size_flags_stretch_ratio = 1.25
	var sb_r = StyleBoxFlat.new()
	sb_r.bg_color = Color(0.08, 0.10, 0.14)
	sb_r.border_color = Color(0.30, 0.45, 0.65)
	sb_r.set_border_width_all(1)
	sb_r.set_corner_radius_all(4)
	right_p.add_theme_stylebox_override("panel", sb_r)
	root.add_child(right_p)
	
	var right_vb = VBoxContainer.new()
	right_vb.add_theme_constant_override("separation", 6)
	right_p.add_child(right_vb)
	
	map_detail_name = Label.new()
	map_detail_name.text = "BORGO STORICO DI SAN CRISTOFORO"
	map_detail_name.add_theme_font_size_override("font_size", 12)
	map_detail_name.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
	right_vb.add_child(map_detail_name)
	
	map_detail_stats = Label.new()
	map_detail_stats.text = "Settore: km 0.0 - 0.9 | Quota: 420m s.l.m. | Pendenza: +2.5%"
	map_detail_stats.add_theme_font_size_override("font_size", 9)
	map_detail_stats.add_theme_color_override("font_color", Color(0.40, 1.0, 0.60))
	right_vb.add_child(map_detail_stats)
	
	map_detail_weather = Label.new()
	map_detail_weather.text = "⛅ Meteo Locale: Sereno autunnale (14°C)"
	map_detail_weather.add_theme_font_size_override("font_size", 9)
	map_detail_weather.add_theme_color_override("font_color", Color(0.85, 0.90, 0.95))
	right_vb.add_child(map_detail_weather)
	
	map_detail_surface = Label.new()
	map_detail_surface.text = "🛣️ Fondo Stradale: Porfido & asfalto riparato"
	map_detail_surface.add_theme_font_size_override("font_size", 9)
	map_detail_surface.add_theme_color_override("font_color", Color(0.85, 0.90, 0.95))
	right_vb.add_child(map_detail_surface)
	
	map_detail_chars = Label.new()
	map_detail_chars.text = "👥 Abitanti & Figure: Mastro Bepi, Don Attilio, Gino"
	map_detail_chars.add_theme_font_size_override("font_size", 9)
	map_detail_chars.add_theme_color_override("font_color", Color(1.0, 0.75, 0.30))
	right_vb.add_child(map_detail_chars)
	
	map_detail_services = Label.new()
	map_detail_services.text = "🏛️ Servizi: Officina Bepi, Bar dello Sport, Cabina SIP"
	map_detail_services.add_theme_font_size_override("font_size", 9)
	map_detail_services.add_theme_color_override("font_color", Color(0.70, 0.85, 1.0))
	right_vb.add_child(map_detail_services)
	
	var lore_p = PanelContainer.new()
	var sb_lp = StyleBoxFlat.new()
	sb_lp.bg_color = Color(0.04, 0.05, 0.07)
	sb_lp.border_color = Color(0.20, 0.25, 0.35)
	sb_lp.set_border_width_all(1)
	sb_lp.set_corner_radius_all(3)
	lore_p.add_theme_stylebox_override("panel", sb_lp)
	right_vb.add_child(lore_p)
	
	map_detail_lore = Label.new()
	map_detail_lore.text = "Antico borgo di pietra che fa da porta d'ingresso alla vallata. Punto di ritrovo di tutti gli appassionati e quartier generale dell'Officina Meccanica di Mastro Bepi."
	map_detail_lore.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	map_detail_lore.add_theme_font_size_override("font_size", 9)
	map_detail_lore.add_theme_color_override("font_color", Color(0.85, 0.88, 0.90))
	lore_p.add_child(map_detail_lore)
	
	# Bottom: Contracts scroll box
	var contr_head = Label.new()
	contr_head.text = "📋 MISSIONI & INCARICHI ATTIVI:"
	contr_head.add_theme_font_size_override("font_size", 10)
	contr_head.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55))
	right_vb.add_child(contr_head)
	
	var scroll_c = ScrollContainer.new()
	scroll_c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vb.add_child(scroll_c)
	
	contracts_vbox = VBoxContainer.new()
	contracts_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contracts_vbox.add_theme_constant_override("separation", 5)
	scroll_c.add_child(contracts_vbox)
	
	return root

func refresh_missions_view():
	if not street_rod_manager: return
	
	# 1. Populate map waypoints
	if map_waypoint_buttons_vbox:
		for c in map_waypoint_buttons_vbox.get_children():
			c.queue_free()
		var locs = street_rod_manager.get_map_locations()
		for i in range(locs.size()):
			var loc = locs[i]
			var btn_wp = Button.new()
			var is_sel = (i == selected_map_idx)
			btn_wp.text = ("▶ " if is_sel else "  ") + "[%dm] " % loc.altitude_m + loc.name
			btn_wp.add_theme_font_size_override("font_size", 9)
			if is_sel:
				btn_wp.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
			var idx = i
			btn_wp.pressed.connect(func(): select_map_waypoint(idx))
			map_waypoint_buttons_vbox.add_child(btn_wp)
			
	select_map_waypoint(selected_map_idx)
	
	# 2. Populate contracts
	if contracts_vbox:
		for c in contracts_vbox.get_children():
			c.queue_free()
		for c_data in street_rod_manager.contracts:
			var c_box = PanelContainer.new()
			var sb_c = StyleBoxFlat.new()
			if c_data.completed:
				sb_c.bg_color = Color(0.08, 0.16, 0.10)
				sb_c.border_color = Color(0.35, 0.85, 0.45)
			elif c_data.active:
				sb_c.bg_color = Color(0.10, 0.12, 0.16)
				sb_c.border_color = Color(0.95, 0.75, 0.20)
			else:
				sb_c.bg_color = Color(0.05, 0.06, 0.08)
				sb_c.border_color = Color(0.20, 0.25, 0.30)
			sb_c.set_border_width_all(1)
			sb_c.set_corner_radius_all(3)
			c_box.add_theme_stylebox_override("panel", sb_c)
			
			var vb = VBoxContainer.new()
			vb.add_theme_constant_override("separation", 2)
			c_box.add_child(vb)
			
			var h_top = HBoxContainer.new()
			var l_tit = Label.new()
			l_tit.text = ("✓ " if c_data.completed else ("▶ " if c_data.active else "🔒 ")) + c_data.title
			l_tit.add_theme_font_size_override("font_size", 9)
			l_tit.add_theme_color_override("font_color", (Color(0.4, 1.0, 0.5) if c_data.completed else (Color(1.0, 0.85, 0.2) if c_data.active else Color(0.6, 0.65, 0.7))))
			h_top.add_child(l_tit)
			
			var sp = Control.new()
			sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			h_top.add_child(sp)
			
			var l_rew = Label.new()
			l_rew.text = "+L. %s" % street_rod_manager.format_lire(c_data.reward_lire)
			l_rew.add_theme_font_size_override("font_size", 9)
			l_rew.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
			h_top.add_child(l_rew)
			vb.add_child(h_top)
			
			var l_desc = Label.new()
			l_desc.text = "%s (%s)" % [c_data.lore, c_data.destination]
			l_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			l_desc.add_theme_font_size_override("font_size", 8)
			l_desc.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
			vb.add_child(l_desc)
			
			contracts_vbox.add_child(c_box)

func select_map_waypoint(idx: int):
	selected_map_idx = idx
	if topographic_map:
		topographic_map.set_selected_waypoint(idx)
	if not street_rod_manager: return
	var locs = street_rod_manager.get_map_locations()
	if idx < 0 or idx >= locs.size(): return
	var loc = locs[idx]
	
	if map_detail_name: map_detail_name.text = loc.name.to_upper()
	if map_detail_stats: map_detail_stats.text = "Settore: %s | Quota: %dm s.l.m. | Pendenza: %s" % [loc.km_range, loc.altitude_m, loc.gradient_pct]
	if map_detail_weather: map_detail_weather.text = "⛅ Meteo: %s" % loc.weather
	if map_detail_surface: map_detail_surface.text = "🛣️ Fondo: %s" % loc.surface
	if map_detail_chars: map_detail_chars.text = "👥 Personaggi: %s" % loc.characters
	if map_detail_services: map_detail_services.text = "🏛️ Servizi: %s" % loc.services
	if map_detail_lore: map_detail_lore.text = loc.lore

# ==============================================================================
# TOAST NOTIFICATIONS & TAB NAVIGATION
# ==============================================================================
func setup_toast_panel():
	toast_panel = PanelContainer.new()
	toast_panel.anchors_preset = Control.PRESET_TOP_WIDE
	toast_panel.position = Vector2(240, 20)
	toast_panel.size = Vector2(440, 48)
	var sb_t = StyleBoxFlat.new()
	sb_t.bg_color = Color(0.08, 0.12, 0.16, 0.95)
	sb_t.border_color = Color(0.95, 0.75, 0.15, 0.95)
	sb_t.set_border_width_all(2)
	sb_t.set_corner_radius_all(6)
	sb_t.shadow_size = 18
	toast_panel.add_theme_stylebox_override("panel", sb_t)
	
	toast_label = Label.new()
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.add_theme_font_size_override("font_size", 11)
	toast_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.35))
	toast_panel.add_child(toast_label)
	toast_panel.visible = false
	add_child(toast_panel)

# ==============================================================================
# ONBOARDING ACCOGLIENZA PILOTA (STREET ROD STYLE WELCOME MANUAL)
# ==============================================================================
func setup_onboarding_modal():
	onboarding_modal = PanelContainer.new()
	onboarding_modal.anchors_preset = Control.PRESET_CENTER
	onboarding_modal.custom_minimum_size = Vector2(740, 520)
	onboarding_modal.position = Vector2(120, 35)
	
	var sb_guide = StyleBoxFlat.new()
	sb_guide.bg_color = Color(0.06, 0.08, 0.12, 0.98) # Dark Amiga Slate
	sb_guide.border_color = Color(0.95, 0.75, 0.18, 0.98) # Lustrous Gold
	sb_guide.border_width_left = 3
	sb_guide.border_width_top = 3
	sb_guide.border_width_right = 3
	sb_guide.border_width_bottom = 3
	sb_guide.set_corner_radius_all(8)
	sb_guide.shadow_size = 35
	sb_guide.shadow_color = Color(0, 0, 0, 0.95)
	onboarding_modal.add_theme_stylebox_override("panel", sb_guide)
	
	var guide_vb = VBoxContainer.new()
	guide_vb.add_theme_constant_override("separation", 10)
	onboarding_modal.add_child(guide_vb)
	
	# Header with Italian Tricolour bar
	var g_hdr = PanelContainer.new()
	var sb_gh = StyleBoxFlat.new()
	sb_gh.bg_color = Color(0.0, 0.30, 0.60, 0.95)
	sb_gh.border_color = Color(0.95, 0.75, 0.15)
	sb_gh.border_width_bottom = 2
	g_hdr.add_theme_stylebox_override("panel", sb_gh)
	guide_vb.add_child(g_hdr)
	
	var gh_hb = HBoxContainer.new()
	gh_hb.add_theme_constant_override("separation", 10)
	g_hdr.add_child(gh_hb)
	
	var gh_title = Label.new()
	gh_title.text = " 🏁 MANUALE DEL PILOTA - VALICO DEI MOTORI '93 (OFFICINA PAOLO)"
	gh_title.add_theme_font_size_override("font_size", 12)
	gh_title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.25))
	gh_hb.add_child(gh_title)
	
	var sp_gh = Control.new(); sp_gh.size_flags_horizontal = Control.SIZE_EXPAND_FILL; gh_hb.add_child(sp_gh)
	
	var btn_close_x = Button.new()
	btn_close_x.text = " [X] "
	btn_close_x.pressed.connect(hide_onboarding_guide)
	gh_hb.add_child(btn_close_x)
	
	# Scrollable narrative content
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	guide_vb.add_child(scroll)
	
	var txt_vb = VBoxContainer.new()
	txt_vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	txt_vb.add_theme_constant_override("separation", 8)
	scroll.add_child(txt_vb)
	
	var intro_lbl = Label.new()
	intro_lbl.text = "Benvenuto, ragazzo! Sono Paolo, ingegnere meccanico e collaudatore.\nHai lasciato la pianura e sei salito quassù al Valico alpino con 3.500.000 Lire in tasca e una passione travolgente per i motori d'epoca.\nQuesta è la mia officina: qui non ci sono computer moderni, solo chiavi inglesi, grasso sui vestiti e pura meccanica.\nTi lascio sui cavalletti la mitica Fiat 127 Special (1974), leggera e grintosa.\n\nEcco come funziona la vita quassù (ispirata ai grandi classici alla Street Rod):"
	intro_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro_lbl.add_theme_font_size_override("font_size", 10)
	intro_lbl.add_theme_color_override("font_color", Color(0.90, 0.94, 0.98))
	txt_vb.add_child(intro_lbl)
	
	var steps = [
		{
			"icon": "🔧",
			"title": "1. IL VANO MOTORE (CLICCA SUL COFANO)",
			"desc": "Apri il cofano per elaborare il motore: monta i doppi carburatori Weber DCOE con tromboncini cromati per un'aspirazione da brividi, lo scarico tubolare 4-in-1 Abarth, o fai il tagliando olio Agip Sint 2000 per ripristinare i cavalli perduti."
		},
		{
			"icon": "🛞",
			"title": "2. LE RUOTE E L'ASSETTO (CLICCA SULLE GOMME)",
			"desc": "La gommatura è fondamentale sulle Alpi! Usa le Pirelli P7 Corsa su asfalto asciutto per la massima aderenza nei tornanti, ma se sali in quota verso il valico ghiacciato monta le tassellate chiodate da neve per non finire nel burrone."
		},
		{
			"icon": "🎨",
			"title": "3. CARROZZERIA & ALLEGGERIMENTO (CLICCA SULLA VERNICE)",
			"desc": "Rivernicia l'auto nelle tinte storiche (Azzurro Iseo, Rosso Corsa, Verde Muschio...) o togli i paraurti per risparmiare 18 kg di peso come facevano i veri Street Rodder italiani negli anni '70!"
		},
		{
			"icon": "🕹️",
			"title": "4. TRASMISSIONE & INTERNI (CLICCA SULL'ABITACOLO)",
			"desc": "Installa un cambio ravvicinato 5 marce Bacci per non far mai scendere il motore di giri nelle salite ripide, frizione in rame e volante sportivo Momo."
		},
		{
			"icon": "🚪",
			"title": "5. IL COLLAUDO IN STRADA (CLICCA SUL PORTONE)",
			"desc": "Apri il portone scorrevole ed esci a collaudare l'auto sui tornanti delle Alpi! Saggia l'accelerazione, la scalata di marcia e la frenata prima di rischiare i tuoi soldi."
		},
		{
			"icon": "🏁",
			"title": "6. LE SFIDE AL RETTIFILO 400M (CLICCA SULLA LOCANDINA)",
			"desc": "Al Diner 'Da Bepi' si ritrovano i piloti locali: sfida Gino con la Panda 4x4 o Kurt con la BMW E30 al semaforo del lago. Puoi scommettere Lire o giocarti l'auto a libretto (Pink Slip)!"
		},
		{
			"icon": "📰",
			"title": "7. IL MERCATINO USATO (CLICCA SUL GIORNALE)",
			"desc": "Sfoglia gli annunci del mercatino per comprare nuove auto usate (Lancia Delta Integrale, Golf GTI, Topolino...) e ampliare la tua collezione nel garage!"
		}
	]
	
	for s in steps:
		var s_box = PanelContainer.new()
		var sb_s = StyleBoxFlat.new()
		sb_s.bg_color = Color(0.08, 0.11, 0.16)
		sb_s.border_color = Color(0.25, 0.35, 0.50)
		sb_s.set_border_width_all(1)
		sb_s.set_corner_radius_all(4)
		s_box.add_theme_stylebox_override("panel", sb_s)
		txt_vb.add_child(s_box)
		
		var s_vb = VBoxContainer.new()
		s_vb.add_theme_constant_override("separation", 2)
		s_box.add_child(s_vb)
		
		var s_t = Label.new()
		s_t.text = "%s %s" % [s.icon, s.title]
		s_t.add_theme_font_size_override("font_size", 9)
		s_t.add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
		s_vb.add_child(s_t)
		
		var s_d = Label.new()
		s_d.text = s.desc
		s_d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		s_d.add_theme_font_size_override("font_size", 8)
		s_d.add_theme_color_override("font_color", Color(0.80, 0.86, 0.92))
		s_vb.add_child(s_d)
		
	# Big Start Button
	var btn_start = Button.new()
	btn_start.text = " 🔧 HO CAPITO! ENTRIAMO IN OFFICINA ED ELABORIAMO L'AUTO! 🚗 "
	btn_start.add_theme_font_size_override("font_size", 11)
	btn_start.add_theme_color_override("font_color", Color(0.15, 1.0, 0.35))
	var sb_bs = StyleBoxFlat.new()
	sb_bs.bg_color = Color(0.08, 0.25, 0.14)
	sb_bs.border_color = Color(0.35, 1.0, 0.45)
	sb_bs.set_border_width_all(2)
	sb_bs.set_corner_radius_all(6)
	btn_start.add_theme_stylebox_override("normal", sb_bs)
	btn_start.pressed.connect(hide_onboarding_guide)
	guide_vb.add_child(btn_start)
	
	onboarding_modal.visible = false
	add_child(onboarding_modal)

func show_onboarding_guide():
	if not onboarding_modal:
		setup_onboarding_modal()
	onboarding_modal.visible = true
	move_child(onboarding_modal, get_child_count() - 1)

func hide_onboarding_guide():
	has_seen_onboarding = true
	if onboarding_modal:
		onboarding_modal.visible = false
	if street_rod_manager and street_rod_manager.has_method("play_sfx"):
		street_rod_manager.play_sfx("chime")

func show_toast(title: String, msg: String, icon: String, _sfx: String):
	if toast_panel and toast_label:
		toast_label.text = "%s %s\n%s" % [icon, title, msg]
		toast_panel.visible = true
		toast_timer = 4.2

func switch_tab(tab_idx: int):
	current_tab = tab_idx
	play_click_sfx()
	if bg_dim:
		bg_dim.color = Color(0.0, 0.0, 0.0, 0.0) if tab_idx == 0 else Color(0.03, 0.05, 0.08, 0.96)
	if sb_amiga_panel:
		if tab_idx == 0:
			sb_amiga_panel.bg_color = Color(0.0, 0.0, 0.0, 0.0)
			sb_amiga_panel.set_border_width_all(0)
			sb_amiga_panel.shadow_size = 0
		else:
			sb_amiga_panel.bg_color = Color(0.06, 0.08, 0.12, 0.98)
			sb_amiga_panel.border_color = Color(0.12, 0.45, 0.85, 0.90)
			sb_amiga_panel.set_border_width_all(2)
			sb_amiga_panel.shadow_size = 24
	if sb_content_panel:
		if tab_idx == 0:
			sb_content_panel.bg_color = Color(0.0, 0.0, 0.0, 0.0)
			sb_content_panel.set_border_width_all(0)
		else:
			sb_content_panel.bg_color = Color(0.05, 0.07, 0.10, 0.95)
			sb_content_panel.border_color = Color(0.20, 0.35, 0.55)
			sb_content_panel.set_border_width_all(1)
			
	for i in range(tab_containers.size()):
		tab_containers[i].visible = (i == tab_idx)
		if i == tab_idx:
			tab_buttons[i].add_theme_color_override("font_color", Color(1.0, 0.85, 0.20))
		else:
			tab_buttons[i].remove_theme_color_override("font_color")
			
	match tab_idx:
		0:
			emit_signal("garage_inspection_view_requested", "default")
			refresh_hub_view()
		1: refresh_garage_view()
		2: refresh_market_view()
		3: select_diner_character(current_diner_char)
		5: refresh_missions_view()

func open_screen(tab_idx: int = 0):
	if not is_interface_setup:
		setup_amiga_interface()
	is_open = true
	visible = true
	switch_tab(tab_idx)
	if street_rod_manager:
		on_career_updated({
			"cash_formatted": street_rod_manager.format_lire(street_rod_manager.cash_lire),
			"reputation": street_rod_manager.reputation,
			"rep_title": street_rod_manager.get_reputation_title(),
			"active_car": street_rod_manager.get_active_car()
		})
	if not has_seen_onboarding and tab_idx == 0:
		show_onboarding_guide()

func close_screen():
	is_open = false
	visible = false
	emit_signal("request_close")

func on_career_updated(info: Dictionary):
	if stats_cash_label:
		stats_cash_label.text = " 💰 LIRE: L. " + info.get("cash_formatted", "3.500.000")
	if stats_rep_label:
		stats_rep_label.text = " ⭐ RISPETTO: %d [%s]" % [
			info.get("reputation", 40),
			info.get("rep_title", "Novellino")
		]
	if stats_car_label and info.has("active_car") and not info["active_car"].is_empty():
		stats_car_label.text = " 🏎️ IN USO: " + info["active_car"].get("name", "Fiat 127")
		
	if is_open:
		match current_tab:
			0: refresh_hub_view()
			1: refresh_garage_view()
			2: refresh_market_view()
			5: refresh_missions_view()

func on_car_switched(car_data: Dictionary):
	emit_signal("car_model_changed", car_data.get("car_id", "fiat_127"))
	emit_signal("upgrades_applied", car_data)
	if stats_car_label:
		stats_car_label.text = " 🏎️ IN USO: " + car_data.get("name", "")
