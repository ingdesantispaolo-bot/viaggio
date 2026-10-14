extends Node3D

# THE LONG MERIDIAN - Master Scene Coordinator (Godot 4)
# Coordinates vehicle physics, procedural road generation, hazard scenarios,
# diorama camera tracking, sunlight orientation, and dashboard telemetry.

const VehicleController = preload("res://scripts/VehicleController.gd")
const RoadGenerator = preload("res://scripts/RoadGenerator.gd")
const HazardManager = preload("res://scripts/HazardManager.gd")
const CameraController = preload("res://scripts/CameraController.gd")
const DashboardUI = preload("res://scripts/DashboardUI.gd")
const BiomeDirector = preload("res://scripts/BiomeDirector.gd")
const JourneyDirector = preload("res://scripts/JourneyDirector.gd")
const BiomeGraph = preload("res://scripts/BiomeGraph.gd")
const StreetRodManager = preload("res://scripts/StreetRodManager.gd")
const StreetRodUI = preload("res://scripts/StreetRodUI.gd")
const RaceDirector = preload("res://scripts/RaceDirector.gd")
const CivilianTrafficManager = preload("res://scripts/CivilianTrafficManager.gd")
const GarageEnvironmentBuilder = preload("res://scripts/GarageEnvironmentBuilder.gd")

@onready var vehicle: VehicleController = $Vehicle
@onready var road_gen: RoadGenerator = $RoadGenerator
@onready var hazard_mgr: HazardManager = $HazardManager
@onready var camera: CameraController = $CameraController
@onready var dashboard_ui: DashboardUI = ($UILayer/DashboardUI if has_node("UILayer/DashboardUI") else $DashboardUI) as DashboardUI
@onready var sun_light: DirectionalLight3D = $SunLight
@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var biome_dir: BiomeDirector = $BiomeDirector
@onready var journey_director: JourneyDirector = $JourneyDirector

var street_rod_manager: StreetRodManager = null
var street_rod_ui: StreetRodUI = null
var race_director: RaceDirector = null
var traffic_manager: CivilianTrafficManager = null

var is_in_garage: bool = true
var garage_building: Node3D = null
const GARAGE_CAR_POS: Vector3 = Vector3(15.5, 0.45, 14.0)
const GARAGE_CAM_POS: Vector3 = Vector3(12.0, 1.65, 17.5)
const GARAGE_CAM_LOOK: Vector3 = Vector3(15.2, 0.75, 14.0)

func _ready():
    # 0. Build 3D Garage & Officina Paolo (1993)
    garage_building = GarageEnvironmentBuilder.build_paolo_garage(self, Vector3(15.5, 0.0, 14.0))

    # 1. Initialize Street Rod 1993 Career & UI
    street_rod_manager = StreetRodManager.new()
    street_rod_manager.name = "StreetRodManager"
    add_child(street_rod_manager)
    
    street_rod_ui = StreetRodUI.new()
    street_rod_ui.name = "StreetRodUI"
    street_rod_ui.street_rod_manager = street_rod_manager
    street_rod_ui.vehicle = vehicle
    var ui_layer = get_node_or_null("UILayer")
    if ui_layer:
        ui_layer.add_child(street_rod_ui)
    else:
        add_child(street_rod_ui)
    street_rod_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        
    # Wire garage exit and inspection view from StreetRodUI
    street_rod_ui.request_close.connect(func(): exit_garage_to_road())
    street_rod_ui.garage_inspection_view_requested.connect(func(v_type): set_garage_camera_view(v_type))
        
    # 2. Initialize 3D RaceDirector (Starting Grid, Arches, Semaforo, AI Rival)
    race_director = RaceDirector.new()
    race_director.name = "RaceDirector"
    race_director.road_generator = road_gen
    race_director.player_vehicle = vehicle
    race_director.street_rod_manager = street_rod_manager
    race_director.camera_controller = camera
    race_director.street_rod_ui = street_rod_ui
    add_child(race_director)
    
    # 3. Initialize Living World Civilian Traffic (Ape Piaggio, Fiat 500, Oncoming downhill cars)
    traffic_manager = CivilianTrafficManager.new()
    traffic_manager.name = "CivilianTrafficManager"
    traffic_manager.road_generator = road_gen
    traffic_manager.player_vehicle = vehicle
    traffic_manager.street_rod_manager = street_rod_manager
    traffic_manager.dashboard_ui = dashboard_ui
    add_child(traffic_manager)
    
    # Wire race start requested from StreetRodUI to RaceDirector
    street_rod_ui.race_start_requested.connect(func(r_id, pink_slip):
        if race_director:
            var src_tab = street_rod_ui.current_tab if street_rod_ui else 3
            race_director.start_drag_race(r_id, pink_slip, src_tab)
    )
        
    # Wire Street Rod Car Switches and Upgrades to VehicleController & 3D Engine Bay
    street_rod_ui.car_model_changed.connect(func(model_id):
        if vehicle:
            vehicle.apply_vehicle_model(model_id)
            if is_in_garage and street_rod_manager:
                var c_data = street_rod_manager.get_active_car()
                GarageEnvironmentBuilder.build_interactive_engine_bay(vehicle, model_id, c_data.get("tuning_parts", []))
    )
    street_rod_ui.upgrades_applied.connect(func(car_data):
        if vehicle:
            vehicle.apply_street_rod_upgrades(car_data)
            if is_in_garage:
                GarageEnvironmentBuilder.build_interactive_engine_bay(vehicle, vehicle.current_model_id, car_data.get("tuning_parts", []))
    )
    
    # Wire Street Rod HUD Updates
    street_rod_manager.career_updated.connect(func(c_info):
        if dashboard_ui and dashboard_ui.has_method("update_street_rod_hud"):
            dashboard_ui.update_street_rod_hud(c_info.get("cash_formatted", "3.500.000"), c_info.get("reputation", 40))
        if dashboard_ui and dashboard_ui.has_method("update_street_rod_mission") and c_info.has("active_contract"):
            dashboard_ui.update_street_rod_mission(c_info["active_contract"])
    )
    street_rod_manager.contract_selected.connect(func(c_info):
        if dashboard_ui and dashboard_ui.has_method("update_street_rod_mission"):
            dashboard_ui.update_street_rod_mission(c_info)
    )
    street_rod_manager.contract_completed.connect(func(_c_info):
        if dashboard_ui and dashboard_ui.has_method("update_street_rod_mission"):
            dashboard_ui.update_street_rod_mission({})
    )
    if dashboard_ui:
        dashboard_ui.open_street_rod_requested.connect(func():
            enter_garage()
        )
        if dashboard_ui.has_method("update_street_rod_mission"):
            dashboard_ui.update_street_rod_mission(street_rod_manager.get_active_contract())


    # Connect vehicle live telemetry to dashboard UI
    if vehicle:
        if road_gen:
            vehicle.road_generator = road_gen
        if hazard_mgr:
            vehicle.hazard_manager = hazard_mgr
        if dashboard_ui:
            vehicle.telemetry_updated.connect(dashboard_ui.update_telemetry)
            dashboard_ui.change_vehicle_requested.connect(vehicle.switch_vehicle)
            
        # Apply initial active car from Street Rod garage
        var init_car = street_rod_manager.get_active_car()
        if not init_car.is_empty():
            vehicle.apply_vehicle_model(init_car.get("car_id", "fiat_127"))
            vehicle.apply_street_rod_upgrades(init_car)
        
    # Connect biome director to world environment and dashboard
    if biome_dir:
        biome_dir.world_environment = world_env
        biome_dir.sun_light = sun_light
        if road_gen:
            biome_dir.road_generator = road_gen
        if dashboard_ui:
            biome_dir.biome_changed.connect(dashboard_ui.update_region)
        
    # Assign references to camera and hazards
    if camera and vehicle:
        camera.target_node = vehicle
        camera.road_generator = road_gen
        camera.setup_initial_position()
        if dashboard_ui:
            dashboard_ui.change_camera_requested.connect(camera.cycle_camera_mode)
            camera.camera_mode_changed.connect(dashboard_ui.update_camera_mode)
            var p = camera.PRESETS[camera.current_mode]
            dashboard_ui.update_camera_mode(p.name, p.height, p.distance)
        
    if hazard_mgr and road_gen:
        hazard_mgr.road_generator = road_gen
        hazard_mgr.enabled = false

    # Connect JourneyDirector to DashboardUI, Audio & Vehicle Services
    if journey_director:
        if road_gen:
            journey_director.road_generator = road_gen
        if dashboard_ui:
            journey_director.journey_updated.connect(dashboard_ui.update_journey)
            journey_director.milestone_reached.connect(dashboard_ui.on_milestone_reached)
            journey_director.stage_cleared.connect(dashboard_ui.on_stage_cleared)
            journey_director.expedition_completed.connect(dashboard_ui.on_expedition_completed)
        if vehicle:
            if vehicle.has_signal("service_completed"):
                vehicle.service_completed.connect(func(_l, _s): journey_director.register_service_bonus())
            if vehicle.audio_engine:
                journey_director.milestone_reached.connect(func(_m): vehicle.audio_engine.play_milestone_chime())
                journey_director.stage_cleared.connect(func(_s): vehicle.audio_engine.play_milestone_chime())

    # Accoglienza del Giocatore (All'avvio auto nel Garage Paolo, non in mezzo alla strada!)
    enter_garage(true)

var garage_cam_tween: Tween = null

func enter_garage(_is_startup: bool = false):
    is_in_garage = true
    if vehicle:
        vehicle.global_position = GARAGE_CAR_POS
        vehicle.rotation.y = deg_to_rad(-90.0) # Affacciata verso il portone e la strada
        vehicle.linear_velocity = Vector3.ZERO
        vehicle.angular_velocity = Vector3.ZERO
        vehicle.freeze = true
        vehicle.set_engine_running(false) # MOTORE SPENTO NEL GARAGE: SILENZIO ASSOLUTO!
    if camera:
        camera.set_process(false)
        camera.set_physics_process(false)
        camera.global_position = GARAGE_CAM_POS
        camera.look_at(GARAGE_CAM_LOOK, Vector3.UP)
        camera.fov = 44.0
    if dashboard_ui:
        dashboard_ui.visible = false
    if street_rod_ui:
        street_rod_ui.open_screen(0)
    # Costruisci vano motore 3D interattivo visibile sotto il cofano in officina
    if vehicle and street_rod_manager:
        var c_data = street_rod_manager.get_active_car()
        GarageEnvironmentBuilder.build_interactive_engine_bay(vehicle, vehicle.current_model_id, c_data.get("tuning_parts", []))
    print("[Garage Paolo] 🏠 Vettura nel Garage & Officina Paolo (Motore SPENTO, silenzio meccanico)!")

func set_garage_camera_view(view_type: String):
    if not is_in_garage or not camera: return
    var target_pos = GARAGE_CAM_POS
    var target_look = GARAGE_CAM_LOOK
    var target_fov = 44.0
    match view_type:
        "engine":
            # Inquadratura frontale ravvicinata sul vano motore aperto e carburatori Weber
            target_pos = Vector3(12.8, 1.35, 14.0)
            target_look = Vector3(14.4, 0.72, 14.0)
            target_fov = 36.0
        "wheels":
            # Inquadratura ribassata sulle ruote anteriori e ponte sollevatore
            target_pos = Vector3(13.2, 0.65, 15.8)
            target_look = Vector3(14.4, 0.35, 14.6)
            target_fov = 36.0
        "body":
            # Vista tre quarti carrozzeria e forno di verniciatura
            target_pos = Vector3(11.8, 1.45, 17.5)
            target_look = Vector3(15.5, 0.65, 14.0)
            target_fov = 42.0
        "cockpit":
            # Vista dall'interno abitacolo attraverso il finestrino
            target_pos = Vector3(14.8, 1.25, 15.6)
            target_look = Vector3(15.2, 0.85, 14.0)
            target_fov = 38.0
        _:
            # Panoramica generale dell'officina
            target_pos = GARAGE_CAM_POS
            target_look = GARAGE_CAM_LOOK
            target_fov = 44.0

    if garage_cam_tween and garage_cam_tween.is_valid():
        garage_cam_tween.kill()
    garage_cam_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    garage_cam_tween.tween_property(camera, "global_position", target_pos, 0.60)
    garage_cam_tween.tween_property(camera, "fov", target_fov, 0.60)
    var look_dummy = Node3D.new()
    add_child(look_dummy)
    look_dummy.global_position = target_pos
    look_dummy.look_at(target_look, Vector3.UP)
    var target_quat = look_dummy.quaternion
    look_dummy.queue_free()
    garage_cam_tween.tween_property(camera, "quaternion", target_quat, 0.60)

func exit_garage_to_road():
    if not is_in_garage: return
    is_in_garage = false
    if garage_cam_tween and garage_cam_tween.is_valid():
        garage_cam_tween.kill()
    # Rimuovi vano motore per massima fluidità fisica durante la guida
    if vehicle:
        var e_bay = vehicle.get_node_or_null("EngineBayRig")
        if e_bay: e_bay.queue_free()
        vehicle.freeze = false
        var r = road_gen.get_road_info_at(20.0) if road_gen else { "x": 0.0, "y": 0.0, "angle": 0.0, "width": 7.8 }
        # In Italia si tiene la destra: con rotazione PI (+Z), la corsia di destra è -X
        var lane_x = r.get("x", 0.0) - (r.get("width", 7.8) * 0.25)
        vehicle.global_position = Vector3(lane_x, r.get("y", 0.0) + 0.45, 20.0)
        vehicle.rotation.y = r.get("angle", 0.0) + PI
        vehicle.linear_velocity = Vector3.ZERO
        vehicle.angular_velocity = Vector3.ZERO
        # Avvia motore con colpo di motorino d'avviamento realistico
        if vehicle.audio_engine:
            vehicle.audio_engine.play_starter_crank(func():
                vehicle.is_engine_running = true
            )
        else:
            vehicle.set_engine_running(true)
    if camera:
        camera.set_process(true)
        camera.set_physics_process(true)
        camera.setup_initial_position()
    if dashboard_ui:
        dashboard_ui.visible = true
    if street_rod_ui:
        street_rod_ui.hide_onboarding_guide()
        street_rod_ui.close_screen()
    if street_rod_manager:
        street_rod_manager.post_notification(
            "PARTENZA DALL'OFFICINA! 🏁",
            "Auto immessa sulla statale alpina. Buon viaggio!",
            "🏎️",
            "wrench"
        )
    print("[Garage Paolo] 🏁 Vettura uscita dal garage ed immessa sulla carreggiata stradale!")

func _process(_delta: float):
    if not vehicle: return
    
    var player_z = vehicle.global_position.z
    
    # 1. Update procedural road streaming
    if road_gen:
        road_gen.update_generation(player_z)
        
    # 2. Update highway events & hazard scenarios
    if hazard_mgr:
        hazard_mgr.update_hazards(player_z)
        
    # 3. Dynamic atmospheric biome & volumetric fog
    if biome_dir:
        biome_dir.update_biome(player_z, _delta)
        
    # 4. Aerodynamic vehicle wake & position for foliage wind shader
    RenderingServer.global_shader_parameter_set("player_car_pos", vehicle.global_position)
    RenderingServer.global_shader_parameter_set("player_car_speed", vehicle.current_speed_kmh)
        
    # 5. Directional sun follows vehicle along highway
    if sun_light:
        sun_light.global_position = Vector3(vehicle.global_position.x + 22.0, 45.0, player_z + 15.0)

    # 6. Update trans-meridian expedition journey progression
    if journey_director:
        journey_director.update_progress(player_z, _delta, vehicle.current_speed_kmh)

    # 7. Check Street Rod travel contracts & barn finds progress
    if street_rod_manager:
        street_rod_manager.check_journey_progress(player_z)

func _unhandled_input(event: InputEvent):
    if event.is_action_pressed("toggle_fullscreen"):
        if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        else:
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_M or event.keycode == KEY_TAB:
            if dashboard_ui and dashboard_ui.has_method("toggle_logbook"):
                dashboard_ui.toggle_logbook()
        elif event.keycode == KEY_E:
            if dashboard_ui:
                if dashboard_ui.has_method("is_bar_modal_open") and dashboard_ui.is_bar_modal_open():
                    dashboard_ui.close_bar_service_modal()
                elif vehicle and (vehicle.get("is_in_service_bay") or vehicle.get("is_in_service_zone")):
                    var s_name = vehicle.get("service_station_name")
                    var s_type = vehicle.get("service_station_type")
                    if not s_type or str(s_type) == "":
                        s_type = "autogrill_bar"
                    dashboard_ui.open_bar_service_modal(str(s_type), { "name": s_name })
        elif event.keycode == KEY_ESCAPE:
            if dashboard_ui and dashboard_ui.has_method("is_bar_modal_open") and dashboard_ui.is_bar_modal_open():
                dashboard_ui.close_bar_service_modal()
        elif event.keycode == KEY_B:
            toggle_diorama_tilt_shift()
        elif event.keycode == KEY_F1 or event.keycode == KEY_G:
            if is_in_garage:
                exit_garage_to_road()
            else:
                enter_garage()
        elif event.keycode == KEY_F2:
            if street_rod_ui: street_rod_ui.open_screen(1)
        elif event.keycode == KEY_F3:
            if street_rod_ui: street_rod_ui.open_screen(2)
        elif event.keycode == KEY_F4:
            if street_rod_ui: street_rod_ui.open_screen(3)
        elif event.keycode == KEY_F5:
            if street_rod_ui: street_rod_ui.open_screen(4)
        elif event.keycode == KEY_F6:
            if street_rod_ui: street_rod_ui.open_screen(5)
        elif event.keycode == KEY_R:
            if vehicle and vehicle.audio_engine:
                var st_name = vehicle.audio_engine.cycle_radio_station()
                if street_rod_manager:
                    street_rod_manager.post_notification("AUTORADIO D'EPOCA '93", st_name, "📻", "wrench")
        elif event.keycode == KEY_O:
            var d_ui = get_node_or_null("DashboardUI")
            if d_ui and d_ui.has_method("toggle_audio_mixer_modal"):
                d_ui.toggle_audio_mixer_modal()

func toggle_diorama_tilt_shift():
    var tilt_rect = get_node_or_null("PostProcessLayer/TiltShiftRect")
    if tilt_rect and tilt_rect.material is ShaderMaterial:
        var sm = tilt_rect.material as ShaderMaterial
        var cur_enabled = sm.get_shader_parameter("enable_tilt_shift")
        if cur_enabled == null:
            cur_enabled = true
        var next_enabled = !cur_enabled
        sm.set_shader_parameter("enable_tilt_shift", next_enabled)
        print("[PostProcess] Sfocatura Diorama Tilt-Shift: %s" % ("ATTIVA (Ultra-Leggera)" if next_enabled else "DISATTIVATA (100% Nitido)"))

