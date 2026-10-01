extends Control
class_name DashboardUI

# THE LONG MERIDIAN - Authentic Multi-Vehicle Cockpit Dashboard (Godot 4)
# Faithfully renders 3 distinct vintage European instrument clusters:
# 1. VEGLIA BORLETTI PANDA (1983): Horizontal fabric marsupio, dual clinometer, green LCD quartz
# 2. VEGLIA COMPETIZIONE CORSE (1991): Lancia Delta WRC Gr.A amber/red dials, live Garrett turbo boost
# 3. VDO STUTTGART (1979): Mercedes-Benz G-Klasse silver bezel dials, 3x mechanical diff locks

signal change_vehicle_requested

# Clusters
@onready var cluster_panda: Control = $Panel/PandaCluster
@onready var cluster_delta: Control = $Panel/DeltaCluster
@onready var cluster_gwagen: Control = $Panel/GwagenCluster

# Header bar
@onready var label_region: Label = $Panel/LabelRegion
@onready var label_vehicle_name: Label = $Panel/LabelVehicleName
@onready var btn_change_car: Button = $Panel/BtnChangeCar
@onready var btn_fs: Button = $Panel/BtnFullscreen

# 1. PANDA 4x4 VEGLIA BORLETTI
@onready var p_speed: Label = $Panel/PandaCluster/SpeedBox/LabelSpeed
@onready var p_rpm: Label = $Panel/PandaCluster/RpmBox/LabelRPM
@onready var p_gear: Label = $Panel/PandaCluster/GearBox/LabelGear
@onready var p_4wd: Label = $Panel/PandaCluster/GearBox/Label4WD
@onready var p_fuel: ProgressBar = $Panel/PandaCluster/TelemetryBox/ProgressFuel
@onready var p_temp: Label = $Panel/PandaCluster/TelemetryBox/LabelTemp
@onready var p_clino: Label = $Panel/PandaCluster/ClinoBox/LabelClino

# 2. LANCIA DELTA HF INTEGRALE VEGLIA CORSE
@onready var d_speed: Label = $Panel/DeltaCluster/SpeedBox/LabelSpeed
@onready var d_rpm: Label = $Panel/DeltaCluster/RpmBox/LabelRPM
@onready var d_gear: Label = $Panel/DeltaCluster/GearBox/LabelGear
@onready var d_awd: Label = $Panel/DeltaCluster/GearBox/LabelAWD
@onready var d_turbo_val: Label = $Panel/DeltaCluster/TurboBox/LabelTurboVal
@onready var d_turbo_bar: ProgressBar = $Panel/DeltaCluster/TurboBox/ProgressTurbo
@onready var d_fuel: ProgressBar = $Panel/DeltaCluster/TelemetryBox/ProgressFuel
@onready var d_temp: Label = $Panel/DeltaCluster/TelemetryBox/LabelTemp

# 3. MERCEDES-BENZ G-KLASSE VDO STUTTGART
@onready var g_speed: Label = $Panel/GwagenCluster/SpeedBox/LabelSpeed
@onready var g_rpm: Label = $Panel/GwagenCluster/RpmBox/LabelRPM
@onready var g_gear: Label = $Panel/GwagenCluster/GearBox/LabelGear
@onready var g_diff: Label = $Panel/GwagenCluster/GearBox/LabelDiff
@onready var g_fuel: ProgressBar = $Panel/GwagenCluster/TelemetryBox/ProgressFuel
@onready var g_temp: Label = $Panel/GwagenCluster/TelemetryBox/LabelTemp
@onready var g_clino: Label = $Panel/GwagenCluster/ClinoBox/LabelClino

var current_model_id: String = ""

func _ready():
    if btn_fs:
        btn_fs.pressed.connect(_on_fullscreen_pressed)
    if btn_change_car:
        btn_change_car.pressed.connect(_on_change_vehicle_pressed)

func update_region(region_name: String):
    if label_region:
        label_region.text = region_name

func update_telemetry(speed_kmh: float, rpm_norm: float, gear_str: String, fuel_l: float, temp_c: float, pitch_deg: float, roll_deg: float, is_4wd: bool, boost_bar: float, model_info: Dictionary):
    var m_id = model_info.get("id", "panda_4x4")
    
    # Switch active cluster skin if vehicle model changed
    if m_id != current_model_id:
        current_model_id = m_id
        if cluster_panda: cluster_panda.visible = (m_id == "panda_4x4")
        if cluster_delta: cluster_delta.visible = (m_id == "delta_integrale")
        if cluster_gwagen: cluster_gwagen.visible = (m_id == "mercedes_gwagen")
        
        if label_vehicle_name:
            label_vehicle_name.text = model_info.get("name", "").to_upper()
            
        if btn_change_car:
            btn_change_car.text = "[C] " + model_info.get("short_name", "AUTO")
            
    # Update cluster-specific instruments
    if m_id == "delta_integrale":
        update_delta_cluster(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, boost_bar, model_info)
    elif m_id == "mercedes_gwagen":
        update_gwagen_cluster(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, pitch_deg, roll_deg, is_4wd, model_info)
    else:
        update_panda_cluster(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, pitch_deg, roll_deg, is_4wd, model_info)

func update_panda_cluster(speed_kmh: float, rpm_norm: float, gear_str: String, fuel_l: float, temp_c: float, pitch_deg: float, roll_deg: float, is_4wd: bool, _info: Dictionary):
    if p_speed: p_speed.text = "%3d" % int(round(speed_kmh))
    if p_rpm:
        var rpm_display = 0.85 + rpm_norm * 5.15
        p_rpm.text = "%.1f" % rpm_display
    if p_gear: p_gear.text = gear_str
    if p_4wd:
        p_4wd.text = "4WD STEYR-PUCH [50:50]" if is_4wd else "TRAZIONE ANTERIORE [FWD]"
        p_4wd.modulate = Color(0.2, 0.95, 0.3) if is_4wd else Color(0.95, 0.65, 0.2)
    if p_fuel:
        p_fuel.max_value = 35.0
        p_fuel.value = fuel_l
    if p_temp: p_temp.text = "%d°C (ACQUA)" % int(round(temp_c))
    if p_clino:
        p_clino.text = "PITCH: %+02d° | ROLL: %+02d°" % [int(round(pitch_deg)), int(round(roll_deg))]

func update_delta_cluster(speed_kmh: float, rpm_norm: float, gear_str: String, fuel_l: float, temp_c: float, boost_bar: float, _info: Dictionary):
    if d_speed: d_speed.text = "%3d" % int(round(speed_kmh))
    if d_rpm:
        var rpm_actual = 950.0 + rpm_norm * 5850.0
        d_rpm.text = "%d" % int(round(rpm_actual))
    if d_gear: d_gear.text = gear_str
    if d_awd:
        d_awd.text = "TORSEN AWD PERMANENTE [47:53]"
        d_awd.modulate = Color(0.95, 0.75, 0.15)
    if d_turbo_val:
        d_turbo_val.text = "%+1.2f BAR" % boost_bar
    if d_turbo_bar:
        d_turbo_bar.max_value = 1.6
        d_turbo_bar.value = boost_bar
    if d_fuel:
        d_fuel.max_value = 57.0
        d_fuel.value = fuel_l
    if d_temp:
        d_temp.text = "%d°C (ACQUA) | 4.8 BAR (OLIO)" % int(round(temp_c))

func update_gwagen_cluster(speed_kmh: float, rpm_norm: float, gear_str: String, fuel_l: float, temp_c: float, pitch_deg: float, roll_deg: float, is_4wd: bool, _info: Dictionary):
    if g_speed: g_speed.text = "%3d" % int(round(speed_kmh))
    if g_rpm:
        var rpm_display = 0.80 + rpm_norm * 5.20
        g_rpm.text = "%.1f" % rpm_display
    if g_gear: g_gear.text = gear_str
    if g_diff:
        if is_4wd:
            g_diff.text = "[DIFF-LOCK ANT: 100%] [DIFF CENT: 100%] [DIFF POST: 100%]"
            g_diff.modulate = Color(0.2, 0.9, 0.3)
        else:
            g_diff.text = "[TRAZIONE POSTERIORE RWD]"
            g_diff.modulate = Color(0.9, 0.7, 0.2)
    if g_fuel:
        g_fuel.max_value = 68.0
        g_fuel.value = fuel_l
    if g_temp: g_temp.text = "%d°C (VDO COOLANT)" % int(round(temp_c))
    if g_clino:
        g_clino.text = "BECCHEGGIO: %+02d° | ROLLIO: %+02d°" % [int(round(pitch_deg)), int(round(roll_deg))]

func _on_change_vehicle_pressed():
    emit_signal("change_vehicle_requested")

func _on_fullscreen_pressed():
    if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
