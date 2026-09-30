extends Control
class_name DashboardUI

# THE LONG MERIDIAN - Veglia Borletti Cockpit Dashboard UI (Godot 4)
# Visualizes live vehicle telemetry: speed, RPM, transmission gear, 4WD status,
# fuel level, coolant temp, and clinometer pitch/roll in retro-futuristic rally style.

@onready var label_speed: Label = $Panel/SpeedBox/LabelSpeed
@onready var label_rpm: Label = $Panel/RpmBox/LabelRPM
@onready var label_gear: Label = $Panel/GearBox/LabelGear
@onready var label_4wd: Label = $Panel/GearBox/Label4WD
@onready var progress_fuel: ProgressBar = $Panel/TelemetryBox/ProgressFuel
@onready var label_temp: Label = $Panel/TelemetryBox/LabelTemp
@onready var label_clinometer: Label = $Panel/ClinoBox/LabelClino

func _ready():
    # Handle F11 fullscreen toggle button if clicked
    var btn_fs = $Panel/BtnFullscreen
    if btn_fs:
        btn_fs.pressed.connect(_on_fullscreen_pressed)

func update_telemetry(speed_kmh: float, rpm_norm: float, gear_str: String, fuel_l: float, temp_c: float, pitch_deg: float, roll_deg: float, is_4wd: bool):
    if label_speed:
        label_speed.text = "%3d" % int(round(speed_kmh))
        
    if label_rpm:
        var rpm_display = 0.85 + rpm_norm * 5.65
        label_rpm.text = "%.1f" % rpm_display
        
    if label_gear:
        label_gear.text = gear_str
        
    if label_4wd:
        label_4wd.text = "4WD STEYR INSERITA [50:50]" if is_4wd else "TRAZIONE ANTERIORE [2WD]"
        label_4wd.modulate = Color(0.2, 0.9, 0.3) if is_4wd else Color(0.9, 0.6, 0.2)
        
    if progress_fuel:
        progress_fuel.value = fuel_l
        
    if label_temp:
        label_temp.text = "%d°C" % int(round(temp_c))
        
    if label_clinometer:
        label_clinometer.text = "PITCH: %+02d° | ROLL: %+02d°" % [int(round(pitch_deg)), int(round(roll_deg))]

func _on_fullscreen_pressed():
    if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
