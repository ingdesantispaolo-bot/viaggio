extends VehicleBody3D
class_name VehicleController

const VehicleModelBuilder = preload("res://scripts/VehicleModelBuilder.gd")
const VehicleCrashSystem = preload("res://scripts/VehicleCrashSystem.gd")

# THE LONG MERIDIAN - Authentic Multi-Vehicle Physics & Drivetrain Controller (Godot 4)
# Authentic Internal Combustion Mechanical Powertrain Kinematics:
# - True wheel-engine RPM mechanical coupling: RPM = (v / R_wheel) * r_gear * r_diff * (60 / 2pi)
# - Progressive clutch slip on takeoff from standstill
# - Dynamic load-dependent automatic gearshift (cruising vs kickdown) with shift clutch pause
# - Calibrated aerodynamic drag (0.5 * rho * Cd * A * v^2) and physical top speed capping
# - Factory-accurate top speeds:
#   * Fiat Panda 4x4 Steyr-Puch: 135 km/h (0-100 in ~18.8s)
#   * Lancia Delta HF Integrale Evo: 220 km/h (0-100 in 5.7s)
#   * Mercedes-Benz G-Klasse W460: 155 km/h (0-100 in 13.8s)

signal telemetry_updated(speed_kmh, rpm_norm, gear_str, fuel_l, temp_c, pitch_deg, roll_deg, is_4wd, boost_bar, model_info)
signal service_completed(liters_added, station_name)

# Scala del 75% per proporzioni armoniose con carreggiata e ambiente alpino
const PLAYER_SCALE: float = 0.75

# Complete real-world technical catalog
var VEHICLE_CATALOG = {
	"panda_4x4": {
		"id": "panda_4x4",
		"name": "Fiat Panda 4x4 Steyr-Puch (1983)",
		"short_name": "PANDA 4x4 STEYR",
		"maker": "Fiat / Steyr-Puch",
		"year": 1983,
		"engine": "965cc A112 Asta e Bilancieri (48 CV)",
		"mass": 780.0,
		"brake_force": 120.0,
		"steer_angle": 30.0,
		"redline_rpm": 6000.0,
		"idle_rpm": 850.0,
		"torque_peak_rpm": 3500.0,
		"max_power_rpm": 5600.0,
		"engine_torque_nm": 70.0,
		"drivetrain_efficiency": 0.88,
		"top_speed": 130.0,
		"force_scale": 0.88,
		"cd_area": 0.69,
		"drivetrain": "4WD STEYR-PUCH [50:50]",
		"drivetrain_2wd": "TRAZIONE ANTERIORE [FWD]",
		"has_turbo": false,
		"turbo_boost_max": 0.0,
		"tank_l": 35.0,
		"gear_ratios": [4.40, 2.47, 1.52, 1.07, 0.81, -3.82],
		"gear_names": ["D1 (CRAWLER)", "D2", "D3", "D4", "D5", "R"],
		"shift_speeds": [16.0, 36.0, 62.0, 92.0],
		"final_drive": 4.417,
		"wheel_radius": 0.28,
		"clutch_lockup_speed": 10.0,
		"cluster_style": "veglia_panda",
		"speedo_max": 160,
		# Authentic Italian 4x4 Assetto & Suspension (Front MacPherson, Rear Steyr Leaf Spring Axle)
		"track_x": 0.65,
		"wheelbase_z": 1.08,
		"wheel_y_mount": 0.28,
		"wheel_rest_length": 0.14,
		"suspension_travel": 0.14,
		"suspension_stiffness": 42.0,
		"damping_compression": 2.20,
		"damping_relaxation": 3.00,
		"wheel_roll_influence": 0.11,
		"wheel_friction_slip": 2.85,
		"center_of_mass": Vector3(0.0, -0.18, -0.04),
		"tire_radius": 0.28,
		"tire_width": 0.16
	},
	"fiat_127": {
		"id": "fiat_127",
		"name": "Fiat 127 Special (1974)",
		"short_name": "FIAT 127 SPECIAL",
		"maker": "Fiat Torino (Pio Manzù)",
		"year": 1974,
		"engine": "903cc Serie 100 Aste e Bilancieri (47 CV)",
		"mass": 710.0,
		"brake_force": 115.0,
		"steer_angle": 32.0,
		"redline_rpm": 6500.0,
		"idle_rpm": 850.0,
		"torque_peak_rpm": 3500.0,
		"max_power_rpm": 6200.0,
		"engine_torque_nm": 63.0,
		"drivetrain_efficiency": 0.91,
		"top_speed": 135.0,
		"force_scale": 1.00,
		"cd_area": 0.65,
		"drivetrain": "TRAZIONE ANTERIORE [FWD] DANTE GIACOSA",
		"drivetrain_2wd": "TRAZIONE ANTERIORE [FWD]",
		"has_turbo": false,
		"turbo_boost_max": 0.0,
		"tank_l": 30.0,
		"gear_ratios": [3.636, 2.056, 1.348, 0.963, -3.615],
		"gear_names": ["1a", "2a", "3a", "4a", "R"],
		"shift_speeds": [22.0, 48.0, 82.0],
		"final_drive": 4.462,
		"wheel_radius": 0.265,
		"clutch_lockup_speed": 9.0,
		"cluster_style": "veglia_127",
		"speedo_max": 160,
		# MacPherson Anteriore & Balestra Trasversale Posteriore Giacosa
		"track_x": 0.64,
		"wheelbase_z": 1.11,
		"wheel_y_mount": 0.25,
		"wheel_rest_length": 0.12,
		"suspension_travel": 0.12,
		"suspension_stiffness": 38.0,
		"damping_compression": 2.10,
		"damping_relaxation": 2.90,
		"wheel_roll_influence": 0.10,
		"wheel_friction_slip": 3.25,
		"center_of_mass": Vector3(0.0, -0.16, -0.18),
		"tire_radius": 0.265,
		"tire_width": 0.15
	},
	"golf_gti_1990": {
		"id": "golf_gti_1990",
		"name": "Volkswagen Golf GTI 16V Mk2 (1990)",
		"short_name": "GOLF GTI 16V",
		"maker": "Volkswagen Motorsport",
		"year": 1990,
		"engine": "1.8L 16V DOHC K-Jetronic (139 CV)",
		"mass": 960.0,
		"brake_force": 210.0,
		"steer_angle": 28.0,
		"redline_rpm": 7200.0,
		"idle_rpm": 950.0,
		"torque_peak_rpm": 4600.0,
		"max_power_rpm": 6100.0,
		"engine_torque_nm": 168.0,
		"drivetrain_efficiency": 0.89,
		"top_speed": 208.0,
		"force_scale": 0.90,
		"cd_area": 0.68,
		"drivetrain": "TRAZIONE ANTERIORE SPORTIVA [FWD GTI]",
		"drivetrain_2wd": "TRAZIONE ANTERIORE SPORTIVA [FWD GTI]",
		"has_turbo": false,
		"turbo_boost_max": 0.0,
		"tank_l": 55.0,
		"gear_ratios": [3.455, 2.118, 1.444, 1.129, 0.912, -3.167],
		"gear_names": ["1a", "2a", "3a", "4a", "5a", "R"],
		"shift_speeds": [46.0, 78.0, 116.0, 160.0],
		"final_drive": 3.667,
		"wheel_radius": 0.285,
		"clutch_lockup_speed": 11.0,
		"cluster_style": "vdo_golf_gti",
		"speedo_max": 260,
		# Assetto Sportivo GTI Ribassato -20mm con Barre Antirollio Maggiorate
		"track_x": 0.71,
		"wheelbase_z": 1.22,
		"wheel_y_mount": 0.24,
		"wheel_rest_length": 0.09,
		"suspension_travel": 0.09,
		"suspension_stiffness": 58.0,
		"damping_compression": 2.80,
		"damping_relaxation": 3.80,
		"wheel_roll_influence": 0.08,
		"wheel_friction_slip": 3.35,
		"center_of_mass": Vector3(0.0, -0.22, -0.06),
		"tire_radius": 0.285,
		"tire_width": 0.20
	},
	"delta_integrale": {
		"id": "delta_integrale",
		"name": "Lancia Delta HF Integrale Evo (1991)",
		"short_name": "DELTA HF INTEGRALE",
		"maker": "Lancia Martini Racing",
		"year": 1991,
		"engine": "2.0L 16V Turbo Garrett T3 (210 CV)",
		"mass": 1300.0,
		"brake_force": 240.0,
		"steer_angle": 27.0,
		"redline_rpm": 6800.0,
		"idle_rpm": 950.0,
		"torque_peak_rpm": 3500.0,
		"max_power_rpm": 5750.0,
		"engine_torque_nm": 304.0,
		"drivetrain_efficiency": 0.86,
		"top_speed": 220.0,
		"force_scale": 0.95,
		"cd_area": 0.68,
		"drivetrain": "TORSEN AWD PERMANENTE [47:53]",
		"drivetrain_2wd": "TORSEN AWD PERMANENTE [47:53]",
		"has_turbo": true,
		"turbo_boost_max": 1.45,
		"tank_l": 57.0,
		"gear_ratios": [3.50, 2.18, 1.52, 1.13, 0.83, -3.20],
		"gear_names": ["D1", "D2", "D3", "D4", "D5", "R"],
		"shift_speeds": [50.0, 85.0, 126.0, 170.0],
		"final_drive": 3.111,
		"wheel_radius": 0.295,
		"clutch_lockup_speed": 12.0,
		"cluster_style": "veglia_corse",
		"speedo_max": 260,
		# Group A Rally Tarmac Assetto (Bilstein inverted struts, boxed blister arches, flat cornering)
		"track_x": 0.76,
		"wheelbase_z": 1.25,
		"wheel_y_mount": 0.22,
		"wheel_rest_length": 0.08,
		"suspension_travel": 0.08,
		"suspension_stiffness": 68.0,
		"damping_compression": 3.10,
		"damping_relaxation": 4.20,
		"wheel_roll_influence": 0.08,
		"wheel_friction_slip": 3.65,
		"center_of_mass": Vector3(0.0, -0.24, -0.06),
		"tire_radius": 0.295,
		"tire_width": 0.22
	},
	"mercedes_gwagen": {
		"id": "mercedes_gwagen",
		"name": "Mercedes-Benz G-Klasse W460 (1979)",
		"short_name": "G-KLASSE W460",
		"maker": "Mercedes-Benz / Steyr",
		"year": 1979,
		"engine": "2.8L M110 6 Cilindri DOHC (156 CV)",
		"mass": 1980.0,
		"brake_force": 180.0,
		"steer_angle": 27.0,
		"redline_rpm": 6000.0,
		"idle_rpm": 800.0,
		"torque_peak_rpm": 4250.0,
		"max_power_rpm": 5250.0,
		"engine_torque_nm": 226.0,
		"drivetrain_efficiency": 0.82,
		"top_speed": 155.0,
		"force_scale": 1.10,
		"cd_area": 1.28,
		"drivetrain": "3x DIFF-LOCK MECCANICI 100%",
		"drivetrain_2wd": "TRAZIONE POSTERIORE [RWD]",
		"has_turbo": false,
		"turbo_boost_max": 0.0,
		"tank_l": 68.0,
		"gear_ratios": [3.82, 2.20, 1.40, 1.00, 0.80, -4.00],
		"gear_names": ["D1", "D2", "D3", "D4", "D5", "R"],
		"shift_speeds": [26.0, 48.0, 80.0, 115.0],
		"final_drive": 4.880,
		"wheel_radius": 0.365,
		"clutch_lockup_speed": 12.0,
		"cluster_style": "vdo_stuttgart",
		"speedo_max": 200,
		# Heavy-duty Dual Live Rigid Axle Assetto (Ponti rigidi, controlled damping)
		"track_x": 0.73,
		"wheelbase_z": 1.20,
		"wheel_y_mount": 0.34,
		"wheel_rest_length": 0.16,
		"suspension_travel": 0.16,
		"suspension_stiffness": 52.0,
		"damping_compression": 2.40,
		"damping_relaxation": 3.20,
		"wheel_roll_influence": 0.12,
		"wheel_friction_slip": 2.60,
		"center_of_mass": Vector3(0.0, -0.16, 0.0),
		"tire_radius": 0.365,
		"tire_width": 0.24
	},
	"renault_4": {
		"id": "renault_4",
		"name": "Renault 4 GTL (1980)",
		"short_name": "RENAULT 4 GTL",
		"maker": "Régie Nationale Renault",
		"year": 1980,
		"engine": "1.1L Cléon-Fonte OHV (34 CV)",
		"mass": 720.0,
		"brake_force": 140.0,
		"steer_angle": 33.0,
		"redline_rpm": 5200.0,
		"idle_rpm": 750.0,
		"torque_peak_rpm": 2500.0,
		"max_power_rpm": 4000.0,
		"engine_torque_nm": 74.0,
		"drivetrain_efficiency": 0.90,
		"top_speed": 122.0,
		"force_scale": 0.86,
		"cd_area": 0.76,
		"drivetrain": "TRACTION AVANT [FWD] COMMANDE CRUSCOTTO",
		"drivetrain_2wd": "TRAZIONE ANTERIORE [FWD]",
		"has_turbo": false,
		"turbo_boost_max": 0.0,
		"tank_l": 34.0,
		"gear_ratios": [3.667, 2.176, 1.409, 1.030, -3.077],
		"gear_names": ["1a", "2a", "3a", "4a", "R"],
		"shift_speeds": [22.0, 44.0, 76.0],
		"final_drive": 3.889,
		"wheel_radius": 0.275,
		"clutch_lockup_speed": 8.0,
		"cluster_style": "jaeger_r4",
		"speedo_max": 140,
		# Barre di torsione indipendenti sulle 4 ruote, passo asimmetrico
		"track_x": 0.63,
		"wheelbase_z": 1.15,
		"wheel_y_mount": 0.26,
		"wheel_rest_length": 0.15,
		"suspension_travel": 0.16,
		"suspension_stiffness": 32.0,
		"damping_compression": 1.80,
		"damping_relaxation": 2.60,
		"wheel_roll_influence": 0.15,
		"wheel_friction_slip": 2.70,
		"center_of_mass": Vector3(0.0, -0.14, -0.06),
		"tire_radius": 0.275,
		"tire_width": 0.145
	},
	"bmw_320_e30": {
		"id": "bmw_320_e30",
		"name": "BMW 320i E30 (1990)",
		"short_name": "BMW 320i E30",
		"maker": "Bayerische Motoren Werke",
		"year": 1990,
		"engine": "2.0L M20B20 6 Cilindri SOHC (129 CV)",
		"mass": 1125.0,
		"brake_force": 220.0,
		"steer_angle": 30.0,
		"redline_rpm": 6400.0,
		"idle_rpm": 800.0,
		"torque_peak_rpm": 4300.0,
		"max_power_rpm": 6000.0,
		"engine_torque_nm": 164.0,
		"drivetrain_efficiency": 0.88,
		"top_speed": 198.0,
		"force_scale": 0.88,
		"cd_area": 0.66,
		"drivetrain": "TRAZIONE POSTERIORE CLASSICA [RWD]",
		"drivetrain_2wd": "TRAZIONE POSTERIORE [RWD]",
		"has_turbo": false,
		"turbo_boost_max": 0.0,
		"tank_l": 55.0,
		"gear_ratios": [3.717, 2.019, 1.320, 1.000, 0.805, -3.456],
		"gear_names": ["1a", "2a", "3a", "4a", "5a", "R"],
		"shift_speeds": [44.0, 76.0, 112.0, 155.0],
		"final_drive": 4.100,
		"wheel_radius": 0.295,
		"clutch_lockup_speed": 10.0,
		"cluster_style": "vdo_bmw",
		"speedo_max": 240,
		# MacPherson Anteriore & Bracci Obliqui Semi-Trailing Posteriore RWD
		"track_x": 0.70,
		"wheelbase_z": 1.28,
		"wheel_y_mount": 0.27,
		"wheel_rest_length": 0.13,
		"suspension_travel": 0.13,
		"suspension_stiffness": 44.0,
		"damping_compression": 2.30,
		"damping_relaxation": 3.10,
		"wheel_roll_influence": 0.10,
		"wheel_friction_slip": 2.85,
		"center_of_mass": Vector3(0.0, -0.18, 0.02),
		"tire_radius": 0.295,
		"tire_width": 0.195
	},
	"mercedes_a250": {
		"id": "mercedes_a250",
		"name": "Mercedes-Benz A 250 Sport W176 (2016)",
		"short_name": "MERCEDES A 250",
		"maker": "Mercedes-Benz AMG Line",
		"year": 2016,
		"engine": "2.0L Turbo M270 BlueDIRECT (211 CV)",
		"mass": 1370.0,
		"brake_force": 260.0,
		"steer_angle": 29.0,
		"redline_rpm": 6500.0,
		"idle_rpm": 700.0,
		"torque_peak_rpm": 2800.0,
		"max_power_rpm": 5500.0,
		"engine_torque_nm": 350.0,
		"drivetrain_efficiency": 0.91,
		"top_speed": 240.0,
		"force_scale": 0.65,
		"cd_area": 0.62,
		"drivetrain": "TRAZIONE ANTERIORE TURBO [FWD 7G-DCT]",
		"drivetrain_2wd": "TRAZIONE ANTERIORE TURBO [FWD]",
		"has_turbo": true,
		"turbo_boost_max": 1.20,
		"tank_l": 50.0,
		"gear_ratios": [3.86, 2.43, 1.54, 1.06, 0.83, 0.65, 0.51, -3.10],
		"gear_names": ["D1", "D2", "D3", "D4", "D5", "D6", "D7", "R"],
		"shift_speeds": [34.0, 58.0, 90.0, 128.0, 170.0, 210.0],
		"final_drive": 4.130,
		"wheel_radius": 0.315,
		"clutch_lockup_speed": 7.0,
		"cluster_style": "mercedes_modern",
		"speedo_max": 260,
		# Assetto Sportivo Ribassato AMG Line con multilink a 4 bracci posteriore
		"track_x": 0.77,
		"wheelbase_z": 1.35,
		"wheel_y_mount": 0.28,
		"wheel_rest_length": 0.11,
		"suspension_travel": 0.11,
		"suspension_stiffness": 50.0,
		"damping_compression": 2.50,
		"damping_relaxation": 3.40,
		"wheel_roll_influence": 0.08,
		"wheel_friction_slip": 3.10,
		"center_of_mass": Vector3(0.0, -0.19, -0.06),
		"tire_radius": 0.315,
		"tire_width": 0.225
	},
	"alfa_8c": {
		"id": "alfa_8c",
		"name": "Alfa Romeo 8C 2900B Spider Corto (1938)",
		"short_name": "ALFA 8C 2900B",
		"maker": "Alfa Romeo Portello (Vittorio Jano / Touring)",
		"year": 1938,
		"engine": "2.9L 8 Cilindri DOHC Twin-Roots Supercharged (180 CV)",
		"mass": 1250.0,
		"brake_force": 165.0,
		"steer_angle": 30.0,
		"redline_rpm": 5400.0,
		"idle_rpm": 750.0,
		"torque_peak_rpm": 3200.0,
		"max_power_rpm": 5200.0,
		"engine_torque_nm": 280.0,
		"drivetrain_efficiency": 0.88,
		"top_speed": 185.0,
		"force_scale": 1.05,
		"cd_area": 0.65,
		"drivetrain": "TRANSAXLE RWD 50:50 CON COMPRESSORE ROOTS",
		"drivetrain_2wd": "TRAZIONE POSTERIORE [RWD]",
		"has_turbo": true,
		"turbo_boost_max": 0.65,
		"tank_l": 100.0,
		"gear_ratios": [3.20, 1.95, 1.35, 1.00, -3.40],
		"gear_names": ["1a", "2a", "3a", "4a", "R"],
		"shift_speeds": [42.0, 78.0, 128.0],
		"final_drive": 3.70,
		"wheel_radius": 0.355,
		"clutch_lockup_speed": 12.0,
		"cluster_style": "veglia_vintage_8c",
		"speedo_max": 200,
		"track_x": 0.72,
		"wheelbase_z": 1.40,
		"wheel_y_mount": 0.32,
		"wheel_rest_length": 0.13,
		"suspension_travel": 0.13,
		"suspension_stiffness": 44.0,
		"damping_compression": 2.20,
		"damping_relaxation": 3.00,
		"wheel_roll_influence": 0.12,
		"wheel_friction_slip": 2.80,
		"center_of_mass": Vector3(0.0, -0.16, 0.0),
		"tire_radius": 0.355,
		"tire_width": 0.185
	},
	"fiat_topolino": {
		"id": "fiat_topolino",
		"name": "Fiat 500A Topolino (1936)",
		"short_name": "FIAT 500A TOPOLINO",
		"maker": "Fiat Lingotto (Dante Giacosa)",
		"year": 1936,
		"engine": "569cc 4 Cilindri Valvole Laterali (13 CV)",
		"mass": 535.0,
		"brake_force": 75.0,
		"steer_angle": 34.0,
		"redline_rpm": 4500.0,
		"idle_rpm": 700.0,
		"torque_peak_rpm": 2500.0,
		"max_power_rpm": 4000.0,
		"engine_torque_nm": 32.0,
		"drivetrain_efficiency": 0.92,
		"top_speed": 85.0,
		"force_scale": 1.15,
		"cd_area": 0.58,
		"drivetrain": "TRAZIONE POSTERIORE MINIMALISTA [RWD]",
		"drivetrain_2wd": "TRAZIONE POSTERIORE [RWD]",
		"has_turbo": false,
		"turbo_boost_max": 0.0,
		"tank_l": 22.0,
		"gear_ratios": [4.48, 2.73, 1.70, 1.00, -5.68],
		"gear_names": ["1a", "2a", "3a", "4a", "R"],
		"shift_speeds": [18.0, 35.0, 58.0],
		"final_drive": 4.875,
		"wheel_radius": 0.250,
		"clutch_lockup_speed": 6.0,
		"cluster_style": "veglia_topolino",
		"speedo_max": 100,
		"track_x": 0.56,
		"wheelbase_z": 1.00,
		"wheel_y_mount": 0.24,
		"wheel_rest_length": 0.12,
		"suspension_travel": 0.12,
		"suspension_stiffness": 28.0,
		"damping_compression": 1.80,
		"damping_relaxation": 2.50,
		"wheel_roll_influence": 0.15,
		"wheel_friction_slip": 2.65,
		"center_of_mass": Vector3(0.0, -0.14, -0.08),
		"tire_radius": 0.250,
		"tire_width": 0.125
	},
	"lancia_aurelia": {
		"id": "lancia_aurelia",
		"name": "Lancia Aurelia B20 GT 2500 (1953)",
		"short_name": "AURELIA B20 GT",
		"maker": "Lancia & C. Torino (De Virgilio / Jano / Pininfarina)",
		"year": 1953,
		"engine": "2.5L V6 60° Valvole in Testa (118 CV)",
		"mass": 1150.0,
		"brake_force": 180.0,
		"steer_angle": 29.0,
		"redline_rpm": 5600.0,
		"idle_rpm": 800.0,
		"torque_peak_rpm": 3500.0,
		"max_power_rpm": 5000.0,
		"engine_torque_nm": 172.0,
		"drivetrain_efficiency": 0.90,
		"top_speed": 185.0,
		"force_scale": 0.92,
		"cd_area": 0.62,
		"drivetrain": "TRANSAXLE RWD PONTE DE DION FRENI ENTROBORDO",
		"drivetrain_2wd": "TRAZIONE POSTERIORE [RWD]",
		"has_turbo": false,
		"turbo_boost_max": 0.0,
		"tank_l": 75.0,
		"gear_ratios": [2.86, 1.84, 1.25, 0.86, -3.61],
		"gear_names": ["1a", "2a", "3a", "4a", "R"],
		"shift_speeds": [48.0, 82.0, 126.0],
		"final_drive": 3.90,
		"wheel_radius": 0.320,
		"clutch_lockup_speed": 11.0,
		"cluster_style": "veglia_aurelia",
		"speedo_max": 200,
		"track_x": 0.68,
		"wheelbase_z": 1.33,
		"wheel_y_mount": 0.28,
		"wheel_rest_length": 0.12,
		"suspension_travel": 0.12,
		"suspension_stiffness": 48.0,
		"damping_compression": 2.40,
		"damping_relaxation": 3.30,
		"wheel_roll_influence": 0.09,
		"wheel_friction_slip": 2.95,
		"center_of_mass": Vector3(0.0, -0.18, 0.0),
		"tire_radius": 0.320,
		"tire_width": 0.165
	},
	"alfa_gta": {
		"id": "alfa_gta",
		"name": "Alfa Romeo Giulia Sprint GTA (1965)",
		"short_name": "GIULIA SPRINT GTA",
		"maker": "Autodelta Settimo Milanese (Carlo Chiti / Bertone)",
		"year": 1965,
		"engine": "1570cc Bialbero DOHC Twin Spark 2x Weber 45 DCOE (115 CV)",
		"mass": 745.0,
		"brake_force": 205.0,
		"steer_angle": 32.0,
		"redline_rpm": 7400.0,
		"idle_rpm": 950.0,
		"torque_peak_rpm": 4500.0,
		"max_power_rpm": 6000.0,
		"engine_torque_nm": 145.0,
		"drivetrain_efficiency": 0.92,
		"top_speed": 195.0,
		"force_scale": 0.98,
		"cd_area": 0.64,
		"drivetrain": "TRAZIONE POSTERIORE RWD SLITTONE AUTODELTA",
		"drivetrain_2wd": "TRAZIONE POSTERIORE [RWD]",
		"has_turbo": false,
		"turbo_boost_max": 0.0,
		"tank_l": 46.0,
		"gear_ratios": [3.304, 1.988, 1.355, 1.000, 0.860, -3.010],
		"gear_names": ["1a", "2a", "3a", "4a", "5a", "R"],
		"shift_speeds": [46.0, 78.0, 114.0, 155.0],
		"final_drive": 4.555,
		"wheel_radius": 0.285,
		"clutch_lockup_speed": 9.0,
		"cluster_style": "veglia_alfa_gta",
		"speedo_max": 220,
		"track_x": 0.66,
		"wheelbase_z": 1.18,
		"wheel_y_mount": 0.25,
		"wheel_rest_length": 0.09,
		"suspension_travel": 0.09,
		"suspension_stiffness": 54.0,
		"damping_compression": 2.60,
		"damping_relaxation": 3.60,
		"wheel_roll_influence": 0.08,
		"wheel_friction_slip": 3.25,
		"center_of_mass": Vector3(0.0, -0.19, -0.04),
		"tire_radius": 0.285,
		"tire_width": 0.175
	},
	"lancia_stratos": {
		"id": "lancia_stratos",
		"name": "Lancia Stratos HF Stradale (1974)",
		"short_name": "STRATOS HF",
		"maker": "Lancia Squadra Corse HF / Bertone (Marcello Gandini)",
		"year": 1974,
		"engine": "2.4L Ferrari Dino V6 65° Centrale Trasversale (190 CV)",
		"mass": 980.0,
		"brake_force": 240.0,
		"steer_angle": 31.0,
		"redline_rpm": 7800.0,
		"idle_rpm": 1000.0,
		"torque_peak_rpm": 4000.0,
		"max_power_rpm": 7000.0,
		"engine_torque_nm": 225.0,
		"drivetrain_efficiency": 0.90,
		"top_speed": 230.0,
		"force_scale": 0.95,
		"cd_area": 0.60,
		"drivetrain": "MOTORE CENTRALE POSTERIORE RWD V6 FERRARI DINO",
		"drivetrain_2wd": "TRAZIONE POSTERIORE [RWD]",
		"has_turbo": false,
		"turbo_boost_max": 0.0,
		"tank_l": 80.0,
		"gear_ratios": [3.554, 2.250, 1.542, 1.125, 0.865, -3.071],
		"gear_names": ["1a", "2a", "3a", "4a", "5a", "R"],
		"shift_speeds": [55.0, 92.0, 135.0, 185.0],
		"final_drive": 3.824,
		"wheel_radius": 0.285,
		"clutch_lockup_speed": 11.0,
		"cluster_style": "veglia_stratos",
		"speedo_max": 260,
		"track_x": 0.74,
		"wheelbase_z": 1.09,
		"wheel_y_mount": 0.23,
		"wheel_rest_length": 0.08,
		"suspension_travel": 0.08,
		"suspension_stiffness": 66.0,
		"damping_compression": 3.00,
		"damping_relaxation": 4.10,
		"wheel_roll_influence": 0.07,
		"wheel_friction_slip": 3.55,
		"center_of_mass": Vector3(0.0, -0.22, 0.08),
		"tire_radius": 0.285,
		"tire_width": 0.225
	},
	"fiat_131_abarth": {
		"id": "fiat_131_abarth",
		"name": "Fiat 131 Abarth Rally (1976)",
		"short_name": "FIAT 131 ABARTH",
		"maker": "Abarth & C. / Bertone Mirafiori (Aurelio Lampredi)",
		"year": 1976,
		"engine": "2.0L 16V DOHC Lampredi Abarth (140 CV)",
		"mass": 980.0,
		"brake_force": 225.0,
		"steer_angle": 30.0,
		"redline_rpm": 7200.0,
		"idle_rpm": 950.0,
		"torque_peak_rpm": 3800.0,
		"max_power_rpm": 6400.0,
		"engine_torque_nm": 180.0,
		"drivetrain_efficiency": 0.90,
		"top_speed": 190.0,
		"force_scale": 0.94,
		"cd_area": 0.72,
		"drivetrain": "TRAZIONE POSTERIORE RWD DIFFERENZIALE AUTOBLOCCANTE",
		"drivetrain_2wd": "TRAZIONE POSTERIORE [RWD]",
		"has_turbo": false,
		"turbo_boost_max": 0.0,
		"tank_l": 60.0,
		"gear_ratios": [3.667, 2.100, 1.450, 1.110, 0.870, -3.333],
		"gear_names": ["1a", "2a", "3a", "4a", "5a", "R"],
		"shift_speeds": [48.0, 84.0, 122.0, 160.0],
		"final_drive": 4.100,
		"wheel_radius": 0.290,
		"clutch_lockup_speed": 10.0,
		"cluster_style": "veglia_131_abarth",
		"speedo_max": 240,
		"track_x": 0.76,
		"wheelbase_z": 1.25,
		"wheel_y_mount": 0.24,
		"wheel_rest_length": 0.09,
		"suspension_travel": 0.09,
		"suspension_stiffness": 60.0,
		"damping_compression": 2.70,
		"damping_relaxation": 3.70,
		"wheel_roll_influence": 0.08,
		"wheel_friction_slip": 3.40,
		"center_of_mass": Vector3(0.0, -0.20, -0.02),
		"tire_radius": 0.290,
		"tire_width": 0.210
	},
	"porsche_930_turbo": {
		"id": "porsche_930_turbo",
		"name": "Porsche 911 Turbo 3.0 (Type 930 - 1975)",
		"short_name": "911 TURBO (930)",
		"maker": "Porsche AG Stuttgart-Zuffenhausen",
		"year": 1975,
		"engine": "3.0L Boxer-6 Turbo KKK K27 Raffreddato ad Aria (260 CV)",
		"mass": 1195.0,
		"brake_force": 260.0,
		"steer_angle": 28.0,
		"redline_rpm": 6800.0,
		"idle_rpm": 950.0,
		"torque_peak_rpm": 4000.0,
		"max_power_rpm": 5500.0,
		"engine_torque_nm": 343.0,
		"drivetrain_efficiency": 0.90,
		"top_speed": 250.0,
		"force_scale": 0.95,
		"cd_area": 0.62,
		"drivetrain": "TRAZIONE POSTERIORE RWD MOTORE POSTERIORE A SBALZO",
		"drivetrain_2wd": "TRAZIONE POSTERIORE [RWD]",
		"has_turbo": true,
		"turbo_boost_max": 0.85,
		"tank_l": 80.0,
		"gear_ratios": [2.250, 1.304, 0.893, 0.656, -2.444],
		"gear_names": ["1a", "2a", "3a", "4a", "R"],
		"shift_speeds": [72.0, 130.0, 192.0],
		"final_drive": 4.222,
		"wheel_radius": 0.315,
		"clutch_lockup_speed": 12.0,
		"cluster_style": "vdo_porsche_5dial",
		"speedo_max": 300,
		"track_x": 0.78,
		"wheelbase_z": 1.18,
		"wheel_y_mount": 0.25,
		"wheel_rest_length": 0.09,
		"suspension_travel": 0.09,
		"suspension_stiffness": 62.0,
		"damping_compression": 2.90,
		"damping_relaxation": 3.90,
		"wheel_roll_influence": 0.07,
		"wheel_friction_slip": 3.45,
		"center_of_mass": Vector3(0.0, -0.19, 0.28),
		"tire_radius": 0.315,
		"tire_width": 0.245
	},
	"porsche_carrera_4s": {
		"id": "porsche_carrera_4s",
		"name": "Porsche 911 Carrera 4S (992 - 2020)",
		"short_name": "911 CARRERA 4S",
		"maker": "Porsche AG Stuttgart-Zuffenhausen",
		"year": 2020,
		"engine": "3.0L Boxer-6 Biturbo DOHC 24V (450 CV)",
		"mass": 1565.0,
		"brake_force": 360.0,
		"steer_angle": 27.0,
		"redline_rpm": 7500.0,
		"idle_rpm": 750.0,
		"torque_peak_rpm": 2300.0,
		"max_power_rpm": 6500.0,
		"engine_torque_nm": 530.0,
		"drivetrain_efficiency": 0.92,
		"top_speed": 306.0,
		"force_scale": 0.96,
		"cd_area": 0.60,
		"drivetrain": "TRAZIONE INTEGRALE PTM [AWD TORQUE VECTORING]",
		"drivetrain_2wd": "TRAZIONE INTEGRALE [AWD]",
		"has_turbo": true,
		"turbo_boost_max": 1.25,
		"tank_l": 67.0,
		"gear_ratios": [4.89, 3.17, 2.15, 1.56, 1.18, 0.94, 0.76, 0.61, -3.99],
		"gear_names": ["PDK 1", "PDK 2", "PDK 3", "PDK 4", "PDK 5", "PDK 6", "PDK 7", "PDK 8", "R"],
		"shift_speeds": [48.0, 84.0, 126.0, 172.0, 220.0, 265.0, 295.0],
		"final_drive": 3.12,
		"wheel_radius": 0.335,
		"clutch_lockup_speed": 6.0,
		"cluster_style": "porsche_modern_digital",
		"speedo_max": 330,
		"track_x": 0.82,
		"wheelbase_z": 1.25,
		"wheel_y_mount": 0.26,
		"wheel_rest_length": 0.08,
		"suspension_travel": 0.08,
		"suspension_stiffness": 70.0,
		"damping_compression": 3.20,
		"damping_relaxation": 4.20,
		"wheel_roll_influence": 0.06,
		"wheel_friction_slip": 3.75,
		"center_of_mass": Vector3(0.0, -0.22, 0.12),
		"tire_radius": 0.335,
		"tire_width": 0.305
	},
	"countach_lpi800": {
		"id": "countach_lpi800",
		"name": "Lamborghini Countach LPI 800-4 (2021)",
		"short_name": "COUNTACH LPI 800",
		"maker": "Automobili Lamborghini Sant'Agata Bolognese",
		"year": 2021,
		"engine": "6.5L V12 Aspirato 60° + Supercondensatore 48V (814 CV)",
		"mass": 1595.0,
		"brake_force": 420.0,
		"steer_angle": 26.0,
		"redline_rpm": 8700.0,
		"idle_rpm": 1050.0,
		"torque_peak_rpm": 6750.0,
		"max_power_rpm": 8500.0,
		"engine_torque_nm": 720.0,
		"drivetrain_efficiency": 0.93,
		"top_speed": 355.0,
		"force_scale": 1.00,
		"cd_area": 0.58,
		"drivetrain": "TRAZIONE INTEGRALE PERMANENTE HALDEX IV [AWD]",
		"drivetrain_2wd": "TRAZIONE INTEGRALE [AWD]",
		"has_turbo": false,
		"turbo_boost_max": 0.0,
		"tank_l": 70.0,
		"gear_ratios": [3.909, 2.438, 1.810, 1.458, 1.185, 0.967, 0.844, -3.429],
		"gear_names": ["ISR 1", "ISR 2", "ISR 3", "ISR 4", "ISR 5", "ISR 6", "ISR 7", "R"],
		"shift_speeds": [68.0, 114.0, 162.0, 218.0, 275.0, 325.0],
		"final_drive": 2.87,
		"wheel_radius": 0.345,
		"clutch_lockup_speed": 7.0,
		"cluster_style": "lamborghini_corsa_tft",
		"speedo_max": 400,
		"track_x": 0.88,
		"wheelbase_z": 1.35,
		"wheel_y_mount": 0.24,
		"wheel_rest_length": 0.07,
		"suspension_travel": 0.07,
		"suspension_stiffness": 82.0,
		"damping_compression": 3.60,
		"damping_relaxation": 4.80,
		"wheel_roll_influence": 0.05,
		"wheel_friction_slip": 3.90,
		"center_of_mass": Vector3(0.0, -0.24, 0.04),
		"tire_radius": 0.345,
		"tire_width": 0.355
	}
}

var model_keys = [
	"fiat_topolino",
	"alfa_8c",
	"lancia_aurelia",
	"alfa_gta",
	"fiat_127",
	"fiat_131_abarth",
	"lancia_stratos",
	"porsche_930_turbo",
	"renault_4",
	"mercedes_gwagen",
	"panda_4x4",
	"golf_gti_1990",
	"bmw_320_e30",
	"delta_integrale",
	"mercedes_a250",
	"porsche_carrera_4s",
	"countach_lpi800"
]
var current_model_idx: int = 0
var current_model_id: String = "fiat_127"

# Internal dynamic telemetry
var current_speed_kmh: float = 0.0
var engine_rpm: float = 850.0
var current_gear: int = 1
var gear_name: String = "D1"
var current_fuel: float = 28.5
var engine_temp: float = 82.0
var current_boost_bar: float = 0.0
var hazard_timer: float = 0.0
var hazard_state: bool = false
var is_4wd_engaged: bool = true
var headlights_on: bool = true
var hazard_lights_on: bool = false
var is_engine_running: bool = false # Silent when parked in garage

# AI Driver control support
@export var is_ai_controlled: bool = false
var ai_throttle: float = 0.0
var ai_brake: float = 0.0
var ai_steer: float = 0.0
var ai_handbrake: bool = false

# Dynamic Weight Transfer & Pothole Telemetry
var last_linear_velocity: Vector3 = Vector3.ZERO
var weight_transfer_long: float = 0.0
var pothole_cooldown: float = 0.0
var horn_cooldown: float = 0.0
var impact_cooldown: float = 0.0
@export var hazard_manager: Node3D = null

# Progressive Analog Steering Dynamics State
var steer_input_smoothed: float = 0.0

# Surface Adhesion, Grip & Drag state
var current_surface_name: String = "ASFALTO"
var current_grip_mult: float = 1.0
var offroad_drag_factor: float = 0.0

# Service Station & Interaction state
var is_in_service_zone: bool = false
var is_in_service_bay: bool = false
var service_station_name: String = ""
var service_station_type: String = "autogrill_bar"
var service_message: String = ""
var service_message_timer: float = 0.0
var service_cooldown: float = 0.0
var service_stop_timer: float = 0.0
var engine_health: float = 100.0
@export var road_generator: Node3D = null

# Drivetrain transmission simulation state
var shift_timer: float = 0.0
var shift_cooldown: float = 0.0
var is_reversing: bool = false
var reverse_intent_timer: float = 0.0

# Wheel nodes
@onready var wheel_fl: VehicleWheel3D = $WheelFL
@onready var wheel_fr: VehicleWheel3D = $WheelFR
@onready var wheel_rl: VehicleWheel3D = $WheelRL
@onready var wheel_rr: VehicleWheel3D = $WheelRR

# Lights
@onready var headlight_l: SpotLight3D = $HeadlightL
@onready var headlight_r: SpotLight3D = $HeadlightR
@onready var taillight_l: OmniLight3D = $TaillightL
@onready var taillight_r: OmniLight3D = $TaillightR
@onready var hazard_fl: MeshInstance3D = get_node_or_null("HazardFL")
@onready var hazard_fr: MeshInstance3D = get_node_or_null("HazardFR")
@onready var hazard_rl: MeshInstance3D = get_node_or_null("HazardRL")
@onready var hazard_rr: MeshInstance3D = get_node_or_null("HazardRR")

# Audio Engine
@onready var audio_engine: VehicleAudio = $VehicleAudio

# Model 3D Meshes Groups
@onready var model_panda: Node3D = $ModelPanda
@onready var model_delta: Node3D = $ModelDelta
@onready var model_gwagen: Node3D = $ModelGwagen
var model_127: Node3D = null
var model_golf: Node3D = null
var model_r4: Node3D = null
var model_bmw: Node3D = null
var model_a250: Node3D = null
var model_8c: Node3D = null
var model_topolino: Node3D = null
var model_aurelia: Node3D = null
var model_gta: Node3D = null
var model_stratos: Node3D = null
var model_131: Node3D = null
var model_porsche_930: Node3D = null
var model_porsche_c4s: Node3D = null
var model_countach: Node3D = null

# Rim Dynamic Materials per vehicle
var mat_panda_rim: StandardMaterial3D
var mat_delta_rim: StandardMaterial3D
var mat_gwagen_rim: StandardMaterial3D
var mat_127_rim: StandardMaterial3D
var mat_golf_rim: StandardMaterial3D
var mat_r4_rim: StandardMaterial3D
var mat_bmw_rim: StandardMaterial3D
var mat_a250_rim: StandardMaterial3D
var mat_8c_rim: StandardMaterial3D
var mat_topolino_rim: StandardMaterial3D
var mat_aurelia_rim: StandardMaterial3D
var mat_gta_rim: StandardMaterial3D
var mat_stratos_rim: StandardMaterial3D
var mat_131_rim: StandardMaterial3D

# Body Dynamic Paint Materials per vehicle (Street Rod paint booth)
var mat_panda_body: StandardMaterial3D
var mat_delta_body: StandardMaterial3D
var mat_gwagen_body: StandardMaterial3D
var mat_127_body: StandardMaterial3D
var mat_golf_body: StandardMaterial3D
var mat_r4_body: StandardMaterial3D
var mat_bmw_body: StandardMaterial3D
var mat_a250_body: StandardMaterial3D
var mat_8c_body: StandardMaterial3D
var mat_topolino_body: StandardMaterial3D
var mat_aurelia_body: StandardMaterial3D
var mat_gta_body: StandardMaterial3D
var mat_stratos_body: StandardMaterial3D
var mat_131_body: StandardMaterial3D

# Street Rod Tuning & Customization State
var active_street_rod_upgrades: Dictionary = {}

# Dynamic Particle Effects (Art of Rally Wheel Spray & Exhaust)
var particle_wheel_rl: CPUParticles3D = null
var particle_wheel_rr: CPUParticles3D = null
var particle_exhaust: CPUParticles3D = null
var mat_wheel_particle: StandardMaterial3D = null
var front_crash_ray: RayCast3D = null

func _ready():
	# Sensore Raycast per verifica ostacoli verticali (muri, guardrail, rocce)
	front_crash_ray = RayCast3D.new()
	front_crash_ray.name = "FrontCrashRay"
	front_crash_ray.position = Vector3(0.0, 0.45, -1.45)
	front_crash_ray.target_position = Vector3(0.0, 0.0, -0.95)
	front_crash_ray.enabled = true
	front_crash_ray.collision_mask = 1
	add_child(front_crash_ray)
	mat_panda_rim = StandardMaterial3D.new()
	mat_panda_rim.albedo_color = Color(0.72, 0.74, 0.76) # Silver Stamped Steel
	mat_panda_rim.metallic = 0.65
	mat_panda_rim.roughness = 0.35
	
	mat_delta_rim = StandardMaterial3D.new()
	mat_delta_rim.albedo_color = Color(0.96, 0.96, 0.98) # Speedline Montecarlo White
	mat_delta_rim.metallic = 0.35
	mat_delta_rim.roughness = 0.20
	mat_delta_rim.clearcoat_enabled = true
	mat_delta_rim.clearcoat = 0.85
	
	mat_gwagen_rim = StandardMaterial3D.new()
	mat_gwagen_rim.albedo_color = Color(0.18, 0.20, 0.22) # Basalt Heavy Steel
	mat_gwagen_rim.metallic = 0.55
	mat_gwagen_rim.roughness = 0.60

	mat_127_rim = StandardMaterial3D.new()
	mat_127_rim.albedo_color = Color(0.78, 0.80, 0.82) # Silver Stamped Steel with Chrome Hub
	mat_127_rim.metallic = 0.75
	mat_127_rim.roughness = 0.28

	mat_golf_rim = StandardMaterial3D.new()
	mat_golf_rim.albedo_color = Color(0.88, 0.89, 0.92) # BBS Cross-spoke Cast Alloy
	mat_golf_rim.metallic = 0.70
	mat_golf_rim.roughness = 0.22
	mat_golf_rim.clearcoat_enabled = true
	mat_golf_rim.clearcoat = 0.75

	mat_r4_rim = StandardMaterial3D.new()
	mat_r4_rim.albedo_color = Color(0.74, 0.76, 0.78) # 3-bolt stamped steel
	mat_r4_rim.metallic = 0.60
	mat_r4_rim.roughness = 0.40

	mat_bmw_rim = StandardMaterial3D.new()
	mat_bmw_rim.albedo_color = Color(0.92, 0.93, 0.95) # BMW Kreuzspeichen Silver
	mat_bmw_rim.metallic = 0.75
	mat_bmw_rim.roughness = 0.20
	mat_bmw_rim.clearcoat_enabled = true
	mat_bmw_rim.clearcoat = 0.80

	mat_a250_rim = StandardMaterial3D.new()
	mat_a250_rim.albedo_color = Color(0.12, 0.12, 0.14) # AMG Bicolor Black & Diamond Lip
	mat_a250_rim.metallic = 0.85
	mat_a250_rim.roughness = 0.15
	mat_a250_rim.clearcoat_enabled = true
	mat_a250_rim.clearcoat = 0.95

	# Historic Rims
	mat_8c_rim = StandardMaterial3D.new()
	mat_8c_rim.albedo_color = Color(0.94, 0.95, 0.98) # Borrani Wire Wheels Mirror Chrome
	mat_8c_rim.metallic = 0.95
	mat_8c_rim.roughness = 0.12

	mat_topolino_rim = StandardMaterial3D.new()
	mat_topolino_rim.albedo_color = Color(0.12, 0.12, 0.12) # Stamped Disc with Chrome Hubcap
	mat_topolino_rim.metallic = 0.40
	mat_topolino_rim.roughness = 0.45

	mat_aurelia_rim = StandardMaterial3D.new()
	mat_aurelia_rim.albedo_color = Color(0.85, 0.86, 0.88) # Cream / Silver Lancia Steel with Chrome Cap
	mat_aurelia_rim.metallic = 0.70
	mat_aurelia_rim.roughness = 0.25

	mat_gta_rim = StandardMaterial3D.new()
	mat_gta_rim.albedo_color = Color(0.88, 0.89, 0.90) # Campagnolo Magnesium Alloy Autodelta
	mat_gta_rim.metallic = 0.80
	mat_gta_rim.roughness = 0.24

	mat_stratos_rim = StandardMaterial3D.new()
	mat_stratos_rim.albedo_color = Color(0.88, 0.74, 0.28) # Campagnolo 5-Spoke Star Gold Racing
	mat_stratos_rim.metallic = 0.82
	mat_stratos_rim.roughness = 0.25

	mat_131_rim = StandardMaterial3D.new()
	mat_131_rim.albedo_color = Color(0.82, 0.83, 0.85) # Cromodora CD68 Silver Cruciform
	mat_131_rim.metallic = 0.78
	mat_131_rim.roughness = 0.28

	# Authentic Factory Paint Materials
	mat_panda_body = StandardMaterial3D.new()
	mat_panda_body.albedo_color = Color(0.20, 0.32, 0.24, 1.0) # Verde Tasmania
	mat_panda_body.roughness = 0.20
	mat_panda_body.metallic = 0.35
	mat_panda_body.clearcoat_enabled = true
	mat_panda_body.clearcoat = 0.90
	mat_panda_body.clearcoat_roughness = 0.08
	
	mat_delta_body = StandardMaterial3D.new()
	mat_delta_body.albedo_color = Color(0.85, 0.08, 0.08, 1.0) # Rosso Monza Rally
	mat_delta_body.roughness = 0.14
	mat_delta_body.metallic = 0.45
	mat_delta_body.clearcoat_enabled = true
	mat_delta_body.clearcoat = 1.0
	mat_delta_body.clearcoat_roughness = 0.05
	
	mat_gwagen_body = StandardMaterial3D.new()
	mat_gwagen_body.albedo_color = Color(0.24, 0.28, 0.22, 1.0) # Agavengrün Safari
	mat_gwagen_body.roughness = 0.32
	mat_gwagen_body.metallic = 0.25
	mat_gwagen_body.clearcoat_enabled = true
	mat_gwagen_body.clearcoat = 0.70

	mat_127_body = StandardMaterial3D.new()
	mat_127_body.albedo_color = Color(0.86, 0.68, 0.18, 1.0) # Giallo Positano / Tufo 1974
	mat_127_body.roughness = 0.22
	mat_127_body.metallic = 0.15
	mat_127_body.clearcoat_enabled = true
	mat_127_body.clearcoat = 0.85
	mat_127_body.clearcoat_roughness = 0.08

	mat_golf_body = StandardMaterial3D.new()
	mat_golf_body.albedo_color = Color(0.82, 0.08, 0.08, 1.0) # Tornado Red GTI 1990
	mat_golf_body.roughness = 0.15
	mat_golf_body.metallic = 0.40
	mat_golf_body.clearcoat_enabled = true
	mat_golf_body.clearcoat = 0.95
	mat_golf_body.clearcoat_roughness = 0.06

	mat_r4_body = StandardMaterial3D.new()
	mat_r4_body.albedo_color = Color(0.24, 0.46, 0.70, 1.0) # Bleu Ille-de-France 1980
	mat_r4_body.roughness = 0.24
	mat_r4_body.metallic = 0.28
	mat_r4_body.clearcoat_enabled = true
	mat_r4_body.clearcoat = 0.85

	mat_bmw_body = StandardMaterial3D.new()
	mat_bmw_body.albedo_color = Color(0.16, 0.20, 0.24, 1.0) # Diamantschwarz Metallic 1990
	mat_bmw_body.roughness = 0.12
	mat_bmw_body.metallic = 0.70
	mat_bmw_body.clearcoat_enabled = true
	mat_bmw_body.clearcoat = 0.98
	mat_bmw_body.clearcoat_roughness = 0.05

	mat_a250_body = StandardMaterial3D.new()
	mat_a250_body.albedo_color = Color(0.78, 0.80, 0.84, 1.0) # Polarsilber Metallic 2016
	mat_a250_body.roughness = 0.14
	mat_a250_body.metallic = 0.75
	mat_a250_body.clearcoat_enabled = true
	mat_a250_body.clearcoat = 0.95

	mat_8c_body = StandardMaterial3D.new()
	mat_8c_body.albedo_color = Color(0.42, 0.06, 0.10, 1.0) # Rosso Amaranto Touring 1938
	mat_8c_body.roughness = 0.18
	mat_8c_body.metallic = 0.15
	mat_8c_body.clearcoat_enabled = true
	mat_8c_body.clearcoat = 0.90

	mat_topolino_body = StandardMaterial3D.new()
	mat_topolino_body.albedo_color = Color(0.36, 0.07, 0.09, 1.0) # Amaranto e Nero Pastello 1936
	mat_topolino_body.roughness = 0.24
	mat_topolino_body.metallic = 0.05
	mat_topolino_body.clearcoat_enabled = true
	mat_topolino_body.clearcoat = 0.85

	mat_aurelia_body = StandardMaterial3D.new()
	mat_aurelia_body.albedo_color = Color(0.06, 0.12, 0.32, 1.0) # Blu Lancia Metallizzato 1953
	mat_aurelia_body.roughness = 0.16
	mat_aurelia_body.metallic = 0.30
	mat_aurelia_body.clearcoat_enabled = true
	mat_aurelia_body.clearcoat = 0.95

	mat_gta_body = StandardMaterial3D.new()
	mat_gta_body.albedo_color = Color(0.72, 0.05, 0.07, 1.0) # Rosso Alfa Corsa Autodelta 1965
	mat_gta_body.roughness = 0.15
	mat_gta_body.metallic = 0.10
	mat_gta_body.clearcoat_enabled = true
	mat_gta_body.clearcoat = 0.95

	mat_stratos_body = StandardMaterial3D.new()
	mat_stratos_body.albedo_color = Color(0.70, 0.84, 0.14, 1.0) # Giallo/Verde Lime Bertone 1974
	mat_stratos_body.roughness = 0.18
	mat_stratos_body.clearcoat_enabled = true
	mat_stratos_body.clearcoat = 0.90

	mat_131_body = StandardMaterial3D.new()
	mat_131_body.albedo_color = Color(0.07, 0.14, 0.42, 1.0) # Blu Navy Livrea Olio Fiat 1976
	mat_131_body.roughness = 0.18
	mat_131_body.metallic = 0.25
	mat_131_body.clearcoat_enabled = true
	mat_131_body.clearcoat = 0.90

	# Setup Inelastic Real-World Automotive Physics Material (absorbs impact energy, zero bouncy rubber ball behavior)
	var auto_phys_mat = PhysicsMaterial.new()
	auto_phys_mat.friction = 0.55
	auto_phys_mat.bounce = 0.02
	physics_material_override = auto_phys_mat
	continuous_cd = true
	contact_monitor = true
	max_contacts_reported = 8

	# Ensure model container nodes exist in tree
	if has_node("ModelPanda"): model_panda = $ModelPanda
	else:
		model_panda = Node3D.new()
		model_panda.name = "ModelPanda"
		add_child(model_panda)

	if has_node("ModelDelta"): model_delta = $ModelDelta
	else:
		model_delta = Node3D.new()
		model_delta.name = "ModelDelta"
		add_child(model_delta)

	if has_node("ModelGwagen"): model_gwagen = $ModelGwagen
	else:
		model_gwagen = Node3D.new()
		model_gwagen.name = "ModelGwagen"
		add_child(model_gwagen)

	if has_node("ModelFiat127"): model_127 = $ModelFiat127
	else:
		model_127 = Node3D.new()
		model_127.name = "ModelFiat127"
		add_child(model_127)

	if has_node("ModelGolfGti"): model_golf = $ModelGolfGti
	else:
		model_golf = Node3D.new()
		model_golf.name = "ModelGolfGti"
		add_child(model_golf)

	if has_node("ModelRenault4"): model_r4 = $ModelRenault4
	else:
		model_r4 = Node3D.new()
		model_r4.name = "ModelRenault4"
		add_child(model_r4)

	if has_node("ModelBmw320"): model_bmw = $ModelBmw320
	else:
		model_bmw = Node3D.new()
		model_bmw.name = "ModelBmw320"
		add_child(model_bmw)

	if has_node("ModelMercedesA250"): model_a250 = $ModelMercedesA250
	else:
		model_a250 = Node3D.new()
		model_a250.name = "ModelMercedesA250"
		add_child(model_a250)

	if has_node("ModelAlfa8C"): model_8c = $ModelAlfa8C
	else:
		model_8c = Node3D.new()
		model_8c.name = "ModelAlfa8C"
		add_child(model_8c)

	if has_node("ModelTopolino"): model_topolino = $ModelTopolino
	else:
		model_topolino = Node3D.new()
		model_topolino.name = "ModelTopolino"
		add_child(model_topolino)

	if has_node("ModelLanciaAurelia"): model_aurelia = $ModelLanciaAurelia
	else:
		model_aurelia = Node3D.new()
		model_aurelia.name = "ModelLanciaAurelia"
		add_child(model_aurelia)

	if has_node("ModelAlfaGTA"): model_gta = $ModelAlfaGTA
	else:
		model_gta = Node3D.new()
		model_gta.name = "ModelAlfaGTA"
		add_child(model_gta)

	if has_node("ModelLanciaStratos"): model_stratos = $ModelLanciaStratos
	else:
		model_stratos = Node3D.new()
		model_stratos.name = "ModelLanciaStratos"
		add_child(model_stratos)

	if has_node("ModelFiat131"): model_131 = $ModelFiat131
	else:
		model_131 = Node3D.new()
		model_131.name = "ModelFiat131"
		add_child(model_131)

	if has_node("ModelPorsche930"): model_porsche_930 = $ModelPorsche930
	else:
		model_porsche_930 = Node3D.new()
		model_porsche_930.name = "ModelPorsche930"
		add_child(model_porsche_930)

	if has_node("ModelPorscheC4S"): model_porsche_c4s = $ModelPorscheC4S
	else:
		model_porsche_c4s = Node3D.new()
		model_porsche_c4s.name = "ModelPorscheC4S"
		add_child(model_porsche_c4s)

	if has_node("ModelCountachLPI800"): model_countach = $ModelCountachLPI800
	else:
		model_countach = Node3D.new()
		model_countach.name = "ModelCountachLPI800"
		add_child(model_countach)

	# Procedurally build authentic vehicle models or load external GLB/GLTF drop-in assets
	setup_hybrid_vehicle_model(model_panda, "panda_4x4", VehicleModelBuilder.build_panda_4x4, mat_panda_body)
	setup_hybrid_vehicle_model(model_delta, "delta_integrale", VehicleModelBuilder.build_delta_integrale, mat_delta_body)
	setup_hybrid_vehicle_model(model_gwagen, "mercedes_gwagen", VehicleModelBuilder.build_gwagen_w460, mat_gwagen_body)
	setup_hybrid_vehicle_model(model_127, "fiat_127", VehicleModelBuilder.build_fiat_127, mat_127_body)
	setup_hybrid_vehicle_model(model_golf, "golf_gti_1990", VehicleModelBuilder.build_golf_gti_1990, mat_golf_body)
	setup_hybrid_vehicle_model(model_r4, "renault_4", VehicleModelBuilder.build_renault_4, mat_r4_body)
	setup_hybrid_vehicle_model(model_bmw, "bmw_320_e30", VehicleModelBuilder.build_bmw_320_e30, mat_bmw_body)
	setup_hybrid_vehicle_model(model_a250, "mercedes_a250", VehicleModelBuilder.build_mercedes_a250, mat_a250_body)
	setup_hybrid_vehicle_model(model_8c, "alfa_8c", VehicleModelBuilder.build_alfa_8c_2900b, mat_8c_body)
	setup_hybrid_vehicle_model(model_topolino, "fiat_topolino", VehicleModelBuilder.build_fiat_topolino, mat_topolino_body)
	setup_hybrid_vehicle_model(model_aurelia, "lancia_aurelia", VehicleModelBuilder.build_lancia_aurelia_b20, mat_aurelia_body)
	setup_hybrid_vehicle_model(model_gta, "alfa_gta", VehicleModelBuilder.build_alfa_giulia_gta, mat_gta_body)
	setup_hybrid_vehicle_model(model_stratos, "lancia_stratos", VehicleModelBuilder.build_lancia_stratos, mat_stratos_body)
	setup_hybrid_vehicle_model(model_131, "fiat_131_abarth", VehicleModelBuilder.build_fiat_131_abarth, mat_131_body)
	setup_hybrid_vehicle_model(model_porsche_930, "porsche_930_turbo", Callable(), null)
	setup_hybrid_vehicle_model(model_porsche_c4s, "porsche_carrera_4s", Callable(), null)
	setup_hybrid_vehicle_model(model_countach, "countach_lpi800", Callable(), null)

	apply_vehicle_model(current_model_id)
	setup_wheel_particles()

func setup_hybrid_vehicle_model(model_node: Node3D, car_id: String, fallback_builder: Callable, body_mat: Material):
	if not model_node: return
	var candidate_paths = [
		"res://models/" + car_id + ".glb",
		"res://models/" + car_id.capitalize().replace(" ", "_") + ".glb",
		"res://models/" + car_id + ".gltf",
		"res://models/" + car_id.capitalize().replace(" ", "_") + ".gltf",
		"res://models/" + car_id + ".blend",
		"res://models/" + car_id.capitalize().replace(" ", "_") + ".blend"
	]
	var found_path = ""
	for p in candidate_paths:
		if FileAccess.file_exists(p) or ResourceLoader.exists(p):
			found_path = p
			break
	
	if found_path != "":
		for c in model_node.get_children(): c.queue_free()
		var inst: Node3D = null
		
		# 1. Standard engine ResourceLoader (se pre-importato da Godot)
		if ResourceLoader.exists(found_path):
			var scene_res = load(found_path)
			if scene_res is PackedScene:
				inst = scene_res.instantiate()
		
		# 2. GLTFDocument runtime loader nativo (se non ancora pre-importato dall'editor)
		if not inst and (found_path.ends_with(".glb") or found_path.ends_with(".gltf")):
			var gltf_doc = GLTFDocument.new()
			var gltf_state = GLTFState.new()
			if gltf_doc.append_from_file(found_path, gltf_state) == OK:
				inst = gltf_doc.generate_scene(gltf_state)
				
		if inst:
			# Allineamento orientamento: i modelli Blender esportati spesso guardano verso +Z.
			# Godot richiede avanti verso -Z. Ruotiamo di 180° attorno a Y se rivolto in avanti.
			if car_id == "fiat_127":
				inst.rotation.y = PI
				var static_rims = inst.find_child("llantas", true, false)
				if static_rims: static_rims.visible = true
				var static_tires = inst.find_child("neumaticos", true, false)
				if static_tires: static_tires.visible = true
				inst.position.y = 0.65
			elif car_id == "porsche_930_turbo":
				inst.rotation.y = PI
				inst.position.y = 1.06
			elif car_id == "porsche_carrera_4s":
				inst.rotation.y = PI
				inst.position.y = 0.55
			elif car_id == "countach_lpi800":
				inst.rotation.y = PI
				inst.position.y = 0.53
			elif inst.find_child("fatos_delanteros", true, false) != null:
				inst.rotation.y = PI
				
			model_node.add_child(inst)
			model_node.scale = Vector3(PLAYER_SCALE, PLAYER_SCALE, PLAYER_SCALE)
			print("[AUTO HYBRID] Caricato con successo modello 3D esterno GLB: ", found_path)
			return
			
	fallback_builder.call(model_node, body_mat)
	model_node.scale = Vector3(PLAYER_SCALE, PLAYER_SCALE, PLAYER_SCALE)

func switch_vehicle():
	current_model_idx = (current_model_idx + 1) % model_keys.size()
	current_model_id = model_keys[current_model_idx]
	apply_vehicle_model(current_model_id)

func apply_vehicle_model(model_id: String, reset_fuel: bool = false):
	var cfg = VEHICLE_CATALOG[model_id]
	current_model_id = model_id
	
	# 1. Physics Tuning & Authentic Center of Mass
	mass = cfg.mass
	center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = cfg.center_of_mass
	linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	linear_damp = 0.0
	angular_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	angular_damp = 3.2
	
	if reset_fuel or current_fuel <= 0.0:
		current_fuel = cfg.tank_l * 0.42
	engine_rpm = cfg.idle_rpm
	current_gear = 1
	gear_name = cfg.gear_names[0]
	shift_timer = 0.0
	shift_cooldown = 0.0
	is_reversing = false
	current_boost_bar = 0.0
	
	# Ensure wheel nodes are resolved
	if not wheel_fl and has_node("WheelFL"):
		wheel_fl = $WheelFL
		wheel_fr = $WheelFR
		wheel_rl = $WheelRL
		wheel_rr = $WheelRR

	# 2. Suspension, Geometry & Stance Setup per car (scalati rigorosamente a PLAYER_SCALE 0.75)
	var track_x = cfg.track_x * PLAYER_SCALE
	var wb_z = cfg.wheelbase_z * PLAYER_SCALE
	var y_mount = cfg.wheel_y_mount * PLAYER_SCALE
	var r_radius = cfg.tire_radius * PLAYER_SCALE
	var t_width = cfg.tire_width * PLAYER_SCALE
	
	if wheel_fl and wheel_fr and wheel_rl and wheel_rr:
		wheel_fl.position = Vector3(-track_x, y_mount, -wb_z)
		wheel_fr.position = Vector3(track_x, y_mount, -wb_z)
		wheel_rl.position = Vector3(-track_x, y_mount, wb_z)
		wheel_rr.position = Vector3(track_x, y_mount, wb_z)
		
	for w in [wheel_fl, wheel_fr, wheel_rl, wheel_rr]:
		if not w: continue
		w.suspension_travel = cfg.suspension_travel * PLAYER_SCALE
		w.suspension_stiffness = cfg.suspension_stiffness
		w.damping_compression = cfg.damping_compression
		w.damping_relaxation = cfg.damping_relaxation
		w.wheel_rest_length = cfg.wheel_rest_length * PLAYER_SCALE
		w.wheel_roll_influence = cfg.wheel_roll_influence
		w.wheel_friction_slip = cfg.wheel_friction_slip
		w.wheel_radius = r_radius
		
		# Proportional cylinder scaling: local X & Z = radius, local Y = width (axle axis)
		var mesh_node = w.get_node_or_null("WheelMesh")
		if mesh_node:
			var s_rad = r_radius / (0.28 * PLAYER_SCALE)
			var s_wid = t_width / (0.18 * PLAYER_SCALE)
			mesh_node.scale = Vector3(s_rad, s_wid, s_rad)
			
			var rim_node = mesh_node.get_node_or_null("RimMesh")
			if rim_node:
				var rim_mat = mat_panda_rim
				if model_id == "delta_integrale": rim_mat = mat_delta_rim
				elif model_id == "mercedes_gwagen": rim_mat = mat_gwagen_rim
				elif model_id == "fiat_127": rim_mat = mat_127_rim
				elif model_id == "golf_gti_1990": rim_mat = mat_golf_rim
				elif model_id == "renault_4": rim_mat = mat_r4_rim
				elif model_id == "bmw_320_e30": rim_mat = mat_bmw_rim
				elif model_id == "mercedes_a250": rim_mat = mat_a250_rim
				elif model_id == "alfa_8c": rim_mat = mat_8c_rim
				elif model_id == "fiat_topolino": rim_mat = mat_topolino_rim
				elif model_id == "lancia_aurelia": rim_mat = mat_aurelia_rim
				elif model_id == "alfa_gta": rim_mat = mat_gta_rim
				elif model_id == "lancia_stratos": rim_mat = mat_stratos_rim
				elif model_id == "fiat_131_abarth": rim_mat = mat_131_rim
				if rim_mat:
					rim_node.material_override = rim_mat
		
	# 3. Model Exterior Visibility
	if not model_panda and has_node("ModelPanda"):
		model_panda = $ModelPanda
		model_delta = $ModelDelta
		model_gwagen = $ModelGwagen
		
	if model_panda: model_panda.visible = (model_id == "panda_4x4")
	if model_delta: model_delta.visible = (model_id == "delta_integrale")
	if model_gwagen: model_gwagen.visible = (model_id == "mercedes_gwagen")
	if model_127: model_127.visible = (model_id == "fiat_127")
	if model_golf: model_golf.visible = (model_id == "golf_gti_1990")
	if model_r4: model_r4.visible = (model_id == "renault_4")
	if model_bmw: model_bmw.visible = (model_id == "bmw_320_e30")
	if model_a250: model_a250.visible = (model_id == "mercedes_a250")
	if model_8c: model_8c.visible = (model_id == "alfa_8c")
	if model_topolino: model_topolino.visible = (model_id == "fiat_topolino")
	if model_aurelia: model_aurelia.visible = (model_id == "lancia_aurelia")
	if model_gta: model_gta.visible = (model_id == "alfa_gta")
	if model_stratos: model_stratos.visible = (model_id == "lancia_stratos")
	if model_131: model_131.visible = (model_id == "fiat_131_abarth")
	if model_porsche_930: model_porsche_930.visible = (model_id == "porsche_930_turbo")
	if model_porsche_c4s: model_porsche_c4s.visible = (model_id == "porsche_carrera_4s")
	if model_countach: model_countach.visible = (model_id == "countach_lpi800")
	
	# 4. Model-specific Physical Collision Box (scalato rigorosamente al 75%)
	var col_shape_node = get_node_or_null("CollisionShape3D")
	if col_shape_node:
		var c_box = BoxShape3D.new()
		var box_size = Vector3(1.48, 0.82, 3.40)
		var box_y = 0.58
		if model_id == "panda_4x4":
			box_size = Vector3(1.48, 0.82, 3.40)
			box_y = 0.58
		elif model_id == "fiat_127":
			box_size = Vector3(1.44, 0.76, 3.44)
			box_y = 0.54
		elif model_id == "golf_gti_1990":
			box_size = Vector3(1.64, 0.78, 3.86)
			box_y = 0.54
		elif model_id == "renault_4":
			box_size = Vector3(1.48, 0.85, 3.62)
			box_y = 0.59
		elif model_id == "bmw_320_e30":
			box_size = Vector3(1.65, 0.74, 4.25)
			box_y = 0.52
		elif model_id == "mercedes_a250":
			box_size = Vector3(1.78, 0.76, 4.25)
			box_y = 0.54
		elif model_id == "delta_integrale":
			box_size = Vector3(1.72, 0.74, 3.90)
			box_y = 0.52
		elif model_id == "mercedes_gwagen":
			box_size = Vector3(1.82, 1.15, 4.15)
			box_y = 0.76
		elif model_id == "alfa_8c":
			box_size = Vector3(1.60, 0.76, 4.40)
			box_y = 0.54
		elif model_id == "fiat_topolino":
			box_size = Vector3(1.28, 0.82, 3.20)
			box_y = 0.56
		elif model_id == "lancia_aurelia":
			box_size = Vector3(1.54, 0.76, 4.35)
			box_y = 0.52
		elif model_id == "alfa_gta":
			box_size = Vector3(1.58, 0.74, 4.08)
			box_y = 0.52
		elif model_id == "lancia_stratos":
			box_size = Vector3(1.75, 0.70, 3.70)
			box_y = 0.48
		elif model_id == "fiat_131_abarth":
			box_size = Vector3(1.72, 0.78, 4.20)
			box_y = 0.54
		elif model_id == "porsche_930_turbo":
			box_size = Vector3(1.78, 0.72, 4.29)
			box_y = 0.50
		elif model_id == "porsche_carrera_4s":
			box_size = Vector3(1.85, 0.70, 4.52)
			box_y = 0.48
		elif model_id == "countach_lpi800":
			box_size = Vector3(2.05, 0.65, 4.87)
			box_y = 0.46
		c_box.size = box_size * PLAYER_SCALE
		col_shape_node.shape = c_box
		col_shape_node.position.y = box_y * PLAYER_SCALE
		
	# Sensore di crash frontale aggiornato per la sagoma scalata
	if front_crash_ray:
		front_crash_ray.position = Vector3(0.0, 0.45 * PLAYER_SCALE, -wb_z - (0.35 * PLAYER_SCALE))
		front_crash_ray.target_position = Vector3(0.0, 0.0, -0.85 * PLAYER_SCALE)
		
	# 5. Position Taillights to rear fascia to prevent illuminating cabin interior (scalati al 75%)
	if taillight_l and taillight_r:
		var tz = 1.76
		var ty = 0.58
		var tx = 0.56
		if model_id == "fiat_127":
			tz = 1.72
			ty = 0.58
			tx = 0.56
		elif model_id == "golf_gti_1990":
			tz = 1.92
			ty = 0.54
			tx = 0.62
		elif model_id == "renault_4":
			tz = 1.82
			ty = 0.60
			tx = 0.56
		elif model_id == "bmw_320_e30":
			tz = 2.12
			ty = 0.56
			tx = 0.64
		elif model_id == "mercedes_a250":
			tz = 2.14
			ty = 0.60
			tx = 0.68
		elif model_id == "delta_integrale":
			tz = 2.02
			ty = 0.54
			tx = 0.62
		elif model_id == "mercedes_gwagen":
			tz = 2.15
			ty = 0.72
			tx = 0.68
		elif model_id == "alfa_8c":
			tz = 2.12
			ty = 0.46
			tx = 0.48
		elif model_id == "fiat_topolino":
			tz = 1.46
			ty = 0.56
			tx = 0.42
		elif model_id == "lancia_aurelia":
			tz = 2.08
			ty = 0.56
			tx = 0.65
		elif model_id == "alfa_gta":
			tz = 2.02
			ty = 0.54
			tx = 0.58
		elif model_id == "lancia_stratos":
			tz = 1.84
			ty = 0.52
			tx = 0.65
		elif model_id == "fiat_131_abarth":
			tz = 2.06
			ty = 0.54
			tx = 0.62
		elif model_id == "porsche_930_turbo":
			tz = 2.10
			ty = 0.52
			tx = 0.70
		elif model_id == "porsche_carrera_4s":
			tz = 2.20
			ty = 0.54
			tx = 0.74
		elif model_id == "countach_lpi800":
			tz = 2.38
			ty = 0.52
			tx = 0.82
		taillight_l.position = Vector3(-tx * PLAYER_SCALE, ty * PLAYER_SCALE, tz * PLAYER_SCALE)
		taillight_r.position = Vector3(tx * PLAYER_SCALE, ty * PLAYER_SCALE, tz * PLAYER_SCALE)
		taillight_l.omni_range = 2.4 * PLAYER_SCALE
		taillight_r.omni_range = 2.4 * PLAYER_SCALE

	# 6. Audio Engine Model Switch
	if audio_engine and audio_engine.has_method("set_sound_profile"):
		audio_engine.set_sound_profile(model_id)

func set_vehicle_body_color(col):
	var c: Color = Color.WHITE
	if col is Color:
		c = col
	elif col is String:
		var s = col.strip_edges()
		if s.begins_with("(") and s.ends_with(")"):
			var parts = s.trim_prefix("(").trim_suffix(")").split(",")
			if parts.size() >= 3:
				var a_val = parts[3].to_float() if parts.size() > 3 else 1.0
				c = Color(parts[0].to_float(), parts[1].to_float(), parts[2].to_float(), a_val)
		else:
			c = Color.from_string(s, Color.WHITE)
	match current_model_id:
		"panda_4x4": if mat_panda_body: mat_panda_body.albedo_color = c
		"delta_integrale": if mat_delta_body: mat_delta_body.albedo_color = c
		"mercedes_gwagen": if mat_gwagen_body: mat_gwagen_body.albedo_color = c
		"fiat_127": if mat_127_body: mat_127_body.albedo_color = c
		"golf_gti_1990": if mat_golf_body: mat_golf_body.albedo_color = c
		"renault_4": if mat_r4_body: mat_r4_body.albedo_color = c
		"bmw_320_e30": if mat_bmw_body: mat_bmw_body.albedo_color = c
		"mercedes_a250": if mat_a250_body: mat_a250_body.albedo_color = c
		"alfa_8c": if mat_8c_body: mat_8c_body.albedo_color = c
		"fiat_topolino": if mat_topolino_body: mat_topolino_body.albedo_color = c
		"lancia_aurelia": if mat_aurelia_body: mat_aurelia_body.albedo_color = c
		"alfa_gta": if mat_gta_body: mat_gta_body.albedo_color = c
		"lancia_stratos": if mat_stratos_body: mat_stratos_body.albedo_color = c
		"fiat_131_abarth": if mat_131_body: mat_131_body.albedo_color = c

func apply_street_rod_upgrades(car_data: Dictionary):
	active_street_rod_upgrades = car_data
	if not VEHICLE_CATALOG.has(current_model_id): return
	var cfg = VEHICLE_CATALOG[current_model_id]
	var parts = car_data.get("tuning_parts", [])
	
	var torque_mult = 1.0
	if parts.has("scarico_sport"): torque_mult *= 1.08
	if parts.has("carburatori_doppi"): torque_mult *= 1.12
	cfg["dynamic_torque_mult"] = torque_mult
	
	if parts.has("camme_spinte"): cfg["dynamic_redline_boost"] = 500.0
	else: cfg["dynamic_redline_boost"] = 0.0
	
	if parts.has("overboost_turbo"): cfg["dynamic_boost_bonus"] = 0.25
	else: cfg["dynamic_boost_bonus"] = 0.0
	
	if parts.has("assetto_corsa"):
		for w in [wheel_fl, wheel_fr, wheel_rl, wheel_rr]:
			if w:
				w.suspension_stiffness = cfg.suspension_stiffness * 1.35
				w.wheel_roll_influence = cfg.wheel_roll_influence * 0.60
	else:
		for w in [wheel_fl, wheel_fr, wheel_rl, wheel_rr]:
			if w:
				w.suspension_stiffness = cfg.suspension_stiffness
				w.wheel_roll_influence = cfg.wheel_roll_influence
				
	var t_type = car_data.get("tire_type", "touring")
	var friction_bonus = 0.0
	if t_type == "semislick": friction_bonus = 0.40
	elif t_type == "studded": friction_bonus = 0.20
	for w in [wheel_fl, wheel_fr, wheel_rl, wheel_rr]:
		if w:
			w.wheel_friction_slip = cfg.wheel_friction_slip + friction_bonus
			
	if car_data.has("color_rgb"):
		set_vehicle_body_color(car_data["color_rgb"])

func get_engine_torque_factor(rpm: float, cfg: Dictionary) -> float:
	var idle = cfg.idle_rpm
	var redline = cfg.redline_rpm
	var peak = cfg.torque_peak_rpm
	var pmax = cfg.max_power_rpm
	if rpm < idle:
		return 0.65
	if rpm <= peak:
		return lerp(0.70, 1.00, (rpm - idle) / (peak - idle))
	elif rpm <= pmax:
		return lerp(1.00, 0.88, (rpm - peak) / (pmax - peak))
	elif rpm <= redline:
		return lerp(0.88, 0.65, (rpm - pmax) / (redline - pmax))
	else:
		# Soft rev limiter cutoff
		var over = (rpm - redline) / 250.0
		return max(0.0, 0.65 - over * 2.0)

func _physics_process(delta: float):
	if not wheel_fl:
		wheel_fl = get_node_or_null("WheelFL")
		wheel_fr = get_node_or_null("WheelFR")
		wheel_rl = get_node_or_null("WheelRL")
		wheel_rr = get_node_or_null("WheelRR")
	if not wheel_fl or not wheel_fr or not wheel_rl or not wheel_rr:
		return

	var cfg = VEHICLE_CATALOG[current_model_id]
	
	# 1. Input Resolution (Player vs AI Driver)
	var throttle_input = ai_throttle if is_ai_controlled else Input.get_action_strength("accelerate")
	var brake_input = ai_brake if is_ai_controlled else Input.get_action_strength("brake")
	var steer_raw = ai_steer if is_ai_controlled else Input.get_axis("steer_right", "steer_left")
	var handbrake = ai_handbrake if is_ai_controlled else Input.is_action_pressed("handbrake")
	
	# Se il motore è spento (in garage o fermo a quadro spento), zero gas e giri fermi
	if not is_engine_running:
		throttle_input = 0.0
		engine_rpm = 0.0
	
	if not is_ai_controlled:
		if Input.is_action_just_pressed("toggle_lights"):
			headlights_on = !headlights_on
			update_headlights()
			
		if Input.is_action_just_pressed("toggle_4wd"):
			is_4wd_engaged = !is_4wd_engaged
			
		if Input.is_action_just_pressed("change_vehicle"):
			switch_vehicle()
			
		# Tasto K: Soccorso Stradale Manuale (Recupero Immediato Veicolo)
		if Input.is_key_pressed(KEY_K):
			recover_vehicle_to_track()
			
		# Tasto H: Clacson Bitonale Italiano (segnala sorpasso al traffico civile)
		if horn_cooldown > 0.0: horn_cooldown -= delta
		if Input.is_key_pressed(KEY_H) and horn_cooldown <= 0.0:
			play_horn_honk()
			horn_cooldown = 0.55

	# Sistema Intelligente Soccorso Stradale ACI / Recupero da Caduta nel Vuoto
	var need_recovery = false
	if road_generator and road_generator.has_method("get_road_info_at"):
		var r_info = road_generator.get_road_info_at(global_position.z)
		if r_info.has("y"):
			var exp_y = float(r_info.y)
			if global_position.y < exp_y - 18.0:
				need_recovery = true
		elif global_position.y < -25.0:
			need_recovery = true
	elif global_position.y < -25.0:
		need_recovery = true
		
	if need_recovery:
		recover_vehicle_to_track()

	var speed_ms = linear_velocity.length()
	if speed_ms < 0.05:
		speed_ms = 0.0
	current_speed_kmh = speed_ms * 3.6
	
	# Dynamic Longitudinal Weight Transfer Calculation (Accelerazione vs Frenata)
	var current_accel_vec = (linear_velocity - last_linear_velocity) / max(0.0001, delta)
	last_linear_velocity = linear_velocity
	var local_accel = global_transform.basis.inverse() * current_accel_vec
	var long_accel_g = -local_accel.z / 9.81
	weight_transfer_long = clamp(long_accel_g * 0.40, -0.65, 0.65)
	
	# Rilevamento Impatti Violenti (SOLO contro ostacoli verticali reali: muretti, guardrail, ostacoli rigidi)
	# Le salite stradali, dossi o pendenze hanno normale rivolta verso l'alto (normal.y > 0.65) e NON sono ostacoli!
	if impact_cooldown > 0.0: impact_cooldown -= delta
	if local_accel.z > 85.0 and speed_ms > 9.0 and impact_cooldown <= 0.0:
		var is_real_vertical_obstacle = false
		if front_crash_ray and front_crash_ray.is_colliding():
			var col_norm = front_crash_ray.get_collision_normal()
			# Ostacolo verticale reale: normal.y < 0.45 (muro, guardrail, roccia verticale)
			# Fondo stradale / salita ripida: normal.y > 0.70 (piano stradale inclinato, NO crash!)
			if col_norm.y < 0.45:
				is_real_vertical_obstacle = true
				
		if is_real_vertical_obstacle:
			on_hard_impact_detected(local_accel.z)
			impact_cooldown = 1.4
	
	# 2. Progressive Analog Steering System (Art of Rally & Driving Sim Architecture)
	# Replaces sudden digital binary jumps ("a scatti") with a calibrated progressive accumulator:
	# - Keypress builds up steering input progressively (~0.18s to full lock)
	# - Releasing key returns swiftly to center (self-aligning caster geometry)
	var is_steering_active = abs(steer_raw) > 0.02
	var steer_input_rate = 4.4 if is_steering_active else 7.8
	if is_steering_active and sign(steer_raw) != sign(steer_input_smoothed) and abs(steer_input_smoothed) > 0.05:
		steer_input_rate = 9.5 # Fast direction reversal through center
		
	steer_input_smoothed = move_toward(steer_input_smoothed, steer_raw, steer_input_rate * delta)
	
	# Non-linear input response curve: micro-precision on straights, full authority in hairpins
	var curved_input = sign(steer_input_smoothed) * pow(abs(steer_input_smoothed), 1.45)
	
	# Speed-Sensitive Steering Lock (Dynamic Ackermann Reduction)
	# High speeds require small angles to prevent violent lateral G shock & snap oversteer:
	var speed_steer_factor = 1.0 / (1.0 + (current_speed_kmh / 45.0) * 1.35)
	speed_steer_factor = clamp(speed_steer_factor, 0.20, 1.0)
	
	var max_steer_angle_rad = deg_to_rad(cfg.steer_angle) * speed_steer_factor
	var target_steer = curved_input * max_steer_angle_rad
	
	# Dynamic Slew Rate:
	# - Turn-in rate: 2.8 rad/s (builds smoothly over progressive frames without shocking chassis)
	# - Centering rate: 6.2 rad/s (rapid stabilizing centering)
	var is_turning_in = (abs(target_steer) > abs(steering)) and (sign(target_steer) == sign(steering) or abs(steering) < 0.01)
	var slew_rate = 2.8 if is_turning_in else 6.2
	
	# Dynamic Self-Aligning Caster & Yaw Damping (Eliminates Pendulum Fishtailing / Tank-Slappers)
	var local_yaw_rate = (global_transform.basis.inverse() * angular_velocity).y
	if not is_steering_active and abs(local_yaw_rate) > 0.20:
		var caster_correction = clamp(-local_yaw_rate * 0.055, -0.12, 0.12)
		target_steer = caster_correction
		slew_rate = 6.8
		
	steering = move_toward(steering, target_steer, slew_rate * delta)
	
	# Tactile cobblestone / pavé micro-jitter feedback (vibrazione tattile da porfido)
	if "PAVÉ" in current_surface_name and speed_ms > 2.0:
		var pave_jitter = sin(Time.get_ticks_msec() * 0.045) * 0.0035 * clamp(speed_ms / 14.0, 0.2, 1.0)
		steering += pave_jitter
	
	# Animate the active 3D interior steering wheel based on steering angle
	var active_wheel: Node3D = null
	if current_model_id == "panda_4x4" and model_panda:
		active_wheel = model_panda.find_child("SteeringWheel_Panda", true, false)
	elif current_model_id == "fiat_127" and model_127:
		active_wheel = model_127.find_child("SteeringWheel_127", true, false)
	elif current_model_id == "golf_gti_1990" and model_golf:
		active_wheel = model_golf.find_child("SteeringWheel_Golf", true, false)
	elif current_model_id == "renault_4" and model_r4:
		active_wheel = model_r4.find_child("SteeringWheel_R4", true, false)
	elif current_model_id == "bmw_320_e30" and model_bmw:
		active_wheel = model_bmw.find_child("SteeringWheel_BMW", true, false)
	elif current_model_id == "mercedes_a250" and model_a250:
		active_wheel = model_a250.find_child("SteeringWheel_A250", true, false)
	elif current_model_id == "delta_integrale" and model_delta:
		active_wheel = model_delta.find_child("SteeringWheel_Delta", true, false)
	elif current_model_id == "mercedes_gwagen" and model_gwagen:
		active_wheel = model_gwagen.find_child("SteeringWheel_Gwagen", true, false)
		
	if active_wheel:
		active_wheel.rotation.z = steering * 3.4
	
	# 3. Surface Classification & Differentiated Traction (Asfalto vs Fuoristrada)
	if not road_generator and get_parent() and get_parent().has_node("RoadGenerator"):
		road_generator = get_parent().get_node("RoadGenerator")
		
	if road_generator:
		# 3a. Service Station & Amenities Query
		if road_generator.has_method("get_service_station_at"):
			var s_info = road_generator.get_service_station_at(global_position)
			is_in_service_zone = s_info.get("found", false)
			is_in_service_bay = s_info.get("in_bay", false)
			service_station_name = s_info.get("name", "")
			service_station_type = s_info.get("type", "autogrill_bar")
			
		var in_forecourt = false
		if road_generator.has_method("is_in_service_forecourt"):
			in_forecourt = road_generator.is_in_service_forecourt(global_position)
			
		# Handle Service Interaction Timer & Player Prompt
		if service_message_timer > 0.0:
			service_message_timer = max(0.0, service_message_timer - delta)
			if service_message_timer <= 0.0:
				service_message = ""
		if service_cooldown > 0.0:
			service_cooldown = max(0.0, service_cooldown - delta)
			
		var service_key_pressed = Input.is_key_pressed(KEY_E)
		if is_in_service_bay:
			if current_speed_kmh < 1.5:
				service_stop_timer += delta
			else:
				service_stop_timer = 0.0
				
			if (service_key_pressed and service_cooldown <= 0.0) or (service_stop_timer >= 2.2 and service_cooldown <= 0.0 and current_fuel < cfg.tank_l * 0.96):
				perform_service(cfg)
		else:
			service_stop_timer = 0.0
				
		# 3b. Road vs Off-road Physical Adhesion & Friction Slip
		if in_forecourt:
			current_surface_name = "AREA DI SERVIZIO"
			current_grip_mult = 1.00
			offroad_drag_factor = 0.0
		elif road_generator.has_method("get_road_info_at"):
			var r_info = road_generator.get_road_info_at(global_position.z)
			if r_info.get("found", false):
				var dist_center = abs(global_position.x - r_info.x)
				var road_hw = r_info.width * 0.5
				var shoulder_hw = road_hw + 1.8
				
				if dist_center <= road_hw:
					current_surface_name = r_info.get("surface_name", "ASFALTO ALPINO USURATO")
					current_grip_mult = r_info.get("grip_mult", 1.00)
					var s_type = r_info.get("surface_type", 0)
					if s_type == 4: # STRADA BIANCA
						offroad_drag_factor = 0.08
					else:
						offroad_drag_factor = 0.0
				elif dist_center <= shoulder_hw:
					current_surface_name = "BANCHINA GHIAIA"
					current_grip_mult = 0.74
					offroad_drag_factor = 0.22
				else:
					# Fuoristrada (Erba, fango o neve montana)
					var is_snow = (global_position.y > 6.0 and global_position.z < 600.0)
					current_surface_name = "NEVE ALTA" if is_snow else "ERBA / FUORISTRADA"
					
					# Mechanical 4WD Advantage!
					var has_active_4wd = (is_4wd_engaged and current_model_id in ["panda_4x4", "mercedes_gwagen"]) or (current_model_id == "delta_integrale")
					if has_active_4wd:
						# 4WD provides tire grip and halves off-road rolling drag
						current_grip_mult = 0.78
						offroad_drag_factor = 0.38
					else:
						# 2WD without locking slips heavily on grass/mud!
						current_grip_mult = 0.36
						offroad_drag_factor = 0.90
						
		# 3b. Controllo macchie scivolose (pozzanghere / olio motore dal HazardManager)
		if not hazard_manager and get_parent() and get_parent().has_node("HazardManager"):
			hazard_manager = get_parent().get_node("HazardManager")
		if hazard_manager and hazard_manager.has_method("get_slippery_factor"):
			var slip_factor = hazard_manager.get_slippery_factor(global_position)
			if slip_factor < 0.95:
				current_grip_mult *= slip_factor
				current_surface_name = "MACCHIA D'OLIO / VISCIDO"

		# 3c. Ripartizione dinamica aderenza: Trasferimento di carico & Dinamica telaio FWD/RWD/AWD
		var base_grip = cfg.wheel_friction_slip * current_grip_mult
		var tire_mult = cfg.get("dynamic_grip_mult", 1.0)
		base_grip *= tire_mult
		
		# Trasferimento longitudinale (accelerazione carica il retrotreno, frenata carica l'avantreno)
		var front_load_factor = clamp(1.0 - weight_transfer_long * 0.45, 0.55, 1.45)
		var rear_load_factor = clamp(1.0 + weight_transfer_long * 0.45, 0.55, 1.45)
		
		var front_grip = base_grip * front_load_factor
		var rear_grip = base_grip * rear_load_factor
		
		var steer_magnitude = abs(steering)
		if current_model_id in ["fiat_127", "golf_gti_1990", "renault_4"]:
			# Dinamica Trazione Anteriore (FWD):
			# Sotto coppia in curva, saturazione ruote anteriori -> sottosterzo progressivo
			if throttle_input > 0.35 and steer_magnitude > 0.04:
				var understeer_drop = clamp(throttle_input * 0.28, 0.0, 0.36)
				front_grip *= (1.0 - understeer_drop)
			# Rilascio gas in curva (Lift-off oversteer): alleggerimento posteriore e inserimento rapido
			elif throttle_input < 0.1 and brake_input > 0.08 and steer_magnitude > 0.05:
				rear_grip *= 0.85
		elif current_model_id in ["bmw_320_e30", "alfa_8c", "fiat_topolino", "lancia_aurelia", "alfa_gta", "lancia_stratos", "fiat_131_abarth"]:
			# Dinamica Trazione Posteriore (RWD):
			# Coppia elevata in curva a marce basse rompe l'aderenza posteriore -> sovrasterzo di potenza / drift
			if throttle_input > 0.40 and steer_magnitude > 0.03 and current_gear <= 3:
				var oversteer_slip = clamp((throttle_input - 0.40) * 0.55, 0.0, 0.46)
				rear_grip *= (1.0 - oversteer_slip)
				# Agevola il controllo in controsterzo
				if sign(steer_raw) != sign(local_yaw_rate) and abs(steer_raw) > 0.10:
					rear_grip *= 1.25
		elif current_model_id in ["delta_integrale", "mercedes_a250"]:
			# Trazione Integrale (AWD): massima motricità neutra e bilanciata
			front_grip *= 1.05
			rear_grip *= 1.05
			
		wheel_fl.wheel_friction_slip = front_grip
		wheel_fr.wheel_friction_slip = front_grip
		wheel_rl.wheel_friction_slip = rear_grip
		wheel_rr.wheel_friction_slip = rear_grip
		
		# 3d. Rilevamento buche e asperità (Scosse realistiche, assorbimento ammortizzatori, ZERO ribaltamento)
		if pothole_cooldown > 0.0:
			pothole_cooldown -= delta
		if road_generator and pothole_cooldown <= 0.0:
			var wheels = [
				{ "node": wheel_fl, "is_front": true, "is_left": true },
				{ "node": wheel_fr, "is_front": true, "is_left": false },
				{ "node": wheel_rl, "is_front": false, "is_left": true },
				{ "node": wheel_rr, "is_front": false, "is_left": false }
			]
			var hit_obstacle = false
			if road_generator.has_method("get_pothole_at_position"):
				for w_data in wheels:
					var w = w_data.node
					var pot = road_generator.get_pothole_at_position(w.global_position, 0.55)
					if not pot.is_empty():
						hit_obstacle = true
						pothole_cooldown = 0.32
						
						# Sospensioni assorbono il 90% dell'energia: impulso calibrato realistico
						var pot_depth = pot.get("depth", 0.05)
						var depth_factor = clamp(pot_depth / 0.05, 0.7, 1.3)
						var shock_mag = mass * clamp(current_speed_kmh / 110.0, 0.12, 0.40) * 0.28 * depth_factor
						
						# Impulso applicato con braccio di rollio ridotto per eliminare il ribaltamento
						var local_impulse_pos = Vector3(w.position.x * 0.15, 0.0, w.position.z * 0.40)
						apply_impulse(Vector3(0, shock_mag, 0), local_impulse_pos)
						
						# Smorzamento attivo velocità di rollio (barra antirollio idraulica)
						angular_velocity.z = clamp(angular_velocity.z * 0.30, -0.40, 0.40)
						
						# Bump Steer realistico (micro-vibrazione di contraccolpo al volante < 0.8 gradi)
						if w_data.is_front:
							var bump_dir = 1.0 if w_data.is_left else -1.0
							var kick = bump_dir * deg_to_rad(randf_range(0.35, 0.70)) * clamp(current_speed_kmh / 60.0, 0.25, 0.65)
							steer_input_smoothed += kick
						
						# Breve calo di aderenza della ruota colpita (saltellamento gomma su spigolo)
						w.wheel_friction_slip = max(0.85, w.wheel_friction_slip * 0.88)
						
						# Scossone visivo camera (Camera Trauma) per restituire il colpo nell'abitacolo
						var cam = get_parent().get_node_or_null("CameraController") if get_parent() else null
						if not cam and get_tree() and get_tree().root:
							cam = get_tree().root.find_child("CameraController", true, false)
						if cam and cam.has_method("add_trauma"):
							cam.add_trauma(clamp(current_speed_kmh / 95.0, 0.15, 0.36))
							
						# Audio tonfo meccanico sordo sospensione/gomma
						if audio_engine and audio_engine.has_method("play_suspension_thud"):
							audio_engine.play_suspension_thud()
							
						if current_speed_kmh > 85.0:
							engine_health = max(10.0, engine_health - 0.20)
						break
			
			# Controlla passaggio su rappezzi d'asfalto (micro-vibrazione da toppa bituminosa)
			if not hit_obstacle and road_generator.has_method("get_road_patch_at_position"):
				for w_data in wheels:
					var w = w_data.node
					var patch = road_generator.get_road_patch_at_position(w.global_position, 0.50)
					if not patch.is_empty():
						pothole_cooldown = 0.20
						var patch_shock = mass * clamp(current_speed_kmh / 140.0, 0.04, 0.10) * 0.08
						apply_impulse(Vector3(0, patch_shock, 0), Vector3(w.position.x * 0.1, 0, w.position.z * 0.2))
						var cam = get_parent().get_node_or_null("CameraController") if get_parent() else null
						if cam and cam.has_method("add_trauma"):
							cam.add_trauma(0.04)
						if audio_engine and audio_engine.has_method("play_road_joint_click"):
							audio_engine.play_road_joint_click()
						break
		
		# Apply physical rolling resistance drag on unpaved terrain
		if offroad_drag_factor > 0.0 and speed_ms > 0.4:
			var drag_dir = linear_velocity / speed_ms
			var drag_n = mass * 1.65 * offroad_drag_factor
			apply_central_force(-drag_dir * drag_n)

	# 4. Transmission, Shift Logic & Engine RPM Kinematics
	update_transmission(throttle_input, brake_input, speed_ms, delta, cfg)
	
	# 4. Turbo boost simulation (Garrett T3 on Lancia Delta)
	if cfg.has_turbo:
		var target_boost = 0.0
		if throttle_input > 0.08 and engine_rpm > 2100.0:
			var spool = clamp((engine_rpm - 2100.0) / 3200.0, 0.0, 1.0)
			var max_b = cfg.turbo_boost_max + cfg.get("dynamic_boost_bonus", 0.0)
			target_boost = throttle_input * max_b * spool
		current_boost_bar = lerp(current_boost_bar, target_boost, delta * 4.8)
	else:
		current_boost_bar = 0.0
		
	# 5. Engine Torque Generation & Real Wheel Tractive Force
	# F_tractive = (Torque_engine * r_gear * r_diff * efficiency) / R_wheel
	var v_top_ms = cfg.top_speed / 3.6
	var total_wheel_force = 0.0
	if shift_timer > 0.0:
		# Clutch disengaged during gear shifting
		total_wheel_force = 0.0
	else:
		var current_ratio = abs(cfg.gear_ratios[current_gear - 1])
		var tractive_mult = (cfg.engine_torque_nm * cfg.final_drive * cfg.drivetrain_efficiency) / cfg.wheel_radius
		var t_factor = get_engine_torque_factor(engine_rpm, cfg)
		var t_input = brake_input if is_reversing else throttle_input
		
		# Mechanical clutch slip model (allows full torque transmission on launch & hill-starts)
		var clutch_pct = 1.0
		if current_speed_kmh < cfg.clutch_lockup_speed:
			var slip_ratio = clamp(current_speed_kmh / cfg.clutch_lockup_speed, 0.0, 1.0)
			clutch_pct = lerp(0.88, 1.0, slip_ratio)
		var t_mult = cfg.get("dynamic_torque_mult", 1.0)
		var gross_wheel_force = t_input * tractive_mult * current_ratio * t_factor * clutch_pct * cfg.get("force_scale", 1.0) * t_mult
		
		if cfg.has_turbo:
			gross_wheel_force *= (1.0 + current_boost_bar * 0.70)
			
		total_wheel_force = gross_wheel_force
			
	# Dynamic Fuel Consumption & Engine Coolant Temperature Physics
	if throttle_input > 0.05 or is_reversing:
		var fuel_burn = delta * 0.0075 * (engine_rpm / 3000.0) * (1.25 if throttle_input > 0.85 else 1.0)
		current_fuel = max(0.0, current_fuel - fuel_burn)
		if current_fuel <= 0.0:
			total_wheel_force = 0.0
			
	# Radiator Thermal Kinetics
	var heat_load = (throttle_input * 1.6 + (engine_rpm / 6000.0) * 1.1) * 1.25
	var air_cooling = 0.45 + (current_speed_kmh / 75.0) * 2.2
	var target_temp = 88.0 + (heat_load - air_cooling) * 7.5
	target_temp = clamp(target_temp, 76.0, 115.0)
	engine_temp = lerp(engine_temp, target_temp, delta * 0.15)
	
	# Overheating power fade (> 108°C)
	if engine_temp > 108.0:
		var heat_fade = clamp(1.0 - (engine_temp - 108.0) * 0.08, 0.50, 1.0)
		total_wheel_force *= heat_fade
			
	# Drive force sign: in Godot 4 VehicleWheel3D facing +Z (180 deg yaw), negative engine_force propels forward (+Z)
	var drive_sign = 1.0 if is_reversing else -1.0
	var final_drive = total_wheel_force * drive_sign
	
	# Apply physical chassis aerodynamic drag
	if speed_ms > 0.5:
		var vel_dir = linear_velocity / speed_ms
		var cd_area = cfg.get("cd_area", 0.70)
		var aero_drag_n = 0.5 * 1.205 * cd_area * (speed_ms * speed_ms)
		apply_central_force(-vel_dir * aero_drag_n)
		
		# Downhill / terminal velocity overspeed governor
		if speed_ms > v_top_ms:
			var overspeed_drag = (speed_ms - v_top_ms) * mass * 3.5
			apply_central_force(-vel_dir * overspeed_drag)
	
	# 5b. Dynamic Anti-Roll Bar & Active Anti-Rollover Protection (Previene Ribaltamenti)
	var local_ang_vel = global_transform.basis.inverse() * angular_velocity
	var roll_rate = local_ang_vel.z
	var pitch_rate = local_ang_vel.x
	
	# Inclinazione trasversale reale rispetto all'orizzonte (indipendente dalla direzione di marcia)
	var local_right = global_transform.basis.x
	var chassis_tilt = clamp(local_right.y, -1.0, 1.0)
	
	var arb_stiffness = mass * 4.2
	var arb_damping = mass * 0.85
	var anti_roll_torque = -chassis_tilt * arb_stiffness - roll_rate * arb_damping
	var anti_pitch_torque = -pitch_rate * (mass * 0.35)
	
	# Applicazione coppia stabilizzatrice longitudinale e trasversale
	apply_torque(global_transform.basis.z * anti_roll_torque + global_transform.basis.x * anti_pitch_torque)
	
	# Garanzia anti-ribaltamento attiva: se l'inclinazione o la velocità angolare di rollio superano la soglia di sicurezza,
	# smorza istantaneamente il momento torcente di ribaltamento (effetto assetto sportivo / baricentro basso)
	if abs(chassis_tilt) > 0.18:
		var righting_mult = clamp((abs(chassis_tilt) - 0.18) * 8.0, 0.0, 4.0)
		apply_torque(global_transform.basis.z * (-chassis_tilt * mass * 12.0 * righting_mult))
		angular_velocity.z *= 0.82
	
	# Apply drive torque to wheels based on car drivetrain
	if current_model_id == "delta_integrale":
		# Torsen AWD 47:53 permanent rally split
		wheel_fl.engine_force = final_drive * 0.235
		wheel_fr.engine_force = final_drive * 0.235
		wheel_rl.engine_force = final_drive * 0.265
		wheel_rr.engine_force = final_drive * 0.265
	elif current_model_id == "mercedes_gwagen":
		if is_4wd_engaged:
			# 3x diff lock rigid 50:50
			wheel_fl.engine_force = final_drive * 0.25
			wheel_fr.engine_force = final_drive * 0.25
			wheel_rl.engine_force = final_drive * 0.25
			wheel_rr.engine_force = final_drive * 0.25
		else:
			# RWD mode
			wheel_fl.engine_force = 0.0
			wheel_fr.engine_force = 0.0
			wheel_rl.engine_force = final_drive * 0.50
			wheel_rr.engine_force = final_drive * 0.50
	elif current_model_id == "bmw_320_e30":
		# Pure Rear-Wheel Drive [RWD] BMW Bavarian Dynamics
		wheel_fl.engine_force = 0.0
		wheel_fr.engine_force = 0.0
		wheel_rl.engine_force = final_drive * 0.50
		wheel_rr.engine_force = final_drive * 0.50
	elif current_model_id in ["alfa_8c", "fiat_topolino", "lancia_aurelia", "alfa_gta", "lancia_stratos", "fiat_131_abarth"]:
		# Pure Classic Italian Rear-Wheel Drive [RWD] (Transaxle, De Dion, Mid-Engine Dino V6 & Lampredi 16V)
		wheel_fl.engine_force = 0.0
		wheel_fr.engine_force = 0.0
		wheel_rl.engine_force = final_drive * 0.50
		wheel_rr.engine_force = final_drive * 0.50
	elif current_model_id in ["fiat_127", "golf_gti_1990", "renault_4", "mercedes_a250"]:
		# Pure Front-Wheel Drive [FWD]
		wheel_fl.engine_force = final_drive * 0.50
		wheel_fr.engine_force = final_drive * 0.50
		wheel_rl.engine_force = 0.0
		wheel_rr.engine_force = 0.0
	else:
		# Panda 4x4 Steyr-Puch 4WD
		if is_4wd_engaged:
			wheel_fl.engine_force = final_drive * 0.25
			wheel_fr.engine_force = final_drive * 0.25
			wheel_rl.engine_force = final_drive * 0.25
			wheel_rr.engine_force = final_drive * 0.25
		else:
			wheel_fl.engine_force = final_drive * 0.50
			wheel_fr.engine_force = final_drive * 0.50
			wheel_rl.engine_force = 0.0
			wheel_rr.engine_force = 0.0
			
	# 6. Braking & Realistic Brake Bias
	var max_brake = cfg.brake_force
	var brake_torque = 0.0
	if not is_reversing and brake_input > 0.05:
		brake_torque = brake_input * max_brake
	elif is_reversing and throttle_input > 0.05:
		brake_torque = throttle_input * max_brake
		
	if handbrake:
		var hb_torque = max_brake * 3.0
		wheel_fl.brake = 0.0
		wheel_fr.brake = 0.0
		wheel_rl.brake = hb_torque
		wheel_rr.brake = hb_torque
	else:
		# Front/Rear brake bias (creates authentic nose-dive under braking without locking rears)
		wheel_fl.brake = brake_torque * 0.68
		wheel_fr.brake = brake_torque * 0.68
		wheel_rl.brake = brake_torque * 0.32
		wheel_rr.brake = brake_torque * 0.32
		
	if taillight_l and taillight_r:
		var is_braking = brake_input > 0.1 || handbrake
		taillight_l.light_energy = 3.5 if is_braking else (0.8 if headlights_on else 0.0)
		taillight_r.light_energy = 3.5 if is_braking else (0.8 if headlights_on else 0.0)

	# 7. Hazard Lights
	if hazard_lights_on:
		hazard_timer += delta
		if hazard_timer >= 0.36:
			hazard_timer = 0.0
			hazard_state = !hazard_state
			set_hazard_mesh_visible(hazard_state)
	else:
		set_hazard_mesh_visible(false)

	# 7b. Dynamic Wheel Particles (Dirt, Gravel, Snow, Tyre Smoke & Exhaust)
	update_wheel_particles(delta, cfg, throttle_input, brake_input, handbrake, speed_ms)

	# 7c. Tactile Chassis Weight Transfer Lean (Circuit Superstars Dynamic Suspension Feel)
	update_tactile_chassis_lean(delta, speed_ms, throttle_input, brake_input, cfg)

	# 8. Pitch & Roll Telemetry
	var pitch_deg = rad_to_deg(rotation.x)
	var roll_deg = rad_to_deg(rotation.z)
	
	# Emit live telemetry with model_info
	var rpm_norm = clamp((engine_rpm - cfg.idle_rpm) / (cfg.redline_rpm - cfg.idle_rpm), 0.0, 1.0)
	cfg["steer_norm"] = clamp(steering / deg_to_rad(cfg.steer_angle), -1.0, 1.0)
	cfg["surface_name"] = current_surface_name
	cfg["grip_pct"] = int(current_grip_mult * 100.0)
	cfg["is_in_service_bay"] = is_in_service_bay
	cfg["is_in_service_zone"] = is_in_service_zone
	cfg["service_message"] = service_message
	cfg["service_station_name"] = service_station_name
	cfg["engine_health"] = engine_health
	emit_signal("telemetry_updated", current_speed_kmh, rpm_norm, gear_name, current_fuel, engine_temp, pitch_deg, roll_deg, is_4wd_engaged, current_boost_bar, cfg)

func perform_service(cfg: Dictionary):
	var liters_added = cfg.tank_l - current_fuel
	current_fuel = cfg.tank_l
	engine_temp = 85.0
	engine_health = 100.0
	service_cooldown = 5.0
	service_message = "RIFORNIMENTO COMPLETATO: +%.1f L | TAGLIANDO & RIPARAZIONE EFFETTUATI (+250 PT)" % max(0.5, liters_added)
	service_message_timer = 5.0
	emit_signal("service_completed", liters_added, service_station_name)

func setup_wheel_particles():
	mat_wheel_particle = StandardMaterial3D.new()
	mat_wheel_particle.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_wheel_particle.vertex_color_use_as_albedo = true
	mat_wheel_particle.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_wheel_particle.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	
	var p_mesh = SphereMesh.new()
	p_mesh.radius = 0.20
	p_mesh.height = 0.20
	p_mesh.radial_segments = 6
	p_mesh.rings = 4
	p_mesh.material = mat_wheel_particle
	
	particle_wheel_rl = CPUParticles3D.new()
	particle_wheel_rl.name = "DustRL"
	particle_wheel_rl.mesh = p_mesh
	particle_wheel_rl.amount = 26
	particle_wheel_rl.lifetime = 0.55
	particle_wheel_rl.explosiveness = 0.0
	particle_wheel_rl.direction = Vector3(0.0, 0.45, 1.0)
	particle_wheel_rl.spread = 24.0
	particle_wheel_rl.gravity = Vector3(0.0, -1.8, 0.0)
	particle_wheel_rl.initial_velocity_min = 2.0
	particle_wheel_rl.initial_velocity_max = 5.5
	particle_wheel_rl.scale_amount_min = 0.4
	particle_wheel_rl.scale_amount_max = 2.2
	particle_wheel_rl.color = Color(0.65, 0.56, 0.42, 0.45)
	particle_wheel_rl.emitting = false
	add_child(particle_wheel_rl)
	
	particle_wheel_rr = CPUParticles3D.new()
	particle_wheel_rr.name = "DustRR"
	particle_wheel_rr.mesh = p_mesh
	particle_wheel_rr.amount = 26
	particle_wheel_rr.lifetime = 0.55
	particle_wheel_rr.explosiveness = 0.0
	particle_wheel_rr.direction = Vector3(0.0, 0.45, 1.0)
	particle_wheel_rr.spread = 24.0
	particle_wheel_rr.gravity = Vector3(0.0, -1.8, 0.0)
	particle_wheel_rr.initial_velocity_min = 2.0
	particle_wheel_rr.initial_velocity_max = 5.5
	particle_wheel_rr.scale_amount_min = 0.4
	particle_wheel_rr.scale_amount_max = 2.2
	particle_wheel_rr.color = Color(0.65, 0.56, 0.42, 0.45)
	particle_wheel_rr.emitting = false
	add_child(particle_wheel_rr)
	
	particle_exhaust = CPUParticles3D.new()
	particle_exhaust.name = "ExhaustParticles"
	particle_exhaust.mesh = p_mesh
	particle_exhaust.amount = 14
	particle_exhaust.lifetime = 0.32
	particle_exhaust.direction = Vector3(0.0, 0.1, 1.0)
	particle_exhaust.spread = 16.0
	particle_exhaust.gravity = Vector3(0.0, 0.4, 0.0)
	particle_exhaust.initial_velocity_min = 1.0
	particle_exhaust.initial_velocity_max = 3.2
	particle_exhaust.scale_amount_min = 0.2
	particle_exhaust.scale_amount_max = 0.75
	particle_exhaust.color = Color(0.35, 0.35, 0.35, 0.25)
	particle_exhaust.emitting = false
	add_child(particle_exhaust)

func update_wheel_particles(delta: float, cfg: Dictionary, throttle: float, brake: float, hb: bool, spd_ms: float):
	if not particle_wheel_rl or not particle_wheel_rr:
		return
		
	var track_x = cfg.track_x
	var wb_z = cfg.wheelbase_z
	var y_pos = 0.08
	particle_wheel_rl.position = Vector3(-track_x, y_pos, wb_z + 0.15)
	particle_wheel_rr.position = Vector3(track_x, y_pos, wb_z + 0.15)
	
	if particle_exhaust:
		var ex_x = 0.50 if current_model_id != "mercedes_gwagen" else -0.55
		var ex_z = wb_z + 0.65
		particle_exhaust.position = Vector3(ex_x, 0.22, ex_z)
	
	var is_offroad = current_surface_name in ["ERBA / FUORISTRADA", "BANCHINA GHIAIA", "NEVE ALTA"]
	var is_gravel = "STRADA BIANCA" in current_surface_name
	var is_wet = "BAGNATO" in current_surface_name
	var is_drifting = hb or (brake > 0.6 and spd_ms > 4.0) or (abs(steering) > 0.28 and spd_ms > 12.0)
	var is_slipping = is_offroad and spd_ms > 1.2
	var is_fast_rolling = (is_gravel or is_wet) and spd_ms > 3.2
	
	if is_slipping or is_drifting or is_fast_rolling:
		particle_wheel_rl.emitting = true
		particle_wheel_rr.emitting = true
		
		var p_col = Color(0.65, 0.56, 0.42, 0.42) # Dirt / gravel ochre
		if current_surface_name == "NEVE ALTA":
			p_col = Color(0.94, 0.96, 1.0, 0.60) # Snow white
		elif is_gravel:
			p_col = Color(0.85, 0.82, 0.74, 0.48) # Chalky limestone Strada Bianca dust plume
		elif is_wet:
			p_col = Color(0.80, 0.86, 0.94, 0.40) # Wet spray mist
		elif not is_offroad and is_drifting:
			p_col = Color(0.90, 0.91, 0.94, 0.38) # Asphalt tyre smoke
			
		particle_wheel_rl.color = p_col
		particle_wheel_rr.color = p_col
		
		var v_scale = clamp(spd_ms * 0.45, 2.0, 8.0)
		particle_wheel_rl.initial_velocity_min = v_scale * 0.6
		particle_wheel_rl.initial_velocity_max = v_scale
		particle_wheel_rr.initial_velocity_min = v_scale * 0.6
		particle_wheel_rr.initial_velocity_max = v_scale
	else:
		particle_wheel_rl.emitting = false
		particle_wheel_rr.emitting = false
		
	if particle_exhaust:
		var show_exhaust = (shift_timer > 0.08) or (current_boost_bar > 1.1 and throttle > 0.85)
		particle_exhaust.emitting = show_exhaust
		if current_model_id == "delta_integrale" and shift_timer > 0.12:
			particle_exhaust.color = Color(1.0, 0.55, 0.15, 0.85)
		else:
			particle_exhaust.color = Color(0.40, 0.40, 0.40, 0.28)

func get_active_model_node() -> Node3D:
	match current_model_id:
		"panda_4x4": return model_panda
		"delta_integrale": return model_delta
		"mercedes_gwagen": return model_gwagen
		"fiat_127": return model_127
		"golf_gti_1990": return model_golf
		"renault_4": return model_r4
		"bmw_320_e30": return model_bmw
		"mercedes_a250": return model_a250
		"alfa_8c": return model_8c
		"fiat_topolino": return model_topolino
		"lancia_aurelia": return model_aurelia
		"alfa_gta": return model_gta
		"lancia_stratos": return model_stratos
		"fiat_131_abarth": return model_131
	return null

func update_tactile_chassis_lean(delta: float, spd_ms: float, throttle: float, brake: float, cfg: Dictionary):
	var active_model = get_active_model_node()
	if not active_model:
		return
		
	# Circuit Superstars / Diorama compliant body roll and pitch:
	# Softer utilitarian cars (Panda 4x4, Fiat 127, R4) lean with great character into hairpins.
	# Stiffer track racers (Delta HF, Golf GTI, Stratos) corner with flatter, tighter chassis composure.
	var roll_multiplier = 0.065
	var pitch_multiplier = 0.045
	if current_model_id in ["panda_4x4", "fiat_127", "renault_4", "fiat_topolino"]:
		roll_multiplier = 0.095
		pitch_multiplier = 0.060
	elif current_model_id in ["delta_integrale", "lancia_stratos", "alfa_gta"]:
		roll_multiplier = 0.038
		pitch_multiplier = 0.028
		
	# Lateral roll responds to steering angle at speed
	var steer_norm = steering / deg_to_rad(cfg.steer_angle)
	var speed_factor = clamp(spd_ms / 16.0, 0.0, 1.35)
	var target_roll = clamp(-steer_norm * speed_factor * roll_multiplier * 1.5, -0.095, 0.095)
	
	# Longitudinal pitch responds to weight transfer (brake dive vs throttle squat)
	var target_pitch = clamp(-weight_transfer_long * pitch_multiplier, -0.055, 0.055)
	
	active_model.rotation.z = lerp(active_model.rotation.z, target_roll, delta * 12.0)
	active_model.rotation.x = lerp(active_model.rotation.x, target_pitch, delta * 10.0)

func set_engine_running(running: bool):
	is_engine_running = running
	if not running:
		engine_rpm = 0.0
	if audio_engine and audio_engine.has_method("set_engine_running"):
		audio_engine.set_engine_running(running)

func update_transmission(throttle: float, brake: float, speed_ms: float, delta: float, cfg: Dictionary):
	if not is_engine_running:
		engine_rpm = 0.0
		return

	# Decrement shift cooldown and shift clutch pause timers
	if shift_timer > 0.0:
		shift_timer = max(0.0, shift_timer - delta)
	if shift_cooldown > 0.0:
		shift_cooldown = max(0.0, shift_cooldown - delta)
		
	var total_gears = cfg.gear_ratios.size()
	var max_fwd_gear = total_gears - 1
	
	# 1. Reverse Gear Engagement Transition (richiede fermata completa e pressione intenzionale freno)
	if not is_reversing:
		if brake > 0.35 and current_speed_kmh < 1.5 and throttle < 0.05:
			reverse_intent_timer += delta
			if reverse_intent_timer > 0.25:
				is_reversing = true
				current_gear = total_gears
				gear_name = "R"
				shift_cooldown = 0.35
		else:
			reverse_intent_timer = 0.0
	else:
		if throttle > 0.08 or (brake < 0.08 and current_speed_kmh < 1.0):
			is_reversing = false
			current_gear = 1
			gear_name = cfg.gear_names[0]
			shift_cooldown = 0.35
			reverse_intent_timer = 0.0
		
	# 2. Kinematic Wheel-RPM coupling in current gear
	var ratio = abs(cfg.gear_ratios[current_gear - 1])
	var total_reduction = ratio * cfg.final_drive
	var wheel_omega = speed_ms / cfg.wheel_radius
	var rpm_from_wheels = (wheel_omega * total_reduction) * (60.0 / TAU)
	
	# 3. Clutch Slip Model (from standstill or low speeds)
	var t_input = brake if is_reversing else throttle
	var max_slip_rev = (cfg.redline_rpm - cfg.idle_rpm) * 0.70
	var slip_target_rpm = cfg.idle_rpm + t_input * (max_slip_rev if current_gear == 1 else max_slip_rev * 0.50)
	var clutch_factor = clamp(current_speed_kmh / cfg.clutch_lockup_speed, 0.0, 1.0)
	var raw_rpm = lerp(slip_target_rpm, rpm_from_wheels, clutch_factor)
	if rpm_from_wheels > slip_target_rpm:
		raw_rpm = rpm_from_wheels
	raw_rpm = max(raw_rpm, cfg.idle_rpm)
	
	# Soft rev limiter
	if raw_rpm > cfg.redline_rpm:
		raw_rpm = cfg.redline_rpm + randf_range(-30.0, 30.0)
		
	# Smooth mechanical engine inertia (decelerazione reattiva al rilascio del gas)
	var rpm_rate = 16.0 if (throttle < 0.05 or raw_rpm < engine_rpm) else (14.0 if shift_timer <= 0.0 else 8.0)
	engine_rpm = lerp(engine_rpm, raw_rpm, delta * rpm_rate)
	
	# 4. Intelligent Progressive Gear Shift Logic (Kickdown & Dynamic Sport Shifting)
	if not is_reversing and shift_cooldown <= 0.0 and shift_timer <= 0.0:
		var shift_speeds = cfg.get("shift_speeds", [16.0, 36.0, 62.0, 92.0])
		
		# Scalata immediata in 1ª se la vettura si arresta o scende sotto i 4.0 km/h
		if current_gear > 1 and current_speed_kmh < 4.0:
			current_gear = 1
			gear_name = cfg.gear_names[0]
			shift_timer = 0.0
			shift_cooldown = 0.20
			return
		
		# --- UPSHIFT ---
		if current_gear < max_fwd_gear:
			var base_shift_spd = shift_speeds[current_gear - 1]
			# Sotto pieno acceleratore, allunga il rapporto per tirare le marce verso il regime di potenza massima
			var throttle_shift_mult = lerp(1.0, 1.60, clamp((throttle - 0.25) / 0.75, 0.0, 1.0))
			var target_shift_spd = base_shift_spd * throttle_shift_mult
			var should_upshift = false
			
			# Speed threshold met e motore sopra il regime minimo di coppia
			if current_speed_kmh >= target_shift_spd and engine_rpm > cfg.idle_rpm * 1.8:
				should_upshift = true
			# Redline fallback: cambia sempre quando il motore e' vicino alla zona rossa (>88%)
			elif engine_rpm >= cfg.redline_rpm * 0.88 and current_speed_kmh >= base_shift_spd * 0.75:
				should_upshift = true
				
			if should_upshift:
				current_gear += 1
				gear_name = cfg.gear_names[current_gear - 1]
				shift_timer = 0.20 # Snappy mechanical gear shift
				shift_cooldown = 0.90 # Substantial cooldown prevents hunting
				return
				
		# --- DOWNSHIFT (with strong hysteresis band) ---
		if current_gear > 1:
			var prev_gear_shift_spd = shift_speeds[current_gear - 2]
			
			# Lugging: engine drops dangerously low
			var is_lugging = (engine_rpm < cfg.idle_rpm * 1.25 and current_speed_kmh > 0.8)
			
			# Speed drop: only downshift if speed has dropped significantly below upshift point
			var is_speed_drop = (current_speed_kmh < prev_gear_shift_spd * 0.74)
			
			# Kickdown: Driver presses throttle (>0.90) and speed is low enough to safely rev down
			var is_kickdown = (throttle > 0.90 and current_speed_kmh < prev_gear_shift_spd * 0.78 and current_speed_kmh > 8.0)
			
			if is_lugging or is_speed_drop or is_kickdown:
				current_gear -= 1
				gear_name = cfg.gear_names[current_gear - 1]
				shift_timer = 0.16
				shift_cooldown = 0.45 if current_speed_kmh < 35.0 else 0.80
				return

func update_headlights():
	if headlight_l and headlight_r:
		headlight_l.visible = headlights_on
		headlight_r.visible = headlights_on

func set_hazard_mesh_visible(visible_state: bool):
	for h in [hazard_fl, hazard_fr, hazard_rl, hazard_rr]:
		if h: h.visible = visible_state

func recover_vehicle_to_track():
	var cur_pos = global_position if is_inside_tree() else position
	var query_z = cur_pos.z
	var r_info = {}
	if road_generator and road_generator.has_method("get_road_info_at"):
		r_info = road_generator.get_road_info_at(query_z)
		
	var target_x = float(r_info.get("x", 0.0))
	var target_y = float(r_info.get("y", 0.0)) + 0.68
	var target_angle = float(r_info.get("angle", 0.0))
	
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	if is_inside_tree():
		global_position = Vector3(target_x, target_y, query_z)
		global_rotation = Vector3(0.0, target_angle, 0.0)
	else:
		position = Vector3(target_x, target_y, query_z)
		rotation = Vector3(0.0, target_angle, 0.0)
	print("[Soccorso Stradale ACI] Veicolo recuperato e riposizionato al centro carreggiata (Z = %.1fm)" % query_z)

func play_horn_honk():
	if audio_engine and audio_engine.has_method("play_horn"):
		audio_engine.play_horn()
	elif get_node_or_null("VehicleAudio"):
		var va = get_node("VehicleAudio")
		if va.has_method("play_horn"):
			va.play_horn()
	print("[Clacson Vintage '93] 📯 BEEP-BEEP! Segnalazione sorpasso al traffico civile!")

func _integrate_forces(state: PhysicsDirectBodyState3D):
	var contact_num = state.get_contact_count()
	if contact_num == 0:
		return
		
	var v = state.linear_velocity
	var v_len = v.length()
	if v_len < 0.6:
		return
		
	for i in range(contact_num):
		var c_norm = -state.get_contact_local_normal(i)
		# Se l'ostacolo è prevalentemente verticale (guardrail, muro, veicolo, roccia, palo)
		if abs(c_norm.y) < 0.65:
			var v_dot_n = v.dot(c_norm)
			if v_dot_n < -0.85: # Movimento incidente verso l'ostacolo
				var c_pos = state.get_contact_collider_position(i)
				var impact_spd = abs(v_dot_n)
				var impact_spd_kmh = impact_spd * 3.6
				
				# Coefficiente di restituzione anelastico (la lamiera dissipa ~88% dell'energia normale)
				var e = 0.12
				var v_norm_component = c_norm * v_dot_n
				var v_tangent_component = v - v_norm_component
				
				# Smorzamento inelastico: annulla il rimbalzo da pallina di gomma
				# e preserva la velocità tangenziale permettendo all'auto di scivolare fluida lungo il guardrail
				var new_v_norm = c_norm * (-v_dot_n * e)
				var new_v_tangent = v_tangent_component * 0.95
				state.linear_velocity = new_v_norm + new_v_tangent
				
				# Impulso angolare di imbardata realistico (fishtail / deviazione controllata da braccio di leva)
				var r_arm = c_pos - global_position
				var torque_yaw = (r_arm.cross(-v_norm_component * mass)).y * 0.0016
				state.angular_velocity.y += clamp(torque_yaw, -3.2, 3.2)
				
				if impact_cooldown <= 0.0 and impact_spd_kmh > 7.0:
					impact_cooldown = 0.35
					on_hard_impact_detected(impact_spd * 25.0, c_pos, c_norm)
				break

func on_hard_impact_detected(decel_val: float, custom_pt: Vector3 = Vector3.ZERO, custom_norm: Vector3 = Vector3.ZERO):
	var impact_kmh = max(current_speed_kmh, decel_val * 0.45)
	var contact_pt = custom_pt if custom_pt != Vector3.ZERO else (global_position + (-global_transform.basis.z * 1.55))
	var impact_norm = custom_norm if custom_norm != Vector3.ZERO else global_transform.basis.z
	
	# Scuotimento angolare e smorzamento inelastico dell'energia d'urto
	var yaw_shock = -sign(steering if abs(steering) > 0.05 else randf_range(-1.0, 1.0)) * clamp(impact_kmh * 0.035, 0.4, 3.2)
	angular_velocity.y += yaw_shock
	linear_velocity *= 0.42
	
	# Deformazione plastica reale della carrozzeria e parti 3D con soft-body vertex crumple
	VehicleCrashSystem.apply_structural_deformation(self, contact_pt, impact_kmh, impact_norm)
	
	if audio_engine and audio_engine.has_method("play_impact_thud"):
		audio_engine.play_impact_thud()
		
	var cam = get_parent().get_node_or_null("CameraController") if get_parent() else null
	if not cam and get_tree() and get_tree().root:
		cam = get_tree().root.find_child("CameraController", true, false)
	if cam and cam.has_method("add_trauma"):
		cam.add_trauma(clamp(impact_kmh / 75.0, 0.22, 0.85))
		
	var main_node = get_parent()
	var sr_mgr = null
	if main_node and main_node.has_node("StreetRodManager"):
		sr_mgr = main_node.get_node("StreetRodManager")
	elif main_node and main_node.get("street_rod_manager"):
		sr_mgr = main_node.get("street_rod_manager")
		
	if sr_mgr and sr_mgr.has_method("get_active_car"):
		var cur_car = sr_mgr.get_active_car()
		if not cur_car.is_empty():
			var dmg_body = clamp(decel_val * 0.0028, 0.06, 0.30)
			var dmg_eng = clamp(decel_val * 0.0014, 0.03, 0.18)
			cur_car["body_health"] = max(0.12, cur_car.get("body_health", 0.85) - dmg_body)
			cur_car["engine_health"] = max(0.18, cur_car.get("engine_health", 0.90) - dmg_eng)
			sr_mgr.post_notification(
				"💥 URTO STRADALE!",
				"Impatto contro ostacolo!\nCarrozzeria: -%d%% | Motore: -%d%%" % [int(dmg_body * 100), int(dmg_eng * 100)],
				"💥",
				"error"
			)
			sr_mgr.broadcast_career()
			sr_mgr.save_career()

func repair_chassis_deformation():
	# Ripristina la geometria del veicolo alle quote di fabbrica integre
	apply_vehicle_model(current_model_id)
	print("[Officina Paolo] 🔧 Carrozzeria e scocca ribattute e riallineate a quota di fabbrica!")

