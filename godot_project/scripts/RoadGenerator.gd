extends Node3D
class_name RoadGenerator

const BiomeGraph = preload("res://scripts/BiomeGraph.gd")
const RuralPlainEnvironmentBuilder = preload("res://scripts/RuralPlainEnvironmentBuilder.gd")
const CoastalEnvironmentBuilder = preload("res://scripts/CoastalEnvironmentBuilder.gd")

# THE LONG MERIDIAN - Procedural Crowned Highway & Alpine Landscape Generator (Godot 4)
# Inspired by Dorfromantik, Tiny Glade & Art of Rally.
# Features:
# 1. Continuous crowned asphalt highway with realistic lane markings & physical wheel raycasts
# 2. Wide multi-zone organic rolling terrain (verges, swales, pastures, and foothills up to 180m)
# 3. Majestic procedural mountain backdrop (Alpine massifs with snow caps & sheer canyon gorge walls)
# 4. Handcrafted Alpine chalets (Baite) with timber logs, slate roofs, and warm glowing windows
# 5. Tiny Glade drystone walls (muretti a secco) and European alpine altitude signposts
# 6. Multi-tiered stylized miniature trees (3-tier conifers, golden larches, and broadleaf trees)
# 7. Low-poly diorama cumulus clouds drifting high across the skyline

@export var road_material: Material
@export var chunk_length: float = 120.0
@export var road_segments: int = 24
@export var base_width: float = 7.8
@export var expedition_seed: int = 1991

var biome_graph: BiomeGraph
var elevation_noise: FastNoiseLite
var curve_noise: FastNoiseLite
var width_noise: FastNoiseLite
var flora_noise: FastNoiseLite

var active_chunks: Array = []
var active_potholes: Array = []
var active_road_patches: Array = []
var next_chunk_z: float = -120.0
var last_chunk_x: float = 0.0
var last_chunk_angle: float = 0.0
var last_chunk_bank: float = 0.0
var active_service_stations: Array = []

# Material Palette
var terrain_material: ShaderMaterial
var mountain_material: ShaderMaterial
var canyon_material: ShaderMaterial
var cloud_material: ShaderMaterial
var storm_cloud_material: ShaderMaterial
var pine_material: ShaderMaterial
var larch_material: ShaderMaterial
var bush_material: ShaderMaterial
var crop_material: ShaderMaterial

var chalet_timber_material: StandardMaterial3D
var chalet_roof_material: StandardMaterial3D
var chalet_window_material: StandardMaterial3D
var drystone_material: StandardMaterial3D
var rock_material: StandardMaterial3D
var guardrail_material: StandardMaterial3D
var post_material: StandardMaterial3D
var sign_wood_material: StandardMaterial3D
var sign_plate_material: StandardMaterial3D

var water_material: ShaderMaterial
var village_wall_material: Material
var village_roof_material: Material
var village_terracotta_material: Material
var wildflower_gold_material: StandardMaterial3D
var wildflower_violet_material: StandardMaterial3D
var wildflower_white_material: StandardMaterial3D
var service_canopy_material: StandardMaterial3D
var service_pump_material: StandardMaterial3D
var service_shop_material: StandardMaterial3D
var bridge_stone_material: StandardMaterial3D
var cobblestone_material: StandardMaterial3D
var lantern_glow_material: StandardMaterial3D
var pier_wood_material: StandardMaterial3D
var boat_hull_material: StandardMaterial3D
var windmill_sail_material: StandardMaterial3D
var cow_white_material: StandardMaterial3D
var cow_brown_material: StandardMaterial3D
var cow_bell_material: StandardMaterial3D
var sheep_wool_material: StandardMaterial3D
var sheep_face_material: StandardMaterial3D
var straw_bale_material: StandardMaterial3D
var cart_wood_material: StandardMaterial3D
var fountain_stone_material: StandardMaterial3D
var moss_log_material: StandardMaterial3D
var moss_green_material: StandardMaterial3D

# Nuovi Materiali Iconici Stradali e Paesaggistici Italiani
var danger_sign_red_material: StandardMaterial3D
var danger_sign_white_material: StandardMaterial3D
var danger_sign_black_material: StandardMaterial3D
var mirror_chrome_material: StandardMaterial3D
var olive_leaf_material: StandardMaterial3D
var olive_bark_material: StandardMaterial3D
var maritime_pine_bark_material: StandardMaterial3D
var guardrail_reflector_red: StandardMaterial3D
var guardrail_reflector_white: StandardMaterial3D

# Materiali Stradali Differenziati
var road_asphalt_alpine_mat: ShaderMaterial
var road_asphalt_curves_mat: ShaderMaterial
var road_pave_porfido_mat: ShaderMaterial
var road_wet_gorge_mat: ShaderMaterial
var road_strada_bianca_mat: ShaderMaterial

# Nuovi Arredi Stradali Autentici Italiani
var anas_stone_material: StandardMaterial3D
var anas_cap_red_material: StandardMaterial3D
var apex_curb_red_material: StandardMaterial3D
var apex_curb_white_material: StandardMaterial3D
var rumble_strip_material: StandardMaterial3D
var bridge_joint_steel_material: StandardMaterial3D

# Dettagli Ispirati a Tiny Glade, Dorfromantik & Art of Rally
var barrel_wood_material: StandardMaterial3D
var iron_dark_material: StandardMaterial3D
var laundry_white_material: StandardMaterial3D
var laundry_red_material: StandardMaterial3D
var laundry_blue_material: StandardMaterial3D
var bicycle_frame_material: StandardMaterial3D
var telegraph_wood_material: StandardMaterial3D
var telegraph_cable_material: StandardMaterial3D
var ceramic_insulator_material: StandardMaterial3D
var spectator_jacket_yellow: StandardMaterial3D
var spectator_jacket_red: StandardMaterial3D
var spectator_jacket_blue: StandardMaterial3D
var spectator_jacket_green: StandardMaterial3D
var spectator_jeans_material: StandardMaterial3D
var spectator_skin_material: StandardMaterial3D
var spectator_camera_material: StandardMaterial3D
var rally_banner_martini: StandardMaterial3D
var rally_banner_agip: StandardMaterial3D
var rally_banner_pirelli: StandardMaterial3D
var chimney_smoke_material: StandardMaterial3D
var ivy_leaf_material: StandardMaterial3D

var last_telegraph_pole_pos: Vector3 = Vector3.ZERO

func _init():
    init_procedural_generation()

func _ready():
    # 1a. Road Asphalt Material (Alpine Pass / Straight)
    var asphalt_shader = load("res://shaders/stylized_asphalt.gdshader")
    var a_mat = ShaderMaterial.new()
    a_mat.shader = asphalt_shader
    a_mat.set_shader_parameter("asphalt_color", Color(0.21, 0.22, 0.24))
    a_mat.set_shader_parameter("worn_asphalt_color", Color(0.27, 0.28, 0.29))
    a_mat.set_shader_parameter("gravel_shoulder_color", Color(0.38, 0.35, 0.30))
    a_mat.set_shader_parameter("grass_blend_color", Color(0.20, 0.32, 0.15))
    a_mat.set_shader_parameter("is_double_line", false)
    a_mat.set_shader_parameter("is_wet_gorge", false)
    road_asphalt_alpine_mat = a_mat
    road_material = a_mat

    # 1b. Asfalto Curve & Passi (Doppia Striscia Continua + Occhi di Gatto)
    var c_mat = ShaderMaterial.new()
    c_mat.shader = asphalt_shader
    c_mat.set_shader_parameter("asphalt_color", Color(0.20, 0.21, 0.23))
    c_mat.set_shader_parameter("worn_asphalt_color", Color(0.26, 0.27, 0.28))
    c_mat.set_shader_parameter("gravel_shoulder_color", Color(0.36, 0.34, 0.30))
    c_mat.set_shader_parameter("grass_blend_color", Color(0.20, 0.32, 0.15))
    c_mat.set_shader_parameter("is_double_line", true)
    c_mat.set_shader_parameter("is_wet_gorge", false)
    road_asphalt_curves_mat = c_mat

    # 1c. Pavé di Porfido Trentino / Sanpietrini (Borgo Storico San Cristoforo)
    var pave_shader = load("res://shaders/stylized_pave.gdshader")
    var p_mat = ShaderMaterial.new()
    p_mat.shader = pave_shader
    p_mat.set_shader_parameter("porphyry_red", Color(0.44, 0.33, 0.30))
    p_mat.set_shader_parameter("porphyry_grey", Color(0.33, 0.34, 0.36))
    p_mat.set_shader_parameter("porphyry_ochre", Color(0.50, 0.44, 0.36))
    p_mat.set_shader_parameter("mortar_color", Color(0.25, 0.24, 0.22))
    p_mat.set_shader_parameter("granite_curb_color", Color(0.68, 0.69, 0.72))
    p_mat.set_shader_parameter("block_scale", 14.0)
    road_pave_porfido_mat = p_mat

    # 1d. Asfalto Bagnato Scuro (Forra dell'Appennino & Ponte dei Ciclopi)
    var wg_mat = ShaderMaterial.new()
    wg_mat.shader = asphalt_shader
    wg_mat.set_shader_parameter("asphalt_color", Color(0.12, 0.13, 0.14))
    wg_mat.set_shader_parameter("worn_asphalt_color", Color(0.18, 0.19, 0.20))
    wg_mat.set_shader_parameter("gravel_shoulder_color", Color(0.28, 0.26, 0.24))
    wg_mat.set_shader_parameter("grass_blend_color", Color(0.16, 0.24, 0.14))
    wg_mat.set_shader_parameter("is_double_line", true)
    wg_mat.set_shader_parameter("is_wet_gorge", true)
    road_wet_gorge_mat = wg_mat

    # 1e. Strada Bianca Toscana / Sterrato (Colline & Altopiano)
    var gravel_shader = load("res://shaders/stylized_gravel.gdshader")
    var sb_mat = ShaderMaterial.new()
    sb_mat.shader = gravel_shader
    sb_mat.set_shader_parameter("gravel_light", Color(0.82, 0.78, 0.70))
    sb_mat.set_shader_parameter("gravel_dark", Color(0.60, 0.54, 0.46))
    sb_mat.set_shader_parameter("rut_compact_color", Color(0.52, 0.46, 0.38))
    sb_mat.set_shader_parameter("grass_border_color", Color(0.24, 0.36, 0.16))
    road_strada_bianca_mat = sb_mat
        
    # 2. Stylized Organic Landscape Terrain
    var terrain_shader = load("res://shaders/stylized_terrain.gdshader")
    terrain_material = ShaderMaterial.new()
    terrain_material.shader = terrain_shader
    terrain_material.set_shader_parameter("grass_color", Color(0.20, 0.32, 0.15))
    terrain_material.set_shader_parameter("grass_dry_color", Color(0.34, 0.36, 0.18))
    terrain_material.set_shader_parameter("wildflower_gold", Color(0.88, 0.74, 0.28))
    terrain_material.set_shader_parameter("wildflower_blue", Color(0.28, 0.44, 0.82))
    terrain_material.set_shader_parameter("rock_slope_color", Color(0.46, 0.45, 0.42))
    terrain_material.set_shader_parameter("dirt_path_color", Color(0.36, 0.28, 0.20))

    # 3. Alpine Mountain & Gorge Rock Shader
    var mountain_shader = load("res://shaders/stylized_mountain.gdshader")
    mountain_material = ShaderMaterial.new()
    mountain_material.shader = mountain_shader
    mountain_material.set_shader_parameter("rock_color", Color(0.52, 0.53, 0.56))
    mountain_material.set_shader_parameter("cliff_color", Color(0.36, 0.38, 0.42))
    mountain_material.set_shader_parameter("foothill_grass_color", Color(0.20, 0.32, 0.15))
    mountain_material.set_shader_parameter("snow_color", Color(0.97, 0.98, 1.0))
    mountain_material.set_shader_parameter("snow_height_threshold", 34.0)
    mountain_material.set_shader_parameter("snow_blend_softness", 9.0)

    # 3b. Sheer Canyon Rock Shader (Dolomite & Slate without snow caps)
    canyon_material = ShaderMaterial.new()
    canyon_material.shader = mountain_shader
    canyon_material.set_shader_parameter("rock_color", Color(0.52, 0.44, 0.38))
    canyon_material.set_shader_parameter("cliff_color", Color(0.36, 0.30, 0.26))
    canyon_material.set_shader_parameter("foothill_grass_color", Color(0.20, 0.32, 0.15))
    canyon_material.set_shader_parameter("snow_color", Color(0.52, 0.44, 0.38))
    canyon_material.set_shader_parameter("snow_height_threshold", 999.0)
    canyon_material.set_shader_parameter("snow_blend_softness", 1.0)

    # 4. Diorama Cumulus Cloud Shader
    var cloud_shader = load("res://shaders/stylized_cloud.gdshader")
    cloud_material = ShaderMaterial.new()
    cloud_material.shader = cloud_shader
    cloud_material.set_shader_parameter("cloud_color", Color(1.0, 0.98, 0.95, 0.96))
    cloud_material.set_shader_parameter("shadow_color", Color(0.72, 0.78, 0.88, 0.96))

    # 4b. Dark Overcast Storm Cloud Shader (for Rainy Canyon & Gorge)
    storm_cloud_material = ShaderMaterial.new()
    storm_cloud_material.shader = cloud_shader
    storm_cloud_material.set_shader_parameter("cloud_color", Color(0.24, 0.27, 0.32, 0.98))
    storm_cloud_material.set_shader_parameter("shadow_color", Color(0.12, 0.14, 0.18, 0.98))

    # 5. Synchronized Foliage Shaders (Wind & Car Wake)
    var foliage_shader = load("res://shaders/stylized_foliage.gdshader")
    
    pine_material = ShaderMaterial.new()
    pine_material.shader = foliage_shader
    pine_material.set_shader_parameter("base_foliage_color", Color(0.12, 0.22, 0.12))
    pine_material.set_shader_parameter("tip_foliage_color", Color(0.28, 0.44, 0.22))
    pine_material.set_shader_parameter("sss_sun_transmission", Color(0.48, 0.68, 0.20))
    pine_material.set_shader_parameter("wind_amplitude", 0.14)
    pine_material.set_shader_parameter("wake_sensitivity", 1.1)

    larch_material = ShaderMaterial.new()
    larch_material.shader = foliage_shader
    larch_material.set_shader_parameter("base_foliage_color", Color(0.62, 0.38, 0.12)) # golden autumn
    larch_material.set_shader_parameter("tip_foliage_color", Color(0.92, 0.72, 0.20))
    larch_material.set_shader_parameter("sss_sun_transmission", Color(0.98, 0.78, 0.24))
    larch_material.set_shader_parameter("wind_amplitude", 0.18)
    larch_material.set_shader_parameter("wake_sensitivity", 1.3)

    bush_material = ShaderMaterial.new()
    bush_material.shader = foliage_shader
    bush_material.set_shader_parameter("base_foliage_color", Color(0.16, 0.28, 0.14))
    bush_material.set_shader_parameter("tip_foliage_color", Color(0.32, 0.48, 0.20))
    bush_material.set_shader_parameter("sss_sun_transmission", Color(0.50, 0.70, 0.18))
    bush_material.set_shader_parameter("wind_amplitude", 0.16)
    bush_material.set_shader_parameter("wake_sensitivity", 1.4)

    crop_material = ShaderMaterial.new()
    crop_material.shader = foliage_shader
    crop_material.set_shader_parameter("base_foliage_color", Color(0.65, 0.48, 0.18))
    crop_material.set_shader_parameter("tip_foliage_color", Color(0.92, 0.76, 0.28))
    crop_material.set_shader_parameter("sss_sun_transmission", Color(0.98, 0.82, 0.32))
    crop_material.set_shader_parameter("wind_amplitude", 0.24)
    crop_material.set_shader_parameter("wake_sensitivity", 1.8)

    # 6. Alpine Architecture & Props Materials
    chalet_timber_material = StandardMaterial3D.new()
    chalet_timber_material.albedo_color = Color(0.34, 0.23, 0.15)
    chalet_timber_material.roughness = 0.88

    chalet_roof_material = StandardMaterial3D.new()
    chalet_roof_material.albedo_color = Color(0.20, 0.18, 0.16)
    chalet_roof_material.roughness = 0.80

    chalet_window_material = StandardMaterial3D.new()
    chalet_window_material.albedo_color = Color(1.0, 0.86, 0.45)
    chalet_window_material.emission_enabled = true
    chalet_window_material.emission = Color(1.0, 0.82, 0.38)
    chalet_window_material.emission_energy_multiplier = 2.4

    drystone_material = StandardMaterial3D.new()
    drystone_material.albedo_color = Color(0.46, 0.45, 0.43)
    drystone_material.roughness = 0.90

    rock_material = StandardMaterial3D.new()
    rock_material.albedo_color = Color(0.56, 0.55, 0.53)
    rock_material.roughness = 0.92

    guardrail_material = StandardMaterial3D.new()
    guardrail_material.albedo_color = Color(0.74, 0.76, 0.78)
    guardrail_material.metallic = 0.82
    guardrail_material.roughness = 0.30

    post_material = StandardMaterial3D.new()
    post_material.albedo_color = Color(0.94, 0.94, 0.94)
    post_material.roughness = 0.45

    sign_wood_material = StandardMaterial3D.new()
    sign_wood_material.albedo_color = Color(0.42, 0.32, 0.22)
    sign_wood_material.roughness = 0.85

    sign_plate_material = StandardMaterial3D.new()
    sign_plate_material.albedo_color = Color(0.92, 0.95, 0.98)
    sign_plate_material.roughness = 0.40

    # Inizializzazione materiali Codice della Strada & Paesaggio Italiano
    danger_sign_red_material = StandardMaterial3D.new()
    danger_sign_red_material.albedo_color = Color(0.92, 0.12, 0.10)
    danger_sign_red_material.roughness = 0.40

    danger_sign_white_material = StandardMaterial3D.new()
    danger_sign_white_material.albedo_color = Color(0.96, 0.96, 0.98)
    danger_sign_white_material.roughness = 0.35

    danger_sign_black_material = StandardMaterial3D.new()
    danger_sign_black_material.albedo_color = Color(0.10, 0.10, 0.12)
    danger_sign_black_material.roughness = 0.60

    mirror_chrome_material = StandardMaterial3D.new()
    mirror_chrome_material.albedo_color = Color(0.95, 0.95, 0.98)
    mirror_chrome_material.metallic = 1.0
    mirror_chrome_material.roughness = 0.04

    olive_leaf_material = StandardMaterial3D.new()
    olive_leaf_material.albedo_color = Color(0.38, 0.46, 0.32)
    olive_leaf_material.roughness = 0.85

    olive_bark_material = StandardMaterial3D.new()
    olive_bark_material.albedo_color = Color(0.36, 0.32, 0.28)
    olive_bark_material.roughness = 0.92

    maritime_pine_bark_material = StandardMaterial3D.new()
    maritime_pine_bark_material.albedo_color = Color(0.42, 0.26, 0.18)
    maritime_pine_bark_material.roughness = 0.90

    guardrail_reflector_red = StandardMaterial3D.new()
    guardrail_reflector_red.albedo_color = Color(1.0, 0.18, 0.14)
    guardrail_reflector_red.emission_enabled = true
    guardrail_reflector_red.emission = Color(1.0, 0.18, 0.14)
    guardrail_reflector_red.emission_energy_multiplier = 1.2

    guardrail_reflector_white = StandardMaterial3D.new()
    guardrail_reflector_white.albedo_color = Color(0.96, 0.96, 0.98)
    guardrail_reflector_white.emission_enabled = true
    guardrail_reflector_white.emission = Color(0.96, 0.96, 0.98)
    guardrail_reflector_white.emission_energy_multiplier = 1.1

    # Arredo Stradale Autentico Italiano
    anas_stone_material = StandardMaterial3D.new()
    anas_stone_material.albedo_color = Color(0.85, 0.83, 0.80)
    anas_stone_material.roughness = 0.90
    
    anas_cap_red_material = StandardMaterial3D.new()
    anas_cap_red_material.albedo_color = Color(0.82, 0.14, 0.12)
    anas_cap_red_material.roughness = 0.55

    apex_curb_red_material = StandardMaterial3D.new()
    apex_curb_red_material.albedo_color = Color(0.86, 0.12, 0.10)
    apex_curb_red_material.roughness = 0.65

    apex_curb_white_material = StandardMaterial3D.new()
    apex_curb_white_material.albedo_color = Color(0.92, 0.92, 0.94)
    apex_curb_white_material.roughness = 0.65

    rumble_strip_material = StandardMaterial3D.new()
    rumble_strip_material.albedo_color = Color(0.94, 0.94, 0.96)
    rumble_strip_material.roughness = 0.40

    bridge_joint_steel_material = StandardMaterial3D.new()
    bridge_joint_steel_material.albedo_color = Color(0.35, 0.36, 0.38)
    bridge_joint_steel_material.metallic = 0.85
    bridge_joint_steel_material.roughness = 0.35

    # 7. Water Material (Alpine Lake & Torrent)
    var water_shader = load("res://shaders/stylized_water.gdshader")
    water_material = ShaderMaterial.new()
    water_material.shader = water_shader
    water_material.set_shader_parameter("shallow_color", Color(0.20, 0.68, 0.76, 0.88))
    water_material.set_shader_parameter("deep_color", Color(0.08, 0.28, 0.50, 0.95))
    water_material.set_shader_parameter("foam_color", Color(0.95, 0.98, 1.0, 0.95))
    water_material.set_shader_parameter("wave_speed", 1.2)
    water_material.set_shader_parameter("wave_frequency", 0.32)
    water_material.set_shader_parameter("wave_height", 0.06)

    # 8. Village & Town Procedural Building Materials (Tiny Glade style)
    var building_shader = load("res://shaders/stylized_building.gdshader")
    
    var vm_wall = ShaderMaterial.new()
    vm_wall.shader = building_shader
    vm_wall.set_shader_parameter("material_type", 0) # Stone Masonry
    vm_wall.set_shader_parameter("base_color", Color(0.72, 0.69, 0.64))
    vm_wall.set_shader_parameter("alt_color", Color(0.56, 0.52, 0.46))
    vm_wall.set_shader_parameter("mortar_color", Color(0.36, 0.33, 0.30))
    vm_wall.set_shader_parameter("texture_scale", 1.8)
    village_wall_material = vm_wall

    var vm_roof = ShaderMaterial.new()
    vm_roof.shader = building_shader
    vm_roof.set_shader_parameter("material_type", 1) # Slate Shingles
    vm_roof.set_shader_parameter("base_color", Color(0.28, 0.28, 0.30))
    vm_roof.set_shader_parameter("alt_color", Color(0.18, 0.18, 0.20))
    vm_roof.set_shader_parameter("mortar_color", Color(0.12, 0.12, 0.14))
    vm_roof.set_shader_parameter("texture_scale", 1.4)
    village_roof_material = vm_roof

    var vm_terra = ShaderMaterial.new()
    vm_terra.shader = building_shader
    vm_terra.set_shader_parameter("material_type", 2) # Terracotta Roof Tiles
    vm_terra.set_shader_parameter("base_color", Color(0.72, 0.36, 0.18))
    vm_terra.set_shader_parameter("alt_color", Color(0.58, 0.28, 0.14))
    vm_terra.set_shader_parameter("mortar_color", Color(0.35, 0.20, 0.12))
    vm_terra.set_shader_parameter("texture_scale", 1.6)
    village_terracotta_material = vm_terra

    cobblestone_material = StandardMaterial3D.new()
    cobblestone_material.albedo_color = Color(0.42, 0.40, 0.38)
    cobblestone_material.roughness = 0.90

    wildflower_gold_material = StandardMaterial3D.new()
    wildflower_gold_material.albedo_color = Color(0.96, 0.82, 0.22)
    wildflower_gold_material.roughness = 0.85
    
    wildflower_violet_material = StandardMaterial3D.new()
    wildflower_violet_material.albedo_color = Color(0.68, 0.45, 0.88)
    wildflower_violet_material.roughness = 0.85
    
    wildflower_white_material = StandardMaterial3D.new()
    wildflower_white_material.albedo_color = Color(0.96, 0.96, 0.94)
    wildflower_white_material.roughness = 0.85

    lantern_glow_material = StandardMaterial3D.new()
    lantern_glow_material.albedo_color = Color(1.0, 0.86, 0.45)
    lantern_glow_material.emission_enabled = true
    lantern_glow_material.emission = Color(1.0, 0.82, 0.38)
    lantern_glow_material.emission_energy_multiplier = 1.2

    # 9. Bridges & River Infrastructure
    bridge_stone_material = StandardMaterial3D.new()
    bridge_stone_material.albedo_color = Color(0.48, 0.46, 0.44)
    bridge_stone_material.roughness = 0.92

    pier_wood_material = StandardMaterial3D.new()
    pier_wood_material.albedo_color = Color(0.36, 0.26, 0.16)
    pier_wood_material.roughness = 0.85

    boat_hull_material = StandardMaterial3D.new()
    boat_hull_material.albedo_color = Color(0.18, 0.42, 0.65)
    boat_hull_material.roughness = 0.60

    windmill_sail_material = StandardMaterial3D.new()
    windmill_sail_material.albedo_color = Color(0.85, 0.80, 0.70)
    windmill_sail_material.roughness = 0.85

    # 10. Service Station (Autogrill & Agip) Materials
    service_canopy_material = StandardMaterial3D.new()
    service_canopy_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    service_canopy_material.albedo_color = Color(0.70, 0.85, 0.96, 0.16) # Ultra-clear crystalline canopy glass
    service_canopy_material.metallic = 0.20
    service_canopy_material.roughness = 0.08
    service_canopy_material.cull_mode = BaseMaterial3D.CULL_DISABLED

    service_pump_material = StandardMaterial3D.new()
    service_pump_material.albedo_color = Color(0.95, 0.72, 0.10) # Agip vintage yellow
    service_pump_material.metallic = 0.20
    service_pump_material.roughness = 0.40

    service_shop_material = StandardMaterial3D.new()
    service_shop_material.albedo_color = Color(0.95, 0.88, 0.65)
    service_shop_material.emission_enabled = true
    service_shop_material.emission = Color(1.0, 0.86, 0.50)
    service_shop_material.emission_energy_multiplier = 0.8

    # 11. Pastoral Animals & Rural Materials
    cow_white_material = StandardMaterial3D.new()
    cow_white_material.albedo_color = Color(0.92, 0.90, 0.86)
    cow_white_material.roughness = 0.85

    cow_brown_material = StandardMaterial3D.new()
    cow_brown_material.albedo_color = Color(0.38, 0.22, 0.12)
    cow_brown_material.roughness = 0.85

    cow_bell_material = StandardMaterial3D.new()
    cow_bell_material.albedo_color = Color(0.88, 0.72, 0.22)
    cow_bell_material.metallic = 0.85
    cow_bell_material.roughness = 0.28

    sheep_wool_material = StandardMaterial3D.new()
    sheep_wool_material.albedo_color = Color(0.94, 0.92, 0.88)
    sheep_wool_material.roughness = 0.96

    sheep_face_material = StandardMaterial3D.new()
    sheep_face_material.albedo_color = Color(0.18, 0.16, 0.15)
    sheep_face_material.roughness = 0.80

    straw_bale_material = StandardMaterial3D.new()
    straw_bale_material.albedo_color = Color(0.85, 0.72, 0.32)
    straw_bale_material.roughness = 0.92

    cart_wood_material = StandardMaterial3D.new()
    cart_wood_material.albedo_color = Color(0.40, 0.28, 0.18)
    cart_wood_material.roughness = 0.88

    fountain_stone_material = StandardMaterial3D.new()
    fountain_stone_material.albedo_color = Color(0.42, 0.43, 0.45)
    fountain_stone_material.roughness = 0.85

    moss_log_material = StandardMaterial3D.new()
    moss_log_material.albedo_color = Color(0.28, 0.20, 0.14)
    moss_log_material.roughness = 0.90

    moss_green_material = StandardMaterial3D.new()
    moss_green_material.albedo_color = Color(0.22, 0.35, 0.14)
    moss_green_material.roughness = 0.95

    # 12. Dettagli Ispirati a Tiny Glade, Dorfromantik & Art of Rally
    barrel_wood_material = StandardMaterial3D.new()
    barrel_wood_material.albedo_color = Color(0.44, 0.30, 0.18)
    barrel_wood_material.roughness = 0.82

    iron_dark_material = StandardMaterial3D.new()
    iron_dark_material.albedo_color = Color(0.18, 0.18, 0.20)
    iron_dark_material.metallic = 0.85
    iron_dark_material.roughness = 0.35

    laundry_white_material = StandardMaterial3D.new()
    laundry_white_material.albedo_color = Color(0.96, 0.96, 0.98)
    laundry_white_material.roughness = 0.75

    laundry_red_material = StandardMaterial3D.new()
    laundry_red_material.albedo_color = Color(0.85, 0.22, 0.20)
    laundry_red_material.roughness = 0.75

    laundry_blue_material = StandardMaterial3D.new()
    laundry_blue_material.albedo_color = Color(0.20, 0.45, 0.78)
    laundry_blue_material.roughness = 0.75

    bicycle_frame_material = StandardMaterial3D.new()
    bicycle_frame_material.albedo_color = Color(0.38, 0.74, 0.68) # Celeste Bianchi
    bicycle_frame_material.metallic = 0.45
    bicycle_frame_material.roughness = 0.30

    telegraph_wood_material = StandardMaterial3D.new()
    telegraph_wood_material.albedo_color = Color(0.32, 0.25, 0.19)
    telegraph_wood_material.roughness = 0.92

    telegraph_cable_material = StandardMaterial3D.new()
    telegraph_cable_material.albedo_color = Color(0.12, 0.12, 0.13)
    telegraph_cable_material.roughness = 0.60

    ceramic_insulator_material = StandardMaterial3D.new()
    ceramic_insulator_material.albedo_color = Color(0.92, 0.96, 0.92)
    ceramic_insulator_material.roughness = 0.15

    spectator_jacket_yellow = StandardMaterial3D.new()
    spectator_jacket_yellow.albedo_color = Color(0.95, 0.82, 0.10) # Giallo Modena
    spectator_jacket_yellow.roughness = 0.60

    spectator_jacket_red = StandardMaterial3D.new()
    spectator_jacket_red.albedo_color = Color(0.88, 0.16, 0.14) # Rosso Corsa
    spectator_jacket_red.roughness = 0.60

    spectator_jacket_blue = StandardMaterial3D.new()
    spectator_jacket_blue.albedo_color = Color(0.15, 0.42, 0.85) # Blu Elettrico 90s
    spectator_jacket_blue.roughness = 0.60

    spectator_jacket_green = StandardMaterial3D.new()
    spectator_jacket_green.albedo_color = Color(0.18, 0.55, 0.25) # Verde Pino
    spectator_jacket_green.roughness = 0.60

    spectator_jeans_material = StandardMaterial3D.new()
    spectator_jeans_material.albedo_color = Color(0.24, 0.35, 0.52) # Denim blue
    spectator_jeans_material.roughness = 0.85

    spectator_skin_material = StandardMaterial3D.new()
    spectator_skin_material.albedo_color = Color(0.90, 0.74, 0.62)
    spectator_skin_material.roughness = 0.70

    spectator_camera_material = StandardMaterial3D.new()
    spectator_camera_material.albedo_color = Color(0.95, 0.95, 0.95)
    spectator_camera_material.emission_enabled = true
    spectator_camera_material.emission = Color(0.90, 0.95, 1.0)
    spectator_camera_material.emission_energy_multiplier = 3.5

    rally_banner_martini = StandardMaterial3D.new()
    rally_banner_martini.albedo_color = Color(0.94, 0.94, 0.96)
    rally_banner_martini.roughness = 0.70

    rally_banner_agip = StandardMaterial3D.new()
    rally_banner_agip.albedo_color = Color(0.95, 0.76, 0.12)
    rally_banner_agip.roughness = 0.70

    rally_banner_pirelli = StandardMaterial3D.new()
    rally_banner_pirelli.albedo_color = Color(0.88, 0.18, 0.15)
    rally_banner_pirelli.roughness = 0.70

    chimney_smoke_material = StandardMaterial3D.new()
    chimney_smoke_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    chimney_smoke_material.albedo_color = Color(0.92, 0.93, 0.95, 0.42)
    chimney_smoke_material.roughness = 0.95

    ivy_leaf_material = StandardMaterial3D.new()
    ivy_leaf_material.albedo_color = Color(0.22, 0.38, 0.16)
    ivy_leaf_material.roughness = 0.85

    # Initialize Seed-Driven Biome Graph & Procedural Noise
    init_procedural_generation()

    # Pre-generate 7 chunks (from -120m to +720m)
    for i in range(7):
        generate_chunk()

func init_procedural_generation():
    if expedition_seed == 0:
        expedition_seed = int(Time.get_ticks_msec()) % 999999 + 1
        
    biome_graph = BiomeGraph.new(expedition_seed)
    
    elevation_noise = FastNoiseLite.new()
    elevation_noise.seed = expedition_seed
    elevation_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
    elevation_noise.frequency = 0.003
    
    curve_noise = FastNoiseLite.new()
    curve_noise.seed = expedition_seed + 101
    curve_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
    curve_noise.frequency = 0.007
    
    width_noise = FastNoiseLite.new()
    width_noise.seed = expedition_seed + 202
    width_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
    width_noise.frequency = 0.02
    
    flora_noise = FastNoiseLite.new()
    flora_noise.seed = expedition_seed + 303
    flora_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
    flora_noise.frequency = 0.04

func get_biome_at(z: float) -> Dictionary:
    if biome_graph:
        return biome_graph.get_biome_at(z)
    return {}

func create_asphalt_texture() -> ImageTexture:
    var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
    var col_base = Color(0.20, 0.21, 0.23)
    var col_rut = Color(0.15, 0.16, 0.18)
    var col_white = Color(0.92, 0.94, 0.96)
    var col_yellow = Color(0.96, 0.74, 0.16)
    var col_shoulder = Color(0.32, 0.30, 0.26)
    
    for y in range(256):
        var v = float(y) / 256.0
        var is_dash = fmod(v * 3.0, 1.0) < 0.55
        for x in range(256):
            var u = float(x) / 256.0
            var c = col_base
            if abs(u - 0.30) < 0.07 or abs(u - 0.70) < 0.07:
                c = col_rut
            if abs(u - 0.12) < 0.014 or abs(u - 0.88) < 0.014:
                c = col_white
            elif abs(u - 0.50) < 0.014 and is_dash:
                c = col_yellow
            elif u < 0.05 or u > 0.95:
                c = col_shoulder
            img.set_pixel(x, y, c)
            
    img.generate_mipmaps()
    return ImageTexture.create_from_image(img)

func ensure_chunks_generated_up_to(target_z: float):
    while next_chunk_z < target_z:
        generate_chunk()

func get_lake_weight(z: float) -> float:
    # Raccordo continuo C1 per evitare scalini al bordo del lago (360m -> 600m)
    if z < 320.0 or z > 640.0:
        return 0.0
    elif z >= 380.0 and z <= 580.0:
        return 1.0
    elif z < 380.0:
        return smoothstep(320.0, 380.0, z)
    else:
        return 1.0 - smoothstep(580.0, 640.0, z)

func get_sea_weight(z: float) -> float:
    # Raccordo continuo C1 per la discesa e l'affaccio sul mare (7800m -> 11000m)
    if z < 7800.0 or z > 11000.0:
        return 0.0
    elif z >= 8200.0 and z <= 10600.0:
        return 1.0
    elif z < 8200.0:
        return smoothstep(7800.0, 8200.0, z)
    else:
        return 1.0 - smoothstep(10600.0, 11000.0, z)

func get_service_flatten_weight(z: float) -> float:
    # Raccordo continuo C1 per il piazzale delle aree di servizio (Agip 1380-1500m, Autogrill 3120-3240m)
    var w1 = 0.0
    if z >= 1350.0 and z <= 1530.0:
        if z < 1390.0:
            w1 = smoothstep(1350.0, 1390.0, z)
        elif z > 1490.0:
            w1 = 1.0 - smoothstep(1490.0, 1530.0, z)
        else:
            w1 = 1.0
            
    var w2 = 0.0
    if z >= 3090.0 and z <= 3270.0:
        if z < 3130.0:
            w2 = smoothstep(3090.0, 3130.0, z)
        elif z > 3230.0:
            w2 = 1.0 - smoothstep(3230.0, 3270.0, z)
        else:
            w2 = 1.0
            
    return max(w1, w2)

func get_junction_flatten_weight_left(z: float) -> float:
    # Raccordo continuo C1 per bivi sul lato sinistro: Forra/Cava Marmo (1660-1820) e Tornanti/Valico Duca (3340-3500)
    var ranges = [
        [1660.0, 1820.0],
        [3340.0, 3500.0]
    ]
    var max_w = 0.0
    for r in ranges:
        var z_start = r[0]
        var z_end = r[1]
        if z >= z_start and z <= z_end:
            var z_mid1 = z_start + 40.0
            var z_mid2 = z_end - 40.0
            var w = 0.0
            if z < z_mid1:
                w = smoothstep(z_start, z_mid1, z)
            elif z > z_mid2:
                w = 1.0 - smoothstep(z_mid2, z_end, z)
            else:
                w = 1.0
            max_w = max(max_w, w)
    return max_w

func get_junction_flatten_weight_right(z: float) -> float:
    # Raccordo continuo C1 per bivi sul lato destro: Cascina San Rocco (560-720) e Podere San Pietro (5020-5180)
    var ranges = [
        [560.0, 720.0],
        [5020.0, 5180.0]
    ]
    var max_w = 0.0
    for r in ranges:
        var z_start = r[0]
        var z_end = r[1]
        if z >= z_start and z <= z_end:
            var z_mid1 = z_start + 40.0
            var z_mid2 = z_end - 40.0
            var w = 0.0
            if z < z_mid1:
                w = smoothstep(z_start, z_mid1, z)
            elif z > z_mid2:
                w = 1.0 - smoothstep(z_mid2, z_end, z)
            else:
                w = 1.0
            max_w = max(max_w, w)
    return max_w

func get_junction_flatten_weight(z: float) -> float:
    return max(get_junction_flatten_weight_left(z), get_junction_flatten_weight_right(z))

func update_generation(player_z: float):
    # Genera con ampio anticipo (720m) per eliminare qualsiasi salto nel vuoto o interruzione dell'orizzonte
    while next_chunk_z < player_z + 720.0:
        generate_chunk()
        
    # Mantiene almeno 360m di tracciato alle spalle per visibilità specchietti e manovre
    var min_keep_z = player_z - 360.0
    var main_node = get_parent()
    if main_node and main_node.has_node("RaceDirector"):
        var rd = main_node.get_node("RaceDirector")
        if rd and int(rd.get("current_state")) != 0:
            var r_start = float(rd.get("race_start_z"))
            min_keep_z = min(min_keep_z, r_start - 120.0)
            
    for i in range(active_chunks.size() - 1, -1, -1):
        var chunk = active_chunks[i]
        # I chunk 0..540m ospitano l'Officina Paolo e il tracciato drag 400m ufficiale:
        # Rimangono SEMPRE residenti per garantire che le auto non cadano mai nel vuoto!
        if chunk.end_z <= 540.0:
            continue
        if chunk.end_z < min_keep_z:
            chunk.node.queue_free()
            active_chunks.remove_at(i)
            
    for j in range(active_service_stations.size() - 1, -1, -1):
        if active_service_stations[j].z_max <= 540.0:
            continue
        if active_service_stations[j].z_max < min_keep_z:
            active_service_stations.remove_at(j)
            
    for k in range(active_potholes.size() - 1, -1, -1):
        if active_potholes[k].z <= 540.0:
            continue
        if active_potholes[k].z < min_keep_z:
            active_potholes.remove_at(k)
            
    for kp in range(active_road_patches.size() - 1, -1, -1):
        if active_road_patches[kp].z <= 540.0:
            continue
        if active_road_patches[kp].z < min_keep_z:
            active_road_patches.remove_at(kp)

func on_circuit_lap_completed():
    print("[Circuito Meridiano] 🏁 Giro del circuito completato a 12.000m! Chiusura del cerchio e rientro a San Cristoforo.")
    # Rimuovi i vecchi chunk oltre 540m per liberare memoria e riprendere la generazione ciclica
    for i in range(active_chunks.size() - 1, -1, -1):
        if active_chunks[i].end_z > 540.0:
            active_chunks[i].node.queue_free()
            active_chunks.remove_at(i)
            
    # Trova le condizioni al contorno del chunk Z=540m per garantire continuità matematica assoluta
    for chunk in active_chunks:
        if abs(chunk.end_z - 540.0) < 1.0:
            var pts = chunk.points
            var last_pt = pts[pts.size() - 1]
            last_chunk_x = last_pt.x
            last_chunk_angle = last_pt.angle
            last_chunk_bank = last_pt.get("bank", 0.0)
            break
    next_chunk_z = 540.0

func get_road_center_x(z: float) -> float:
    for chunk in active_chunks:
        if z >= chunk.start_z and z <= chunk.end_z:
            var pts = chunk.points
            for i in range(pts.size() - 1):
                if z >= pts[i].z and z <= pts[i + 1].z:
                    var t = (z - pts[i].z) / max(0.001, pts[i + 1].z - pts[i].z)
                    return lerp(pts[i].x, pts[i + 1].x, t)
    return 0.0

const ROAD_ALTITUDE_KEYPOINTS = [
    Vector2(0.0, 0.0),       # San Cristoforo - Quota 0m (Piazza e Borgo)
    Vector2(80.0, 0.0),      # Uscita dalla Città verso la Pianura
    Vector2(280.0, 0.6),     # Piana di San Giorgio & Cascina Padana
    Vector2(520.0, 1.2),     # Ponte in pietra & Mulino ad Acqua
    Vector2(820.0, 1.5),     # Podere Belvedere & Campagna aperta
    Vector2(1080.0, 1.4),    # Conca del Lago dei Salici
    Vector2(1380.0, 3.5),    # Piana Stazione Agip '93 (orizzontale)
    Vector2(1620.0, 4.0),    # Uscita dalla Piana, inizio salita verso l'Appennino
    Vector2(2100.0, 32.0),   # Forra dell'Appennino
    Vector2(2800.0, 62.0),   # Viadotto dei Ciclopi
    Vector2(3240.0, 62.0),   # Piana Autogrill Valico del Meridiano (orizzontale)
    Vector2(3900.0, 105.0),  # I Tornanti dei Larici (+6.5%)
    Vector2(4600.0, 145.0),  # Uscita Tornanti
    Vector2(6000.0, 220.0),  # Valico Glaciale del Duca Quota 2650m
    Vector2(6800.0, 205.0),  # Giro della Montagna attorno al Massiccio
    Vector2(7500.0, 155.0),  # Discesa Panoramica delle Balze Rocciose
    Vector2(8200.0, 85.0),   # Inizio Costiera delle Sirene & Primo Panorama sul Mare
    Vector2(8700.0, 48.0),   # Belvedere delle Sirene & Faro della Scogliera
    Vector2(9300.0, 15.0),   # Discesa litoranea verso il mare
    Vector2(9600.0, 2.5),    # Ingresso Borgo Marina dei Pescatori
    Vector2(10200.0, 2.5),   # Calata del Porto e Banchine Gozzi
    Vector2(10700.0, 2.5),   # Uscita Borgo Marina
    Vector2(11200.0, 1.0),   # Viale degli Oleandri e Pini Marittimi
    Vector2(11700.0, 0.0),   # Porta Marina - Rientro Trionfale a San Cristoforo
    Vector2(12000.0, 0.0)    # Piazza San Cristoforo - Chiusura Cerchio Perfetta
]

func calculate_road_elevation(z: float) -> float:
    if z <= 20.0:
        return 0.0
    var blend = clamp((z - 20.0) / 40.0, 0.0, 1.0)
    
    # 1. Altimetria Stradale Continua C1/C2 (Monotonic Smoothstep Spline)
    var base_alt = 0.0
    var num_k = ROAD_ALTITUDE_KEYPOINTS.size()
    if z <= ROAD_ALTITUDE_KEYPOINTS[0].x:
        base_alt = ROAD_ALTITUDE_KEYPOINTS[0].y
    elif z >= ROAD_ALTITUDE_KEYPOINTS[num_k - 1].x:
        base_alt = ROAD_ALTITUDE_KEYPOINTS[num_k - 1].y
    else:
        for k in range(num_k - 1):
            var k1 = ROAD_ALTITUDE_KEYPOINTS[k]
            var k2 = ROAD_ALTITUDE_KEYPOINTS[k + 1]
            if z >= k1.x and z <= k2.x:
                var span = max(0.001, k2.x - k1.x)
                var t = (z - k1.x) / span
                # Raccordo Hermite C1 (smoothstep: d/dt = 0 a inizio e fine, zero spigoli)
                var s = t * t * (3.0 - 2.0 * t)
                base_alt = lerp(k1.y, k2.y, s)
                break
                
    # 2. Raccordo perfetto per i piazzali di servizio (Stazione Agip a 3.5m e Autogrill a 62.0m)
    var s_weight = get_service_flatten_weight(z)
    if s_weight > 0.0:
        var s_target = 3.5 if z < 2300.0 else 62.0
        base_alt = lerp(base_alt, s_target, s_weight)
        
    # 3. Micro-rilievo procedurale morbido e naturale (niente sobbalzi secchi)
    var micro_elev = elevation_noise.get_noise_1d(z * 0.005) * 0.35 if elevation_noise else 0.0
    if z >= 11800.0:
        var end_blend = clamp((12000.0 - z) / 200.0, 0.0, 1.0)
        # Raccordo cubico dolce C1 per annullare il micro-rilievo al traguardo di San Cristoforo
        end_blend = end_blend * end_blend * (3.0 - 2.0 * end_blend)
        micro_elev *= end_blend
    return (base_alt + micro_elev) * blend

func generate_chunk():
    if elevation_noise == null:
        init_procedural_generation()
    var start_z = next_chunk_z
    var end_z = start_z + chunk_length
    var step_z = chunk_length / float(road_segments)
    
    # Surface classification per chunk
    var surface_type = 0 # 0: Alpine Asphalt, 1: Curves Asphalt, 2: Pavé Porfido, 3: Wet Gorge, 4: Strada Bianca
    var surface_name = "ASFALTO ALPINO USURATO"
    var grip_mult = 1.00
    var chunk_road_mat = road_asphalt_alpine_mat
    
    if (start_z >= 840.0 and start_z < 1140.0) or (start_z >= 9400.0 and start_z < 10700.0):
        surface_type = 2
        surface_name = "PAVÉ MARINARO DI BORGO MARINA" if start_z >= 9400.0 else "PAVÉ DI PORFIDO TRENTINO"
        grip_mult = 0.88 if start_z >= 9400.0 else 0.86
        chunk_road_mat = road_pave_porfido_mat
    elif start_z >= 1440.0 and start_z < 3000.0:
        surface_type = 3
        surface_name = "ASFALTO BAGNATO SCURO"
        grip_mult = 0.72
        chunk_road_mat = road_wet_gorge_mat
    elif (start_z >= 3480.0 and start_z < 4200.0) or (start_z >= 4800.0 and start_z < 5600.0):
        surface_type = 4
        surface_name = "STRADA BIANCA TOSCANA"
        grip_mult = 0.68
        chunk_road_mat = road_strada_bianca_mat
    elif (start_z >= 120.0 and start_z < 340.0) or (start_z >= 1200.0 and start_z < 1390.0) or (start_z >= 3000.0 and start_z < 3480.0) or (start_z >= 8200.0 and start_z < 9400.0):
        surface_type = 1
        surface_name = "ASFALTO COSTIERO PANORAMICO" if start_z >= 8200.0 else "ASFALTO VALICO & TORNANTI"
        grip_mult = 0.98 if start_z >= 8200.0 else 0.95
        chunk_road_mat = road_asphalt_curves_mat
    elif start_z >= 10700.0 and start_z <= 12000.0:
        surface_type = 0
        surface_name = "VIALE DEI PINI MARITTIMI"
        grip_mult = 1.00
        chunk_road_mat = road_asphalt_alpine_mat
    else:
        surface_type = 0
        surface_name = "ASFALTO ALPINO USURATO"
        grip_mult = 1.00
        chunk_road_mat = road_asphalt_alpine_mat
        
    var points: Array = []
    var cur_x = last_chunk_x
    var cur_angle = last_chunk_angle
    var cur_bank = last_chunk_bank
    
    for s in range(road_segments + 1):
        var z = start_z + float(s) * step_z
        var y = calculate_road_elevation(z)
        
        # Adaptive civil engineering roadway widths
        var is_hairpin_now = (z >= 130.0 and z <= 330.0) or (z >= 1200.0 and z <= 1390.0) or (z >= 3000.0 and z <= 3480.0) or (z >= 4250.0 and z <= 4800.0) or (z >= 5650.0 and z <= 6200.0) or (z >= 6900.0 and z <= 7400.0)
        var width = base_width
        if (z >= 840.0 and z <= 1140.0) or (z >= 9400.0 and z <= 10700.0):
            width = 6.8 # Authentic narrow historic street (Borgo San Cristoforo & Borgo Marina)
        elif (z >= 3480.0 and z <= 4200.0) or (z >= 4800.0 and z <= 5600.0):
            width = 7.0 # Rural Strada Bianca
        elif is_hairpin_now:
            width = 8.8 # Hairpin apex widening for vehicle turning sweep
        elif z > 20.0 and width_noise:
            width = base_width + width_noise.get_noise_1d(z * 0.02) * 0.5
            
        points.append({ "x": cur_x, "y": y, "z": z, "width": width, "angle": cur_angle, "bank": cur_bank })
        
        if s < road_segments and z > 20.0:
            var b_info = get_biome_at(z)
            var curv_scale = b_info.get("curv_factor", 1.0)
            
            # --- CURVATURE MODULATION: TORNANTI A 180°, CHICANE & RETTILINEI ---
            var is_hairpin_zone = (z >= 130.0 and z <= 330.0) or (z >= 1200.0 and z <= 1390.0) or (z >= 3000.0 and z <= 3480.0) or (z >= 4250.0 and z <= 4800.0) or (z >= 5650.0 and z <= 6200.0) or (z >= 6900.0 and z <= 7400.0)
            var is_straight_zone = (z < 60.0) or (z >= 380.0 and z <= 540.0) or (z >= 670.0 and z <= 790.0) or (z >= 3120.0 and z <= 3240.0) or (z >= 11500.0)
            
            var target_angle_delta = 0.0
            if is_straight_zone:
                # Tratti rettilinei (partenza, lungolago, piazzali stazioni e rientro a San Cristoforo a 12000m)
                target_angle_delta = -cur_angle * (0.28 if z >= 11500.0 else 0.15)
            elif is_hairpin_zone:
                # TORNANTI ALPINI A GOMITO (180° Hairpins): decisa inversione ad arco
                var hairpin_cycle = sin(z * 0.048)
                var hairpin_intensity = 1.35 * curv_scale
                target_angle_delta = hairpin_cycle * hairpin_intensity * 0.16
            else:
                # CURVE APPINNINICHE E CHICANE COLLINARI A RAGGIO VARIABILE
                var n1 = curve_noise.get_noise_1d(z * 0.008) * 1.35 if curve_noise else 0.0
                var n2 = curve_noise.get_noise_1d(z * 0.024) * 0.65 if curve_noise else 0.0
                target_angle_delta = (n1 + n2) * curv_scale * 0.052
                
            # Forza centripeta di contenimento nel corridoio della vallata (Max +/- 34m dal centro)
            if abs(cur_x) > 28.0 and not is_hairpin_zone:
                var pull = -sign(cur_x) * pow((abs(cur_x) - 28.0) / 10.0, 1.6) * 0.045
                target_angle_delta += pull
                
            cur_angle += target_angle_delta
            if z >= 11500.0:
                cur_angle = clamp(cur_angle, -0.6, 0.6)
                cur_x = lerp(cur_x, 0.0, 0.08)
                cur_bank = lerp(cur_bank, 0.0, 0.15)
            else:
                # Angolo fino a +/- 1.15 rad (~66°) per autentici tornanti a gomito alpini!
                cur_angle = clamp(cur_angle, -1.15, 1.15)
                cur_x += sin(cur_angle) * step_z * 0.72
                # Sopraelevazione parabolica in curva (Inward superelevation banking)
                cur_bank = clamp((target_angle_delta / max(0.1, step_z)) * 2.2, -0.13, 0.13)

            
    last_chunk_x = cur_x
    last_chunk_angle = cur_angle
    last_chunk_bank = cur_bank
    next_chunk_z = end_z
    
    var chunk_node = build_chunk_node(points, start_z, chunk_road_mat)
    add_child(chunk_node)
    
    spawn_road_potholes(chunk_node, points, start_z)
    spawn_road_patches_and_details(chunk_node, points, start_z)
    
    active_chunks.append({
        "start_z": start_z,
        "end_z": end_z,
        "points": points,
        "node": chunk_node,
        "surface_type": surface_type,
        "surface_name": surface_name,
        "grip_mult": grip_mult
    })

func build_chunk_node(points: Array, start_z: float, chunk_road_mat: Material = null) -> Node3D:
    var root = Node3D.new()
    var num_pts = points.size()
    
    # 1. Road Surface Mesh
    var surface_tool = SurfaceTool.new()
    surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    var use_road_mat = chunk_road_mat if chunk_road_mat else road_material
    surface_tool.set_material(use_road_mat)
    
    # 2. Multi-Zone Rolling Landscape Terrain Mesh
    var terrain_tool = SurfaceTool.new()
    terrain_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    terrain_tool.set_material(terrain_material)
    
    var collision_faces = PackedVector3Array()
    
    # Precalcolo dei vettori normali perpendicolari alla traiettoria per ogni fetta (continui al 100% sui giunti dei chunk)
    var normals: Array = []
    for k in range(num_pts):
        var ang = points[k].angle
        normals.append(Vector3(cos(ang), 0.0, -sin(ang)))
        
    for i in range(num_pts - 1):
        var p1 = points[i]
        var p2 = points[i + 1]
        var n1 = normals[i]
        var n2 = normals[i + 1]
        
        var hw1 = p1.width * 0.5
        var phw1 = hw1 * 0.78
        var hw2 = p2.width * 0.5
        var phw2 = hw2 * 0.78
        
        var uv_y1 = p1.z * 0.08
        var uv_y2 = p2.z * 0.08
        
        # Authentic mountain road banking (sopraelevazione dinamica interna in curva)
        var bank1 = p1.get("bank", 0.0)
        var bank2 = p2.get("bank", 0.0)
        var b1_0 = hw1 * bank1
        var b1_1 = phw1 * bank1
        var b1_3 = -phw1 * bank1
        var b1_4 = -hw1 * bank1
        
        var b2_0 = hw2 * bank2
        var b2_1 = phw2 * bank2
        var b2_3 = -phw2 * bank2
        var b2_4 = -hw2 * bank2
        
        # 5 crowned road points with authentic camber & banking (calcolati rigorosamente lungo la normale alla curva)
        var v1_0 = Vector3(p1.x - n1.x * hw1, p1.y + b1_0, p1.z - n1.z * hw1)
        var v1_1 = Vector3(p1.x - n1.x * phw1, p1.y + 0.045 + b1_1, p1.z - n1.z * phw1)
        var v1_2 = Vector3(p1.x, p1.y + 0.08, p1.z)
        var v1_3 = Vector3(p1.x + n1.x * phw1, p1.y + 0.045 + b1_3, p1.z + n1.z * phw1)
        var v1_4 = Vector3(p1.x + n1.x * hw1, p1.y + b1_4, p1.z + n1.z * hw1)
        
        var v2_0 = Vector3(p2.x - n2.x * hw2, p2.y + b2_0, p2.z - n2.z * hw2)
        var v2_1 = Vector3(p2.x - n2.x * phw2, p2.y + 0.045 + b2_1, p2.z - n2.z * phw2)
        var v2_2 = Vector3(p2.x, p2.y + 0.08, p2.z)
        var v2_3 = Vector3(p2.x + n2.x * phw2, p2.y + 0.045 + b2_3, p2.z + n2.z * phw2)
        var v2_4 = Vector3(p2.x + n2.x * hw2, p2.y + b2_4, p2.z + n2.z * hw2)
        
        add_quad(surface_tool, collision_faces, v1_0, v2_0, v2_1, v1_1, 0.0, 0.122, uv_y1, uv_y2)
        add_quad(surface_tool, collision_faces, v1_1, v2_1, v2_2, v1_2, 0.122, 0.500, uv_y1, uv_y2)
        add_quad(surface_tool, collision_faces, v1_2, v2_2, v2_3, v1_3, 0.500, 0.878, uv_y1, uv_y2)
        add_quad(surface_tool, collision_faces, v1_3, v2_3, v2_4, v1_4, 0.878, 1.000, uv_y1, uv_y2)
        
        # --- ROLLING MULTI-TIER MEADOWS (Left and Right out to 180m) ---
        # Zone 1: Roadside verge swale (0 to 18m)
        var jl_weight1 = get_junction_flatten_weight_left(p1.z)
        var jl_weight2 = get_junction_flatten_weight_left(p2.z)
        var swale_l_drop1 = lerp(-0.25, 0.0, jl_weight1)
        var swale_l_drop2 = lerp(-0.25, 0.0, jl_weight2)
        var v_swale_l1 = Vector3(p1.x - n1.x * (hw1 + 18.0), p1.y + b1_0 + swale_l_drop1, p1.z - n1.z * (hw1 + 18.0))
        var v_swale_l2 = Vector3(p2.x - n2.x * (hw2 + 18.0), p2.y + b2_0 + swale_l_drop2, p2.z - n2.z * (hw2 + 18.0))
        add_quad(terrain_tool, collision_faces, v_swale_l1, v_swale_l2, v2_0, v1_0, 0.0, 0.25, uv_y1, uv_y2)
        
        var s_weight1 = get_service_flatten_weight(p1.z)
        var s_weight2 = get_service_flatten_weight(p2.z)
        var jr_weight1 = get_junction_flatten_weight_right(p1.z)
        var jr_weight2 = get_junction_flatten_weight_right(p2.z)
        var r_flatten1 = max(s_weight1, jr_weight1)
        var r_flatten2 = max(s_weight2, jr_weight2)
        var swale_r_drop1 = lerp(-0.25, 0.0, r_flatten1)
        var swale_r_drop2 = lerp(-0.25, 0.0, r_flatten2)
        var v_swale_r1 = Vector3(p1.x + n1.x * (hw1 + 18.0), p1.y + b1_4 + swale_r_drop1, p1.z + n1.z * (hw1 + 18.0))
        var v_swale_r2 = Vector3(p2.x + n2.x * (hw2 + 18.0), p2.y + b2_4 + swale_r_drop2, p2.z + n2.z * (hw2 + 18.0))
        add_quad(terrain_tool, collision_faces, v1_4, v2_4, v_swale_r2, v_swale_r1, 0.75, 1.0, uv_y1, uv_y2)
        
        # Zone 2: Rolling Pasture Knolls (18m to 65m) - Raccordo continuo analitico C1 (Zero salti nel vuoto)
        var l_weight1 = get_lake_weight(p1.z)
        var l_weight2 = get_lake_weight(p2.z)
        var normal_knoll_l1 = p1.y + sin(p1.z * 0.024 - 1.2) * 3.6 + cos(p1.z * 0.009) * 2.0
        var normal_knoll_l2 = p2.y + sin(p2.z * 0.024 - 1.2) * 3.6 + cos(p2.z * 0.009) * 2.0
        var lake_knoll_l1 = p1.y - 3.9 + sin(p1.z * 0.015) * 0.6
        var lake_knoll_l2 = p2.y - 3.9 + sin(p2.z * 0.015) * 0.6
        var h_knoll_l1_base = lerp(normal_knoll_l1, lake_knoll_l1, l_weight1)
        var h_knoll_l2_base = lerp(normal_knoll_l2, lake_knoll_l2, l_weight2)
        var h_knoll_l1 = lerp(h_knoll_l1_base, p1.y, jl_weight1)
        var h_knoll_l2 = lerp(h_knoll_l2_base, p2.y, jl_weight2)
        
        var sea_w1 = get_sea_weight(p1.z)
        var sea_w2 = get_sea_weight(p2.z)
        if sea_w1 > 0.0:
            h_knoll_l1 = lerp(h_knoll_l1, min(p1.y - 1.2, 1.8), sea_w1)
        if sea_w2 > 0.0:
            h_knoll_l2 = lerp(h_knoll_l2, min(p2.y - 1.2, 1.8), sea_w2)
            
        var v_knoll_l1 = Vector3(p1.x - n1.x * (hw1 + 65.0), h_knoll_l1, p1.z - n1.z * (hw1 + 65.0))
        var v_knoll_l2 = Vector3(p2.x - n2.x * (hw2 + 65.0), h_knoll_l2, p2.z - n2.z * (hw2 + 65.0))
        add_quad(terrain_tool, collision_faces, v_knoll_l1, v_knoll_l2, v_swale_l2, v_swale_l1, 0.0, 0.45, uv_y1, uv_y2)
        
        var normal_knoll_r1 = p1.y + sin(p1.z * 0.022 + 1.4) * 3.4 + cos(p1.z * 0.011) * 2.2
        var normal_knoll_r2 = p2.y + sin(p2.z * 0.022 + 1.4) * 3.4 + cos(p2.z * 0.011) * 2.2
        var h_knoll_r1 = lerp(normal_knoll_r1, p1.y, r_flatten1)
        var h_knoll_r2 = lerp(normal_knoll_r2, p2.y, r_flatten2)
        var v_knoll_r1 = Vector3(p1.x + n1.x * (hw1 + 65.0), h_knoll_r1, p1.z + n1.z * (hw1 + 65.0))
        var v_knoll_r2 = Vector3(p2.x + n2.x * (hw2 + 65.0), h_knoll_r2, p2.z + n2.z * (hw2 + 65.0))
        add_quad(terrain_tool, collision_faces, v_swale_r1, v_swale_r2, v_knoll_r2, v_knoll_r1, 0.55, 1.0, uv_y1, uv_y2)
        
        # Zone 3: Outer Foothills (65m to 165m) - Con piena collisione fisica per evitare cadute laterali nel vuoto
        var h_foot_l1 = p1.y + 6.0 + sin(p1.z * 0.016) * 6.5 + cos(p1.z * 0.006) * 3.5
        var h_foot_l2 = p2.y + 6.0 + sin(p2.z * 0.016) * 6.5 + cos(p2.z * 0.006) * 3.5
        if sea_w1 > 0.0:
            h_foot_l1 = lerp(h_foot_l1, 0.2, sea_w1)
        if sea_w2 > 0.0:
            h_foot_l2 = lerp(h_foot_l2, 0.2, sea_w2)
            
        var v_foot_l1 = Vector3(p1.x - n1.x * (hw1 + 165.0), h_foot_l1, p1.z - n1.z * (hw1 + 165.0))
        var v_foot_l2 = Vector3(p2.x - n2.x * (hw2 + 165.0), h_foot_l2, p2.z - n2.z * (hw2 + 165.0))
        add_quad(terrain_tool, collision_faces, v_foot_l1, v_foot_l2, v_knoll_l2, v_knoll_l1, 0.0, 0.4, uv_y1, uv_y2)
        
        var h_foot_r1 = p1.y + 6.0 + sin(p1.z * 0.015 + 2.0) * 6.0 + cos(p1.z * 0.007) * 3.5
        var h_foot_r2 = p2.y + 6.0 + sin(p2.z * 0.015 + 2.0) * 6.0 + cos(p2.z * 0.007) * 3.5
        var v_foot_r1 = Vector3(p1.x + n1.x * (hw1 + 165.0), h_foot_r1, p1.z + n1.z * (hw1 + 165.0))
        var v_foot_r2 = Vector3(p2.x + n2.x * (hw2 + 165.0), h_foot_r2, p2.z + n2.z * (hw2 + 165.0))
        add_quad(terrain_tool, collision_faces, v_knoll_r1, v_knoll_r2, v_foot_r2, v_foot_r1, 0.6, 1.0, uv_y1, uv_y2)
        
        # Zone 4: Extended Horizon Foothills (165m to 280m)
        var h_rim_l1 = h_foot_l1 + 14.0 + sin(p1.z * 0.011) * 8.0
        var h_rim_l2 = h_foot_l2 + 14.0 + sin(p2.z * 0.011) * 8.0
        if sea_w1 > 0.0:
            h_rim_l1 = lerp(h_rim_l1, 0.1, sea_w1)
        if sea_w2 > 0.0:
            h_rim_l2 = lerp(h_rim_l2, 0.1, sea_w2)

        var v_rim_l1 = Vector3(p1.x - n1.x * (hw1 + 280.0), h_rim_l1, p1.z - n1.z * (hw1 + 280.0))
        var v_rim_l2 = Vector3(p2.x - n2.x * (hw2 + 280.0), h_rim_l2, p2.z - n2.z * (hw2 + 280.0))
        add_quad_mesh_only(terrain_tool, v_rim_l1, v_rim_l2, v_foot_l2, v_foot_l1, 0.0, 0.2, uv_y1, uv_y2)
        
        var h_rim_r1 = h_foot_r1 + 14.0 + sin(p1.z * 0.010 + 1.8) * 8.0
        var h_rim_r2 = h_foot_r2 + 14.0 + sin(p2.z * 0.010 + 1.8) * 8.0
        var v_rim_r1 = Vector3(p1.x + n1.x * (hw1 + 280.0), h_rim_r1, p1.z + n1.z * (hw1 + 280.0))
        var v_rim_r2 = Vector3(p2.x + n2.x * (hw2 + 280.0), h_rim_r2, p2.z + n2.z * (hw2 + 280.0))
        add_quad_mesh_only(terrain_tool, v_foot_r1, v_foot_r2, v_rim_r2, v_rim_r1, 0.8, 1.0, uv_y1, uv_y2)

    surface_tool.generate_normals()
    var mesh = surface_tool.commit()
    var mesh_instance = MeshInstance3D.new()
    mesh_instance.mesh = mesh
    mesh_instance.material_override = use_road_mat
    mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    root.add_child(mesh_instance)
    
    terrain_tool.generate_normals()
    var terrain_mesh = terrain_tool.commit()
    var terrain_instance = MeshInstance3D.new()
    terrain_instance.mesh = terrain_mesh
    terrain_instance.material_override = terrain_material
    terrain_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    root.add_child(terrain_instance)
    
    # Physics Collision (Road + Verge + Knoll up to 65m)
    var static_body = StaticBody3D.new()
    
    var road_shape = mesh.create_trimesh_shape()
    if road_shape:
        if road_shape is ConcavePolygonShape3D:
            road_shape.backface_collision = true
        var col_shape = CollisionShape3D.new()
        col_shape.shape = road_shape
        static_body.add_child(col_shape)
        
    var terrain_shape = terrain_mesh.create_trimesh_shape()
    if terrain_shape:
        if terrain_shape is ConcavePolygonShape3D:
            terrain_shape.backface_collision = true
        var terrain_col = CollisionShape3D.new()
        terrain_col.shape = terrain_shape
        static_body.add_child(terrain_col)
        
    root.add_child(static_body)
    
    # 3. Procedural Mountain Backdrop & Canyon Walls
    build_mountain_backdrop(root, points, start_z)
    
    # 4. Handcrafted Architecture, Trees & Roadside Props
    spawn_scenic_props(root, points, start_z)
    
    # 5. Bridges & Viaducts (Ponte dei Ciclopi, Ponte dell'Altopiano)
    spawn_bridges(root, points, start_z)
    
    # 6. Water Features (Lago Alpino, Torrente della Gola, Fiume dell'Altopiano)
    spawn_water_features(root, points, start_z)
    
    # 7. Towns & Villages (Borgo San Cristoforo, Borgo dell'Altopiano)
    spawn_villages(root, points, start_z)
    
    # 8. Service Station & Amenities (Autogrill Valico, Belvedere del Lago, Edicola Votiva)
    spawn_service_station(root, points, start_z)
    spawn_scenic_amenities(root, points, start_z)
    
    # 9. Pastoral Fauna & Rural / Natural Heritage
    spawn_fauna_and_pastures(root, points, start_z)
    spawn_rural_and_natural_heritage(root, points, start_z)
    
    # 10. Incroci Stradali, Semafori Italiani & Delineatori di Curva a Chevron
    spawn_road_junctions_and_traffic_lights(root, points, start_z)
    
    # 11. Pianura Agricola dei Poderi & Campagna Aperta (Fattorie, Campi, Mulino, Bivi, Laghi e Ruscelli)
    if start_z >= 60.0 and start_z < 1380.0:
        RuralPlainEnvironmentBuilder.spawn_plain_chunk_features(root, points, start_z)
        
    # 12. Tratto Costiero, Affacci sul Mare & Borgo Marina dei Pescatori (Z >= 7800m -> 12000m)
    if start_z >= 7800.0:
        CoastalEnvironmentBuilder.spawn_coastal_chunk_features(root, points, start_z, water_material)
    
    return root

func build_mountain_backdrop(root: Node3D, points: Array, start_z: float):
    var b_info = get_biome_at(start_z)
    var b_type = b_info.get("type", BiomeGraph.BiomeType.ALPINE_MEADOWS)
    var is_gorge = b_type == BiomeGraph.BiomeType.ROCKY_GORGE
    var is_golden = b_type == BiomeGraph.BiomeType.GOLDEN_PLATEAU
    var num_pts = points.size()
    
    if is_gorge:
        # --- GOLA DEL MERIDIANO: TOWERING SHEER CANYON MONOLITHS ---
        # Spaced along the road corridor every 30m on both sides
        var sample_indices = [int(num_pts * 0.15), int(num_pts * 0.40), int(num_pts * 0.65), int(num_pts * 0.88)]
        for idx in sample_indices:
            var p = points[idx]
            for side in [-1.0, 1.0]:
                var mono = MeshInstance3D.new()
                var seed_v = p.z * 0.05 + side * 13.0
                var mw = randf_range(28.0, 44.0)
                var md = randf_range(35.0, 52.0)
                var mh = randf_range(42.0, 68.0)
                mono.mesh = create_canyon_monolith_mesh(mw, md, mh, seed_v)
                mono.material_override = canyon_material
                var dist_x = side * (p.width * 0.5 + randf_range(24.0, 38.0))
                mono.position = Vector3(p.x + dist_x, p.y, p.z)
                mono.rotation.y = randf_range(0.0, TAU)
                root.add_child(mono)
    else:
        # --- PASSO ALPI / VALICO / ALTOPIANO: MAJESTIC FACETED ALPINE MASSIFS ---
        # 1. Mid-distance Mountain Ridge Peaks
        var mid_samples = [int(num_pts * 0.2), int(num_pts * 0.5), int(num_pts * 0.8)]
        for idx in mid_samples:
            var p = points[idx]
            var is_sea = get_sea_weight(p.z) > 0.0
            var mid_sides = [1.0] if is_sea else [-1.0, 1.0]
            for side in mid_sides:
                var peak = MeshInstance3D.new()
                var seed_v = p.z * 0.03 + side * 7.7
                var pw = randf_range(90.0, 140.0)
                var pd = randf_range(80.0, 130.0)
                var ph = 52.0 + sin(p.z * 0.02 + side) * 16.0 + (32.0 if not is_golden else 16.0)
                peak.mesh = create_organic_mountain_massif(pw, pd, ph, seed_v)
                peak.material_override = mountain_material
                # Per la pianura agricola, arretra i massicci montuosi ad almeno 340m per lasciare spazio alla grande vallata aperta
                var is_plain = p.z < 1380.0
                var base_dist = 340.0 if is_plain else (280.0 if p.z < 180.0 else 145.0)
                var dist_x = side * (base_dist + sin(p.z * 0.015) * 25.0)
                peak.position = Vector3(p.x + dist_x, p.y, p.z)
                peak.rotation.y = randf_range(0.0, TAU)
                root.add_child(peak)
                
        # 2. Grand Alpine Summits (towering snow-capped peaks)
        var far_samples = [int(num_pts * 0.3), int(num_pts * 0.7)]
        for idx in far_samples:
            var p = points[idx]
            var is_sea_far = get_sea_weight(p.z) > 0.0
            var far_sides = [1.0] if is_sea_far else [-1.0, 1.0]
            for side in far_sides:
                var summit = MeshInstance3D.new()
                var seed_v = p.z * 0.02 + side * 19.3
                var sw = randf_range(140.0, 200.0)
                var sd = randf_range(130.0, 190.0)
                var sh = 82.0 + cos(p.z * 0.012 + side * 2.0) * 28.0 + (42.0 if not is_golden else 20.0)
                summit.mesh = create_organic_mountain_massif(sw, sd, sh, seed_v)
                summit.material_override = mountain_material
                var is_plain = p.z < 1380.0
                var base_far = 440.0 if is_plain else (380.0 if p.z < 180.0 else 225.0)
                var dist_far = side * (base_far + cos(p.z * 0.01) * 35.0)
                summit.position = Vector3(p.x + dist_far, p.y + 4.0, p.z)
                summit.rotation.y = randf_range(0.0, TAU)
                root.add_child(summit)


func create_organic_mountain_massif(width: float, depth: float, height: float, seed_val: float) -> ArrayMesh:
    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    
    var num_segments = 14
    var rings = [
        { "y": -18.0, "rx": width * 0.55, "rz": depth * 0.55 },
        { "y": height * 0.22, "rx": width * 0.44, "rz": depth * 0.44 },
        { "y": height * 0.55, "rx": width * 0.28, "rz": depth * 0.28 },
        { "y": height * 0.82, "rx": width * 0.14, "rz": depth * 0.14 }
    ]
    
    var ring_vertices: Array = []
    for r_idx in range(rings.size()):
        var r_data = rings[r_idx]
        var pts: Array = []
        for s in range(num_segments):
            var ang = float(s) * (TAU / float(num_segments))
            var harm = sin(ang * 3.0 + seed_val) * 0.18 + cos(ang * 2.0 - seed_val * 1.5) * 0.12
            var rx = r_data.rx * (1.0 + harm)
            var rz = r_data.rz * (1.0 + harm)
            var vy = r_data.y + sin(ang * 4.0 + seed_val) * (height * 0.05)
            pts.append(Vector3(cos(ang) * rx, vy, sin(ang) * rz))
        ring_vertices.append(pts)
        
    var crest_a = Vector3(-width * 0.04, height, -depth * 0.05)
    var crest_b = Vector3(width * 0.04, height * 0.98, depth * 0.05)
    
    for r in range(rings.size() - 1):
        var curr_pts = ring_vertices[r]
        var next_pts = ring_vertices[r + 1]
        for s in range(num_segments):
            var next_s = (s + 1) % num_segments
            var p1 = curr_pts[s]
            var p2 = curr_pts[next_s]
            var p3 = next_pts[s]
            var p4 = next_pts[next_s]
            
            st.add_vertex(p1)
            st.add_vertex(p3)
            st.add_vertex(p2)
            
            st.add_vertex(p2)
            st.add_vertex(p3)
            st.add_vertex(p4)
            
    var top_pts = ring_vertices[rings.size() - 1]
    for s in range(num_segments):
        var next_s = (s + 1) % num_segments
        var target_crest = crest_a if s < int(num_segments * 0.5) else crest_b
        st.add_vertex(top_pts[s])
        st.add_vertex(target_crest)
        st.add_vertex(top_pts[next_s])
        
    st.generate_normals()
    return st.commit()

func create_canyon_monolith_mesh(width: float, depth: float, height: float, seed_val: float) -> ArrayMesh:
    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    
    var num_corners = 8
    var bottom_pts: Array = []
    var mid_pts: Array = []
    var top_pts: Array = []
    for i in range(num_corners):
        var ang = float(i) * (TAU / float(num_corners))
        var harm = sin(seed_val + float(i) * 1.5) * 0.15
        var rx = (width * 0.5) * (0.85 + harm)
        var rz = (depth * 0.5) * (0.85 + harm)
        var bx = cos(ang) * rx
        var bz = sin(ang) * rz
        bottom_pts.append(Vector3(bx, -12.0, bz))
        mid_pts.append(Vector3(bx * 0.94, height * 0.5, bz * 0.94))
        var th = height + sin(seed_val * 3.5 + float(i)) * (height * 0.08)
        top_pts.append(Vector3(bx * 0.88, th, bz * 0.88))
        
    for i in range(num_corners):
        var next_i = (i + 1) % num_corners
        st.add_vertex(bottom_pts[i])
        st.add_vertex(mid_pts[next_i])
        st.add_vertex(bottom_pts[next_i])
        st.add_vertex(bottom_pts[i])
        st.add_vertex(mid_pts[i])
        st.add_vertex(mid_pts[next_i])
        
        st.add_vertex(mid_pts[i])
        st.add_vertex(top_pts[next_i])
        st.add_vertex(mid_pts[next_i])
        st.add_vertex(mid_pts[i])
        st.add_vertex(top_pts[i])
        st.add_vertex(top_pts[next_i])
        
    var top_center = Vector3(0, height + 1.2, 0)
    for i in range(num_corners):
        var next_i = (i + 1) % num_corners
        st.add_vertex(top_center)
        st.add_vertex(top_pts[i])
        st.add_vertex(top_pts[next_i])
        
    st.generate_normals()
    return st.commit()

func add_tri_flat(st: SurfaceTool, p1: Vector3, p2: Vector3, p3: Vector3):
    var norm = (p2 - p1).cross(p3 - p1).normalized()
    if norm.length_squared() < 0.001:
        norm = Vector3.UP
    st.set_normal(norm)
    st.add_vertex(p1)
    st.set_normal(norm)
    st.add_vertex(p2)
    st.set_normal(norm)
    st.add_vertex(p3)

func spawn_scenic_props(root: Node3D, points: Array, start_z: float):
    var num_points = points.size()
    var normals: Array = []
    for k in range(num_points):
        var ang = points[k].angle
        normals.append(Vector3(cos(ang), 0.0, -sin(ang)))

    var b_info = get_biome_at(start_z)
    var b_type = b_info.get("type", BiomeGraph.BiomeType.ALPINE_MEADOWS)
    var is_gorge = b_type == BiomeGraph.BiomeType.ROCKY_GORGE
    var is_larch = b_type == BiomeGraph.BiomeType.AUTUMN_LARCH
    var is_golden = b_type == BiomeGraph.BiomeType.GOLDEN_PLATEAU
    var is_polar = b_type == BiomeGraph.BiomeType.POLAR_TUNDRA
    var is_village = b_info.get("has_village", false)
    var is_service = b_info.get("has_service", false)
    var is_bridge = b_info.get("has_bridge", false)
    var is_lake = b_info.get("has_lake", false)
    
    var is_plain = b_type == BiomeGraph.BiomeType.AGRICULTURAL_PLAIN or (start_z >= 60.0 and start_z < 1380.0)
    # 1. Alpine Chalet / Baita (1 per chunk nestled in scenic pasture, starting outside town)
    if not is_gorge and not is_plain and not is_village and not is_service and not is_bridge and start_z >= 120.0:
        var chalet_idx = int(num_points * 0.45)
        var cp = points[chalet_idx]
        # In lake chunks, ALWAYS place chalet on the uphill slope (c_side = 1.0) overlooking the lake, never in the water
        var c_side = 1.0 if is_lake else (1.0 if (int(start_z / 120.0) % 2 == 0) else -1.0)
        var c_dist = c_side * (cp.width * 0.5 + (38.0 if is_lake else 46.0))
        var c_y = get_terrain_elevation(cp.y, cp.z, c_dist, is_lake)
        var c_pos = Vector3(cp.x + c_dist, c_y, cp.z)
        var c_rot = atan2(-c_dist, 0.0) + (PI * 0.5 if c_side > 0 else -PI * 0.5)
        spawn_alpine_chalet(root, c_pos, c_rot)
        if start_z >= 120.0 and start_z < 360.0:
            active_service_stations.append({
                "name": "Malga Passo delle Alpi '89 - Degustazione & Ristoro",
                "type": "chalet_malga",
                "center": c_pos,
                "bay_center": Vector3(cp.x + c_side * (cp.width * 0.5 + 4.0), cp.y, cp.z),
                "pump_bay_min": Vector3(cp.x + (0.0 if c_side > 0 else -18.0), cp.y - 2.0, cp.z - 18.0),
                "pump_bay_max": Vector3(cp.x + (18.0 if c_side > 0 else 0.0), cp.y + 4.0, cp.z + 18.0),
                "forecourt_min_x": cp.x - 22.0,
                "forecourt_max_x": cp.x + 22.0,
                "z_min": cp.z - 25.0,
                "z_max": cp.z + 25.0
            })
    
    # 2. Roadside Milestone / Altitude Pass Marker at start of chunk
    if start_z > 40.0 and (int(start_z) % 240 == 0):
        var p0 = points[0]
        var n0 = normals[0]
        var p1 = points[min(2, num_points - 1)]
        var r_angle = atan2(p1.x - p0.x, p1.z - p0.z)
        # Posizionato lungo la normale della strada a +2.5m dal ciglio, senza mai invadere l'asfalto
        var sign_pos = Vector3(p0.x - n0.x * (p0.width * 0.5 + 2.5), p0.y + 0.1, p0.z - n0.z * (p0.width * 0.5 + 2.5))
        var sign_text = b_info.get("name", "PASSO ALPINO")
        spawn_alpine_signpost(root, sign_pos, r_angle + PI, sign_text)

    # 2b. Colonnina di Emergenza SOS Anas (Extra-urbano ogni ~240m sulla banchina di emergenza)
    if start_z > 80.0 and (int(start_z) % 240 == 120) and not is_village and not is_bridge and not is_gorge:
        var mid_idx = int(num_points * 0.5)
        var p_mid = points[mid_idx]
        var n_mid = normals[mid_idx]
        var p_mid_next = points[min(mid_idx + 1, num_points - 1)]
        var r_rot = atan2(p_mid_next.x - p_mid.x, p_mid_next.z - p_mid.z)
        var sos_pos = Vector3(p_mid.x + n_mid.x * (p_mid.width * 0.5 + 1.8), p_mid.y, p_mid.z + n_mid.z * (p_mid.width * 0.5 + 1.8))
        var sos_pillar = create_sos_call_pillar(sos_pos, r_rot - PI * 0.5)
        root.add_child(sos_pillar)

    # 3. Clouds & Weather: Heavy Storm Clouds in Gorge vs Fluffy Cumulus in Sunny Biomes
    if is_gorge:
        # Dense dark overcast storm clouds directly overhead across the gorge
        var mid_p = points[num_points / 2]
        for c_i in range(3):
            var c_pos = Vector3(mid_p.x + randf_range(-40.0, 40.0), randf_range(60.0, 85.0), mid_p.z + randf_range(-35.0, 35.0))
            spawn_diorama_cloud_cluster(root, c_pos, true)
    elif randf() < 0.65:
        var mid_p = points[num_points / 2]
        var cloud_side = -1.0 if randf() < 0.5 else 1.0
        var cloud_pos = Vector3(mid_p.x + cloud_side * randf_range(110.0, 220.0), randf_range(90.0, 130.0), mid_p.z + randf_range(-30.0, 30.0))
        spawn_diorama_cloud_cluster(root, cloud_pos, false)

    # 4. Roadside details (Delineators, Walls, Multi-Tier Trees, Crops)
    for i in range(0, num_points - 1):
        var p = points[i]
        var p_next = points[min(i + 1, num_points - 1)]
        var hw = p.width * 0.5
        var hw_next = p_next.width * 0.5
        var n_curr = normals[i]
        var n_next = normals[min(i + 1, num_points - 1)]
        
        # Guide posts every 3 steps (~15m) - suppressed in city center, on bridge decks and service station entrance
        if not is_bridge and i % 3 == 0 and (p.z < -80.0 or p.z > 80.0):
            for side in [-1.0, 1.0]:
                if is_service and side > 0.0:
                    continue
                var post = MeshInstance3D.new()
                var cyl = CylinderMesh.new()
                cyl.top_radius = 0.05; cyl.bottom_radius = 0.06; cyl.height = 0.88
                cyl.material = post_material
                post.mesh = cyl
                post.position = Vector3(p.x + n_curr.x * side * (hw + 0.50), p.y + 0.44, p.z + n_curr.z * side * (hw + 0.50))
                
                # Black diagonal band / cap
                var cap = MeshInstance3D.new()
                var cap_cyl = CylinderMesh.new()
                cap_cyl.top_radius = 0.051; cap_cyl.bottom_radius = 0.054; cap_cyl.height = 0.16
                cap_cyl.material = chalet_roof_material
                cap.mesh = cap_cyl
                cap.position.y = 0.36
                post.add_child(cap)
                
                # European Red / White Retro-Reflector (cats-eye)
                var ref = MeshInstance3D.new()
                var ref_box = BoxMesh.new()
                ref_box.size = Vector3(0.03, 0.08, 0.08)
                var ref_mat = StandardMaterial3D.new()
                ref_mat.albedo_color = Color(1.0, 0.22, 0.18) if side > 0.0 else Color(0.96, 0.96, 0.96)
                ref_mat.emission_enabled = true
                ref_mat.emission = ref_mat.albedo_color
                ref_mat.emission_energy_multiplier = 0.85
                ref.mesh = ref_box
                ref.material_override = ref_mat
                ref.position = Vector3(-side * 0.035, 0.36, 0.0)
                post.add_child(ref)
                
                root.add_child(post)
                
        # Barriere di sicurezza Anas continue (Guardrail a doppia onda N2/H2 e Muretti in pietra)
        # Protezione anti-salto nel vuoto su tornanti, gole, scarpate e ponti
        var is_curving = abs(p_next.x - p.x) > 0.065
        var need_barrier_both_sides = is_gorge or (start_z >= 1400.0 and start_z < 3000.0) or (abs(p.y) > 4.5 and is_curving)
        
        if not is_bridge and (p.z < -80.0 or p.z > 80.0):
            var wall_side = 1.0 if (p_next.x - p.x) >= 0.0 else -1.0
            var sides_to_protect = [-1.0, 1.0] if need_barrier_both_sides else [wall_side]
            
            for b_side in sides_to_protect:
                if is_service and b_side > 0.0:
                    continue # Lascia libero l'accesso alla stazione di servizio sul lato destro
                var is_near_junction = (p.z >= 570.0 and p.z <= 690.0 and b_side > 0.0) or \
                                      (p.z >= 1670.0 and p.z <= 1790.0 and b_side < 0.0) or \
                                      (p.z >= 3350.0 and p.z <= 3470.0 and b_side < 0.0) or \
                                      (p.z >= 5030.0 and p.z <= 5150.0 and b_side > 0.0)
                if is_near_junction:
                    continue # Lascia libero l'accesso all'innesto del bivio stradale
                    
                var is_outer_curve = (b_side == wall_side and is_curving)
                var use_stone_wall = is_outer_curve and (b_info.get("has_village", false) or b_type == BiomeGraph.BiomeType.ALPINE_VILLAGE or b_type == BiomeGraph.BiomeType.GOLDEN_PLATEAU or b_type == BiomeGraph.BiomeType.TUSCAN_HILLS)
                
                if use_stone_wall and p.z > 50.0:
                    var w_p1 = Vector3(p.x + n_curr.x * b_side * (hw + 0.65), p.y, p.z + n_curr.z * b_side * (hw + 0.65))
                    var w_p2 = Vector3(p_next.x + n_next.x * b_side * (hw_next + 0.65), p_next.y, p_next.z + n_next.z * b_side * (hw_next + 0.65))
                    spawn_drystone_wall(root, w_p1, w_p2)
                elif (is_curving or need_barrier_both_sides or (abs(p.y) > 3.5 and p.z > 60.0)):
                    # Guardrail Anas metallico continuo calcolato lungo la normale alla curva (senza interruzioni a scatti)
                    var rail = MeshInstance3D.new()
                    var box = BoxMesh.new()
                    var p_curr_v = Vector3(p.x, p.y, p.z)
                    var p_next_v = Vector3(p_next.x, p_next.y, p_next.z)
                    var seg_vec = p_next_v - p_curr_v
                    var seg_len = max(0.5, seg_vec.length())
                    box.size = Vector3(0.12, 0.36, seg_len * 1.02)
                    box.material = guardrail_material
                    rail.mesh = box
                    
                    var mid_norm = (n_curr + n_next).normalized()
                    var mid_hw = (hw + hw_next) * 0.5
                    var mid_pt = (p_curr_v + p_next_v) * 0.5
                    # Distanza di sicurezza realistica dal bordo strada (banchina di 80 cm libera)
                    rail.position = mid_pt + mid_norm * b_side * (mid_hw + 0.82) + Vector3(0.0, 0.52, 0.0)
                    rail.rotation.y = atan2(seg_vec.x, seg_vec.z)
                    
                    # Montante IPE verticale di sostegno arretrato
                    var post_inst = MeshInstance3D.new()
                    var p_cyl = CylinderMesh.new()
                    p_cyl.top_radius = 0.045; p_cyl.bottom_radius = 0.045; p_cyl.height = 0.72
                    p_cyl.material = guardrail_material
                    post_inst.mesh = p_cyl
                    post_inst.position = Vector3(b_side * 0.05, -0.22, 0.0)
                    rail.add_child(post_inst)
                    
                    # Catadiottro Anas (rosso a destra, bianco a sinistra)
                    var catad = MeshInstance3D.new()
                    var c_box = BoxMesh.new()
                    c_box.size = Vector3(0.02, 0.08, 0.12)
                    c_box.material = guardrail_reflector_red if b_side > 0.0 else guardrail_reflector_white
                    catad.mesh = c_box
                    catad.position = Vector3(-b_side * 0.065, 0.0, 0.0)
                    rail.add_child(catad)
                    
                    # Physical Solid Crash Barrier Collider con fisica di scivolamento anti-incastro
                    var col_body = StaticBody3D.new()
                    var col_shape = CollisionShape3D.new()
                    var c_shape_box = BoxShape3D.new()
                    c_shape_box.size = Vector3(0.26, 0.88, seg_len * 1.02)
                    col_shape.shape = c_shape_box
                    col_body.add_child(col_shape)
                    
                    # Materiale fisico a basso attrito (Teflon/acciaio zincato) e zero rimbalzo per evitare incastri
                    var barrier_phys = PhysicsMaterial.new()
                    barrier_phys.friction = 0.04
                    barrier_phys.bounce = 0.0
                    col_body.physics_material_override = barrier_phys
                    
                    rail.add_child(col_body)
                    root.add_child(rail)

        # Multi-Tier Miniature Trees (Tiny Glade style)
        if i % 5 == 0 and (p.z < -80.0 or p.z > 80.0):
            for side in [-1.0, 1.0]:
                if is_service and side > 0.0:
                    continue
                var tree_dist = side * (hw + randf_range(5.2, 24.0))
                if is_lake and side < 0.0:
                    # On lake side (-1.0), stay strictly within grassy road verge with safe clearance (4.2m to 7.8m)
                    tree_dist = side * (hw + randf_range(4.2, 7.8))
                var tree_y = get_terrain_elevation(p.y, p.z, tree_dist, is_lake)
                var tree_pos = Vector3(p.x + tree_dist, tree_y, p.z + randf_range(-2.5, 2.5))
                var h_scale = randf_range(0.85, 1.45)
                var is_decid = (is_golden and randf() < 0.6) or (randf() < 0.25 and not is_gorge)
                spawn_stylized_tree(root, tree_pos, h_scale, is_larch, is_decid)
                
        # Alpine Boulders in Gorge and High Pass (safe setback outside road shoulder)
        if (is_gorge and i % 4 == 0) or (i % 8 == 2 and p.z > 40.0):
            var r_side = -1.0 if randf() < 0.5 else 1.0
            if not (is_service and r_side > 0.0):
                var rock_r = randf_range(1.1, 2.2 if is_gorge else 1.6)
                var rock = MeshInstance3D.new()
                rock.mesh = create_faceted_boulder_mesh(rock_r, p.z * 0.15 + r_side * 7.7)
                rock.material_override = rock_material
                var rock_dist = r_side * (hw + (randf_range(4.5, 7.5) if (is_lake and r_side < 0.0) else randf_range(5.8, 12.0)))
                rock.position = Vector3(p.x + rock_dist, p.y + rock_r * 0.25, p.z)
                
                # Physical Solid Rock Collider
                var r_col_body = StaticBody3D.new()
                var r_col_shape = CollisionShape3D.new()
                var r_sph = SphereShape3D.new()
                r_sph.radius = rock_r * 0.95
                r_col_shape.shape = r_sph
                r_col_body.add_child(r_col_shape)
                rock.add_child(r_col_body)
                
                root.add_child(rock)

        # Roadside Alpine Flora & Wildflower Clusters (Tiny Glade style)
        if i % 2 == 0 and p.z > 20.0:
            for side in [-1.0, 1.0]:
                if is_service and side > 0.0:
                    continue
                var tuft_node = Node3D.new()
                var c_dist = side * (hw + randf_range(0.6, 2.8))
                tuft_node.position = Vector3(p.x + c_dist, p.y + 0.02, p.z + randf_range(-1.2, 1.2))
                
                # 1. Crossing Grass Blade Tufts (sway with foliage wind shader)
                for b_i in range(2):
                    var blade = MeshInstance3D.new()
                    var p_mesh = PrismMesh.new()
                    p_mesh.size = Vector3(0.08, 0.38, 0.48)
                    blade.mesh = p_mesh
                    blade.material_override = crop_material if (is_larch or is_golden) else bush_material
                    blade.rotation.y = float(b_i) * (PI * 0.45) + randf_range(-0.2, 0.2)
                    blade.position.y = 0.18
                    tuft_node.add_child(blade)
                
                # 2. Slender Stalks & Colorful Wildflower Disks (Buttercup, Clover, Gentian)
                for f_i in range(3):
                    var fl_stem = MeshInstance3D.new()
                    var s_cyl = CylinderMesh.new()
                    s_cyl.top_radius = 0.015; s_cyl.bottom_radius = 0.02; s_cyl.height = 0.24
                    s_cyl.material = chalet_timber_material
                    fl_stem.mesh = s_cyl
                    
                    var f_ang = float(f_i) * (TAU / 3.0) + randf_range(-0.3, 0.3)
                    var f_offset = Vector3(cos(f_ang) * 0.22, 0.12, sin(f_ang) * 0.22)
                    fl_stem.position = f_offset
                    tuft_node.add_child(fl_stem)
                    
                    var fl_head = MeshInstance3D.new()
                    var h_cyl = CylinderMesh.new()
                    h_cyl.top_radius = 0.08; h_cyl.bottom_radius = 0.07; h_cyl.height = 0.03
                    var f_mat = wildflower_gold_material
                    if f_i == 1: f_mat = wildflower_violet_material
                    elif f_i == 2: f_mat = wildflower_white_material
                    fl_head.mesh = h_cyl
                    fl_head.material_override = f_mat
                    fl_head.position = f_offset + Vector3(0.0, 0.13, 0.0)
                    tuft_node.add_child(fl_head)
                    
                root.add_child(tuft_node)

    # 5. Authentic Italian Roadside Furniture & Realism Enhancements
    var is_hairpin = (start_z >= 120.0 and start_z <= 340.0) or (start_z >= 1200.0 and start_z <= 1400.0) or (start_z >= 3340.0 and start_z <= 4250.0) or (start_z >= 4850.0 and start_z <= 5650.0)
    spawn_anas_milestones(root, points, start_z)
    spawn_hairpin_apex_curbs(root, points, start_z, is_hairpin)
    spawn_rumble_strips(root, points, start_z)
    spawn_bridge_expansion_joints(root, points, start_z)
    
    # 6. Dorfromantik & Art of Rally Trackside & Landscape Enrichment
    spawn_telegraph_pole_line(root, points, start_z)
    spawn_rally_spectators_and_banners(root, points, start_z, is_hairpin)

func spawn_anas_milestones(root: Node3D, points: Array, start_z: float):
    # Cippi chilometrici monumentali ANAS ogni 1000 metri sulla banchina destra
    var km_idx = int(ceil(start_z / 1000.0))
    var target_z = float(km_idx) * 1000.0
    if target_z >= start_z and target_z < (start_z + chunk_length) and target_z > 10.0:
        var num_pts = points.size()
        var p_found = null
        var p_next = null
        for i in range(num_pts - 1):
            if target_z >= points[i].z and target_z <= points[i + 1].z:
                p_found = points[i]
                p_next = points[i + 1]
                break
        if p_found and p_next:
            var milestone = Node3D.new()
            milestone.name = "AnasMilestone_KM%d" % km_idx
            var hw = p_found.width * 0.5
            var angle = atan2(p_next.x - p_found.x, p_next.z - p_found.z)
            # Base in pietra sagomata Anas
            var base_mesh = MeshInstance3D.new()
            var box = BoxMesh.new()
            box.size = Vector3(0.38, 0.85, 0.28)
            box.material = anas_stone_material
            base_mesh.mesh = box
            base_mesh.position.y = 0.425
            base_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
            milestone.add_child(base_mesh)
            
            # Cappello rosso sagomato Anas (testata a semicilindro rosso brillante)
            var cap_mesh = MeshInstance3D.new()
            var cap_cyl = CylinderMesh.new()
            cap_cyl.top_radius = 0.14
            cap_cyl.bottom_radius = 0.14
            cap_cyl.height = 0.38
            cap_cyl.material = anas_cap_red_material
            cap_mesh.mesh = cap_cyl
            cap_mesh.rotation.z = deg_to_rad(90.0)
            cap_mesh.position.y = 0.85
            cap_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
            milestone.add_child(cap_mesh)
            
            # Targa identificativa bianca
            var plaque = MeshInstance3D.new()
            var p_box = BoxMesh.new()
            p_box.size = Vector3(0.28, 0.35, 0.04)
            p_box.material = danger_sign_white_material if danger_sign_white_material else anas_stone_material
            plaque.mesh = p_box
            plaque.position = Vector3(0.0, 0.50, -0.14)
            milestone.add_child(plaque)
            
            # Posizionamento sulla banchina destra
            milestone.position = Vector3(p_found.x + hw + 0.95, p_found.y, target_z)
            milestone.rotation.y = angle
            root.add_child(milestone)

func spawn_hairpin_apex_curbs(root: Node3D, points: Array, start_z: float, is_hairpin_zone: bool):
    if not is_hairpin_zone:
        return
    var num_pts = points.size()
    for i in range(num_pts - 1):
        var p1 = points[i]
        var p2 = points[i + 1]
        var delta_x = p2.x - p1.x
        # Cordolo solo sul punto di corda (apice interno) dove la curvatura è decisa
        if abs(delta_x) > 0.08:
            var inner_side = 1.0 if delta_x > 0.0 else -1.0
            var hw1 = p1.width * 0.5
            var hw2 = p2.width * 0.5
            var seg_len = p2.z - p1.z
            var rot_y = atan2(delta_x, seg_len)
            
            var curb = MeshInstance3D.new()
            var box = BoxMesh.new()
            box.size = Vector3(0.35, 0.12, seg_len * 1.02)
            var is_red = (i % 2 == 0)
            box.material = apex_curb_red_material if is_red else apex_curb_white_material
            curb.mesh = box
            
            var mid_x = lerp(p1.x + inner_side * (hw1 - 0.12), p2.x + inner_side * (hw2 - 0.12), 0.5)
            var mid_y = lerp(p1.y, p2.y, 0.5) + 0.06
            var mid_z = (p1.z + p2.z) * 0.5
            curb.position = Vector3(mid_x, mid_y, mid_z)
            curb.rotation.y = rot_y
            root.add_child(curb)

func spawn_rumble_strips(root: Node3D, points: Array, start_z: float):
    # Bande sonore rallentatrici termoplastiche a scaglioni prima dell'ingresso nei paesi
    var target_zs = []
    if start_z <= 820.0 and (start_z + chunk_length) > 820.0:
        target_zs.append(820.0) # Ingresso Borgo San Cristoforo
    if start_z <= 4780.0 and (start_z + chunk_length) > 4780.0:
        target_zs.append(4780.0) # Ingresso Colline Toscane
        
    for r_z in target_zs:
        var num_pts = points.size()
        for i in range(num_pts - 1):
            if r_z >= points[i].z and r_z <= points[i + 1].z:
                var p = points[i]
                var p_next = points[i + 1]
                var rot_y = atan2(p_next.x - p.x, p_next.z - p.z)
                # Gruppo di 4 strisce trasversali
                for b in range(4):
                    var strip = MeshInstance3D.new()
                    var box = BoxMesh.new()
                    box.size = Vector3(p.width * 0.88, 0.025, 0.38)
                    box.material = rumble_strip_material
                    strip.mesh = box
                    var b_z = r_z + float(b) * 1.8
                    strip.position = Vector3(p.x, p.y + 0.05, b_z)
                    strip.rotation.y = rot_y
                    root.add_child(strip)
                break

func spawn_bridge_expansion_joints(root: Node3D, points: Array, start_z: float):
    # Giunti di dilatazione in acciaio alle testate del Viadotto dei Ciclopi
    var joint_zs = []
    if start_z <= 1442.0 and (start_z + chunk_length) > 1442.0:
        joint_zs.append(1442.0)
    if start_z <= 1556.0 and (start_z + chunk_length) > 1556.0:
        joint_zs.append(1556.0)
        
    for j_z in joint_zs:
        var num_pts = points.size()
        for i in range(num_pts - 1):
            if j_z >= points[i].z and j_z <= points[i + 1].z:
                var p = points[i]
                var p_next = points[i + 1]
                var rot_y = atan2(p_next.x - p.x, p_next.z - p.z)
                var joint = MeshInstance3D.new()
                var box = BoxMesh.new()
                box.size = Vector3(p.width * 0.94, 0.035, 0.32)
                box.material = bridge_joint_steel_material
                joint.mesh = box
                joint.position = Vector3(p.x, p.y + 0.06, j_z)
                joint.rotation.y = rot_y
                root.add_child(joint)
                break

func spawn_telegraph_pole_line(root: Node3D, points: Array, start_z: float):
    var b_info = get_biome_at(start_z)
    var is_village = b_info.get("has_village", false)
    var is_bridge = b_info.get("has_bridge", false)
    var is_gorge = b_info.get("type", 0) == BiomeGraph.BiomeType.ROCKY_GORGE
    
    # I pali telegrafici corrono lungo la campagna aperta e pascoli alpini (Dorfromantik diorama)
    if is_village or is_bridge or is_gorge:
        last_telegraph_pole_pos = Vector3.ZERO
        return
        
    var num_pts = points.size()
    var pole_steps = [int(num_pts * 0.15), int(num_pts * 0.50), int(num_pts * 0.85)]
    
    for idx in pole_steps:
        var p = points[idx]
        var p_next = points[min(idx + 1, num_pts - 1)]
        var r_angle = atan2(p_next.x - p.x, p_next.z - p.z)
        
        var side = -1.0
        var hw = p.width * 0.5
        var p_dist = side * (hw + 4.2)
        var p_y = get_terrain_elevation(p.y, p.z, p_dist, false)
        var pole_pos = Vector3(p.x + p_dist, p_y, p.z)
        
        var pole_node = Node3D.new()
        pole_node.name = "TelegraphPole"
        pole_node.position = pole_pos
        pole_node.rotation.y = r_angle
        
        # 1. Palo verticale in legno rustico consumato dal tempo
        var pole_mesh = MeshInstance3D.new()
        var cyl = CylinderMesh.new()
        cyl.top_radius = 0.09
        cyl.bottom_radius = 0.13
        cyl.height = 6.8
        cyl.material = telegraph_wood_material
        pole_mesh.mesh = cyl
        pole_mesh.position.y = 3.4
        pole_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
        pole_node.add_child(pole_mesh)
        
        # 2. Traversa orizzontale in legno (crossarm)
        var arm_mesh = MeshInstance3D.new()
        var arm_box = BoxMesh.new()
        arm_box.size = Vector3(1.8, 0.12, 0.10)
        arm_box.material = telegraph_wood_material
        arm_mesh.mesh = arm_box
        arm_mesh.position.y = 6.2
        arm_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
        pole_node.add_child(arm_mesh)
        
        # 3. Tiranti diagonali di rinforzo in ferro scuro
        for b_dir in [-0.45, 0.45]:
            var brace = MeshInstance3D.new()
            var br_cyl = CylinderMesh.new()
            br_cyl.top_radius = 0.02
            br_cyl.bottom_radius = 0.02
            br_cyl.height = 0.75
            br_cyl.material = iron_dark_material
            brace.mesh = br_cyl
            brace.position = Vector3(b_dir * 0.5, 5.85, 0.0)
            brace.rotation.z = -b_dir * 0.75
            pole_node.add_child(brace)
            
        # 4. Isolatori ceramici smaltati bianchi/verdi sulla traversa
        for ix in [-0.75, 0.75]:
            var ins = MeshInstance3D.new()
            var ins_cyl = CylinderMesh.new()
            ins_cyl.top_radius = 0.035
            ins_cyl.bottom_radius = 0.045
            ins_cyl.height = 0.14
            ins_cyl.material = ceramic_insulator_material
            ins.mesh = ins_cyl
            ins.position = Vector3(ix, 6.32, 0.0)
            pole_node.add_child(ins)
            
        # 5. Piccole rondini appollaiate sulla traversa (Dorfromantik touch)
        if (int(p.z) % 7) < 3:
            var bird = MeshInstance3D.new()
            var b_sph = SphereMesh.new()
            b_sph.radius = 0.05
            b_sph.height = 0.11
            b_sph.material = iron_dark_material
            bird.mesh = b_sph
            bird.position = Vector3(randf_range(-0.4, 0.4), 6.31, 0.0)
            pole_node.add_child(bird)
            
        root.add_child(pole_node)
        
        # 6. Cavi telefonici aerei continui con catenaria parabolica
        var curr_world_pole = pole_pos + Vector3(0.0, 6.32, 0.0)
        if last_telegraph_pole_pos != Vector3.ZERO:
            var dist_poles = last_telegraph_pole_pos.distance_to(curr_world_pole)
            if dist_poles >= 20.0 and dist_poles <= 55.0:
                for cable_side in [-0.75, 0.75]:
                    var offset_arm = Vector3(cos(r_angle) * cable_side, 0.0, -sin(r_angle) * cable_side)
                    var p_start = last_telegraph_pole_pos + offset_arm
                    var p_end = curr_world_pole + offset_arm
                    
                    var cable_node = Node3D.new()
                    cable_node.name = "TelegraphCable"
                    
                    var num_segs = 4
                    for seg_k in range(num_segs):
                        var t0 = float(seg_k) / float(num_segs)
                        var t1 = float(seg_k + 1) / float(num_segs)
                        var sag0 = 0.48 * 4.0 * t0 * (1.0 - t0)
                        var sag1 = 0.48 * 4.0 * t1 * (1.0 - t1)
                        var v0 = p_start.lerp(p_end, t0) - Vector3(0.0, sag0, 0.0)
                        var v1 = p_start.lerp(p_end, t1) - Vector3(0.0, sag1, 0.0)
                        
                        var seg_mesh = MeshInstance3D.new()
                        var seg_box = BoxMesh.new()
                        var seg_len = v0.distance_to(v1)
                        seg_box.size = Vector3(0.025, 0.025, seg_len)
                        seg_box.material = telegraph_cable_material
                        seg_mesh.mesh = seg_box
                        
                        var diff = v1 - v0
                        if diff.length_squared() > 0.0001:
                            var fwd = diff.normalized()
                            var up_v = Vector3.UP if abs(fwd.y) < 0.9 else Vector3.RIGHT
                            var r_v = up_v.cross(fwd).normalized()
                            var u_v = fwd.cross(r_v).normalized()
                            seg_mesh.transform.basis = Basis(r_v, u_v, fwd)
                        seg_mesh.position = (v0 + v1) * 0.5
                        cable_node.add_child(seg_mesh)
                        
                    root.add_child(cable_node)
                    
        last_telegraph_pole_pos = curr_world_pole

func spawn_rally_spectators_and_banners(root: Node3D, points: Array, start_z: float, is_hairpin: bool):
    var num_pts = points.size()
    var b_info = get_biome_at(start_z)
    var is_village = b_info.get("has_village", false)
    var is_bridge = b_info.get("has_bridge", false)
    
    if is_village or is_bridge:
        return
        
    # 1. Striscioni Sponsor d'Epoca sui Guardrail (Art of Rally trackside dressing)
    if is_hairpin or (int(start_z) % 240 == 120):
        var banner_indices = [int(num_pts * 0.3), int(num_pts * 0.7)]
        for b_idx in banner_indices:
            var p = points[b_idx]
            var p_next = points[min(b_idx + 1, num_pts - 1)]
            var r_angle = atan2(p_next.x - p.x, p_next.z - p.z)
            var hw = p.width * 0.5
            var wall_side = 1.0 if (p_next.x - p.x) >= 0.0 else -1.0
            
            var sponsor_type = (int(p.z * 0.05) + b_idx) % 3
            var banner_node = create_rally_banner(sponsor_type)
            banner_node.position = Vector3(p.x + wall_side * (hw + 0.36), p.y + 0.52, p.z)
            banner_node.rotation.y = r_angle
            root.add_child(banner_node)
            
    # 2. Gruppi di Spettatori con Giubbotti Anni '80/'90 (Art of Rally atmosphere)
    # Always spawn in hairpin chunks and frequent in open countryside
    if is_hairpin or start_z >= 100.0:
        var spec_idx = int(num_pts * (0.45 if is_hairpin else 0.60))
        var sp = points[spec_idx]
        var sp_next = points[min(spec_idx + 1, num_pts - 1)]
        var hw = sp.width * 0.5
        
        var s_side = -1.0 if (sp_next.x - sp.x) >= 0.0 else 1.0
        if is_hairpin:
            s_side = -s_side
        var s_dist = s_side * (hw + 5.5)
        var s_y = get_terrain_elevation(sp.y, sp.z, s_dist, false)
        var spec_pos = Vector3(sp.x + s_dist, s_y, sp.z)
        
        var rot_to_road = atan2(-s_dist, 0.0) + (PI * 0.5 if s_side > 0 else -PI * 0.5)
        var crowd = create_rally_spectator_group(spec_pos, rot_to_road)
        crowd.name = "RallySpectators"
        root.add_child(crowd)
        print("[RALLY CROWD SPAWNED] at Z=%.1f, node name=%s" % [sp.z, crowd.name])

func create_rally_banner(sponsor_type: int) -> Node3D:
    var banner = Node3D.new()
    banner.name = "RallyBanner"
    
    var base_mat = rally_banner_martini
    if sponsor_type == 1:
        base_mat = rally_banner_agip
    elif sponsor_type == 2:
        base_mat = rally_banner_pirelli
        
    var canvas_mesh = MeshInstance3D.new()
    var c_box = BoxMesh.new()
    c_box.size = Vector3(0.04, 0.55, 3.2)
    c_box.material = base_mat
    canvas_mesh.mesh = c_box
    canvas_mesh.position.y = 0.0
    canvas_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
    banner.add_child(canvas_mesh)
    
    if sponsor_type == 0:
        # Martini Racing: Blue & Red horizontal racing stripe
        var stripe_mesh = MeshInstance3D.new()
        var s_box = BoxMesh.new()
        s_box.size = Vector3(0.045, 0.16, 3.1)
        s_box.material = spectator_jacket_blue
        stripe_mesh.mesh = s_box
        banner.add_child(stripe_mesh)
        
        var red_stripe = MeshInstance3D.new()
        var rs_box = BoxMesh.new()
        rs_box.size = Vector3(0.048, 0.05, 3.1)
        rs_box.material = spectator_jacket_red
        red_stripe.mesh = rs_box
        banner.add_child(red_stripe)
    elif sponsor_type == 1:
        # Agip Sint 2000: Dark banner stripe and red logo badge
        var agip_bar = MeshInstance3D.new()
        var ab_box = BoxMesh.new()
        ab_box.size = Vector3(0.045, 0.14, 2.9)
        ab_box.material = iron_dark_material
        agip_bar.mesh = ab_box
        banner.add_child(agip_bar)
        
        var agip_flame = MeshInstance3D.new()
        var af_box = BoxMesh.new()
        af_box.size = Vector3(0.048, 0.10, 0.35)
        af_box.material = spectator_jacket_red
        agip_flame.mesh = af_box
        agip_flame.position = Vector3(0.0, 0.0, -1.1)
        banner.add_child(agip_flame)
    elif sponsor_type == 2:
        # Pirelli P7: Yellow graphic band
        var pir_bar = MeshInstance3D.new()
        var pb_box = BoxMesh.new()
        pb_box.size = Vector3(0.045, 0.12, 2.9)
        pb_box.material = spectator_jacket_yellow
        pir_bar.mesh = pb_box
        banner.add_child(pir_bar)
        
    for z_off in [-1.45, -0.5, 0.5, 1.45]:
        var tie = MeshInstance3D.new()
        var t_box = BoxMesh.new()
        t_box.size = Vector3(0.05, 0.62, 0.03)
        t_box.material = iron_dark_material
        tie.mesh = t_box
        tie.position = Vector3(0.0, 0.0, z_off)
        banner.add_child(tie)
        
    return banner

func create_rally_spectator_group(pos: Vector3, rot_y: float) -> Node3D:
    var group = Node3D.new()
    group.name = "RallySpectators"
    group.position = pos
    group.rotation.y = rot_y
    
    var configs = [
        { "x": -0.85, "z": -0.3, "jacket_mat": spectator_jacket_yellow, "pose": "cheer", "beanie": spectator_jacket_red },
        { "x": 0.0, "z": 0.0, "jacket_mat": spectator_jacket_red, "pose": "photo", "beanie": iron_dark_material },
        { "x": 0.85, "z": -0.2, "jacket_mat": spectator_jacket_blue, "pose": "watch", "beanie": spectator_jacket_yellow },
        { "x": 1.65, "z": 0.4, "jacket_mat": spectator_jacket_green, "pose": "sit", "beanie": spectator_jacket_red }
    ]
    
    for cfg in configs:
        var p_node = Node3D.new()
        p_node.position = Vector3(cfg.x, 0.0, cfg.z)
        
        var is_sit = cfg.pose == "sit"
        var leg_h = 0.45 if is_sit else 0.85
        var hip_y = leg_h
        
        if is_sit:
            var cooler = MeshInstance3D.new()
            var c_box = BoxMesh.new()
            c_box.size = Vector3(0.42, 0.42, 0.35)
            c_box.material = spectator_jacket_blue
            cooler.mesh = c_box
            cooler.position.y = 0.21
            p_node.add_child(cooler)
            
            var lid = MeshInstance3D.new()
            var l_box = BoxMesh.new()
            l_box.size = Vector3(0.44, 0.06, 0.37)
            l_box.material = laundry_white_material
            lid.mesh = l_box
            lid.position.y = 0.44
            p_node.add_child(lid)
            
        for lx in [-0.10, 0.10]:
            var leg = MeshInstance3D.new()
            var l_box = BoxMesh.new()
            l_box.size = Vector3(0.12, leg_h, 0.14)
            l_box.material = spectator_jeans_material
            leg.mesh = l_box
            leg.position = Vector3(lx, leg_h * 0.5, 0.0 if not is_sit else 0.12)
            p_node.add_child(leg)
            
        var torso = MeshInstance3D.new()
        var t_box = BoxMesh.new()
        t_box.size = Vector3(0.38, 0.54, 0.26)
        t_box.material = cfg.jacket_mat
        torso.mesh = t_box
        torso.position.y = hip_y + 0.27
        torso.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
        p_node.add_child(torso)
        
        var head = MeshInstance3D.new()
        var h_sph = SphereMesh.new()
        h_sph.radius = 0.11
        h_sph.height = 0.22
        h_sph.material = spectator_skin_material
        head.mesh = h_sph
        head.position.y = hip_y + 0.65
        p_node.add_child(head)
        
        var beanie = MeshInstance3D.new()
        var b_sph = SphereMesh.new()
        b_sph.radius = 0.12
        b_sph.height = 0.14
        b_sph.material = cfg.beanie
        beanie.mesh = b_sph
        beanie.position.y = hip_y + 0.72
        p_node.add_child(beanie)
        
        if cfg.pose == "cheer":
            for ax in [-0.25, 0.25]:
                var arm = MeshInstance3D.new()
                var a_box = BoxMesh.new()
                a_box.size = Vector3(0.09, 0.45, 0.09)
                a_box.material = cfg.jacket_mat
                arm.mesh = a_box
                arm.position = Vector3(ax, hip_y + 0.52, 0.0)
                arm.rotation.z = -sign(ax) * 0.45
                p_node.add_child(arm)
        elif cfg.pose == "photo":
            var cam = MeshInstance3D.new()
            var cb_box = BoxMesh.new()
            cb_box.size = Vector3(0.20, 0.12, 0.14)
            cb_box.material = iron_dark_material
            cam.mesh = cb_box
            cam.position = Vector3(0.0, hip_y + 0.58, -0.22)
            p_node.add_child(cam)
            
            var lens = MeshInstance3D.new()
            var l_cyl = CylinderMesh.new()
            l_cyl.top_radius = 0.05
            l_cyl.bottom_radius = 0.05
            l_cyl.height = 0.10
            l_cyl.material = spectator_camera_material
            lens.mesh = l_cyl
            lens.rotation.x = deg_to_rad(90.0)
            lens.position = Vector3(0.0, hip_y + 0.58, -0.32)
            p_node.add_child(lens)
            
            var flash = OmniLight3D.new()
            flash.light_color = Color(0.92, 0.96, 1.0)
            flash.light_energy = 1.8
            flash.omni_range = 4.5
            flash.position = Vector3(0.0, hip_y + 0.62, -0.36)
            p_node.add_child(flash)
        else:
            for ax in [-0.24, 0.24]:
                var arm = MeshInstance3D.new()
                var a_box = BoxMesh.new()
                a_box.size = Vector3(0.09, 0.42, 0.09)
                a_box.material = cfg.jacket_mat
                arm.mesh = a_box
                arm.position = Vector3(ax, hip_y + 0.26, 0.0)
                p_node.add_child(arm)
                
        group.add_child(p_node)
        
    return group

func create_chimney_smoke(pos: Vector3) -> Node3D:
    var smoke = Node3D.new()
    smoke.name = "ChimneySmoke"
    smoke.position = pos
    
    var puffs = [
        { "y": 0.25, "rad": 0.20, "x_drift": 0.04, "z_drift": 0.03 },
        { "y": 0.70, "rad": 0.32, "x_drift": 0.12, "z_drift": 0.09 },
        { "y": 1.35, "rad": 0.48, "x_drift": 0.26, "z_drift": 0.18 },
        { "y": 2.20, "rad": 0.68, "x_drift": 0.48, "z_drift": 0.32 },
        { "y": 3.30, "rad": 0.92, "x_drift": 0.78, "z_drift": 0.52 }
    ]
    
    for p in puffs:
        var sphere = MeshInstance3D.new()
        var s_mesh = SphereMesh.new()
        s_mesh.radius = p.rad
        s_mesh.height = p.rad * 1.8
        s_mesh.radial_segments = 8
        s_mesh.rings = 5
        s_mesh.material = chimney_smoke_material
        sphere.mesh = s_mesh
        sphere.position = Vector3(p.x_drift, p.y, p.z_drift)
        smoke.add_child(sphere)
        
    return smoke

func create_stacked_barrels_and_crates(pos: Vector3, rot_y: float) -> Node3D:
    var clutter = Node3D.new()
    clutter.name = "BarrelsAndCrates"
    clutter.position = pos
    clutter.rotation.y = rot_y
    
    for bx in [-0.42, 0.42]:
        var barrel = MeshInstance3D.new()
        var b_cyl = CylinderMesh.new()
        b_cyl.top_radius = 0.30
        b_cyl.bottom_radius = 0.30
        b_cyl.height = 0.88
        b_cyl.material = barrel_wood_material
        barrel.mesh = b_cyl
        barrel.position = Vector3(bx, 0.44, 0.0)
        barrel.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
        clutter.add_child(barrel)
        
        for hy in [-0.26, 0.26]:
            var hoop = MeshInstance3D.new()
            var h_cyl = CylinderMesh.new()
            h_cyl.top_radius = 0.315
            h_cyl.bottom_radius = 0.315
            h_cyl.height = 0.06
            h_cyl.material = iron_dark_material
            hoop.mesh = h_cyl
            hoop.position = Vector3(bx, 0.44 + hy, 0.0)
            clutter.add_child(hoop)
            
    var top_bar = MeshInstance3D.new()
    var tb_cyl = CylinderMesh.new()
    tb_cyl.top_radius = 0.28
    tb_cyl.bottom_radius = 0.28
    tb_cyl.height = 0.82
    tb_cyl.material = barrel_wood_material
    top_bar.mesh = tb_cyl
    top_bar.rotation.z = deg_to_rad(90.0)
    top_bar.position = Vector3(0.0, 1.15, 0.0)
    top_bar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
    clutter.add_child(top_bar)
    
    for thx in [-0.22, 0.22]:
        var thoop = MeshInstance3D.new()
        var th_cyl = CylinderMesh.new()
        th_cyl.top_radius = 0.295
        th_cyl.bottom_radius = 0.295
        th_cyl.height = 0.05
        th_cyl.material = iron_dark_material
        thoop.mesh = th_cyl
        thoop.rotation.z = deg_to_rad(90.0)
        thoop.position = Vector3(thx, 1.15, 0.0)
        clutter.add_child(thoop)
        
    for cy in [0.16, 0.48]:
        var crate = MeshInstance3D.new()
        var c_box = BoxMesh.new()
        c_box.size = Vector3(0.55, 0.30, 0.40)
        c_box.material = chalet_timber_material
        crate.mesh = c_box
        crate.position = Vector3(1.05, cy, 0.08 if cy > 0.2 else 0.0)
        crate.rotation.y = 0.12 if cy > 0.2 else -0.05
        crate.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
        clutter.add_child(crate)
        
    return clutter

func create_vintage_bicycle(pos: Vector3, rot_y: float, lean_deg: float = 7.5) -> Node3D:
    var bike = Node3D.new()
    bike.name = "VintageBicycle"
    bike.position = pos
    bike.rotation.y = rot_y
    bike.rotation.z = deg_to_rad(lean_deg)
    
    for wz in [-0.55, 0.55]:
        var wheel = MeshInstance3D.new()
        var w_cyl = CylinderMesh.new()
        w_cyl.top_radius = 0.33
        w_cyl.bottom_radius = 0.33
        w_cyl.height = 0.04
        w_cyl.material = iron_dark_material
        wheel.mesh = w_cyl
        wheel.rotation.x = deg_to_rad(90.0)
        wheel.position = Vector3(0.0, 0.33, wz)
        bike.add_child(wheel)
        
        var hub = MeshInstance3D.new()
        var h_cyl = CylinderMesh.new()
        h_cyl.top_radius = 0.06
        h_cyl.bottom_radius = 0.06
        h_cyl.height = 0.06
        h_cyl.material = mirror_chrome_material
        hub.mesh = h_cyl
        hub.rotation.x = deg_to_rad(90.0)
        hub.position = Vector3(0.0, 0.33, wz)
        bike.add_child(hub)
        
    var top_tube = MeshInstance3D.new()
    var tt_box = BoxMesh.new()
    tt_box.size = Vector3(0.04, 0.04, 0.65)
    tt_box.material = bicycle_frame_material
    top_tube.mesh = tt_box
    top_tube.position = Vector3(0.0, 0.68, 0.0)
    bike.add_child(top_tube)
    
    var down_tube = MeshInstance3D.new()
    var dt_box = BoxMesh.new()
    dt_box.size = Vector3(0.04, 0.04, 0.68)
    dt_box.material = bicycle_frame_material
    down_tube.mesh = dt_box
    down_tube.position = Vector3(0.0, 0.50, 0.12)
    down_tube.rotation.x = deg_to_rad(32.0)
    bike.add_child(down_tube)
    
    var seat_tube = MeshInstance3D.new()
    var st_box = BoxMesh.new()
    st_box.size = Vector3(0.04, 0.45, 0.04)
    st_box.material = bicycle_frame_material
    seat_tube.mesh = st_box
    seat_tube.position = Vector3(0.0, 0.52, -0.22)
    bike.add_child(seat_tube)
    
    var saddle = MeshInstance3D.new()
    var sd_box = BoxMesh.new()
    sd_box.size = Vector3(0.16, 0.06, 0.24)
    sd_box.material = chalet_timber_material
    saddle.mesh = sd_box
    saddle.position = Vector3(0.0, 0.77, -0.22)
    bike.add_child(saddle)
    
    var bar = MeshInstance3D.new()
    var b_box = BoxMesh.new()
    b_box.size = Vector3(0.42, 0.04, 0.08)
    b_box.material = mirror_chrome_material
    bar.mesh = b_box
    bar.position = Vector3(0.0, 0.82, 0.48)
    bike.add_child(bar)
    
    var basket = MeshInstance3D.new()
    var bs_box = BoxMesh.new()
    bs_box.size = Vector3(0.32, 0.22, 0.24)
    bs_box.material = straw_bale_material
    basket.mesh = bs_box
    basket.position = Vector3(0.0, 0.76, 0.62)
    bike.add_child(basket)
    
    return bike

func create_laundry_clothesline(pos_a: Vector3, pos_b: Vector3) -> Node3D:
    var line_node = Node3D.new()
    line_node.name = "LaundryClothesline"
    
    var num_segs = 4
    for k in range(num_segs):
        var t0 = float(k) / float(num_segs)
        var t1 = float(k + 1) / float(num_segs)
        var sag0 = 0.32 * 4.0 * t0 * (1.0 - t0)
        var sag1 = 0.32 * 4.0 * t1 * (1.0 - t1)
        var v0 = pos_a.lerp(pos_b, t0) - Vector3(0.0, sag0, 0.0)
        var v1 = pos_a.lerp(pos_b, t1) - Vector3(0.0, sag1, 0.0)
        
        var cord = MeshInstance3D.new()
        var c_box = BoxMesh.new()
        c_box.size = Vector3(0.02, 0.02, v0.distance_to(v1))
        c_box.material = telegraph_cable_material
        cord.mesh = c_box
        var diff = v1 - v0
        if diff.length_squared() > 0.0001:
            var fwd = diff.normalized()
            var up_v = Vector3.UP if abs(fwd.y) < 0.9 else Vector3.RIGHT
            var r_v = up_v.cross(fwd).normalized()
            var u_v = fwd.cross(r_v).normalized()
            cord.transform.basis = Basis(r_v, u_v, fwd)
        cord.position = (v0 + v1) * 0.5
        line_node.add_child(cord)
        
    var garments = [
        { "t": 0.25, "mat": laundry_white_material, "w": 0.85, "h": 0.95, "tilt": 0.08 },
        { "t": 0.52, "mat": laundry_red_material, "w": 0.55, "h": 0.65, "tilt": -0.12 },
        { "t": 0.78, "mat": laundry_blue_material, "w": 0.45, "h": 0.85, "tilt": 0.15 }
    ]
    
    for g in garments:
        var sag = 0.32 * 4.0 * g.t * (1.0 - g.t)
        var g_pos = pos_a.lerp(pos_b, g.t) - Vector3(0.0, sag, 0.0)
        
        var cloth = MeshInstance3D.new()
        var cl_box = BoxMesh.new()
        cl_box.size = Vector3(g.w, g.h, 0.02)
        cl_box.material = g.mat
        cloth.mesh = cl_box
        cloth.position = g_pos - Vector3(0.0, g.h * 0.5, 0.0)
        cloth.rotation.y = atan2(pos_b.x - pos_a.x, pos_b.z - pos_a.z) + PI * 0.5
        cloth.rotation.z = g.tilt
        cloth.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
        line_node.add_child(cloth)
        
        for cx in [-g.w * 0.35, g.w * 0.35]:
            var pin = MeshInstance3D.new()
            var p_box = BoxMesh.new()
            p_box.size = Vector3(0.03, 0.08, 0.04)
            p_box.material = chalet_timber_material
            pin.mesh = p_box
            pin.position = g_pos + Vector3(0.0, 0.02, 0.0)
            line_node.add_child(pin)
            
    return line_node

func create_firewood_log_stack(pos: Vector3, rot_y: float) -> Node3D:
    var shelter = Node3D.new()
    shelter.name = "FirewoodShelter"
    shelter.position = pos
    shelter.rotation.y = rot_y
    
    var roof = MeshInstance3D.new()
    var r_box = BoxMesh.new()
    r_box.size = Vector3(2.2, 0.08, 1.4)
    r_box.material = chalet_roof_material
    roof.mesh = r_box
    roof.position = Vector3(0.0, 1.75, 0.0)
    roof.rotation.x = deg_to_rad(15.0)
    shelter.add_child(roof)
    
    for px in [-0.95, 0.95]:
        for pz in [-0.5, 0.5]:
            var post = MeshInstance3D.new()
            var p_cyl = CylinderMesh.new()
            p_cyl.top_radius = 0.06
            p_cyl.bottom_radius = 0.06
            p_cyl.height = 1.7
            p_cyl.material = chalet_timber_material
            post.mesh = p_cyl
            post.position = Vector3(px, 0.85, pz)
            shelter.add_child(post)
            
    for tier in range(3):
        var ty = 0.22 + float(tier) * 0.35
        var num_logs = 5 - (tier % 2)
        var x_start = -0.75 + (0.15 if (tier % 2 == 1) else 0.0)
        for li in range(num_logs):
            var lx = x_start + float(li) * 0.34
            var log_mesh = MeshInstance3D.new()
            var l_cyl = CylinderMesh.new()
            l_cyl.top_radius = 0.14
            l_cyl.bottom_radius = 0.14
            l_cyl.height = 0.95
            l_cyl.material = chalet_timber_material
            log_mesh.mesh = l_cyl
            log_mesh.rotation.x = deg_to_rad(90.0)
            log_mesh.position = Vector3(lx, ty, 0.0)
            log_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
            shelter.add_child(log_mesh)
            
    var stump = MeshInstance3D.new()
    var s_cyl = CylinderMesh.new()
    s_cyl.top_radius = 0.26
    s_cyl.bottom_radius = 0.29
    s_cyl.height = 0.55
    s_cyl.material = chalet_timber_material
    stump.mesh = s_cyl
    stump.position = Vector3(1.5, 0.275, 0.2)
    stump.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
    shelter.add_child(stump)
    
    var axe_head = MeshInstance3D.new()
    var a_box = BoxMesh.new()
    a_box.size = Vector3(0.04, 0.16, 0.24)
    a_box.material = iron_dark_material
    axe_head.mesh = a_box
    axe_head.position = Vector3(1.5, 0.58, 0.2)
    shelter.add_child(axe_head)
    
    var axe_handle = MeshInstance3D.new()
    var ah_cyl = CylinderMesh.new()
    ah_cyl.top_radius = 0.02
    ah_cyl.bottom_radius = 0.025
    ah_cyl.height = 0.72
    ah_cyl.material = cart_wood_material if cart_wood_material else chalet_timber_material
    axe_handle.mesh = ah_cyl
    axe_handle.position = Vector3(1.5, 0.85, 0.38)
    axe_handle.rotation.x = deg_to_rad(-35.0)
    shelter.add_child(axe_handle)
    
    return shelter

func create_climbing_ivy(pos: Vector3) -> Node3D:
    var ivy = Node3D.new()
    ivy.name = "ClimbingIvy"
    ivy.position = pos
    
    for leaf_i in range(5):
        var leaf = MeshInstance3D.new()
        var l_box = BoxMesh.new()
        l_box.size = Vector3(0.35 + randf() * 0.2, 0.40 + randf() * 0.25, 0.06)
        l_box.material = ivy_leaf_material
        leaf.mesh = l_box
        leaf.position = Vector3(randf_range(-0.3, 0.3), float(leaf_i) * 0.45, randf_range(-0.3, 0.3))
        leaf.rotation.y = randf_range(-0.4, 0.4)
        ivy.add_child(leaf)
        
    return ivy

func spawn_alpine_chalet(root: Node3D, pos: Vector3, rot_y: float):
    var chalet = Node3D.new()
    chalet.position = pos
    chalet.rotation.y = rot_y
    
    # 1. Foundation Plinth (anchors deep into slope)
    var base_mesh = MeshInstance3D.new()
    var base_box = BoxMesh.new()
    base_box.size = Vector3(5.6, 3.4, 6.6)
    base_box.material = rock_material
    base_mesh.mesh = base_box
    base_mesh.position.y = 0.5
    chalet.add_child(base_mesh)
    
    # 2. Alpine Timber Cabin
    var cabin_mesh = MeshInstance3D.new()
    var cabin_box = BoxMesh.new()
    cabin_box.size = Vector3(5.0, 2.6, 6.0)
    cabin_box.material = chalet_timber_material
    cabin_mesh.mesh = cabin_box
    cabin_mesh.position.y = 2.7
    chalet.add_child(cabin_mesh)
    
    # 3. Pitched Slate/Wooden Shingle Roof
    var roof_mesh = MeshInstance3D.new()
    var roof_prism = PrismMesh.new()
    roof_prism.size = Vector3(6.2, 2.5, 7.2)
    roof_prism.material = chalet_roof_material
    roof_mesh.mesh = roof_prism
    roof_mesh.position.y = 5.25
    chalet.add_child(roof_mesh)
    
    # 4. Cozy Glowing Windows (with warm amber emission)
    for wx in [-1.4, 1.4]:
        var win_f = MeshInstance3D.new()
        var win_box = BoxMesh.new()
        win_box.size = Vector3(0.95, 0.95, 0.08)
        win_box.material = chalet_window_material
        win_f.mesh = win_box
        win_f.position = Vector3(wx, 2.8, -3.02)
        chalet.add_child(win_f)
        
    var win_s = MeshInstance3D.new()
    var win_s_box = BoxMesh.new()
    win_s_box.size = Vector3(0.08, 0.95, 0.95)
    win_s_box.material = chalet_window_material
    win_s.mesh = win_s_box
    win_s.position = Vector3(2.52, 2.8, 0.0)
    chalet.add_child(win_s)
    
    # 5. Stone Chimney with Soft Stylized Volumetric Smoke (Tiny Glade style)
    var chim = MeshInstance3D.new()
    var chim_box = BoxMesh.new()
    chim_box.size = Vector3(0.68, 2.2, 0.68)
    chim_box.material = rock_material
    chim.mesh = chim_box
    chim.position = Vector3(1.5, 5.4, 1.2)
    chalet.add_child(chim)
    
    var smoke = create_chimney_smoke(Vector3(1.5, 6.6, 1.2))
    chalet.add_child(smoke)
    
    # 6. Warm Porch Glow Light
    var light = OmniLight3D.new()
    light.light_color = Color(1.0, 0.85, 0.50)
    light.light_energy = 1.6
    light.omni_range = 16.0
    light.position = Vector3(0.0, 2.8, -3.4)
    chalet.add_child(light)
    
    # 7. Tiny Glade Firewood Log Stack & Chopping Block with Axe
    var woodstack = create_firewood_log_stack(Vector3(-3.2, 0.4, -0.6), 0.0)
    chalet.add_child(woodstack)
    
    # 8. Stacked Rustic Barrels outside cellar
    var chalet_barrels = create_stacked_barrels_and_crates(Vector3(2.6, 0.4, -2.4), deg_to_rad(20.0))
    chalet.add_child(chalet_barrels)
    
    # 8. Rustic Pasture Fence (staccionata)
    for fx in [-4.0, 4.0]:
        var f_post = MeshInstance3D.new()
        var f_cyl = CylinderMesh.new()
        f_cyl.top_radius = 0.08; f_cyl.bottom_radius = 0.09; f_cyl.height = 1.2
        f_cyl.material = chalet_timber_material
        f_post.mesh = f_cyl
        f_post.position = Vector3(fx, 1.4, -4.0)
        chalet.add_child(f_post)
    var f_rail = MeshInstance3D.new()
    var r_box = BoxMesh.new()
    r_box.size = Vector3(8.0, 0.12, 0.12)
    r_box.material = chalet_timber_material
    f_rail.mesh = r_box
    f_rail.position = Vector3(0.0, 1.6, -4.0)
    chalet.add_child(f_rail)
    
    # Solid Chalet Building Collider
    var c_col = StaticBody3D.new()
    var c_shape = CollisionShape3D.new()
    var cb_box = BoxShape3D.new()
    cb_box.size = Vector3(5.6, 5.2, 6.6)
    c_shape.shape = cb_box
    c_shape.position.y = 2.6
    c_col.add_child(c_shape)
    chalet.add_child(c_col)
    
    root.add_child(chalet)

func spawn_drystone_wall(root: Node3D, p1: Vector3, p2: Vector3):
    var wall = MeshInstance3D.new()
    var box = BoxMesh.new()
    var delta_vec = p2 - p1
    var seg_len = delta_vec.length()
    box.size = Vector3(0.36, 0.72, seg_len * 1.04)
    box.material = drystone_material
    wall.mesh = box
    wall.position = (p1 + p2) * 0.5 + Vector3(0.0, 0.36, 0.0)
    wall.rotation.y = atan2(delta_vec.x, delta_vec.z)
    
    # Solid Drystone Wall Collider
    var w_col = StaticBody3D.new()
    var w_shape = CollisionShape3D.new()
    var wb_box = BoxShape3D.new()
    wb_box.size = Vector3(0.40, 0.85, seg_len * 1.04)
    w_shape.shape = wb_box
    w_col.add_child(w_shape)
    wall.add_child(w_col)
    
    root.add_child(wall)

func spawn_stylized_tree(root: Node3D, pos: Vector3, h_scale: float, is_larch: bool, is_deciduous: bool):
    var tree = Node3D.new()
    tree.position = pos
    var h = 4.8 * h_scale
    
    # Trunk - Extended deep into terrain with flared root collar (anti-sospensione nel vuoto)
    var trunk = MeshInstance3D.new()
    var t_cyl = CylinderMesh.new()
    t_cyl.top_radius = 0.11 * h_scale
    t_cyl.bottom_radius = 0.18 * h_scale
    t_cyl.height = h * 0.75
    t_cyl.material = chalet_timber_material
    trunk.mesh = t_cyl
    trunk.position.y = (t_cyl.height * 0.5) - 1.4 * h_scale # Starts 1.4m below ground anchor
    tree.add_child(trunk)
    
    # Flared base root collar firmly rooting tree into soil
    var flare = MeshInstance3D.new()
    var f_cyl = CylinderMesh.new()
    f_cyl.top_radius = 0.18 * h_scale
    f_cyl.bottom_radius = 0.38 * h_scale
    f_cyl.height = 0.60 * h_scale
    f_cyl.material = chalet_timber_material
    flare.mesh = f_cyl
    flare.position.y = 0.10 * h_scale
    tree.add_child(flare)
    
    # Solid Tree Trunk Collider
    var t_col = StaticBody3D.new()
    var t_shape = CollisionShape3D.new()
    var tc_cyl = CylinderShape3D.new()
    tc_cyl.radius = 0.35 * h_scale
    tc_cyl.height = h
    t_shape.shape = tc_cyl
    t_shape.position.y = h * 0.5
    t_col.add_child(t_shape)
    tree.add_child(t_col)
    
    var fol_mat = larch_material if is_larch else (bush_material if is_deciduous else pine_material)
    
    if is_deciduous:
        # Fluffy Cloud Canopy (Tiny Glade / Dorfromantik multi-lobe cluster)
        var lobes = [
            { "pos": Vector3(0.0, h * 0.68, 0.0), "r": 1.45 * h_scale, "h": 1.65 * h_scale },
            { "pos": Vector3(0.70 * h_scale, h * 0.58, 0.40 * h_scale), "r": 1.15 * h_scale, "h": 1.30 * h_scale },
            { "pos": Vector3(-0.65 * h_scale, h * 0.60, 0.45 * h_scale), "r": 1.10 * h_scale, "h": 1.25 * h_scale },
            { "pos": Vector3(0.20 * h_scale, h * 0.62, -0.70 * h_scale), "r": 1.20 * h_scale, "h": 1.35 * h_scale },
            { "pos": Vector3(0.0, h * 0.88, 0.0), "r": 0.98 * h_scale, "h": 1.15 * h_scale }
        ]
        for lb in lobes:
            var sphere = MeshInstance3D.new()
            var s_mesh = SphereMesh.new()
            s_mesh.radius = lb.r
            s_mesh.height = lb.h
            s_mesh.radial_segments = 10
            s_mesh.rings = 6
            s_mesh.material = fol_mat
            sphere.mesh = s_mesh
            sphere.position = lb.pos
            tree.add_child(sphere)
    else:
        # Sculpted Faceted Conifer Tiers (Art of Rally iconic polygonal fir trees with crisp facet normals & baked AO)
        var tiers = [
            { "r": 2.35 * h_scale, "h": 1.70 * h_scale, "y": h * 0.32 },
            { "r": 1.85 * h_scale, "h": 1.60 * h_scale, "y": h * 0.50 },
            { "r": 1.30 * h_scale, "h": 1.50 * h_scale, "y": h * 0.68 },
            { "r": 0.75 * h_scale, "h": 1.35 * h_scale, "y": h * 0.85 }
        ]
        for t_idx in range(tiers.size()):
            var t = tiers[t_idx]
            var rot_offset = float(t_idx) * 0.58 + (pos.x * 0.1)
            var tier_mesh = create_faceted_conifer_tier(t.r, t.h, 7, rot_offset, fol_mat)
            tier_mesh.position.y = t.y
            tree.add_child(tier_mesh)
            
    root.add_child(tree)

func create_faceted_conifer_tier(r: float, h: float, segs: int, rot_offset: float, mat: Material) -> MeshInstance3D:
    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    
    var apex = Vector3(0.0, h, 0.0)
    var base_center = Vector3(0.0, 0.0, 0.0)
    var pts: Array = []
    
    # Generate scalloped base perimeter vertices
    for s in range(segs):
        var ang = float(s) * (TAU / float(segs)) + rot_offset
        var branch_dip = -0.10 * h if (s % 2 == 0) else 0.04 * h
        pts.append(Vector3(cos(ang) * r, branch_dip, sin(ang) * r))
        
    for s in range(segs):
        var s_next = (s + 1) % segs
        var p1 = pts[s]
        var p2 = pts[s_next]
        
        # Cone side facet with flat-shaded normal
        var norm = (p1 - apex).cross(p2 - apex).normalized()
        if norm.length_squared() < 0.001:
            norm = Vector3.UP
            
        st.set_color(Color(0.92, 0.98, 0.88))
        st.set_normal(norm)
        st.add_vertex(apex)
        
        st.set_color(Color(0.24, 0.32, 0.22))
        st.set_normal(norm)
        st.add_vertex(p1)
        
        st.set_color(Color(0.24, 0.32, 0.22))
        st.set_normal(norm)
        st.add_vertex(p2)
        
        # Underside base cap (dark contact AO)
        var under_norm = Vector3.DOWN
        st.set_color(Color(0.08, 0.10, 0.08))
        st.set_normal(under_norm)
        st.add_vertex(base_center)
        st.set_normal(under_norm)
        st.add_vertex(p2)
        st.set_normal(under_norm)
        st.add_vertex(p1)
        
    var m_inst = MeshInstance3D.new()
    m_inst.mesh = st.commit()
    m_inst.material_override = mat
    return m_inst

func create_faceted_boulder_mesh(rock_r: float, seed_val: float) -> ArrayMesh:
    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    
    var num_pts = 7
    var top_apex = Vector3(
        sin(seed_val * 3.1) * rock_r * 0.22,
        rock_r * (1.1 + cos(seed_val * 1.9) * 0.22),
        cos(seed_val * 4.3) * rock_r * 0.22
    )
    var bottom_apex = Vector3(0.0, -rock_r * 0.35, 0.0)
    
    var rim: Array = []
    for i in range(num_pts):
        var ang = float(i) * (TAU / float(num_pts))
        var r_var = rock_r * (0.85 + sin(seed_val * 2.0 + float(i) * 1.7) * 0.26)
        var y_var = rock_r * (0.20 + cos(seed_val * 3.5 + float(i) * 2.1) * 0.22)
        rim.append(Vector3(cos(ang) * r_var, y_var, sin(ang) * r_var))
        
    for i in range(num_pts):
        var next_i = (i + 1) % num_pts
        # Upper facet (mossy / sunlit) - Winding order top_apex -> rim[next_i] -> rim[i] yields outward-facing normal
        add_tri_flat(st, top_apex, rim[next_i], rim[i])
        # Lower skirt facet (buried / shadow) - Winding order bottom_apex -> rim[i] -> rim[next_i] yields outward-facing normal
        add_tri_flat(st, bottom_apex, rim[i], rim[next_i])
        
    return st.commit()

func spawn_alpine_signpost(root: Node3D, pos: Vector3, rot_y: float, text_label: String):
    var sign_group = Node3D.new()
    sign_group.position = pos
    sign_group.rotation.y = rot_y
    
    # Dual carved timber posts
    for px in [-0.85, 0.85]:
        var post = MeshInstance3D.new()
        var post_cyl = CylinderMesh.new()
        post_cyl.top_radius = 0.08; post_cyl.bottom_radius = 0.09; post_cyl.height = 2.4
        post_cyl.material = sign_wood_material
        post.mesh = post_cyl
        post.position = Vector3(px, 1.2, 0.0)
        sign_group.add_child(post)
    
    # Dark timber backing board
    var back_board = MeshInstance3D.new()
    var bb_box = BoxMesh.new()
    bb_box.size = Vector3(2.5, 0.85, 0.12)
    bb_box.material = chalet_timber_material
    back_board.mesh = bb_box
    back_board.position = Vector3(0.0, 1.75, 0.0)
    sign_group.add_child(back_board)
    
    # Cream metal plate inset
    var board = MeshInstance3D.new()
    var b_box = BoxMesh.new()
    b_box.size = Vector3(2.35, 0.70, 0.06)
    b_box.material = sign_plate_material
    board.mesh = b_box
    board.position = Vector3(0.0, 1.75, 0.04)
    sign_group.add_child(board)
    
    # Yellow retro Italian priority diamond below
    var diamond = MeshInstance3D.new()
    var d_box = BoxMesh.new()
    d_box.size = Vector3(0.50, 0.50, 0.06)
    var d_mat = StandardMaterial3D.new()
    d_mat.albedo_color = Color(0.96, 0.78, 0.12)
    diamond.mesh = d_box
    diamond.material_override = d_mat
    diamond.position = Vector3(0.0, 0.95, 0.04)
    diamond.rotation.z = PI * 0.25 # diamond angle
    sign_group.add_child(diamond)
    
    root.add_child(sign_group)

func create_sos_call_pillar(pos: Vector3, rot_y: float) -> Node3D:
    var pillar = Node3D.new()
    pillar.position = pos
    pillar.rotation.y = rot_y
    
    # Colonna metallica arancione Anas (RAL 2004 Arancio Puro)
    var col_mesh = MeshInstance3D.new()
    var b = BoxMesh.new()
    b.size = Vector3(0.42, 1.65, 0.32)
    var sos_mat = StandardMaterial3D.new()
    sos_mat.albedo_color = Color(0.98, 0.42, 0.05) # Arancione Anas di soccorso
    sos_mat.roughness = 0.35
    col_mesh.mesh = b
    col_mesh.material_override = sos_mat
    col_mesh.position.y = 0.825
    pillar.add_child(col_mesh)
    
    # Vano cornetta telefonica nero incassato
    var recess = MeshInstance3D.new()
    var rb = BoxMesh.new()
    rb.size = Vector3(0.30, 0.50, 0.12)
    var r_mat = StandardMaterial3D.new()
    r_mat.albedo_color = Color(0.12, 0.12, 0.14)
    recess.mesh = rb
    recess.material_override = r_mat
    recess.position = Vector3(0.0, 1.05, -0.12)
    pillar.add_child(recess)
    
    # Pannello fotovoltaico inclinato sulla sommita'
    var panel = MeshInstance3D.new()
    var pb = BoxMesh.new()
    pb.size = Vector3(0.36, 0.04, 0.36)
    var p_mat = StandardMaterial3D.new()
    p_mat.albedo_color = Color(0.10, 0.18, 0.32)
    p_mat.metallic = 0.80
    p_mat.roughness = 0.15
    panel.mesh = pb
    panel.material_override = p_mat
    panel.position = Vector3(0.0, 1.70, 0.0)
    panel.rotation.x = deg_to_rad(25.0)
    pillar.add_child(panel)
    
    # Lampeggiante stroboscopico di emergenza (luce ambra/gialla in cima)
    var beacon = MeshInstance3D.new()
    var bc = CylinderMesh.new()
    bc.top_radius = 0.06; bc.bottom_radius = 0.07; bc.height = 0.12
    var b_mat = StandardMaterial3D.new()
    b_mat.albedo_color = Color(1.0, 0.70, 0.10)
    b_mat.emission_enabled = true
    b_mat.emission = Color(1.0, 0.65, 0.05)
    b_mat.emission_energy_multiplier = 2.0
    beacon.mesh = bc
    beacon.material_override = b_mat
    beacon.position = Vector3(0.0, 1.76, 0.0)
    pillar.add_child(beacon)
    
    # Scritta bianca "SOS" rifrangente
    var sos_sign = MeshInstance3D.new()
    var sb = BoxMesh.new()
    sb.size = Vector3(0.28, 0.12, 0.02)
    var smat = StandardMaterial3D.new()
    smat.albedo_color = Color(0.96, 0.96, 0.98)
    sos_sign.mesh = sb
    sos_sign.material_override = smat
    sos_sign.position = Vector3(0.0, 1.42, -0.16)
    pillar.add_child(sos_sign)
    
    # Solid Physical Collider
    var col_body = StaticBody3D.new()
    var col_shape = CollisionShape3D.new()
    var c_box = BoxShape3D.new()
    c_box.size = Vector3(0.45, 1.70, 0.35)
    col_shape.shape = c_box
    col_shape.position.y = 0.85
    col_body.add_child(col_shape)
    pillar.add_child(col_body)
    
    return pillar

func spawn_diorama_cloud_cluster(root: Node3D, pos: Vector3, is_storm: bool = false):
    var cloud_group = Node3D.new()
    cloud_group.position = pos
    
    var puff_data = [
        Vector3(0, 0, 0), Vector3(14, -2, 6), Vector3(-16, -1, -5),
        Vector3(7, 5, -9), Vector3(-7, 4, 8)
    ]
    for p_offset in puff_data:
        var puff = MeshInstance3D.new()
        var s = SphereMesh.new()
        var r = randf_range(11.0, 18.0)
        s.radius = r; s.height = r * 1.25
        s.radial_segments = 14; s.rings = 8
        s.material = storm_cloud_material if is_storm else cloud_material
        puff.mesh = s
        puff.position = p_offset
        puff.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
        cloud_group.add_child(puff)
        
    root.add_child(cloud_group)

func add_quad(st: SurfaceTool, col_faces: PackedVector3Array, a: Vector3, b: Vector3, c: Vector3, d: Vector3, u1: float, u2: float, v1: float, v2: float):
    st.set_uv(Vector2(u1, v1)); st.add_vertex(a)
    st.set_uv(Vector2(u2, v2)); st.add_vertex(c)
    st.set_uv(Vector2(u1, v2)); st.add_vertex(b)
    
    st.set_uv(Vector2(u1, v1)); st.add_vertex(a)
    st.set_uv(Vector2(u2, v1)); st.add_vertex(d)
    st.set_uv(Vector2(u2, v2)); st.add_vertex(c)

func add_quad_mesh_only(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, u1: float, u2: float, v1: float, v2: float):
    st.set_uv(Vector2(u1, v1)); st.add_vertex(a)
    st.set_uv(Vector2(u2, v2)); st.add_vertex(c)
    st.set_uv(Vector2(u1, v2)); st.add_vertex(b)
    
    st.set_uv(Vector2(u1, v1)); st.add_vertex(a)
    st.set_uv(Vector2(u2, v1)); st.add_vertex(d)
    st.set_uv(Vector2(u2, v2)); st.add_vertex(c)

func get_road_info_at(query_z: float) -> Dictionary:
    for chunk in active_chunks:
        if query_z >= chunk.start_z and query_z <= chunk.end_z:
            var pts = chunk.points
            var surface_type = chunk.get("surface_type", 0)
            var surface_name = chunk.get("surface_name", "ASFALTO ALPINO USURATO")
            var grip_mult = chunk.get("grip_mult", 1.0)
            for i in range(pts.size() - 1):
                if query_z >= pts[i].z and query_z <= pts[i + 1].z:
                    var t = (query_z - pts[i].z) / max(0.001, pts[i + 1].z - pts[i].z)
                    var x = lerp(pts[i].x, pts[i + 1].x, t)
                    var y = lerp(pts[i].y, pts[i + 1].y, t)
                    var width = lerp(pts[i].width, pts[i + 1].width, t)
                    var bank = lerp(pts[i].get("bank", 0.0), pts[i + 1].get("bank", 0.0), t)
                    var dx = pts[i + 1].x - pts[i].x
                    var dz = pts[i + 1].z - pts[i].z
                    var angle = atan2(dx, dz)
                    return { 
                        "x": x, 
                        "y": y, 
                        "width": width, 
                        "angle": angle, 
                        "bank": bank,
                        "surface_type": surface_type,
                        "surface_name": surface_name,
                        "grip_mult": grip_mult,
                        "found": true 
                    }
    return { 
        "x": 0.0, 
        "y": 0.0, 
        "width": base_width, 
        "angle": 0.0, 
        "bank": 0.0,
        "surface_type": 0,
        "surface_name": "ASFALTO ALPINO USURATO",
        "grip_mult": 1.0,
        "found": false 
    }

# =========================================================================
# 5. PONTI & VIADOTTI (Bridges & Viaducts)
# =========================================================================
func spawn_bridges(root: Node3D, points: Array, start_z: float):
    var num_pts = points.size()
    
    # 5a. PONTE DEI CICLOPI (Gola del Meridiano, Z in [1440, 1560])
    if start_z >= 1440.0 and start_z < 1560.0:
        var bridge_node = Node3D.new()
        
        # Deck substructure and monumental stone balustrades
        for i in range(num_pts - 1):
            var p1 = points[i]
            var p2 = points[i + 1]
            var hw1 = p1.width * 0.5
            var hw2 = p2.width * 0.5
            var delta_z = p2.z - p1.z
            var mid_z = (p1.z + p2.z) * 0.5
            var mid_y = (p1.y + p2.y) * 0.5
            var rot_y = atan2(p2.x - p1.x, delta_z)
            
            for side in [-1.0, 1.0]:
                var x1 = p1.x + side * (hw1 + 0.35)
                var x2 = p2.x + side * (hw2 + 0.35)
                var mid_x = (x1 + x2) * 0.5
                
                # Masonry parapet wall
                var parapet = MeshInstance3D.new()
                var p_box = BoxMesh.new()
                p_box.size = Vector3(0.50, 1.15, delta_z * 1.05)
                p_box.material = bridge_stone_material
                parapet.mesh = p_box
                parapet.position = Vector3(mid_x, mid_y + 0.58, mid_z)
                parapet.rotation.y = rot_y
                
                # Solid Bridge Parapet Barrier Collider
                var bp_col = StaticBody3D.new()
                var bp_shape = CollisionShape3D.new()
                var bp_box = BoxShape3D.new()
                bp_box.size = Vector3(0.55, 1.30, delta_z * 1.05)
                bp_shape.shape = bp_box
                bp_col.add_child(bp_shape)
                parapet.add_child(bp_col)
                
                bridge_node.add_child(parapet)
                
                # Top capstone moulding
                var cap = MeshInstance3D.new()
                var c_box = BoxMesh.new()
                c_box.size = Vector3(0.62, 0.16, delta_z * 1.05)
                c_box.material = cobblestone_material
                cap.mesh = c_box
                cap.position = Vector3(mid_x, mid_y + 1.18, mid_z)
                cap.rotation.y = rot_y
                bridge_node.add_child(cap)
                
                # Under-deck stone cantilever beam
                var beam = MeshInstance3D.new()
                var b_box = BoxMesh.new()
                b_box.size = Vector3(1.2, 1.4, delta_z * 1.05)
                b_box.material = bridge_stone_material
                beam.mesh = b_box
                beam.position = Vector3(mid_x - side * 0.25, mid_y - 0.70, mid_z)
                beam.rotation.y = rot_y
                bridge_node.add_child(beam)
                
                # Pilasters & Wrought-Iron Brass Lanterns every 4 segments
                if i % 4 == 0:
                    var pilaster = MeshInstance3D.new()
                    var pi_box = BoxMesh.new()
                    pi_box.size = Vector3(0.68, 1.4, 0.68)
                    pi_box.material = bridge_stone_material
                    pilaster.mesh = pi_box
                    pilaster.position = Vector3(x1, p1.y + 0.70, p1.z)
                    bridge_node.add_child(pilaster)
                    
                    var lantern = create_bridge_lantern(Vector3(x1, p1.y + 1.45, p1.z))
                    bridge_node.add_child(lantern)
                    
        # Monumental Pylons at bridge entry/exit
        var p_start = points[1]
        var p_end = points[num_pts - 2]
        for portal_p in [p_start, p_end]:
            for side in [-1.0, 1.0]:
                var obelisk = Node3D.new()
                var ob_mesh = MeshInstance3D.new()
                var ob_box = BoxMesh.new()
                ob_box.size = Vector3(1.2, 3.8, 1.2)
                ob_box.material = bridge_stone_material
                ob_mesh.mesh = ob_box
                ob_mesh.position.y = 1.9
                obelisk.add_child(ob_mesh)
                
                var ob_cap = MeshInstance3D.new()
                var cap_prism = PrismMesh.new()
                cap_prism.size = Vector3(1.4, 0.8, 1.4)
                cap_prism.material = cobblestone_material
                ob_cap.mesh = cap_prism
                ob_cap.position.y = 4.2
                obelisk.add_child(ob_cap)
                
                obelisk.position = Vector3(portal_p.x + side * (portal_p.width * 0.5 + 0.6), portal_p.y, portal_p.z)
                bridge_node.add_child(obelisk)
                
        # 3 Monumental Stone Canyon Piers extending into the gorge
        var pier_indices = [int(num_pts * 0.22), int(num_pts * 0.50), int(num_pts * 0.78)]
        for p_idx in pier_indices:
            var pt = points[p_idx]
            var pier = Node3D.new()
            pier.position = Vector3(pt.x, pt.y - 0.6, pt.z)
            
            # Pier main shaft descending 22m into canyon floor
            var pier_mesh = MeshInstance3D.new()
            var pier_box = BoxMesh.new()
            pier_box.size = Vector3(pt.width + 1.8, 22.0, 5.2)
            pier_box.material = bridge_stone_material
            pier_mesh.mesh = pier_box
            pier_mesh.position.y = -11.0
            pier.add_child(pier_mesh)
            
            # Pier head corbel bracket
            var corbel = MeshInstance3D.new()
            var corbel_box = BoxMesh.new()
            corbel_box.size = Vector3(pt.width + 3.0, 2.0, 6.4)
            corbel_box.material = cobblestone_material
            corbel.mesh = corbel_box
            corbel.position.y = -1.0
            pier.add_child(corbel)
            
            # Arch ribs extending from pier
            for arch_dir in [-1.0, 1.0]:
                var arch_rib = MeshInstance3D.new()
                var rib_box = BoxMesh.new()
                rib_box.size = Vector3(pt.width + 1.2, 1.2, 14.0)
                rib_box.material = bridge_stone_material
                arch_rib.mesh = rib_box
                arch_rib.position = Vector3(0.0, -3.2, arch_dir * 8.5)
                arch_rib.rotation.x = arch_dir * 0.22
                pier.add_child(arch_rib)
                
            bridge_node.add_child(pier)
            
        root.add_child(bridge_node)

    # 5b. PONTE DELL'ALTOPIANO (Lowland River Bridge, Z in [5160, 5280])
    elif start_z >= 5160.0 and start_z < 5280.0:
        var bridge_node = Node3D.new()
        for i in range(num_pts - 1):
            var p1 = points[i]
            var p2 = points[i + 1]
            var hw1 = p1.width * 0.5
            var hw2 = p2.width * 0.5
            var delta_z = p2.z - p1.z
            var mid_z = (p1.z + p2.z) * 0.5
            var mid_y = (p1.y + p2.y) * 0.5
            var rot_y = atan2(p2.x - p1.x, delta_z)
            
            for side in [-1.0, 1.0]:
                var x1 = p1.x + side * (hw1 + 0.32)
                var x2 = p2.x + side * (hw2 + 0.32)
                var mid_x = (x1 + x2) * 0.5
                
                var parapet = MeshInstance3D.new()
                var p_box = BoxMesh.new()
                p_box.size = Vector3(0.42, 1.0, delta_z * 1.05)
                p_box.material = village_wall_material
                parapet.mesh = p_box
                parapet.position = Vector3(mid_x, mid_y + 0.50, mid_z)
                parapet.rotation.y = rot_y
                
                # Solid Bridge Parapet Barrier Collider
                var bp2_col = StaticBody3D.new()
                var bp2_shape = CollisionShape3D.new()
                var bp2_box = BoxShape3D.new()
                bp2_box.size = Vector3(0.48, 1.20, delta_z * 1.05)
                bp2_shape.shape = bp2_box
                bp2_col.add_child(bp2_shape)
                parapet.add_child(bp2_col)
                
                bridge_node.add_child(parapet)
                
                # Rounded stone bollards
                if i % 3 == 0:
                    var bollard = MeshInstance3D.new()
                    var b_cyl = CylinderMesh.new()
                    b_cyl.top_radius = 0.22; b_cyl.bottom_radius = 0.24; b_cyl.height = 1.15
                    b_cyl.material = bridge_stone_material
                    bollard.mesh = b_cyl
                    bollard.position = Vector3(x1, p1.y + 0.58, p1.z)
                    bridge_node.add_child(bollard)
                    
        # Central River Pier with Cutwater prow
        var mid_p = points[int(num_pts * 0.5)]
        var river_pier = Node3D.new()
        river_pier.position = Vector3(mid_p.x, mid_p.y - 0.4, mid_p.z)
        
        var rp_mesh = MeshInstance3D.new()
        var rp_box = BoxMesh.new()
        rp_box.size = Vector3(mid_p.width + 1.2, 6.0, 4.2)
        rp_box.material = bridge_stone_material
        rp_mesh.mesh = rp_box
        rp_mesh.position.y = -3.0
        river_pier.add_child(rp_mesh)
        
        var prow = MeshInstance3D.new()
        var prow_prism = PrismMesh.new()
        prow_prism.size = Vector3(mid_p.width + 1.2, 6.0, 3.2)
        prow_prism.material = bridge_stone_material
        prow.mesh = prow_prism
        prow.position = Vector3(0.0, -3.0, -3.2)
        prow.rotation.y = PI * 0.5
        prow.rotation.x = PI * 0.5
        river_pier.add_child(prow)
        
        bridge_node.add_child(river_pier)
        root.add_child(bridge_node)

func create_bridge_lantern(pos: Vector3) -> Node3D:
    var lantern_node = Node3D.new()
    lantern_node.position = pos
    
    var post = MeshInstance3D.new()
    var post_cyl = CylinderMesh.new()
    post_cyl.top_radius = 0.05; post_cyl.bottom_radius = 0.07; post_cyl.height = 0.75
    post_cyl.material = chalet_roof_material
    post.mesh = post_cyl
    post.position.y = 0.38
    lantern_node.add_child(post)
    
    var glass = MeshInstance3D.new()
    var g_box = BoxMesh.new()
    g_box.size = Vector3(0.32, 0.42, 0.32)
    g_box.material = lantern_glow_material
    glass.mesh = g_box
    glass.position.y = 0.88
    lantern_node.add_child(glass)
    
    var cap = MeshInstance3D.new()
    var c_prism = PrismMesh.new()
    c_prism.size = Vector3(0.42, 0.22, 0.42)
    c_prism.material = chalet_roof_material
    cap.mesh = c_prism
    cap.position.y = 1.15
    lantern_node.add_child(cap)
    
    var light = OmniLight3D.new()
    light.light_color = Color(1.0, 0.82, 0.42)
    light.light_energy = 1.3
    light.omni_range = 10.0
    light.position.y = 0.88
    lantern_node.add_child(light)
    
    return lantern_node

# =========================================================================
# 6. LAGHI & FIUMI (Lakes & Rivers)
# =========================================================================
func spawn_water_features(root: Node3D, points: Array, start_z: float):
    var num_pts = points.size()
    var mid_p = points[int(num_pts * 0.5)]
    
    # 6a. LAGO ALPINO (Passo delle Alpi, Z in [360, 600])
    # Nella nuova geografia, il tratto Z in [80, 1380] ospita l'ampia pianura agricola con Ruscello Chiaro e Lago dei Salici gestiti da RuralPlainEnvironmentBuilder
    if false and start_z >= 360.0 and start_z < 600.0:
        var min_road_y = 999.0
        var avg_road_x = 0.0
        for pt in points:
            if pt.y < min_road_y:
                min_road_y = pt.y
            avg_road_x += pt.x
        avg_road_x /= float(num_pts)
        
        var lake_group = Node3D.new()
        
        # Water elevation guaranteed to be below the lowest road point in the depression
        var lake_water_y = min_road_y - 4.2
        var lake_center_x = avg_road_x - 62.0
        var lake_center_z = mid_p.z
        
        # 1. Organic contoured curved lake surface
        var st_lake = SurfaceTool.new()
        st_lake.begin(Mesh.PRIMITIVE_TRIANGLES)
        st_lake.set_material(water_material)
        
        var radial_segs = 32
        var base_rx = 36.0
        var base_rz = 58.0
        var center_pos = Vector3(lake_center_x, lake_water_y, lake_center_z)
        
        var rim_pts: Array = []
        for k in range(radial_segs):
            var ang = float(k) * (TAU / float(radial_segs))
            var r_var = 1.0 + sin(ang * 2.0) * 0.16 + cos(ang * 3.0) * 0.10 + sin(ang * 5.0) * 0.06
            var px = lake_center_x + cos(ang) * base_rx * r_var
            var pz = lake_center_z + sin(ang) * base_rz * r_var
            rim_pts.append(Vector3(px, lake_water_y, pz))
            
        for k in range(radial_segs):
            var next_k = (k + 1) % radial_segs
            var p_curr = rim_pts[k]
            var p_next = rim_pts[next_k]
            
            st_lake.set_normal(Vector3.UP)
            st_lake.set_uv(Vector2(center_pos.x, center_pos.z) * 0.04)
            st_lake.add_vertex(center_pos)
            
            st_lake.set_normal(Vector3.UP)
            st_lake.set_uv(Vector2(p_next.x, p_next.z) * 0.04)
            st_lake.add_vertex(p_next)
            
            st_lake.set_normal(Vector3.UP)
            st_lake.set_uv(Vector2(p_curr.x, p_curr.z) * 0.04)
            st_lake.add_vertex(p_curr)
            
        st_lake.generate_normals()
        var lake_mesh_inst = MeshInstance3D.new()
        lake_mesh_inst.mesh = st_lake.commit()
        lake_mesh_inst.material_override = water_material
        lake_group.add_child(lake_mesh_inst)
        
        # 2. Natural pebble and stone shoreline embankment rim
        var st_shore = SurfaceTool.new()
        st_shore.begin(Mesh.PRIMITIVE_TRIANGLES)
        st_shore.set_material(cobblestone_material)
        
        for k in range(radial_segs):
            var next_k = (k + 1) % radial_segs
            var p_curr = rim_pts[k]
            var p_next = rim_pts[next_k]
            
            var dir_curr = (p_curr - center_pos).normalized()
            var dir_next = (p_next - center_pos).normalized()
            
            var shore_w = 4.2 + sin(float(k) * 0.8) * 1.4
            var shore_curr = p_curr + dir_curr * shore_w + Vector3(0.0, 0.48, 0.0)
            var shore_next = p_next + dir_next * shore_w + Vector3(0.0, 0.48, 0.0)
            
            # Quad: p_curr, p_next, shore_next, shore_curr
            st_shore.set_normal(Vector3.UP)
            st_shore.set_uv(Vector2(p_curr.x, p_curr.z) * 0.08)
            st_shore.add_vertex(p_curr)
            st_shore.set_uv(Vector2(p_next.x, p_next.z) * 0.08)
            st_shore.add_vertex(p_next)
            st_shore.set_uv(Vector2(shore_curr.x, shore_curr.z) * 0.08)
            st_shore.add_vertex(shore_curr)
            
            st_shore.set_normal(Vector3.UP)
            st_shore.set_uv(Vector2(p_next.x, p_next.z) * 0.08)
            st_shore.add_vertex(p_next)
            st_shore.set_uv(Vector2(shore_next.x, shore_next.z) * 0.08)
            st_shore.add_vertex(shore_next)
            st_shore.set_uv(Vector2(shore_curr.x, shore_curr.z) * 0.08)
            st_shore.add_vertex(shore_curr)
            
        st_shore.generate_normals()
        var shore_mesh_inst = MeshInstance3D.new()
        shore_mesh_inst.mesh = st_shore.commit()
        shore_mesh_inst.material_override = cobblestone_material
        lake_group.add_child(shore_mesh_inst)
        
        # 3. Scenic Shoreline Boulders nestled half-in water
        for k in range(0, radial_segs, 2):
            var p_rim = rim_pts[k]
            var r_sz = randf_range(1.1, 2.2)
            var rock = MeshInstance3D.new()
            var s = SphereMesh.new()
            s.radius = r_sz; s.height = r_sz * 1.2
            s.material = rock_material
            rock.mesh = s
            var rock_pos = p_rim + (p_rim - center_pos).normalized() * randf_range(0.2, 1.8)
            rock_pos.y = lake_water_y + r_sz * 0.35
            rock.position = rock_pos
            lake_group.add_child(rock)
            
        # 4. Wooden Fishing Pier & Moored Rowboat
        if start_z >= 480.0 and start_z < 600.0:
            var pier_z = mid_p.z - 8.0
            var pier_x_start = avg_road_x - 22.0
            var pier_x_end = avg_road_x - 38.0
            var pier_len = abs(pier_x_end - pier_x_start)
            
            var pier_deck = MeshInstance3D.new()
            var d_box = BoxMesh.new()
            d_box.size = Vector3(pier_len, 0.22, 2.8)
            d_box.material = pier_wood_material
            pier_deck.mesh = d_box
            pier_deck.position = Vector3((pier_x_start + pier_x_end) * 0.5, lake_water_y + 0.38, pier_z)
            lake_group.add_child(pier_deck)
            
            for px in [pier_x_start + 2.0, pier_x_start + 7.5, pier_x_end]:
                for pz_off in [-1.2, 1.2]:
                    var pile = MeshInstance3D.new()
                    var pile_cyl = CylinderMesh.new()
                    pile_cyl.top_radius = 0.12; pile_cyl.bottom_radius = 0.14; pile_cyl.height = 3.6
                    pile_cyl.material = pier_wood_material
                    pile.mesh = pile_cyl
                    pile.position = Vector3(px, lake_water_y - 1.2, pier_z + pz_off)
                    lake_group.add_child(pile)
                    
            var cleat = MeshInstance3D.new()
            var c_box = BoxMesh.new()
            c_box.size = Vector3(0.35, 0.40, 0.35)
            c_box.material = pier_wood_material
            cleat.mesh = c_box
            cleat.position = Vector3(pier_x_end - 0.4, lake_water_y + 0.65, pier_z + 1.1)
            lake_group.add_child(cleat)
            
            var boat = create_rowboat(Vector3(pier_x_end - 3.2, lake_water_y + 0.05, pier_z + 2.2), 0.28)
            lake_group.add_child(boat)
            
        root.add_child(lake_group)

    # 6b. TORRENTE DELLA GOLA (Gola del Meridiano, Z in [1440, 2880])
    elif start_z >= 1440.0 and start_z < 2880.0:
        var torrent_node = Node3D.new()
        var st_water = SurfaceTool.new()
        st_water.begin(Mesh.PRIMITIVE_TRIANGLES)
        st_water.set_material(water_material)
        
        var t_half_w = 6.8
        for i in range(num_pts - 1):
            var p1 = points[i]
            var p2 = points[i + 1]
            var tx1 = p1.x - 24.0
            var tx2 = p2.x - 24.0
            var ty1 = p1.y - 7.6
            var ty2 = p2.y - 7.6
            
            var v1_l = Vector3(tx1 - t_half_w, ty1, p1.z)
            var v1_r = Vector3(tx1 + t_half_w, ty1, p1.z)
            var v2_l = Vector3(tx2 - t_half_w, ty2, p2.z)
            var v2_r = Vector3(tx2 + t_half_w, ty2, p2.z)
            
            add_quad_mesh_only(st_water, v1_l, v2_l, v2_r, v1_r, 0.0, 1.0, p1.z * 0.05, p2.z * 0.05)
            
        st_water.generate_normals()
        var t_mesh_inst = MeshInstance3D.new()
        t_mesh_inst.mesh = st_water.commit()
        t_mesh_inst.material_override = water_material
        torrent_node.add_child(t_mesh_inst)
        
        for b_idx in [int(num_pts * 0.25), int(num_pts * 0.55), int(num_pts * 0.85)]:
            var bp = points[b_idx]
            var boulder = MeshInstance3D.new()
            var b_sph = SphereMesh.new()
            var b_rad = randf_range(1.4, 2.5)
            b_sph.radius = b_rad; b_sph.height = b_rad * 1.3
            b_sph.material = rock_material
            boulder.mesh = b_sph
            boulder.position = Vector3(bp.x - 24.0 + randf_range(-3.5, 3.5), bp.y - 7.6 + b_rad * 0.45, bp.z)
            torrent_node.add_child(boulder)
            
        root.add_child(torrent_node)

    # 6c. FIUME DELL'ALTOPIANO (Altopiano Dorato, Z in [5040, 5280])
    elif start_z >= 5040.0 and start_z < 5280.0:
        var river_node = Node3D.new()
        var r_plane = MeshInstance3D.new()
        var p_mesh = PlaneMesh.new()
        p_mesh.size = Vector2(32.0, 150.0)
        p_mesh.subdivide_width = 8
        p_mesh.subdivide_depth = 12
        p_mesh.material = water_material
        r_plane.mesh = p_mesh
        # Underneath the bridge deck
        r_plane.position = Vector3(mid_p.x, mid_p.y - 4.5, mid_p.z)
        r_plane.rotation.y = PI * 0.35
        river_node.add_child(r_plane)
        root.add_child(river_node)

func create_rowboat(pos: Vector3, rot_y: float) -> Node3D:
    var boat = Node3D.new()
    boat.position = pos
    boat.rotation.y = rot_y
    
    var hull = MeshInstance3D.new()
    var h_box = BoxMesh.new()
    h_box.size = Vector3(1.35, 0.65, 3.6)
    h_box.material = boat_hull_material
    hull.mesh = h_box
    hull.position.y = 0.28
    boat.add_child(hull)
    
    var bow = MeshInstance3D.new()
    var b_prism = PrismMesh.new()
    b_prism.size = Vector3(1.35, 0.65, 1.2)
    b_prism.material = boat_hull_material
    bow.mesh = b_prism
    bow.position = Vector3(0.0, 0.28, 2.1)
    bow.rotation.y = PI
    boat.add_child(bow)
    
    var floor_m = MeshInstance3D.new()
    var f_box = BoxMesh.new()
    f_box.size = Vector3(1.05, 0.15, 3.2)
    f_box.material = pier_wood_material
    floor_m.mesh = f_box
    floor_m.position.y = 0.15
    boat.add_child(floor_m)
    
    for bz in [-0.6, 0.7]:
        var bench = MeshInstance3D.new()
        var bb = BoxMesh.new()
        bb.size = Vector3(1.2, 0.08, 0.35)
        bb.material = pier_wood_material
        bench.mesh = bb
        bench.position = Vector3(0.0, 0.42, bz)
        boat.add_child(bench)
        
    for oar_side in [-1.0, 1.0]:
        var oar = MeshInstance3D.new()
        var o_cyl = CylinderMesh.new()
        o_cyl.top_radius = 0.03; o_cyl.bottom_radius = 0.04; o_cyl.height = 2.2
        o_cyl.material = pier_wood_material
        oar.mesh = o_cyl
        oar.position = Vector3(oar_side * 0.65, 0.52, 0.1)
        oar.rotation.z = oar_side * 0.25
        oar.rotation.x = PI * 0.45
        boat.add_child(oar)
        
    return boat

func sample_chunk_road(points: Array, query_z: float) -> Dictionary:
    for i in range(points.size() - 1):
        if query_z >= points[i].z and query_z <= points[i + 1].z:
            var t = (query_z - points[i].z) / max(0.001, points[i + 1].z - points[i].z)
            var rx = lerp(points[i].x, points[i + 1].x, t)
            var ry = lerp(points[i].y, points[i + 1].y, t)
            var rw = lerp(points[i].width, points[i + 1].width, t)
            var dx = points[i + 1].x - points[i].x
            var dz = points[i + 1].z - points[i].z
            var angle = atan2(dx, dz)
            return { "x": rx, "y": ry, "width": rw, "angle": angle }
    var p0 = points[0]
    return { "x": p0.x, "y": p0.y, "width": p0.width, "angle": 0.0 }

# =========================================================================
# 7. CITTÀ, PAESI & VILLAGGI (Towns & Alpine Villages)
# =========================================================================
func spawn_villages(root: Node3D, points: Array, start_z: float):
    var num_pts = points.size()
    var mid_p = points[int(num_pts * 0.5)]
    
    # 7a. BORGO SAN CRISTOFORO - Generato ora alla partenza (Z in [0, 80m]) da CityEnvironmentBuilder
    if false and start_z >= 840.0 and start_z < 960.0:
        var village_group = Node3D.new()
        spawn_village_sidewalks(village_group, points)
        
        # Entrance gateposts with safe clearance
        var p0 = points[0]
        var portal = Node3D.new()
        portal.position = Vector3(p0.x + p0.width * 0.5 + 2.8, p0.y, p0.z + 10.0)
        for side in [-1.0, 1.0]:
            var pillar = MeshInstance3D.new()
            var pil_box = BoxMesh.new()
            pil_box.size = Vector3(0.65, 3.4, 0.65)
            pil_box.material = village_wall_material
            pillar.mesh = pil_box
            pillar.position = Vector3(0.0, 1.7, side * 2.8)
            portal.add_child(pillar)
        village_group.add_child(portal)
        
        # Houses follow the real curved road contour with safe setback
        var h_configs = [
            { "z_off": -35.0, "side": 1.0, "lateral": 8.5, "rot_rel": 0.15, "stories": 2 },
            { "z_off": -24.0, "side": 1.0, "lateral": 17.5, "rot_rel": -0.20, "stories": 3 },
            { "z_off": 18.0, "side": 1.0, "lateral": 9.0, "rot_rel": 0.08, "stories": 2 },
            { "z_off": 32.0, "side": 1.0, "lateral": 18.0, "rot_rel": -0.12, "stories": 2 },
        ]
        for hc in h_configs:
            var target_z = mid_p.z + hc.z_off
            var info = sample_chunk_road(points, target_z)
            var h_x = info.x + hc.side * (info.width * 0.5 + hc.lateral)
            var h_rot = info.angle + hc.rot_rel
            var h_node = create_village_house(Vector3(h_x, info.y, target_z), h_rot, hc.stories, false)
            village_group.add_child(h_node)
            
        for l_z_off in [-48.0, -26.0, -6.0, 16.0, 38.0]:
            var l_target_z = mid_p.z + l_z_off
            var l_info = sample_chunk_road(points, l_target_z)
            var l_side = 1.0 if int(abs(l_z_off)) % 2 == 0 else -1.0
            var lantern = create_street_lantern(Vector3(l_info.x + l_side * (l_info.width * 0.5 + 1.4), l_info.y, l_target_z), l_side < 0.0)
            village_group.add_child(lantern)
            
        # 1993 PERIOD LIFE: Parked Piaggio Ape 50 with firewood logs outside House 1
        var ape_info = sample_chunk_road(points, mid_p.z - 16.0)
        var ape_pos = Vector3(ape_info.x + ape_info.width * 0.5 + 3.8, ape_info.y, mid_p.z - 16.0)
        var ape = create_parked_ape_piaggio(ape_pos, ape_info.angle + 0.35, Color(0.18, 0.42, 0.62))
        village_group.add_child(ape)
        
        # 1993 PERIOD LIFE: Parked Vespa 50 Special outside House 3
        var vespa_info = sample_chunk_road(points, mid_p.z + 12.0)
        var vespa_pos = Vector3(vespa_info.x + vespa_info.width * 0.5 + 3.4, vespa_info.y, mid_p.z + 12.0)
        var vespa = create_parked_vespa_special(vespa_pos, vespa_info.angle - 0.20, Color(0.85, 0.15, 0.12))
        village_group.add_child(vespa)
        
        # 1993 PERIOD LIFE: Cabina Telefonica Pubblica SIP
        var sip_info = sample_chunk_road(points, mid_p.z + 2.0)
        var sip_pos = Vector3(sip_info.x + sip_info.width * 0.5 + 3.2, sip_info.y, mid_p.z + 2.0)
        var sip_booth = create_cabina_sip(sip_pos, sip_info.angle - 0.15)
        village_group.add_child(sip_booth)
        
        # 1993 PERIOD LIFE: Insegne botteghe ("OFFICINA BEPI", "TRATTORIA ALPINO")
        var s1_info = sample_chunk_road(points, mid_p.z - 28.0)
        var sign1 = create_vintage_sign(Vector3(s1_info.x + s1_info.width * 0.5 + 6.0, s1_info.y + 3.2, mid_p.z - 28.0), s1_info.angle + 0.15, "OFFICINA MECCANICA BEPI", "Riparazioni & Gomme", Color(0.15, 0.25, 0.45))
        village_group.add_child(sign1)
        
        var s2_info = sample_chunk_road(points, mid_p.z + 24.0)
        var sign2 = create_vintage_sign(Vector3(s2_info.x + s2_info.width * 0.5 + 6.0, s2_info.y + 3.2, mid_p.z + 24.0), s2_info.angle + 0.10, "TRATTORIA ALPINO", "Specialità Polenta & Capriolo", Color(0.45, 0.20, 0.15))
        village_group.add_child(sign2)
        
        # Tiny Glade: Botti di vino in rovere e cassette di frutta fuori dalla Trattoria Alpino
        var barrels = create_stacked_barrels_and_crates(Vector3(s2_info.x + s2_info.width * 0.5 + 4.2, s2_info.y, mid_p.z + 21.5), s2_info.angle - 0.25)
        village_group.add_child(barrels)
        
        # Tiny Glade: Bicicletta vintage Celeste Bianchi con cestino in vimini appoggiata al muretto
        var bike = create_vintage_bicycle(Vector3(s2_info.x + s2_info.width * 0.5 + 3.8, s2_info.y, mid_p.z + 26.2), s2_info.angle + 1.35, 7.5)
        village_group.add_child(bike)
        
        # Tiny Glade: Panni stesi al sole tra le facciate del borgo (lenzuola bianche, maglia rossa, pantaloni blu)
        var la_info = sample_chunk_road(points, mid_p.z - 35.0)
        var lb_info = sample_chunk_road(points, mid_p.z - 24.0)
        var p_la = Vector3(la_info.x + la_info.width * 0.5 + 8.5, la_info.y + 4.6, mid_p.z - 34.0)
        var p_lb = Vector3(lb_info.x + lb_info.width * 0.5 + 16.5, lb_info.y + 4.2, mid_p.z - 25.5)
        var clothesline = create_laundry_clothesline(p_la, p_lb)
        village_group.add_child(clothesline)
        
        # Villager spectator watching passing cars
        var v1_info = sample_chunk_road(points, mid_p.z - 8.0)
        var villager_stand = create_villager_silhouette(Vector3(v1_info.x + v1_info.width * 0.5 + 2.8, v1_info.y, mid_p.z - 8.0), v1_info.angle - 1.4, false)
        village_group.add_child(villager_stand)
            
        root.add_child(village_group)
        
    # 7b. BORGO SAN CRISTOFORO - Piazza Storica & Campanile (Z in [960, 1080])
    elif start_z >= 960.0 and start_z < 1080.0:
        var village_center = Node3D.new()
        spawn_village_sidewalks(village_center, points)
        
        # Historic houses along the curved piazza perimeter
        var piazza_houses = [
            { "z_off": -32.0, "side": 1.0, "lateral": 9.5, "rot_rel": 0.22, "stories": 3 },
            { "z_off": -20.0, "side": 1.0, "lateral": 19.0, "rot_rel": -0.15, "stories": 2 },
            { "z_off": 10.0, "side": 1.0, "lateral": 18.5, "rot_rel": -0.30, "stories": 3 },
            { "z_off": 26.0, "side": 1.0, "lateral": 10.0, "rot_rel": 0.12, "stories": 2 },
            { "z_off": 38.0, "side": 1.0, "lateral": 19.5, "rot_rel": -0.18, "stories": 3 }
        ]
        for ph in piazza_houses:
            var target_z = mid_p.z + ph.z_off
            var info = sample_chunk_road(points, target_z)
            var h_x = info.x + ph.side * (info.width * 0.5 + ph.lateral)
            var h_rot = info.angle + ph.rot_rel
            var h_node = create_village_house(Vector3(h_x, info.y, target_z), h_rot, ph.stories, false)
            village_center.add_child(h_node)
            
        # Panni stesi al sole anche nella piazza storica
        var pla_info = sample_chunk_road(points, mid_p.z - 32.0)
        var plb_info = sample_chunk_road(points, mid_p.z - 20.0)
        var pz_la = Vector3(pla_info.x + pla_info.width * 0.5 + 9.5, pla_info.y + 5.2, mid_p.z - 31.0)
        var pz_lb = Vector3(plb_info.x + plb_info.width * 0.5 + 18.0, plb_info.y + 4.8, mid_p.z - 21.0)
        var pz_clothesline = create_laundry_clothesline(pz_la, pz_lb)
        village_center.add_child(pz_clothesline)
        
        # Campanile safely set back outside the road perimeter
        var c_info = sample_chunk_road(points, mid_p.z + 18.0)
        var campanile_pos = Vector3(c_info.x + c_info.width * 0.5 + 17.5, c_info.y, mid_p.z + 18.0)
        var campanile = create_campanile(campanile_pos)
        village_center.add_child(campanile)
        
        # Village fountain
        var f_info = sample_chunk_road(points, mid_p.z + 4.0)
        var fountain_pos = Vector3(f_info.x + f_info.width * 0.5 + 9.5, f_info.y, mid_p.z + 4.0)
        var fountain = create_piazza_fountain(fountain_pos)
        village_center.add_child(fountain)
            
        for l_z_off in [-42.0, -22.0, -2.0, 18.0, 38.0]:
            var l_target_z = mid_p.z + l_z_off
            var l_info = sample_chunk_road(points, l_target_z)
            var l_side = 1.0 if int(abs(l_z_off)) % 2 == 0 else -1.0
            var lantern = create_street_lantern(Vector3(l_info.x + l_side * (l_info.width * 0.5 + 1.4), l_info.y, l_target_z), l_side < 0.0)
            village_center.add_child(lantern)
            
        # 1993 PERIOD LIFE: "Bar dello Sport" cafe terrace with tables, parasol, bench & sitting villager
        var bar_info = sample_chunk_road(points, mid_p.z - 12.0)
        var bar_pos = Vector3(bar_info.x + bar_info.width * 0.5 + 5.5, bar_info.y, mid_p.z - 12.0)
        var bar_terrace = create_bar_terrace(bar_pos, bar_info.angle)
        village_center.add_child(bar_terrace)
        
        var bar_sign = create_vintage_sign(Vector3(bar_pos.x + 1.2, bar_info.y + 3.2, bar_pos.z - 3.0), bar_info.angle, "BAR DELLO SPORT", "Caffè espresso & Grappe alpine", Color(0.65, 0.15, 0.15))
        village_center.add_child(bar_sign)
        
        # Register Bar dello Sport as an interactive village hospitality & service location
        active_service_stations.append({
            "name": "Bar dello Sport 'Da Roberto' - Borgo San Cristoforo",
            "type": "bar_sport",
            "center": bar_pos,
            "bay_center": Vector3(bar_info.x + bar_info.width * 0.5 + 2.5, bar_info.y, mid_p.z - 12.0),
            "pump_bay_min": Vector3(bar_info.x, bar_info.y - 2.0, mid_p.z - 25.0),
            "pump_bay_max": Vector3(bar_info.x + bar_info.width * 0.5 + 9.0, bar_info.y + 4.0, mid_p.z + 5.0),
            "forecourt_min_x": bar_info.x - 2.0,
            "forecourt_max_x": bar_info.x + bar_info.width * 0.5 + 12.0,
            "z_min": mid_p.z - 25.0,
            "z_max": mid_p.z + 5.0
        })
        
        var villager_bench = create_villager_silhouette(Vector3(bar_pos.x - 0.4, bar_info.y, bar_pos.z - 1.4), bar_info.angle, true)
        village_center.add_child(villager_bench)
        
        # Parked white Vespa 50 Special outside Bar dello Sport
        var vespa_bar = create_parked_vespa_special(Vector3(bar_pos.x - 1.2, bar_info.y, bar_pos.z + 1.6), bar_info.angle + 0.35, Color(0.92, 0.90, 0.85))
        village_center.add_child(vespa_bar)
        
        # Tiny Glade: Bicicletta d'epoca appoggiata alla facciata del Bar dello Sport
        var bike_bar = create_vintage_bicycle(Vector3(bar_pos.x + 2.4, bar_info.y, bar_pos.z - 3.8), bar_info.angle - 0.45, -7.0)
        village_center.add_child(bike_bar)
        
        # Parked green Piaggio Ape 50 near fountain edge
        var ape2_info = sample_chunk_road(points, mid_p.z + 24.0)
        var ape2_pos = Vector3(ape2_info.x + ape2_info.width * 0.5 + 4.5, ape2_info.y, mid_p.z + 24.0)
        var ape2 = create_parked_ape_piaggio(ape2_pos, ape2_info.angle - 0.25, Color(0.22, 0.48, 0.25))
        village_center.add_child(ape2)
            
        root.add_child(village_center)

    # 7c. BORGO DELL'ALTOPIANO & MULINO (Z in [5400, 5640])
    elif start_z >= 5400.0 and start_z < 5640.0:
        var borgo_alt = Node3D.new()
        
        var alt_houses = [
            { "z_off": -30.0, "lateral": 10.0, "rot_rel": 0.25, "stories": 2 },
            { "z_off": -8.0, "lateral": 18.0, "rot_rel": -0.15, "stories": 2 },
            { "z_off": 28.0, "lateral": 10.5, "rot_rel": 0.10, "stories": 2 },
        ]
        for ah in alt_houses:
            var target_z = mid_p.z + ah.z_off
            var info = sample_chunk_road(points, target_z)
            var h_x = info.x + (info.width * 0.5 + ah.lateral)
            var h_rot = info.angle + ah.rot_rel
            var h_node = create_village_house(Vector3(h_x, info.y, target_z), h_rot, ah.stories, true)
            borgo_alt.add_child(h_node)
            
        if start_z >= 5400.0 and start_z < 5520.0:
            var m_info = sample_chunk_road(points, mid_p.z - 2.0)
            var mill_pos = Vector3(m_info.x + m_info.width * 0.5 + 16.5, m_info.y + 1.8, mid_p.z - 2.0)
            var windmill = create_windmill(mill_pos)
            windmill.rotation.y = deg_to_rad(-30.0)
            borgo_alt.add_child(windmill)
            
        for c_idx in range(6):
            var cz = mid_p.z - 45.0 + float(c_idx) * 18.0
            var c_info = sample_chunk_road(points, cz)
            var cx = c_info.x + c_info.width * 0.5 + 7.5 + (c_idx % 2) * 12.0
            var cypress = create_cypress_tree(Vector3(cx, c_info.y, cz))
            borgo_alt.add_child(cypress)
            
        spawn_village_sidewalks(borgo_alt, points)
        root.add_child(borgo_alt)

func spawn_village_sidewalks(parent: Node3D, points: Array):
    var sw_node = Node3D.new()
    var st_walk = SurfaceTool.new()
    st_walk.begin(Mesh.PRIMITIVE_TRIANGLES)
    var sw_mat = cobblestone_material if cobblestone_material else chalet_roof_material
    st_walk.set_material(sw_mat)
    
    var st_curb = SurfaceTool.new()
    st_curb.begin(Mesh.PRIMITIVE_TRIANGLES)
    var curb_mat = StandardMaterial3D.new()
    curb_mat.albedo_color = Color(0.72, 0.70, 0.68)
    curb_mat.roughness = 0.85
    st_curb.set_material(curb_mat)
    
    var num_pts = points.size()
    var sidewalk_w = 1.85
    var curb_w = 0.16
    var curb_h = 0.16 # +16cm sopra la quota asfalto
    
    for side in [-1.0, 1.0]:
        for i in range(num_pts - 1):
            var p1 = points[i]
            var p2 = points[i + 1]
            var hw1 = p1.width * 0.5
            var hw2 = p2.width * 0.5
            
            # Ciglio stradale interno
            var c_in_1 = Vector3(p1.x + side * hw1, p1.y, p1.z)
            var c_in_2 = Vector3(p2.x + side * hw2, p2.y, p2.z)
            
            # Spigolo superiore del cordolo in granito
            var c_top_1 = Vector3(p1.x + side * (hw1 + curb_w), p1.y + curb_h, p1.z)
            var c_top_2 = Vector3(p2.x + side * (hw2 + curb_w), p2.y + curb_h, p2.z)
            
            # Alzata verticale del cordolo
            if side > 0.0:
                st_curb.add_vertex(c_in_1); st_curb.add_vertex(c_top_1); st_curb.add_vertex(c_top_2)
                st_curb.add_vertex(c_in_1); st_curb.add_vertex(c_top_2); st_curb.add_vertex(c_in_2)
            else:
                st_curb.add_vertex(c_in_1); st_curb.add_vertex(c_top_2); st_curb.add_vertex(c_top_1)
                st_curb.add_vertex(c_in_1); st_curb.add_vertex(c_in_2); st_curb.add_vertex(c_top_2)
                
            # Piano calpestabile in porfido del marciapiede
            var sw_out_1 = Vector3(p1.x + side * (hw1 + curb_w + sidewalk_w), p1.y + curb_h, p1.z)
            var sw_out_2 = Vector3(p2.x + side * (hw2 + curb_w + sidewalk_w), p2.y + curb_h, p2.z)
            
            if side > 0.0:
                st_walk.add_vertex(c_top_1); st_walk.add_vertex(sw_out_1); st_walk.add_vertex(sw_out_2)
                st_walk.add_vertex(c_top_1); st_walk.add_vertex(sw_out_2); st_walk.add_vertex(c_top_2)
            else:
                st_walk.add_vertex(c_top_1); st_walk.add_vertex(sw_out_2); st_walk.add_vertex(sw_out_1)
                st_walk.add_vertex(c_top_1); st_walk.add_vertex(c_top_2); st_walk.add_vertex(sw_out_2)
                
            # Parigine classiche in ghisa (dissuasori pedonali) ogni 6 passi
            if i % 6 == 0:
                var bollard = MeshInstance3D.new()
                var bcyl = CylinderMesh.new()
                bcyl.top_radius = 0.055; bcyl.bottom_radius = 0.075; bcyl.height = 0.82
                var bmat = StandardMaterial3D.new()
                bmat.albedo_color = Color(0.12, 0.13, 0.14)
                bmat.metallic = 0.85
                bmat.roughness = 0.40
                bollard.mesh = bcyl
                bollard.material_override = bmat
                bollard.position = Vector3(p1.x + side * (hw1 + curb_w * 0.5), p1.y + curb_h + 0.41, p1.z)
                sw_node.add_child(bollard)
                
    st_curb.generate_normals()
    var curb_mesh = st_curb.commit()
    var curb_inst = MeshInstance3D.new()
    curb_inst.mesh = curb_mesh
    sw_node.add_child(curb_inst)
    
    st_walk.generate_normals()
    var walk_mesh = st_walk.commit()
    var walk_inst = MeshInstance3D.new()
    walk_inst.mesh = walk_mesh
    
    var col_body = StaticBody3D.new()
    var col_shape = CollisionShape3D.new()
    col_shape.shape = walk_mesh.create_trimesh_shape()
    col_body.add_child(col_shape)
    walk_inst.add_child(col_body)
    sw_node.add_child(walk_inst)
    
    parent.add_child(sw_node)

func create_village_house(pos: Vector3, rot_y: float, stories: int, is_terracotta: bool) -> Node3D:
    var house = Node3D.new()
    house.position = pos
    house.rotation.y = rot_y
    
    var h_height = 3.2 * float(stories)
    var w = 6.4
    var d = 7.6
    
    # Deep stone foundation plinth anchored firmly into slope
    var plinth = MeshInstance3D.new()
    var pl_box = BoxMesh.new()
    pl_box.size = Vector3(w + 1.2, 3.8, d + 1.2)
    pl_box.material = rock_material
    plinth.mesh = pl_box
    plinth.position.y = -0.6
    house.add_child(plinth)
    
    var walls = MeshInstance3D.new()
    var w_box = BoxMesh.new()
    w_box.size = Vector3(w, h_height, d)
    w_box.material = village_wall_material
    walls.mesh = w_box
    walls.position.y = 0.8 + h_height * 0.5
    house.add_child(walls)
    
    # Solid Village Building Collider
    var v_col = StaticBody3D.new()
    var v_shape = CollisionShape3D.new()
    var vb_box = BoxShape3D.new()
    vb_box.size = Vector3(w, h_height + 2.0, d)
    v_shape.shape = vb_box
    v_shape.position.y = 0.8 + h_height * 0.5
    v_col.add_child(v_shape)
    house.add_child(v_col)
    
    var eaves = MeshInstance3D.new()
    var e_box = BoxMesh.new()
    e_box.size = Vector3(w + 1.4, 0.22, d + 1.2)
    e_box.material = chalet_timber_material
    eaves.mesh = e_box
    eaves.position.y = 0.8 + h_height + 0.11
    house.add_child(eaves)

    var roof = MeshInstance3D.new()
    var r_prism = PrismMesh.new()
    r_prism.size = Vector3(w + 1.2, 2.6, d + 1.0)
    r_prism.material = village_terracotta_material if is_terracotta else village_roof_material
    roof.mesh = r_prism
    roof.position.y = 0.8 + h_height + 1.3
    house.add_child(roof)
    
    var chim = MeshInstance3D.new()
    var c_box = BoxMesh.new()
    c_box.size = Vector3(0.75, 2.4, 0.75)
    c_box.material = village_wall_material
    chim.mesh = c_box
    chim.position = Vector3(w * 0.3, 0.8 + h_height + 1.8, d * 0.2)
    house.add_child(chim)
    
    var chim_cap = MeshInstance3D.new()
    var cc_box = BoxMesh.new()
    cc_box.size = Vector3(0.95, 0.14, 0.95)
    cc_box.material = chalet_roof_material
    chim_cap.mesh = cc_box
    chim_cap.position = Vector3(w * 0.3, 0.8 + h_height + 3.05, d * 0.2)
    house.add_child(chim_cap)
    
    # Soft Stylized Volumetric Chimney Smoke (Tiny Glade style)
    var smoke = create_chimney_smoke(Vector3(w * 0.3, 0.8 + h_height + 3.35, d * 0.2))
    house.add_child(smoke)
    
    # Climbing Ivy on lower corner plinth
    if (stories % 2 == 0):
        var ivy = create_climbing_ivy(Vector3(-w * 0.48, 0.6, -d * 0.45))
        house.add_child(ivy)
    
    for s in range(stories):
        var wy = 1.8 + float(s) * 3.0
        for wx in [-1.8, 1.8]:
            var win = MeshInstance3D.new()
            var win_box = BoxMesh.new()
            win_box.size = Vector3(0.95, 1.15, 0.12)
            win_box.material = chalet_window_material
            win.mesh = win_box
            win.position = Vector3(wx, wy, -(d * 0.5 + 0.05))
            house.add_child(win)
            
            for sh_side in [-1.0, 1.0]:
                var shutter = MeshInstance3D.new()
                var s_box = BoxMesh.new()
                s_box.size = Vector3(0.38, 1.15, 0.08)
                s_box.material = chalet_timber_material
                shutter.mesh = s_box
                shutter.position = Vector3(wx + sh_side * 0.65, wy, -(d * 0.5 + 0.05))
                house.add_child(shutter)
                
            var f_box_mesh = MeshInstance3D.new()
            var fb_box = BoxMesh.new()
            fb_box.size = Vector3(1.1, 0.20, 0.30)
            fb_box.material = chalet_timber_material
            f_box_mesh.mesh = fb_box
            f_box_mesh.position = Vector3(wx, wy - 0.65, -(d * 0.5 + 0.18))
            house.add_child(f_box_mesh)
            
            var f_dot = MeshInstance3D.new()
            var fd_sphere = SphereMesh.new()
            fd_sphere.radius = 0.14; fd_sphere.height = 0.18
            f_dot.mesh = fd_sphere
            f_dot.material_override = wildflower_gold_material if (wx > 0) else wildflower_violet_material
            f_dot.position = Vector3(wx, wy - 0.52, -(d * 0.5 + 0.18))
            house.add_child(f_dot)
            
    if stories >= 2:
        var balc = MeshInstance3D.new()
        var balc_box = BoxMesh.new()
        balc_box.size = Vector3(4.8, 0.95, 1.2)
        balc_box.material = chalet_timber_material
        balc.mesh = balc_box
        balc.position = Vector3(0.0, 4.4, -(d * 0.5 + 0.6))
        house.add_child(balc)
        
        # Floral railing boxes on balcony
        for bx_off in [-1.4, 1.4]:
            var b_flower = MeshInstance3D.new()
            var bf_s = SphereMesh.new()
            bf_s.radius = 0.20; bf_s.height = 0.22
            b_flower.mesh = bf_s
            b_flower.material_override = wildflower_violet_material if (bx_off < 0) else wildflower_white_material
            b_flower.position = Vector3(bx_off, 4.95, -(d * 0.5 + 1.25))
            house.add_child(b_flower)
        
    return house

func create_campanile(pos: Vector3) -> Node3D:
    var tower = Node3D.new()
    tower.position = pos
    
    var shaft = MeshInstance3D.new()
    var s_box = BoxMesh.new()
    s_box.size = Vector3(4.6, 15.0, 4.6)
    s_box.material = village_wall_material
    shaft.mesh = s_box
    shaft.position.y = 7.5
    tower.add_child(shaft)
    
    var belfry = MeshInstance3D.new()
    var b_box = BoxMesh.new()
    b_box.size = Vector3(4.8, 3.8, 4.8)
    b_box.material = cobblestone_material
    belfry.mesh = b_box
    belfry.position.y = 16.9
    tower.add_child(belfry)
    
    var bell = MeshInstance3D.new()
    var bell_cyl = CylinderMesh.new()
    bell_cyl.top_radius = 0.22; bell_cyl.bottom_radius = 0.55; bell_cyl.height = 0.95
    bell_cyl.material = pier_wood_material
    bell.mesh = bell_cyl
    bell.position.y = 16.8
    tower.add_child(bell)
    
    var b_light = OmniLight3D.new()
    b_light.light_color = Color(1.0, 0.85, 0.45)
    b_light.light_energy = 1.8
    b_light.omni_range = 14.0
    b_light.position.y = 17.0
    tower.add_child(b_light)
    
    var spire = MeshInstance3D.new()
    var sp_prism = PrismMesh.new()
    sp_prism.size = Vector3(5.2, 5.0, 5.2)
    sp_prism.material = village_roof_material
    spire.mesh = sp_prism
    spire.position.y = 21.3
    tower.add_child(spire)
    
    var cross_v = MeshInstance3D.new()
    var cv_box = BoxMesh.new()
    cv_box.size = Vector3(0.14, 1.4, 0.14)
    cv_box.material = post_material
    cross_v.mesh = cv_box
    cross_v.position.y = 24.5
    tower.add_child(cross_v)
    
    var cross_h = MeshInstance3D.new()
    var ch_box = BoxMesh.new()
    ch_box.size = Vector3(0.8, 0.14, 0.14)
    ch_box.material = post_material
    cross_h.mesh = ch_box
    cross_h.position.y = 24.8
    tower.add_child(cross_h)
    
    # Solid Campanile Stone Tower Collider
    var camp_col = StaticBody3D.new()
    var camp_shape = CollisionShape3D.new()
    var cb_box = BoxShape3D.new()
    cb_box.size = Vector3(4.8, 18.0, 4.8)
    camp_shape.shape = cb_box
    camp_shape.position.y = 9.0
    camp_col.add_child(camp_shape)
    tower.add_child(camp_col)
    
    return tower

func create_piazza_fountain(pos: Vector3) -> Node3D:
    var f_node = Node3D.new()
    f_node.position = pos
    
    var basin = MeshInstance3D.new()
    var b_cyl = CylinderMesh.new()
    b_cyl.top_radius = 2.4; b_cyl.bottom_radius = 2.6; b_cyl.height = 0.85
    b_cyl.radial_segments = 8
    b_cyl.material = village_wall_material
    basin.mesh = b_cyl
    basin.position.y = 0.42
    f_node.add_child(basin)
    
    var w_disc = MeshInstance3D.new()
    var wd_cyl = CylinderMesh.new()
    wd_cyl.top_radius = 2.15; wd_cyl.bottom_radius = 2.15; wd_cyl.height = 0.12
    wd_cyl.radial_segments = 8
    wd_cyl.material = water_material
    w_disc.mesh = wd_cyl
    w_disc.position.y = 0.72
    f_node.add_child(w_disc)
    
    var col = MeshInstance3D.new()
    var col_cyl = CylinderMesh.new()
    col_cyl.top_radius = 0.35; col_cyl.bottom_radius = 0.42; col_cyl.height = 2.4
    col_cyl.material = cobblestone_material
    col.mesh = col_cyl
    col.position.y = 1.2
    f_node.add_child(col)
    
    var urn = MeshInstance3D.new()
    var u_sph = SphereMesh.new()
    u_sph.radius = 0.42; u_sph.height = 0.85
    u_sph.material = cobblestone_material
    urn.mesh = u_sph
    urn.position.y = 2.6
    f_node.add_child(urn)
    
    # Solid Fountain Basin Collider
    var f_col = StaticBody3D.new()
    var f_shape = CollisionShape3D.new()
    var fc_cyl = CylinderShape3D.new()
    fc_cyl.radius = 2.5
    fc_cyl.height = 1.8
    f_shape.shape = fc_cyl
    f_shape.position.y = 0.9
    f_col.add_child(f_shape)
    f_node.add_child(f_col)
    
    return f_node

func create_street_lantern(pos: Vector3, is_facing_left: bool = false) -> Node3D:
    var lantern = Node3D.new()
    lantern.position = pos
    
    var post = MeshInstance3D.new()
    var p_cyl = CylinderMesh.new()
    p_cyl.top_radius = 0.08; p_cyl.bottom_radius = 0.14; p_cyl.height = 3.4
    p_cyl.material = chalet_roof_material
    post.mesh = p_cyl
    post.position.y = 1.7
    lantern.add_child(post)
    
    var dir_x = -1.0 if is_facing_left else 1.0
    var bracket = MeshInstance3D.new()
    var b_box = BoxMesh.new()
    b_box.size = Vector3(0.75, 0.12, 0.12)
    b_box.material = chalet_roof_material
    bracket.mesh = b_box
    bracket.position = Vector3(dir_x * 0.35, 3.4, 0.0)
    lantern.add_child(bracket)
    
    var glass = MeshInstance3D.new()
    var g_box = BoxMesh.new()
    g_box.size = Vector3(0.42, 0.58, 0.42)
    var g_mat = StandardMaterial3D.new()
    g_mat.albedo_color = Color(1.0, 0.72, 0.20) # Calda luce al sodio 1993
    g_mat.emission_enabled = true
    g_mat.emission = Color(1.0, 0.72, 0.20)
    g_mat.emission_energy_multiplier = 4.5
    glass.mesh = g_box
    glass.material_override = g_mat
    glass.position = Vector3(dir_x * 0.65, 3.15, 0.0)
    lantern.add_child(glass)
    
    # Caldo bagliore diffuso al sodio
    var light = OmniLight3D.new()
    light.light_color = Color(1.0, 0.72, 0.20)
    light.light_energy = 2.8
    light.omni_range = 18.0
    light.position = Vector3(dir_x * 0.65, 3.0, 0.0)
    lantern.add_child(light)
    
    # Fascio concentrato verso il manto stradale / ciottoli
    var spot = SpotLight3D.new()
    spot.light_color = Color(1.0, 0.74, 0.24)
    spot.light_energy = 3.6
    spot.spot_range = 14.0
    spot.spot_angle = 55.0
    spot.position = Vector3(dir_x * 0.65, 3.0, 0.0)
    spot.rotation.x = -PI * 0.5
    lantern.add_child(spot)
    
    return lantern

func create_cypress_tree(pos: Vector3) -> Node3D:
    var tree = Node3D.new()
    tree.position = pos
    
    var trunk = MeshInstance3D.new()
    var t_cyl = CylinderMesh.new()
    t_cyl.top_radius = 0.12; t_cyl.bottom_radius = 0.22; t_cyl.height = 2.4
    t_cyl.material = chalet_timber_material
    trunk.mesh = t_cyl
    trunk.position.y = 0.4 # Sinks 0.8m into soil
    tree.add_child(trunk)
    
    var flare = MeshInstance3D.new()
    var flare_cyl = CylinderMesh.new()
    flare_cyl.top_radius = 0.20; flare_cyl.bottom_radius = 0.42; flare_cyl.height = 0.50
    flare_cyl.material = chalet_timber_material
    flare.mesh = flare_cyl
    flare.position.y = 0.10
    tree.add_child(flare)
    
    var fol = MeshInstance3D.new()
    var f_cyl = CylinderMesh.new()
    f_cyl.top_radius = 0.15; f_cyl.bottom_radius = 0.85; f_cyl.height = 6.2
    f_cyl.material = pine_material
    fol.mesh = f_cyl
    fol.position.y = 4.2
    tree.add_child(fol)
    
    # Solid Cypress Trunk Collider
    var c_col = StaticBody3D.new()
    var c_shape = CollisionShape3D.new()
    var cc_cyl = CylinderShape3D.new()
    cc_cyl.radius = 0.40
    cc_cyl.height = 4.5
    c_shape.shape = cc_cyl
    c_shape.position.y = 2.25
    c_col.add_child(c_shape)
    tree.add_child(c_col)
    
    return tree

func create_windmill(pos: Vector3) -> Node3D:
    var mill = Node3D.new()
    mill.position = pos
    
    var tower = MeshInstance3D.new()
    var t_cyl = CylinderMesh.new()
    t_cyl.top_radius = 2.6; t_cyl.bottom_radius = 3.4; t_cyl.height = 9.5
    t_cyl.radial_segments = 14
    t_cyl.material = village_wall_material
    tower.mesh = t_cyl
    tower.position.y = 4.75
    mill.add_child(tower)
    
    # Solid Windmill Masonry Base Collider
    var wm_col = StaticBody3D.new()
    var wm_shape = CollisionShape3D.new()
    var wmc_cyl = CylinderShape3D.new()
    wmc_cyl.radius = 3.2
    wmc_cyl.height = 9.5
    wm_shape.shape = wmc_cyl
    wm_shape.position.y = 4.75
    wm_col.add_child(wm_shape)
    mill.add_child(wm_col)
    
    var roof = MeshInstance3D.new()
    var r_cone = CylinderMesh.new()
    r_cone.top_radius = 0.08; r_cone.bottom_radius = 3.0; r_cone.height = 3.4
    r_cone.radial_segments = 14
    r_cone.material = village_roof_material
    roof.mesh = r_cone
    roof.position.y = 11.2
    mill.add_child(roof)
    
    var hub = MeshInstance3D.new()
    var h_cyl = CylinderMesh.new()
    h_cyl.top_radius = 0.45; h_cyl.bottom_radius = 0.45; h_cyl.height = 0.95
    h_cyl.material = chalet_timber_material
    hub.mesh = h_cyl
    hub.position = Vector3(-2.8, 9.2, 0.0)
    hub.rotation.z = PI * 0.5
    mill.add_child(hub)
    
    for a in range(4):
        var arm_ang = float(a) * (PI * 0.5) + 0.35
        var sail = MeshInstance3D.new()
        var s_box = BoxMesh.new()
        s_box.size = Vector3(0.12, 5.5, 1.2)
        s_box.material = windmill_sail_material
        sail.mesh = s_box
        sail.position = Vector3(-3.1, 9.2 + sin(arm_ang) * 3.0, cos(arm_ang) * 3.0)
        sail.rotation.x = -arm_ang
        mill.add_child(sail)
        
    return mill

# =========================================================================
# 8. STAZIONI DI SERVIZIO & AMENITÀ (Gas Station & Amenities)
# =========================================================================
func spawn_service_station(root: Node3D, points: Array, start_z: float):
    if (start_z >= 1380.0 and start_z < 1500.0) or (start_z >= 3120.0 and start_z < 3240.0):
        var num_pts = points.size()
        var mid_p = points[int(num_pts * 0.5)]
        var station = Node3D.new()
        var is_alpine_pass = start_z < 2000.0
        var station_name = "STAZIONE AGIP '93 - PIANURA DEI PODERI" if is_alpine_pass else "AUTOGRILL VALICO DEL MERIDIANO"
        var forecourt_x = mid_p.x + (mid_p.width * 0.5) + 10.0
        var forecourt_y = mid_p.y
        var forecourt_z = mid_p.z
        
        # 1. Road-following Paved Forecourt Apron (12 contiguous slices with solid physics collision)
        var apron_length = 72.0
        var num_slices = 12
        var slice_dz = apron_length / float(num_slices)
        for s in range(num_slices):
            var sz_start = forecourt_z - apron_length * 0.5 + float(s) * slice_dz
            var sz_end = sz_start + slice_dz
            var sz_mid = (sz_start + sz_end) * 0.5
            var r_slice = get_road_info_at(sz_mid)
            var rx = r_slice.x if r_slice.found else mid_p.x
            var ry = r_slice.y if r_slice.found else forecourt_y
            var rw = r_slice.width if r_slice.found else 9.0
            var r_ang = r_slice.angle if r_slice.found else 0.0
            
            var apron_w = 26.0
            var apron_x = rx + (rw * 0.5 - 0.4) + apron_w * 0.5
            var slice_mesh = MeshInstance3D.new()
            # Massicciata di fondazione profonda (4.5m) ancorata saldamente al suolo montano
            var s_box = BoxMesh.new()
            s_box.size = Vector3(apron_w, 4.5, slice_dz * 1.05)
            s_box.material = cobblestone_material
            slice_mesh.mesh = s_box
            slice_mesh.position = Vector3(apron_x, ry + 0.06 - 2.25, sz_mid)
            slice_mesh.rotation.y = r_ang
            
            # Muro di sostegno esterno in pietra (retaining wall) lungo il bordo valle del piazzale
            var wall_mesh = MeshInstance3D.new()
            var w_box = BoxMesh.new()
            w_box.size = Vector3(0.70, 5.2, slice_dz * 1.05)
            w_box.material = cobblestone_material
            wall_mesh.mesh = w_box
            wall_mesh.position = Vector3(apron_x + apron_w * 0.5 - 0.25, ry + 0.06 - 2.5, sz_mid)
            wall_mesh.rotation.y = r_ang
            station.add_child(wall_mesh)
            
            # Solid Paved Forecourt Apron Collider (guarantees car wheels NEVER sink through asphalt/cobblestone!)
            var apron_body = StaticBody3D.new()
            var apron_col = CollisionShape3D.new()
            var col_box = BoxShape3D.new()
            col_box.size = Vector3(apron_w + 0.6, 4.6, slice_dz * 1.06)
            apron_col.shape = col_box
            apron_col.position.y = 0.0 # Top surface exactly flush at ry + 0.06m
            apron_body.add_child(apron_col)
            slice_mesh.add_child(apron_body)
            
            station.add_child(slice_mesh)
            
        # 1b. Yellow Painted Ground Chevrons & Service Bay Markings
        for mark_z in [-10.0, -5.0, 0.0, 5.0, 10.0]:
            var mark = MeshInstance3D.new()
            var m_box = BoxMesh.new()
            m_box.size = Vector3(5.5, 0.03, 0.35)
            m_box.material = service_pump_material # Yellow paint
            mark.mesh = m_box
            mark.position = Vector3(forecourt_x - 3.5, forecourt_y + 0.18, forecourt_z + mark_z)
            station.add_child(mark)
            
        # Entry / Exit Service Chevron Strips
        for ch_side in [-26.0, 26.0]:
            var chevron = MeshInstance3D.new()
            var ch_box = BoxMesh.new()
            ch_box.size = Vector3(6.5, 0.03, 0.45)
            ch_box.material = service_pump_material
            chevron.mesh = ch_box
            chevron.position = Vector3(forecourt_x - 5.0, forecourt_y + 0.18, forecourt_z + ch_side)
            chevron.rotation.y = deg_to_rad(30.0 if ch_side < 0 else -30.0)
            station.add_child(chevron)
        
        # 2. Translucent Glass Fuel Canopy Structure
        var canopy_pos = Vector3(mid_p.x + 12.5, forecourt_y, forecourt_z - 4.0)
        var canopy = Node3D.new()
        canopy.position = canopy_pos
        
        # Semi-transparent crystalline glass roof (car underneath remains 100% visible from above!)
        var roof = MeshInstance3D.new()
        var r_box = BoxMesh.new()
        r_box.size = Vector3(10.2, 0.06, 23.6)
        r_box.material = service_canopy_material
        roof.mesh = r_box
        roof.position.y = 5.2
        canopy.add_child(roof)
        
        # Steel Truss Roof Perimeter Fascia (Agip / Autogrill yellow trim around outer edges only)
        # North & South outer fascia rims
        for rim_z in [-12.0, 12.0]:
            var fascia_ns = MeshInstance3D.new()
            var f_ns_box = BoxMesh.new()
            f_ns_box.size = Vector3(10.6, 0.48, 0.35)
            f_ns_box.material = service_pump_material
            fascia_ns.mesh = f_ns_box
            fascia_ns.position = Vector3(0.0, 5.2, rim_z)
            canopy.add_child(fascia_ns)
            
        # East & West outer fascia rims
        for rim_x in [-5.25, 5.25]:
            var fascia_ew = MeshInstance3D.new()
            var f_ew_box = BoxMesh.new()
            f_ew_box.size = Vector3(0.35, 0.48, 24.2)
            f_ew_box.material = service_pump_material
            fascia_ew.mesh = f_ew_box
            fascia_ew.position = Vector3(rim_x, 5.2, 0.0)
            canopy.add_child(fascia_ew)
            
            if rim_x < 0.0:
                var c_lbl = Label3D.new()
                c_lbl.text = "AGIP SINT 2000"
                c_lbl.font_size = 44
                c_lbl.modulate = Color(0.10, 0.10, 0.12)
                c_lbl.outline_modulate = Color(0.96, 0.74, 0.16)
                c_lbl.outline_size = 6
                c_lbl.position = Vector3(rim_x - 0.22, 5.2, 0.0)
                c_lbl.rotation.y = -PI * 0.5
                canopy.add_child(c_lbl)
        
        # Steel structural cross-trusses supporting the glass roof
        for truss_z in [-9.0, -4.5, 0.0, 4.5, 9.0]:
            var truss = MeshInstance3D.new()
            var tb_box = BoxMesh.new()
            tb_box.size = Vector3(10.2, 0.12, 0.18)
            tb_box.material = guardrail_material
            truss.mesh = tb_box
            truss.position = Vector3(0.0, 5.12, truss_z)
            canopy.add_child(truss)
        
        # 2b. Solid Canopy Columns
        for col_z in [-7.5, 7.5]:
            var col = MeshInstance3D.new()
            var c_cyl = CylinderMesh.new()
            c_cyl.top_radius = 0.30; c_cyl.bottom_radius = 0.32; c_cyl.height = 5.0
            c_cyl.material = guardrail_material
            col.mesh = c_cyl
            col.position = Vector3(0.0, 2.5, col_z)
            
            # Solid Column Physics Collider
            var col_body = StaticBody3D.new()
            var col_cs = CollisionShape3D.new()
            var col_shape = CylinderShape3D.new()
            col_shape.radius = 0.38
            col_shape.height = 5.0
            col_cs.shape = col_shape
            col_body.add_child(col_cs)
            col.add_child(col_body)
            canopy.add_child(col)
            
            var bollard = MeshInstance3D.new()
            var b_cyl = CylinderMesh.new()
            b_cyl.top_radius = 0.44; b_cyl.bottom_radius = 0.46; b_cyl.height = 0.85
            b_cyl.material = service_pump_material
            bollard.mesh = b_cyl
            bollard.position = Vector3(0.0, 0.42, col_z)
            canopy.add_child(bollard)
            
        # Overhead floodlights illuminating vehicle and pumps
        for light_z in [-8.0, 0.0, 8.0]:
            var downlight = OmniLight3D.new()
            downlight.light_color = Color(0.98, 0.98, 1.0)
            downlight.light_energy = 0.45
            downlight.omni_range = 10.0
            downlight.position = Vector3(0.0, 4.8, light_z)
            canopy.add_child(downlight)
            
        # 3. Solid Fuel Pump Islands
        for pump_z in [-5.0, 5.0]:
            var pump_island = Node3D.new()
            pump_island.position = Vector3(0.0, 0.0, pump_z)
            
            var plinth = MeshInstance3D.new()
            var p_box = BoxMesh.new()
            p_box.size = Vector3(1.3, 0.28, 5.2)
            p_box.material = cobblestone_material
            plinth.mesh = p_box
            plinth.position.y = 0.14
            pump_island.add_child(plinth)
            
            var dispenser = create_fuel_dispenser(Vector3(0.0, 0.28, 0.0))
            pump_island.add_child(dispenser)
            
            # Solid Pump Island Collider
            var p_col_body = StaticBody3D.new()
            var p_col_cs = CollisionShape3D.new()
            var p_shape = BoxShape3D.new()
            p_shape.size = Vector3(1.3, 2.0, 5.2)
            p_col_cs.shape = p_shape
            p_col_cs.position.y = 1.0
            p_col_body.add_child(p_col_cs)
            pump_island.add_child(p_col_body)
            
            canopy.add_child(pump_island)
            
        station.add_child(canopy)
        
        # 4. Service Station Shop / Autogrill Building
        var shop_pos = Vector3(mid_p.x + 23.5, forecourt_y, forecourt_z)
        var shop = Node3D.new()
        shop.position = shop_pos
        
        # Two-tone Alpine Architecture: Plaster / Stone with Timber Framing
        var bld_mesh = MeshInstance3D.new()
        var b_box = BoxMesh.new()
        b_box.size = Vector3(11.0, 3.4, 20.0)
        b_box.material = village_wall_material # Alpine stone plaster main floor
        bld_mesh.mesh = b_box
        bld_mesh.position.y = 2.2
        shop.add_child(bld_mesh)
        
        # Upper Timber Loft Story
        var loft_mesh = MeshInstance3D.new()
        var l_box = BoxMesh.new()
        l_box.size = Vector3(11.2, 2.8, 20.2)
        l_box.material = chalet_timber_material
        loft_mesh.mesh = l_box
        loft_mesh.position.y = 5.2
        shop.add_child(loft_mesh)
        
        # Upper Loft Windows with Alpine Shutters
        for l_win_z in [-6.0, 0.0, 6.0]:
            var l_win = MeshInstance3D.new()
            var lw_box = BoxMesh.new()
            lw_box.size = Vector3(0.12, 1.1, 1.4)
            lw_box.material = chalet_window_material
            l_win.mesh = lw_box
            l_win.position = Vector3(-5.62, 5.2, l_win_z)
            shop.add_child(l_win)
            
            # Timber Geranium Flower Box (Fioriera con gerani rossi alpini)
            var fioriera = MeshInstance3D.new()
            var f_box = BoxMesh.new()
            f_box.size = Vector3(0.24, 0.26, 1.6)
            f_box.material = chalet_timber_material
            fioriera.mesh = f_box
            fioriera.position = Vector3(-5.72, 4.5, l_win_z)
            shop.add_child(fioriera)
            
            # Vibrant Red Alpine Geranium Blooms
            for g_i in range(3):
                var bloom = MeshInstance3D.new()
                var bl_box = BoxMesh.new()
                bl_box.size = Vector3(0.20, 0.18, 0.38)
                var bl_mat = StandardMaterial3D.new()
                bl_mat.albedo_color = Color(0.92, 0.12, 0.14)
                bl_mat.roughness = 0.80
                bloom.mesh = bl_box
                bloom.material_override = bl_mat
                bloom.position = Vector3(-5.75, 4.65, l_win_z - 0.45 + float(g_i) * 0.45)
                shop.add_child(bloom)
        
        # Stone base plinth (1m height)
        var base_mesh = MeshInstance3D.new()
        var ba_box = BoxMesh.new()
        ba_box.size = Vector3(11.4, 1.0, 20.4)
        ba_box.material = cobblestone_material
        base_mesh.mesh = ba_box
        base_mesh.position.y = 0.5
        shop.add_child(base_mesh)
        
        # Solid Shop Building Collider
        var s_col_body = StaticBody3D.new()
        var s_col_cs = CollisionShape3D.new()
        var s_shape = BoxShape3D.new()
        s_shape.size = Vector3(11.0, 6.5, 20.0)
        s_col_cs.shape = s_shape
        s_col_cs.position.y = 3.1
        s_col_body.add_child(s_col_cs)
        shop.add_child(s_col_body)
        
        # Glazed Storefront Facade (facing pumps at local X = -5.55):
        # 4a. Tinted Glass Showfront Windows (replaces the flat white wall!)
        var glass_front = MeshInstance3D.new()
        var g_box = BoxMesh.new()
        g_box.size = Vector3(0.08, 2.8, 16.0)
        g_box.material = service_canopy_material # Clear tinted glass
        glass_front.mesh = g_box
        glass_front.position = Vector3(-5.54, 2.4, 0.0)
        shop.add_child(glass_front)
        
        # 4b. Dark Aluminum Window Mullions & Transoms
        for mul_z in [-7.5, -5.0, -2.5, 0.0, 2.5, 5.0, 7.5]:
            var mullion = MeshInstance3D.new()
            var m_box = BoxMesh.new()
            m_box.size = Vector3(0.16, 2.85, 0.12)
            m_box.material = guardrail_material
            mullion.mesh = m_box
            mullion.position = Vector3(-5.55, 2.4, mul_z)
            shop.add_child(mullion)
            
        var transom = MeshInstance3D.new()
        var tr_box = BoxMesh.new()
        tr_box.size = Vector3(0.16, 0.12, 16.0)
        tr_box.material = guardrail_material
        transom.mesh = tr_box
        transom.position = Vector3(-5.55, 3.2, 0.0)
        shop.add_child(transom)
        
        # 4c. Interior Espresso Bar Counter (visible through glass)
        var bar_counter = MeshInstance3D.new()
        var bc_box = BoxMesh.new()
        bc_box.size = Vector3(1.2, 1.0, 8.0)
        bc_box.material = chalet_timber_material
        bar_counter.mesh = bc_box
        bar_counter.position = Vector3(-3.8, 1.0, 0.0)
        shop.add_child(bar_counter)
        
        # Warm ambient interior illumination
        var shop_light = OmniLight3D.new()
        shop_light.light_color = Color(1.0, 0.88, 0.65)
        shop_light.light_energy = 1.2
        shop_light.omni_range = 10.0
        shop_light.position = Vector3(-2.0, 2.8, 0.0)
        shop.add_child(shop_light)
        
        # 4d. Architectural Illuminated Fascia Sign
        var sign_base = MeshInstance3D.new()
        var sb_box = BoxMesh.new()
        sb_box.size = Vector3(0.35, 1.1, 10.0)
        sb_box.material = service_pump_material if is_alpine_pass else chalet_roof_material
        sign_base.mesh = sb_box
        sign_base.position = Vector3(-5.6, 4.4, 0.0)
        shop.add_child(sign_base)
        
        var sign_inner = MeshInstance3D.new()
        var si_box = BoxMesh.new()
        si_box.size = Vector3(0.38, 0.75, 9.2)
        si_box.material = lantern_glow_material
        sign_inner.mesh = si_box
        sign_inner.position = Vector3(-5.62, 4.4, 0.0)
        shop.add_child(sign_inner)
        
        var shop_label = Label3D.new()
        shop_label.text = "AUTOGRILL & BAR RISTORO '89"
        shop_label.font_size = 38
        shop_label.modulate = Color(0.12, 0.12, 0.14)
        shop_label.outline_modulate = Color(1.0, 0.85, 0.28)
        shop_label.outline_size = 5
        shop_label.position = Vector3(-5.85, 4.4, 0.0)
        shop_label.rotation.y = -PI * 0.5
        shop.add_child(shop_label)
        
        var shop_roof = MeshInstance3D.new()
        var r_prism = PrismMesh.new()
        r_prism.size = Vector3(12.0, 2.0, 21.0)
        r_prism.material = chalet_roof_material
        shop_roof.mesh = r_prism
        shop_roof.position.y = 7.2
        shop.add_child(shop_roof)
        
        station.add_child(shop)
        
        # 5. Terrace Café Tables
        var terrace_pos = Vector3(mid_p.x + 22.0, forecourt_y, forecourt_z + 18.0)
        for t_off in [-4.5, 0.0, 4.5]:
            var table_pos = Vector3(terrace_pos.x - 2.5, terrace_pos.y, terrace_pos.z + t_off)
            var cafe_table = create_cafe_table(table_pos, t_off != 0.0)
            station.add_child(cafe_table)
            
        # 6. Fuel Price Totem Sign (safely placed 5.2m outside road verge, NEVER in the lane!)
        var totem_z = forecourt_z - 28.0
        var r_tot = get_road_info_at(totem_z)
        var totem_x = (r_tot.x if r_tot.found else mid_p.x) + (r_tot.width * 0.5 if r_tot.found else 4.5) + 8.5
        var totem_y = r_tot.y if r_tot.found else forecourt_y
        var totem_pos = Vector3(totem_x, totem_y, totem_z)
        var totem = create_price_totem(totem_pos)
        if r_tot.found:
            totem.rotation.y = r_tot.angle
            
        var t_col_body = StaticBody3D.new()
        var t_col_cs = CollisionShape3D.new()
        var t_shape = BoxShape3D.new()
        t_shape.size = Vector3(1.4, 6.5, 0.8)
        t_col_cs.shape = t_shape
        t_col_cs.position.y = 3.25
        t_col_body.add_child(t_col_cs)
        totem.add_child(t_col_body)
        station.add_child(totem)
        
        # 7. Register Service Station for Physics & Interaction Queries
        active_service_stations.append({
            "name": station_name,
            "type": "autogrill_bar",
            "center": Vector3(forecourt_x, forecourt_y, forecourt_z),
            "bay_center": Vector3(mid_p.x + 12.5, forecourt_y, forecourt_z - 4.0),
            "pump_bay_min": Vector3(mid_p.x + 6.0, forecourt_y - 2.0, forecourt_z - 18.0),
            "pump_bay_max": Vector3(mid_p.x + 19.0, forecourt_y + 4.0, forecourt_z + 10.0),
            "forecourt_min_x": mid_p.x + 3.5,
            "forecourt_max_x": mid_p.x + 34.0,
            "z_min": mid_p.z - 40.0,
            "z_max": mid_p.z + 40.0
        })
        
        root.add_child(station)

func get_service_station_at(query_pos: Vector3) -> Dictionary:
    for st in active_service_stations:
        if query_pos.z >= st.z_min and query_pos.z <= st.z_max:
            if query_pos.x >= st.forecourt_min_x and query_pos.x <= st.forecourt_max_x:
                var in_bay = (query_pos.x >= st.pump_bay_min.x and query_pos.x <= st.pump_bay_max.x
                            and query_pos.z >= st.pump_bay_min.z and query_pos.z <= st.pump_bay_max.z)
                return { 
                    "found": true, 
                    "name": st.name, 
                    "type": st.get("type", "autogrill_bar"),
                    "in_bay": in_bay, 
                    "bay_center": st.bay_center 
                }
    return { "found": false, "in_bay": false, "name": "", "type": "" }

func is_in_service_forecourt(query_pos: Vector3) -> bool:
    for st in active_service_stations:
        if query_pos.z >= st.z_min and query_pos.z <= st.z_max:
            if query_pos.x >= st.forecourt_min_x and query_pos.x <= st.forecourt_max_x:
                return true
    return false

func create_fuel_dispenser(pos: Vector3) -> Node3D:
    var disp = Node3D.new()
    disp.position = pos
    
    # Main dispenser housing (Agip yellow body with dark side panels)
    var body = MeshInstance3D.new()
    var b_box = BoxMesh.new()
    b_box.size = Vector3(0.75, 1.65, 1.35)
    b_box.material = service_pump_material
    body.mesh = b_box
    body.position.y = 0.82
    disp.add_child(body)
    
    # Dark side panels
    for side in [-1.0, 1.0]:
        var side_p = MeshInstance3D.new()
        var sp_box = BoxMesh.new()
        sp_box.size = Vector3(0.77, 1.60, 0.15)
        sp_box.material = chalet_roof_material
        side_p.mesh = sp_box
        side_p.position = Vector3(0.0, 0.82, side * 0.60)
        disp.add_child(side_p)
        
    # Counter Bezel
    var disp_win = MeshInstance3D.new()
    var dw_box = BoxMesh.new()
    dw_box.size = Vector3(0.78, 0.42, 0.85)
    dw_box.material = chalet_roof_material
    disp_win.mesh = dw_box
    disp_win.position.y = 1.15
    disp.add_child(disp_win)
    
    # Counter dials display
    var screen = MeshInstance3D.new()
    var sc_box = BoxMesh.new()
    sc_box.size = Vector3(0.79, 0.28, 0.70)
    sc_box.material = post_material
    screen.mesh = sc_box
    screen.position.y = 1.15
    disp.add_child(screen)
    
    # Fuel hoses & chrome nozzles
    for side in [-1.0, 1.0]:
        var hose = MeshInstance3D.new()
        var h_cyl = CylinderMesh.new()
        h_cyl.top_radius = 0.035; h_cyl.bottom_radius = 0.035; h_cyl.height = 1.05
        h_cyl.material = post_material
        hose.mesh = h_cyl
        hose.position = Vector3(0.0, 0.75, side * 0.68)
        disp.add_child(hose)
        
        var nozzle = MeshInstance3D.new()
        var n_box = BoxMesh.new()
        n_box.size = Vector3(0.10, 0.35, 0.10)
        n_box.material = guardrail_material
        nozzle.mesh = n_box
        nozzle.position = Vector3(0.0, 0.95, side * 0.68)
        disp.add_child(nozzle)
        
    # Curved safety crash pipe bollards on island ends
    for b_side in [-2.2, 2.2]:
        var bollard = MeshInstance3D.new()
        var c_cyl = CylinderMesh.new()
        c_cyl.top_radius = 0.06; c_cyl.bottom_radius = 0.06; c_cyl.height = 0.85
        c_cyl.material = guardrail_material
        bollard.mesh = c_cyl
        bollard.position = Vector3(0.0, 0.42, b_side)
        disp.add_child(bollard)
        
    return disp

func create_cafe_table(pos: Vector3, has_parasol: bool) -> Node3D:
    var table = Node3D.new()
    table.position = pos
    
    var top = MeshInstance3D.new()
    var t_cyl = CylinderMesh.new()
    t_cyl.top_radius = 0.65; t_cyl.bottom_radius = 0.65; t_cyl.height = 0.08
    t_cyl.material = guardrail_material
    top.mesh = t_cyl
    top.position.y = 0.75
    table.add_child(top)
    
    var leg = MeshInstance3D.new()
    var l_cyl = CylinderMesh.new()
    l_cyl.top_radius = 0.06; l_cyl.bottom_radius = 0.25; l_cyl.height = 0.72
    l_cyl.material = guardrail_material
    leg.mesh = l_cyl
    leg.position.y = 0.36
    table.add_child(leg)
    
    for ch_x in [-1.05, 1.05]:
        var chair = MeshInstance3D.new()
        var c_box = BoxMesh.new()
        c_box.size = Vector3(0.42, 0.45, 0.42)
        c_box.material = chalet_timber_material
        chair.mesh = c_box
        chair.position = Vector3(ch_x, 0.22, 0.0)
        table.add_child(chair)
        
    if has_parasol:
        var pole = MeshInstance3D.new()
        var p_cyl = CylinderMesh.new()
        p_cyl.top_radius = 0.04; p_cyl.bottom_radius = 0.04; p_cyl.height = 2.4
        p_cyl.material = guardrail_material
        pole.mesh = p_cyl
        pole.position.y = 1.2
        table.add_child(pole)
        
        var canopy_m = MeshInstance3D.new()
        var c_prism = CylinderMesh.new()
        c_prism.top_radius = 0.08; c_prism.bottom_radius = 1.45; c_prism.height = 0.55
        c_prism.material = service_pump_material
        canopy_m.mesh = c_prism
        canopy_m.position.y = 2.3
        table.add_child(canopy_m)
        
    return table

func create_price_totem(pos: Vector3) -> Node3D:
    var totem = Node3D.new()
    totem.position = pos
    
    # 1. Concrete ground plinth
    var plinth = MeshInstance3D.new()
    var pl_box = BoxMesh.new()
    pl_box.size = Vector3(0.70, 0.40, 1.8)
    pl_box.material = cobblestone_material
    plinth.mesh = pl_box
    plinth.position.y = 0.20
    totem.add_child(plinth)
    
    # 2. Twin steel vertical pylon posts
    for pz in [-0.55, 0.55]:
        var post = MeshInstance3D.new()
        var po_box = BoxMesh.new()
        po_box.size = Vector3(0.22, 5.4, 0.22)
        po_box.material = guardrail_material
        post.mesh = po_box
        post.position = Vector3(0.0, 2.7, pz)
        totem.add_child(post)
        
    # 3. Dark charcoal price display bezel
    var bezel = MeshInstance3D.new()
    var bz_box = BoxMesh.new()
    bz_box.size = Vector3(0.32, 2.6, 1.45)
    bz_box.material = chalet_roof_material
    bezel.mesh = bz_box
    bezel.position.y = 2.4
    totem.add_child(bezel)
    
    # 4. LED price lines (Super 98 & Diesel)
    for l_y in [1.8, 2.4, 3.0]:
        var led = MeshInstance3D.new()
        var l_box = BoxMesh.new()
        l_box.size = Vector3(0.36, 0.22, 1.25)
        l_box.material = lantern_glow_material
        led.mesh = l_box
        led.position.y = l_y
        totem.add_child(led)
        
    # 5. Agip / Autogrill brand header box at top
    var header = MeshInstance3D.new()
    var h_box = BoxMesh.new()
    h_box.size = Vector3(0.36, 1.35, 1.55)
    h_box.material = service_pump_material
    header.mesh = h_box
    header.position.y = 4.7
    totem.add_child(header)
    
    return totem

func spawn_scenic_amenities(root: Node3D, points: Array, start_z: float):
    var num_pts = points.size()
    var mid_p = points[int(num_pts * 0.5)]
    
    # 8a. BELVEDERE PANORAMICO DEL LAGO (Z in [460, 520])
    if start_z >= 460.0 and start_z < 520.0:
        var belvedere = Node3D.new()
        var b_x = mid_p.x - (mid_p.width * 0.5 + 7.5)
        var b_y = mid_p.y
        var b_z = mid_p.z
        belvedere.position = Vector3(b_x, b_y, b_z)
        
        var terrace = MeshInstance3D.new()
        var t_cyl = CylinderMesh.new()
        t_cyl.top_radius = 8.5; t_cyl.bottom_radius = 9.0; t_cyl.height = 0.35
        t_cyl.material = cobblestone_material
        terrace.mesh = t_cyl
        terrace.position.y = 0.18
        belvedere.add_child(terrace)
        
        for ang_deg in range(120, 240, 20):
            var rad = deg_to_rad(float(ang_deg))
            var post = MeshInstance3D.new()
            var p_box = BoxMesh.new()
            p_box.size = Vector3(0.35, 1.05, 0.35)
            p_box.material = bridge_stone_material
            post.mesh = p_box
            post.position = Vector3(cos(rad) * 8.0, 0.68, sin(rad) * 8.0)
            belvedere.add_child(post)
            
        var orient_table = MeshInstance3D.new()
        var ot_box = BoxMesh.new()
        ot_box.size = Vector3(1.2, 0.95, 0.8)
        ot_box.material = bridge_stone_material
        orient_table.mesh = ot_box
        orient_table.position = Vector3(-7.2, 0.65, 0.0)
        belvedere.add_child(orient_table)
        
        var telescope = Node3D.new()
        telescope.position = Vector3(-6.8, 0.85, 2.8)
        var t_stand = MeshInstance3D.new()
        var ts_cyl = CylinderMesh.new()
        ts_cyl.top_radius = 0.08; ts_cyl.bottom_radius = 0.14; ts_cyl.height = 1.2
        ts_cyl.material = guardrail_material
        t_stand.mesh = ts_cyl
        t_stand.position.y = 0.6
        telescope.add_child(t_stand)
        
        var t_barrel = MeshInstance3D.new()
        var tb_cyl = CylinderMesh.new()
        tb_cyl.top_radius = 0.09; tb_cyl.bottom_radius = 0.07; tb_cyl.height = 0.65
        tb_cyl.material = guardrail_material
        t_barrel.mesh = tb_cyl
        t_barrel.position = Vector3(0.0, 1.22, 0.0)
        t_barrel.rotation.z = PI * 0.5 - 0.25
        telescope.add_child(t_barrel)
        belvedere.add_child(telescope)
        
        for p_off in [-3.5, 3.5]:
            var picnic = create_picnic_table(Vector3(1.2, 0.18, p_off), 0.0)
            belvedere.add_child(picnic)
            
        root.add_child(belvedere)

    # 8b. EDICOLA VOTIVA ALPINA (Gola del Meridiano, Z in [2160, 2200])
    elif start_z >= 2160.0 and start_z < 2200.0:
        var shrine = Node3D.new()
        var s_x = mid_p.x + (mid_p.width * 0.5 + 4.5)
        shrine.position = Vector3(s_x, mid_p.y, mid_p.z)
        
        var niche = MeshInstance3D.new()
        var n_box = BoxMesh.new()
        n_box.size = Vector3(1.4, 2.5, 1.2)
        n_box.material = village_wall_material
        niche.mesh = n_box
        niche.position.y = 1.25
        shrine.add_child(niche)
        
        var s_roof = MeshInstance3D.new()
        var sr_prism = PrismMesh.new()
        sr_prism.size = Vector3(1.8, 0.9, 1.5)
        sr_prism.material = chalet_roof_material
        s_roof.mesh = sr_prism
        s_roof.position.y = 2.9
        shrine.add_child(s_roof)
        
        var candle = MeshInstance3D.new()
        var c_cyl = CylinderMesh.new()
        c_cyl.top_radius = 0.06; c_cyl.bottom_radius = 0.07; c_cyl.height = 0.25
        c_cyl.material = lantern_glow_material
        candle.mesh = c_cyl
        candle.position = Vector3(-0.45, 1.3, 0.0)
        shrine.add_child(candle)
        
        var candle_light = OmniLight3D.new()
        candle_light.light_color = Color(1.0, 0.75, 0.35)
        candle_light.light_energy = 1.5
        candle_light.omni_range = 6.0
        candle_light.position = Vector3(-0.45, 1.45, 0.0)
        shrine.add_child(candle_light)
        
        root.add_child(shrine)

func create_picnic_table(pos: Vector3, rot_y: float) -> Node3D:
    var picnic = Node3D.new()
    picnic.position = pos
    picnic.rotation.y = rot_y
    
    var table_top = MeshInstance3D.new()
    var tt_box = BoxMesh.new()
    tt_box.size = Vector3(2.2, 0.12, 1.1)
    tt_box.material = pier_wood_material
    table_top.mesh = tt_box
    table_top.position.y = 0.78
    picnic.add_child(table_top)
    
    var leg_a = MeshInstance3D.new()
    var la_box = BoxMesh.new()
    la_box.size = Vector3(1.8, 0.72, 0.12)
    la_box.material = pier_wood_material
    leg_a.mesh = la_box
    leg_a.position = Vector3(0.0, 0.36, -0.32)
    picnic.add_child(leg_a)
    
    var leg_b = MeshInstance3D.new()
    leg_b.mesh = la_box
    leg_b.material_override = pier_wood_material
    leg_b.position = Vector3(0.0, 0.36, 0.32)
    picnic.add_child(leg_b)
    
    for b_z in [-0.85, 0.85]:
        var bench = MeshInstance3D.new()
        var b_box = BoxMesh.new()
        b_box.size = Vector3(2.2, 0.08, 0.35)
        b_box.material = pier_wood_material
        bench.mesh = b_box
        bench.position = Vector3(0.0, 0.44, b_z)
        picnic.add_child(bench)
        
    return picnic

func get_terrain_elevation(road_y: float, z: float, lateral_offset: float, _is_lake_chunk: bool = false) -> float:
    var abs_dist = abs(lateral_offset)
    var l_weight = get_lake_weight(z)
    var s_weight = get_service_flatten_weight(z)
    
    # 0. Ampia Zona Pianeggiante dei Poderi & Campagna (Z in [60, 1380])
    var is_plain = (z >= 60.0 and z < 1380.0)
    if is_plain:
        if abs_dist <= 75.0:
            # Piattaforma perfettamente livellata per campi di grano, girasoli, cascine e bivi poderali
            var drop = -0.05 * (abs_dist / 75.0)
            return road_y + drop
        else:
            # Morbida salita verso le colline di contorno dell'orizzonte
            var t_hill = clamp((abs_dist - 75.0) / 105.0, 0.0, 1.0)
            var hill_height = 8.0 + sin(z * 0.015) * 4.0 + cos(z * 0.008) * 3.0
            return road_y - 0.05 + t_hill * t_hill * hill_height
            
    if abs_dist <= 18.0:
        var drop = lerp(-0.25, 0.0, s_weight)
        return road_y + (abs_dist / 18.0) * drop
    elif abs_dist <= 65.0:
        var t = (abs_dist - 18.0) / 47.0
        var normal_knoll_l = road_y + sin(z * 0.024 - 1.2) * 3.6 + cos(z * 0.009) * 2.0
        var lake_knoll_l = road_y - 3.9 + sin(z * 0.015) * 0.6
        var h_knoll_l = lerp(normal_knoll_l, lake_knoll_l, l_weight)
        
        var normal_knoll_r = road_y + sin(z * 0.022 + 1.4) * 3.4 + cos(z * 0.011) * 2.2
        var h_knoll_r = lerp(normal_knoll_r, road_y, s_weight)
        
        var h_knoll = h_knoll_l if lateral_offset < 0.0 else h_knoll_r
        var swale_edge = road_y + (lerp(-0.25, 0.0, s_weight) if lateral_offset > 0.0 else -0.25)
        return lerp(swale_edge, h_knoll, t)
    else:
        var normal_knoll_l = road_y + sin(z * 0.024 - 1.2) * 3.6 + cos(z * 0.009) * 2.0
        var lake_knoll_l = road_y - 3.9 + sin(z * 0.015) * 0.6
        var h_knoll_l = lerp(normal_knoll_l, lake_knoll_l, l_weight)
        
        var normal_knoll_r = road_y + sin(z * 0.022 + 1.4) * 3.4 + cos(z * 0.011) * 2.2
        var h_knoll_r = lerp(normal_knoll_r, road_y, s_weight)
        return h_knoll_l if lateral_offset < 0.0 else h_knoll_r

# =========================================================================
# 10. FAUNA ALPINA & ELEMENTI PASTORALI (Cows, Sheep, Mountain Birds)
# =========================================================================
func spawn_fauna_and_pastures(root: Node3D, points: Array, start_z: float):
    var num_pts = points.size()
    var b_info = get_biome_at(start_z)
    var b_type = b_info.get("type", BiomeGraph.BiomeType.ALPINE_MEADOWS)
    var is_gorge = b_type == BiomeGraph.BiomeType.ROCKY_GORGE
    var is_larch = b_type == BiomeGraph.BiomeType.AUTUMN_LARCH
    var is_golden = b_type == BiomeGraph.BiomeType.GOLDEN_PLATEAU
    var is_village = b_info.get("has_village", false)
    var is_service = b_info.get("has_service", false)
    var is_bridge = b_info.get("has_bridge", false)
    var is_lake = b_info.get("has_lake", false)
    
    # 10a. High Altitude Soaring Birds (over Gola del Meridiano & Alpine passes)
    if is_gorge or (int(start_z) % 360 == 0):
        var mid_p = points[int(num_pts * 0.5)]
        spawn_alpine_bird_flock(root, Vector3(mid_p.x, mid_p.y + 42.0, mid_p.z))

    # Skip land animals on bridges and inside dense villages / service stations
    if is_bridge or is_village or is_service:
        return
        
    # 10b. Mucche Alpine Pezzate al Pascolo (Grazing cows in scenic pastures)
    # Spawn in Alpine Meadows (Passo Alpi Z in [120, 360], Z in [1120, 1400]), Valico dei Larici, and Golden Plateau
    if (int(start_z) % 240 == 0) and not is_gorge:
        var sample_idx = int(num_pts * 0.35)
        var sp = points[sample_idx]
        # On lake chunk, always place on uphill side (+1.0), never in water
        var side = 1.0 if is_lake else (1.0 if (int(start_z / 120.0) % 2 == 0) else -1.0)
        var base_lat = side * (sp.width * 0.5 + randf_range(16.0, 26.0))
        var cow_y = get_terrain_elevation(sp.y, sp.z, base_lat, is_lake)
        
        # Spawn small group of 2 cows grazing peacefully
        for c_i in range(2):
            var c_pos = Vector3(sp.x + base_lat + randf_range(-2.5, 2.5), cow_y, sp.z + float(c_i) * 5.0 + randf_range(-1.0, 1.0))
            var c_rot = randf_range(-0.6, 0.6) + (0.0 if side > 0 else PI)
            spawn_alpine_cow(root, c_pos, c_rot)
            
    # 10c. Gregge di Pecorelle Soffici (Flocks of mountain sheep)
    # Spawn on open slopes and gentle meadows
    if (int(start_z) % 240 == 120) and not is_gorge:
        var sample_idx = int(num_pts * 0.65)
        var sp = points[sample_idx]
        var side = 1.0 if is_lake else (-1.0 if (int(start_z / 120.0) % 2 == 0) else 1.0)
        var base_lat = side * (sp.width * 0.5 + randf_range(16.0, 26.0))
        var sheep_y = get_terrain_elevation(sp.y, sp.z, base_lat, is_lake)
        var center_pos = Vector3(sp.x + base_lat, sheep_y, sp.z)
        spawn_flock_of_sheep(root, center_pos, randi_range(4, 6))

func spawn_alpine_cow(root: Node3D, pos: Vector3, rot_y: float):
    var cow = Node3D.new()
    cow.position = pos
    cow.rotation.y = rot_y
    
    # 1. Torso (Pezzata bianca alpina)
    var body = MeshInstance3D.new()
    var b_box = BoxMesh.new()
    b_box.size = Vector3(1.15, 0.95, 2.1)
    b_box.material = cow_white_material
    body.mesh = b_box
    body.position.y = 1.15
    cow.add_child(body)
    
    # 2. Pezzatura Bruna/Nera sul dorso e fianco
    var patch = MeshInstance3D.new()
    var p_box = BoxMesh.new()
    p_box.size = Vector3(1.18, 0.72, 0.95)
    p_box.material = cow_brown_material
    patch.mesh = p_box
    patch.position = Vector3(0.0, 1.18, 0.15)
    cow.add_child(patch)
    
    # 3. Zampe (4 zampe con stacchi bianchi)
    var leg_offsets = [
        Vector3(-0.42, 0.45, -0.68),
        Vector3(0.42, 0.45, -0.68),
        Vector3(-0.42, 0.45, 0.68),
        Vector3(0.42, 0.45, 0.68)
    ]
    for lo in leg_offsets:
        var leg = MeshInstance3D.new()
        var l_cyl = CylinderMesh.new()
        l_cyl.top_radius = 0.09
        l_cyl.bottom_radius = 0.08
        l_cyl.height = 0.90
        l_cyl.material = cow_white_material
        leg.mesh = l_cyl
        leg.position = lo
        cow.add_child(leg)
        
    # 4. Testa e Collo (inclinata verso l'erba a brucare)
    var head = MeshInstance3D.new()
    var h_box = BoxMesh.new()
    h_box.size = Vector3(0.62, 0.58, 0.78)
    h_box.material = cow_white_material
    head.mesh = h_box
    head.position = Vector3(0.0, 1.25, -1.25)
    head.rotation.x = deg_to_rad(14.0)
    cow.add_child(head)
    
    # 5. Museruola
    var snout = MeshInstance3D.new()
    var s_box = BoxMesh.new()
    s_box.size = Vector3(0.54, 0.38, 0.42)
    s_box.material = cow_brown_material
    snout.mesh = s_box
    snout.position = Vector3(0.0, 1.10, -1.62)
    cow.add_child(snout)
    
    # 6. Corna Alpine
    for h_side in [-1.0, 1.0]:
        var horn = MeshInstance3D.new()
        var h_cyl = CylinderMesh.new()
        h_cyl.top_radius = 0.02
        h_cyl.bottom_radius = 0.05
        h_cyl.height = 0.32
        h_cyl.material = sheep_wool_material
        horn.mesh = h_cyl
        horn.position = Vector3(h_side * 0.28, 1.62, -1.25)
        horn.rotation.z = deg_to_rad(-h_side * 35.0)
        horn.rotation.x = deg_to_rad(-15.0)
        cow.add_child(horn)
        
    # 7. Campanaccio d'Oro Tradizionale al Collo
    var bell = MeshInstance3D.new()
    var bell_box = BoxMesh.new()
    bell_box.size = Vector3(0.24, 0.28, 0.20)
    bell_box.material = cow_bell_material
    bell.mesh = bell_box
    bell.position = Vector3(0.0, 0.85, -1.05)
    cow.add_child(bell)
    
    # 8. Coda
    var tail = MeshInstance3D.new()
    var t_cyl = CylinderMesh.new()
    t_cyl.top_radius = 0.03
    t_cyl.bottom_radius = 0.03
    t_cyl.height = 0.75
    t_cyl.material = cow_white_material
    tail.mesh = t_cyl
    tail.position = Vector3(0.0, 0.95, 1.08)
    tail.rotation.x = deg_to_rad(-15.0)
    cow.add_child(tail)
    
    root.add_child(cow)

func spawn_flock_of_sheep(root: Node3D, center_pos: Vector3, count: int = 5):
    var flock_group = Node3D.new()
    flock_group.position = center_pos
    
    for s_i in range(count):
        var s_node = Node3D.new()
        var ox = randf_range(-4.2, 4.2)
        var oz = randf_range(-4.2, 4.2)
        var s_rot = randf_range(0.0, TAU)
        var s_scale = randf_range(0.85, 1.15)
        s_node.position = Vector3(ox, 0.0, oz)
        s_node.rotation.y = s_rot
        s_node.scale = Vector3.ONE * s_scale
        
        # 1. Fluffy woolly body
        var body = MeshInstance3D.new()
        var b_box = BoxMesh.new()
        b_box.size = Vector3(0.82, 0.72, 1.15)
        b_box.material = sheep_wool_material
        body.mesh = b_box
        body.position.y = 0.72
        s_node.add_child(body)
        
        # 2. Rounded rump
        var rump = MeshInstance3D.new()
        var r_sph = SphereMesh.new()
        r_sph.radius = 0.42; r_sph.height = 0.68
        r_sph.radial_segments = 10; r_sph.rings = 6
        r_sph.material = sheep_wool_material
        rump.mesh = r_sph
        rump.position = Vector3(0.0, 0.72, 0.35)
        s_node.add_child(rump)
        
        # 3. Charcoal face
        var head = MeshInstance3D.new()
        var h_box = BoxMesh.new()
        h_box.size = Vector3(0.32, 0.32, 0.44)
        h_box.material = sheep_face_material
        head.mesh = h_box
        head.position = Vector3(0.0, 0.78, -0.68)
        head.rotation.x = deg_to_rad(15.0)
        s_node.add_child(head)
        
        # 4. Floppy ears
        for e_side in [-1.0, 1.0]:
            var ear = MeshInstance3D.new()
            var e_box = BoxMesh.new()
            e_box.size = Vector3(0.18, 0.06, 0.09)
            e_box.material = sheep_face_material
            ear.mesh = e_box
            ear.position = Vector3(e_side * 0.22, 0.85, -0.62)
            s_node.add_child(ear)
            
        # 5. Slender dark legs
        var leg_offs = [
            Vector3(-0.28, 0.26, -0.36),
            Vector3(0.28, 0.26, -0.36),
            Vector3(-0.28, 0.26, 0.36),
            Vector3(0.28, 0.26, 0.36)
        ]
        for lo in leg_offs:
            var leg = MeshInstance3D.new()
            var l_cyl = CylinderMesh.new()
            l_cyl.top_radius = 0.05
            l_cyl.bottom_radius = 0.04
            l_cyl.height = 0.52
            l_cyl.material = sheep_face_material
            leg.mesh = l_cyl
            leg.position = lo
            s_node.add_child(leg)
            
        flock_group.add_child(s_node)
        
    root.add_child(flock_group)

func spawn_alpine_bird_flock(root: Node3D, center_pos: Vector3):
    var bird_group = Node3D.new()
    bird_group.position = center_pos
    for b_i in range(3):
        var b = MeshInstance3D.new()
        var prism = PrismMesh.new()
        prism.size = Vector3(2.2, 0.12, 0.8)
        prism.material = chalet_roof_material
        b.mesh = prism
        b.position = Vector3(randf_range(-18.0, 18.0), randf_range(30.0, 48.0), randf_range(-18.0, 18.0))
        b.rotation.y = randf_range(0.0, TAU)
        b.rotation.z = deg_to_rad(14.0)
        bird_group.add_child(b)
    root.add_child(bird_group)

# =========================================================================
# 11. PATRIMONIO RURALE & ELEMENTI NATURALI (Straw Bales, Carts, Fountains, Logs)
# =========================================================================
func spawn_rural_and_natural_heritage(root: Node3D, points: Array, start_z: float):
    var num_pts = points.size()
    var mid_p = points[int(num_pts * 0.5)]
    var b_info = get_biome_at(start_z)
    var is_gorge = (start_z >= 1400.0 and start_z < 3000.0) or b_info.get("type", -1) == BiomeGraph.BiomeType.ROCKY_GORGE
    
    # 11a. RURAL HERITAGE NEAR VILLAGES & IN RURAL BIOMES
    # Near Borgo San Cristoforo, Borgo dell'Altopiano, or any procedural segment with rural flag
    var is_near_san_cristoforo = (start_z >= 720.0 and start_z < 840.0) or (start_z >= 1080.0 and start_z < 1200.0)
    var is_near_altopiano = (start_z >= 5280.0 and start_z < 5400.0) or (start_z >= 5640.0 and start_z < 5760.0)
    var has_rural_param = b_info.get("has_rural", false) or b_info.get("has_straw_bales", false)
    
    if is_near_san_cristoforo or is_near_altopiano or (has_rural_param and int(start_z) % 240 == 0):
        var rural_group = Node3D.new()
        var p_ref = points[int(num_pts * 0.4)]
        var r_side = -1.0 if start_z < 840.0 else 1.0
        
        # 1. Cluster di Rotoballe di fieno dorate
        var bale_base_x = p_ref.x + r_side * (p_ref.width * 0.5 + 11.0)
        var bale_y = p_ref.y + 0.05
        # Due rotoballe a terra e una sopra o di fianco
        rural_group.add_child(spawn_round_straw_bale(Vector3(bale_base_x, bale_y, p_ref.z - 4.0), false))
        rural_group.add_child(spawn_round_straw_bale(Vector3(bale_base_x + r_side * 2.2, bale_y, p_ref.z - 3.5), false))
        rural_group.add_child(spawn_round_straw_bale(Vector3(bale_base_x + r_side * 1.1, bale_y, p_ref.z - 6.2), true))
        
        # 2. Carretto rustico d'epoca in legno
        var cart_x = p_ref.x + r_side * (p_ref.width * 0.5 + 6.8)
        var cart = spawn_rustic_farm_cart(Vector3(cart_x, p_ref.y, p_ref.z + 12.0), deg_to_rad(25.0 if r_side > 0 else -25.0))
        rural_group.add_child(cart)
        
        # 3. Fontanile in pietra con zampillo d'acqua sorgiva
        var f_ref = points[int(num_pts * 0.75)]
        var f_side = -r_side
        var fountain_x = f_ref.x + f_side * (f_ref.width * 0.5 + 4.5)
        var fountain = spawn_alpine_stone_trough(Vector3(fountain_x, f_ref.y, f_ref.z), deg_to_rad(90.0 if f_side > 0 else -90.0))
        rural_group.add_child(fountain)
        
        # 4. Legnaia / Catasta di legna da ardere
        var pile_x = p_ref.x + r_side * (p_ref.width * 0.5 + 17.5)
        var woodpile = spawn_woodpile_shelter(Vector3(pile_x, p_ref.y, p_ref.z + 4.0), deg_to_rad(10.0 if r_side > 0 else -10.0))
        rural_group.add_child(woodpile)
        
        root.add_child(rural_group)

    # 11b. NATURAL ELEMENTS: Mossy fallen logs & clustered natural copses
    # Spawn in Alpine mountain woods (not on bridges, gorge beds, or lakes)
    if not is_gorge and (int(start_z) % 180 == 60):
        var p_log = points[int(num_pts * 0.55)]
        var l_side = -1.0 if randf() < 0.5 else 1.0
        var log_dist = l_side * (p_log.width * 0.5 + randf_range(11.0, 22.0))
        var log_y = p_log.y + sin(p_log.z * 0.02) * 1.5
        var log_pos = Vector3(p_log.x + log_dist, log_y, p_log.z + randf_range(-4.0, 4.0))
        var fallen_log = spawn_mossy_fallen_log(log_pos, randf_range(-0.8, 0.8), randf_range(4.2, 6.5))
        root.add_child(fallen_log)

func spawn_round_straw_bale(pos: Vector3, is_standing: bool) -> Node3D:
    var bale = MeshInstance3D.new()
    var cyl = CylinderMesh.new()
    cyl.top_radius = 0.88; cyl.bottom_radius = 0.88; cyl.height = 1.38
    cyl.radial_segments = 14
    cyl.material = straw_bale_material
    bale.mesh = cyl
    bale.position = pos
    if not is_standing:
        bale.rotation.z = deg_to_rad(90.0)
        bale.position.y += 0.88
    else:
        bale.position.y += 0.69
    return bale

func spawn_rustic_farm_cart(pos: Vector3, rot_y: float) -> Node3D:
    var cart = Node3D.new()
    cart.position = pos
    cart.rotation.y = rot_y
    
    # Pianale in legno
    var bed = MeshInstance3D.new()
    var b_box = BoxMesh.new()
    b_box.size = Vector3(1.65, 0.45, 2.7)
    b_box.material = cart_wood_material
    bed.mesh = b_box
    bed.position.y = 0.85
    cart.add_child(bed)
    
    # Grandi ruote a raggi in legno
    for side in [-1.0, 1.0]:
        var wheel = MeshInstance3D.new()
        var w_cyl = CylinderMesh.new()
        w_cyl.top_radius = 0.68; w_cyl.bottom_radius = 0.68; w_cyl.height = 0.12
        w_cyl.radial_segments = 14
        w_cyl.material = cart_wood_material
        wheel.mesh = w_cyl
        wheel.rotation.z = deg_to_rad(90.0)
        wheel.position = Vector3(side * 0.92, 0.68, 0.0)
        cart.add_child(wheel)
        
    # Timone di traino
    for side in [-0.35, 0.35]:
        var shaft = MeshInstance3D.new()
        var s_box = BoxMesh.new()
        s_box.size = Vector3(0.08, 0.08, 2.0)
        s_box.material = cart_wood_material
        shaft.mesh = s_box
        shaft.position = Vector3(side, 0.45, -2.1)
        shaft.rotation.x = deg_to_rad(12.0)
        cart.add_child(shaft)
        
    # Carico di fieno sul carretto
    var cargo_bale = MeshInstance3D.new()
    var c_cyl = CylinderMesh.new()
    c_cyl.top_radius = 0.52; c_cyl.bottom_radius = 0.52; c_cyl.height = 1.1
    c_cyl.material = straw_bale_material
    cargo_bale.mesh = c_cyl
    cargo_bale.position = Vector3(0.0, 1.15, 0.2)
    cargo_bale.rotation.z = deg_to_rad(90.0)
    cart.add_child(cargo_bale)
    
    # Collisione solida fisica
    var col_body = StaticBody3D.new()
    var col_shape = CollisionShape3D.new()
    var cb = BoxShape3D.new()
    cb.size = Vector3(2.0, 1.5, 3.0)
    col_shape.shape = cb
    col_shape.position.y = 0.75
    col_body.add_child(col_shape)
    cart.add_child(col_body)
    
    return cart

func spawn_alpine_stone_trough(pos: Vector3, rot_y: float) -> Node3D:
    var trough = Node3D.new()
    trough.position = pos
    trough.rotation.y = rot_y
    
    # Vasca in pietra monolitica
    var basin = MeshInstance3D.new()
    var b_box = BoxMesh.new()
    b_box.size = Vector3(1.3, 0.75, 2.6)
    b_box.material = fountain_stone_material
    basin.mesh = b_box
    basin.position.y = 0.38
    trough.add_child(basin)
    
    # Specchio d'acqua sorgiva
    var water = MeshInstance3D.new()
    var w_plane = PlaneMesh.new()
    w_plane.size = Vector2(1.05, 2.35)
    w_plane.material = water_material
    water.mesh = w_plane
    water.position.y = 0.70
    trough.add_child(water)
    
    # Pilastro verticale in pietra con bocchetta
    var pillar = MeshInstance3D.new()
    var p_box = BoxMesh.new()
    p_box.size = Vector3(0.48, 1.6, 0.48)
    p_box.material = fountain_stone_material
    pillar.mesh = p_box
    pillar.position = Vector3(0.0, 0.8, -1.25)
    trough.add_child(pillar)
    
    # Tubo erogatore in ottone
    var spout = MeshInstance3D.new()
    var s_cyl = CylinderMesh.new()
    s_cyl.top_radius = 0.04; s_cyl.bottom_radius = 0.04; s_cyl.height = 0.35
    s_cyl.material = cow_bell_material
    spout.mesh = s_cyl
    spout.rotation.x = deg_to_rad(90.0)
    spout.position = Vector3(0.0, 1.15, -1.05)
    trough.add_child(spout)
    
    return trough

func spawn_woodpile_shelter(pos: Vector3, rot_y: float) -> Node3D:
    return create_firewood_log_stack(pos, rot_y)

func spawn_mossy_fallen_log(pos: Vector3, rot_y: float, length: float) -> Node3D:
    var log_node = Node3D.new()
    log_node.position = pos
    log_node.rotation.y = rot_y
    
    var trunk = MeshInstance3D.new()
    var cyl = CylinderMesh.new()
    cyl.top_radius = 0.34; cyl.bottom_radius = 0.38; cyl.height = length
    cyl.material = moss_log_material
    trunk.mesh = cyl
    trunk.rotation.x = deg_to_rad(90.0)
    trunk.position.y = 0.32
    log_node.add_child(trunk)
    
    # Cuscinetto di muschio verde smeraldo sul tronco
    var moss = MeshInstance3D.new()
    var m_box = BoxMesh.new()
    m_box.size = Vector3(0.55, 0.12, length * 0.65)
    m_box.material = moss_green_material
    moss.mesh = m_box
    moss.position = Vector3(0.0, 0.64, 0.0)
    log_node.add_child(moss)
    
    return log_node

func spawn_summit_pass_closure_barrier(root: Node3D, points: Array, start_z: float):
    if start_z < 5400.0 or start_z >= 5520.0:
        return
    var num_pts = points.size()
    var mid_p = points[int(num_pts * 0.5)]
    var b_node = Node3D.new()
    b_node.name = "SummitClosureBarrier"
    
    # 1. Barriere New Jersey pesanti in calcestruzzo a sbarramento carreggiata (anti-caduta nel vuoto)
    for nj_i in range(5):
        var nj_x = mid_p.x - 4.0 + float(nj_i) * 2.0
        var nj_body = StaticBody3D.new()
        var nj_mesh = MeshInstance3D.new()
        var b_box = BoxMesh.new()
        b_box.size = Vector3(1.85, 1.10, 0.65)
        b_box.material = cobblestone_material
        nj_mesh.mesh = b_box
        nj_mesh.position = Vector3(nj_x, mid_p.y + 0.55, mid_p.z)
        nj_body.add_child(nj_mesh)
        
        var c_shape = CollisionShape3D.new()
        var b_shape = BoxShape3D.new()
        b_shape.size = Vector3(1.90, 1.30, 0.80)
        c_shape.shape = b_shape
        c_shape.position = Vector3(nj_x, mid_p.y + 0.65, mid_p.z)
        nj_body.add_child(c_shape)
        b_node.add_child(nj_body)
        
    # 2. Trave orizzontale in legno e segnaletica bicolore rifrangente ANAS
    var beam = MeshInstance3D.new()
    var beam_box = BoxMesh.new()
    beam_box.size = Vector3(mid_p.width + 1.2, 0.45, 0.15)
    beam_box.material = danger_sign_red_material
    beam.mesh = beam_box
    beam.position = Vector3(mid_p.x, mid_p.y + 1.25, mid_p.z - 0.2)
    b_node.add_child(beam)
    
    # Cartello di chiusura passo: "VALICO DEL DUCA - STRADA CHIUSA PER NEVE"
    var sign_mesh = MeshInstance3D.new()
    var s_box = BoxMesh.new()
    s_box.size = Vector3(4.2, 0.85, 0.12)
    s_box.material = danger_sign_white_material
    sign_mesh.mesh = s_box
    sign_mesh.position = Vector3(mid_p.x, mid_p.y + 2.1, mid_p.z - 0.2)
    b_node.add_child(sign_mesh)
    
    # 3. Lampeggianti arancioni attivi per cantiere/chiusura passo
    for lx in [-3.5, 3.5]:
        var beacon = Node3D.new()
        beacon.position = Vector3(mid_p.x + lx, mid_p.y + 1.7, mid_p.z - 0.2)
        var light = OmniLight3D.new()
        light.light_color = Color(1.0, 0.65, 0.10)
        light.light_energy = 2.2
        light.omni_range = 10.0
        beacon.add_child(light)
        b_node.add_child(beacon)
        
    # 4. Muri di contenimento neve e valanghe laterali
    for side in [-1.0, 1.0]:
        var snow_wall = StaticBody3D.new()
        var sw_mesh = MeshInstance3D.new()
        var sw_box = BoxMesh.new()
        sw_box.size = Vector3(25.0, 3.5, 2.5)
        sw_box.material = drystone_material
        sw_mesh.mesh = sw_box
        sw_mesh.position = Vector3(mid_p.x + side * (mid_p.width * 0.5 + 13.0), mid_p.y + 1.75, mid_p.z)
        snow_wall.add_child(sw_mesh)
        var sw_col = CollisionShape3D.new()
        var sw_shape = BoxShape3D.new()
        sw_shape.size = Vector3(25.0, 3.5, 2.5)
        sw_col.shape = sw_shape
        sw_col.position = sw_mesh.position
        snow_wall.add_child(sw_col)
        b_node.add_child(snow_wall)
        
    root.add_child(b_node)

func spawn_road_potholes(root: Node3D, points: Array, start_z: float):
    if start_z < 100.0 or points.size() < 6: return
    
    # 1. Calibrazione realistica frequenza buche (non un campo minato continuo):
    var is_curvy = false
    for pt in points:
        if abs(pt.get("angle", 0.0)) > 0.12:
            is_curvy = true
            break
            
    var pot_count = 0
    if start_z >= 100.0 and start_z < 300.0:
        # 1 buca nel tratto iniziale montano per collaudo e test procedurali
        pot_count = 1
    elif is_curvy:
        # Tratti montani tortuosi soggetti a gelo e degrado: 40% 1 buca, 15% 2 buche, 45% 0 buche
        var roll = randf()
        if roll < 0.15: pot_count = 2
        elif roll < 0.55: pot_count = 1
    else:
        # Rettilinei ordinari: 30% 1 buca, 70% 0 buche (manutenzione realistica)
        if randf() < 0.30: pot_count = 1
        
    for p_idx in range(pot_count):
        var s_idx = randi_range(2, points.size() - 3)
        var pt = points[s_idx]
        # Collocazione realistica sui binari di passaggio ruote o ciglio carreggiata
        var wheel_tracks = [-1.45, 1.45, -2.10, 2.10]
        var pot_x = pt.x + wheel_tracks.pick_random() + randf_range(-0.20, 0.20)
        var dx = abs(pot_x - pt.x)
        var crown = 0.08 - pow(clamp(dx / max(0.1, pt.width * 0.5), 0.0, 1.0), 1.6) * 0.075
        var pot_y = pt.y + crown + 0.003
        var pot_z = pt.z + randf_range(-1.5, 1.5)
        # Dimensioni realistiche: raggio 40-70cm, profondità 3.5-6.5cm
        var r = randf_range(0.40, 0.68)
        var depth = randf_range(0.035, 0.065)
        
        # 1. Base visiva asfalto sgretolato scuro e umido
        var pot_mesh = MeshInstance3D.new()
        var cyl = CylinderMesh.new()
        cyl.top_radius = r
        cyl.bottom_radius = r * 0.88
        cyl.height = 0.010
        var m = StandardMaterial3D.new()
        m.albedo_color = Color(0.09, 0.09, 0.10) # Nero bitume cavità
        m.roughness = 0.95
        cyl.material = m
        pot_mesh.mesh = cyl
        pot_mesh.position = Vector3(pot_x, pot_y, pot_z)
        root.add_child(pot_mesh)
        
        active_potholes.append({
            "x": pot_x,
            "y": pot_y,
            "z": pot_z,
            "radius": r,
            "depth": depth
        })

func spawn_road_patches_and_details(root: Node3D, points: Array, start_z: float):
    if points.size() < 6: return
    
    # 2. DELIMITATORI STRADALI ALPINI (Paracarri bianchi e neri con catarifrangente)
    # Posizionati ogni ~28m sulla banchina esterna delle curve e dei rettilinei
    var step = max(1, points.size() / 4)
    for i in range(1, points.size() - 1, step):
        var pt = points[i]
        var hw = pt.width * 0.5 + 0.65
        var p_nx = cos(pt.angle)
        var p_nz = -sin(pt.angle)
        for side in [-1.0, 1.0]:
            var delin = Node3D.new()
            delin.position = Vector3(pt.x + p_nx * side * hw, pt.y, pt.z + p_nz * side * hw)
            
            # Fusto cilindrico bianco
            var post = MeshInstance3D.new()
            var c = CylinderMesh.new()
            c.top_radius = 0.055
            c.bottom_radius = 0.060
            c.height = 0.85
            var post_m = StandardMaterial3D.new()
            post_m.albedo_color = Color(0.92, 0.93, 0.95)
            post_m.roughness = 0.65
            post.mesh = c
            post.material_override = post_m
            post.position.y = 0.42
            delin.add_child(post)
            
            # Fascia superiore nera
            var band = MeshInstance3D.new()
            var bc = CylinderMesh.new()
            bc.top_radius = 0.057
            bc.bottom_radius = 0.058
            bc.height = 0.16
            var band_m = StandardMaterial3D.new()
            band_m.albedo_color = Color(0.10, 0.10, 0.11)
            band_m.roughness = 0.70
            band.mesh = bc
            band.material_override = band_m
            band.position.y = 0.72
            delin.add_child(band)
            
            # Catarifrangente rosso (o bianco per senso opposto)
            var refl = MeshInstance3D.new()
            var rb = BoxMesh.new()
            rb.size = Vector3(0.04, 0.08, 0.02)
            var rm = StandardMaterial3D.new()
            rm.albedo_color = Color(0.90, 0.15, 0.10) if side > 0.0 else Color(0.95, 0.95, 0.95)
            rm.emission_enabled = true
            rm.emission = rm.albedo_color
            rm.emission_energy_multiplier = 0.6
            refl.mesh = rb
            refl.material_override = rm
            refl.position = Vector3(0.0, 0.72, -0.055)
            delin.add_child(refl)
            
            root.add_child(delin)

func get_pothole_at_position(pos: Vector3, check_radius: float = 0.55) -> Dictionary:
    for p in active_potholes:
        if abs(pos.z - p.z) <= check_radius + p.radius:
            var dx = pos.x - p.x
            var dz = pos.z - p.z
            if (dx * dx + dz * dz) <= (check_radius + p.radius) * (check_radius + p.radius):
                return p
    return {}

func get_road_patch_at_position(pos: Vector3, check_radius: float = 0.50) -> Dictionary:
    for patch in active_road_patches:
        if abs(pos.z - patch.z) <= (patch.length * 0.5 + check_radius):
            if abs(pos.x - patch.x) <= (patch.width * 0.5 + check_radius):
                return patch
    return {}

# =========================================================================
# 8. LIVING WORLD 1993 - VEICOLI STORICI, CABINE SIP, TERRAZZE & PAESANI
# =========================================================================

func create_parked_ape_piaggio(pos: Vector3, rot_y: float, body_color: Color) -> Node3D:
    var ape = Node3D.new()
    ape.position = pos
    ape.rotation.y = rot_y
    
    var b_mat = StandardMaterial3D.new()
    b_mat.albedo_color = body_color
    b_mat.roughness = 0.45
    
    var rubber_mat = StandardMaterial3D.new()
    rubber_mat.albedo_color = Color(0.12, 0.12, 0.13)
    rubber_mat.roughness = 0.90
    
    var glass_mat = StandardMaterial3D.new()
    glass_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.70)
    glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    glass_mat.roughness = 0.10
    
    # 1. Cabin
    var cab = MeshInstance3D.new()
    var cb = BoxMesh.new()
    cb.size = Vector3(1.05, 1.15, 0.95)
    cb.material = b_mat
    cab.mesh = cb
    cab.position = Vector3(0.0, 0.75, -0.45)
    ape.add_child(cab)
    
    # Windshield
    var wind = MeshInstance3D.new()
    var wb = BoxMesh.new()
    wb.size = Vector3(0.92, 0.48, 0.05)
    wb.material = glass_mat
    wind.mesh = wb
    wind.position = Vector3(0.0, 0.95, -0.93)
    ape.add_child(wind)
    
    # Headlight (Single central round)
    var light = MeshInstance3D.new()
    var lm = CylinderMesh.new()
    lm.top_radius = 0.10
    lm.bottom_radius = 0.10
    lm.height = 0.08
    var l_mat = StandardMaterial3D.new()
    l_mat.albedo_color = Color(1.0, 0.92, 0.45)
    l_mat.emission_enabled = true
    l_mat.emission = Color(1.0, 0.92, 0.45)
    l_mat.emission_energy_multiplier = 0.8
    light.mesh = lm
    light.material_override = l_mat
    light.rotation.x = deg_to_rad(90.0)
    light.position = Vector3(0.0, 0.65, -0.94)
    ape.add_child(light)
    
    # 2. Rear Flatbed with wooden sideboards
    var bed = MeshInstance3D.new()
    var bb = BoxMesh.new()
    bb.size = Vector3(1.25, 0.35, 1.45)
    bb.material = chalet_timber_material
    bed.mesh = bb
    bed.position = Vector3(0.0, 0.50, 0.55)
    ape.add_child(bed)
    
    # Firewood log pile in flatbed
    for lx in [-0.35, 0.0, 0.35]:
        for ly in [0.0, 0.14]:
            var log = MeshInstance3D.new()
            var log_cyl = CylinderMesh.new()
            log_cyl.top_radius = 0.08
            log_cyl.bottom_radius = 0.08
            log_cyl.height = 1.25
            log.mesh = log_cyl
            log.material_override = cart_wood_material if cart_wood_material else chalet_timber_material
            log.rotation.x = deg_to_rad(90.0)
            log.position = Vector3(lx, 0.65 + ly, 0.55)
            ape.add_child(log)
            
    # 3. Wheels (1 Front, 2 Rear)
    var f_wheel = MeshInstance3D.new()
    var fc = CylinderMesh.new()
    fc.top_radius = 0.20
    fc.bottom_radius = 0.20
    fc.height = 0.12
    fc.material = rubber_mat
    f_wheel.mesh = fc
    f_wheel.rotation.z = deg_to_rad(90.0)
    f_wheel.position = Vector3(0.0, 0.20, -0.75)
    ape.add_child(f_wheel)
    
    for side in [-1.0, 1.0]:
        var r_wheel = MeshInstance3D.new()
        var rc = CylinderMesh.new()
        rc.top_radius = 0.22
        rc.bottom_radius = 0.22
        rc.height = 0.14
        rc.material = rubber_mat
        r_wheel.mesh = rc
        r_wheel.rotation.z = deg_to_rad(90.0)
        r_wheel.position = Vector3(side * 0.56, 0.22, 0.55)
        ape.add_child(r_wheel)
        
    return ape

func create_parked_vespa_special(pos: Vector3, rot_y: float, body_color: Color) -> Node3D:
    var vespa = Node3D.new()
    vespa.position = pos
    vespa.rotation.y = rot_y
    vespa.rotation.z = deg_to_rad(6.5) # Leaned on side kickstand
    
    var b_mat = StandardMaterial3D.new()
    b_mat.albedo_color = body_color
    b_mat.roughness = 0.35
    
    var rubber_mat = StandardMaterial3D.new()
    rubber_mat.albedo_color = Color(0.12, 0.12, 0.13)
    
    var chrome_mat = StandardMaterial3D.new()
    chrome_mat.albedo_color = Color(0.90, 0.92, 0.95)
    chrome_mat.metallic = 0.90
    chrome_mat.roughness = 0.15
    
    # Central chassis & floorboards
    var body = MeshInstance3D.new()
    var bb = BoxMesh.new()
    bb.size = Vector3(0.32, 0.45, 0.85)
    bb.material = b_mat
    body.mesh = bb
    body.position = Vector3(0.0, 0.35, 0.0)
    vespa.add_child(body)
    
    # Front curved legshield
    var shield = MeshInstance3D.new()
    var sb = BoxMesh.new()
    sb.size = Vector3(0.48, 0.65, 0.06)
    sb.material = b_mat
    shield.mesh = sb
    shield.position = Vector3(0.0, 0.60, -0.38)
    vespa.add_child(shield)
    
    # Handlebar & square 50 Special headlight
    var bar = MeshInstance3D.new()
    var barb = BoxMesh.new()
    barb.size = Vector3(0.55, 0.06, 0.08)
    barb.material = chrome_mat
    bar.mesh = barb
    bar.position = Vector3(0.0, 0.92, -0.35)
    vespa.add_child(bar)
    
    var head = MeshInstance3D.new()
    var hb = BoxMesh.new()
    hb.size = Vector3(0.14, 0.11, 0.08)
    var h_mat = StandardMaterial3D.new()
    h_mat.albedo_color = Color(1.0, 0.95, 0.70)
    h_mat.emission_enabled = true
    h_mat.emission = Color(1.0, 0.95, 0.70)
    h_mat.emission_energy_multiplier = 0.5
    head.mesh = hb
    head.material_override = h_mat
    head.position = Vector3(0.0, 0.94, -0.40)
    vespa.add_child(head)
    
    # Saddle seat (Black leather)
    var seat = MeshInstance3D.new()
    var stb = BoxMesh.new()
    stb.size = Vector3(0.24, 0.12, 0.48)
    stb.material = rubber_mat
    seat.mesh = stb
    seat.position = Vector3(0.0, 0.62, 0.05)
    vespa.add_child(seat)
    
    # Wheels (Front & Rear)
    for wz in [-0.42, 0.38]:
        var w = MeshInstance3D.new()
        var wc = CylinderMesh.new()
        wc.top_radius = 0.16
        wc.bottom_radius = 0.16
        wc.height = 0.08
        wc.material = rubber_mat
        w.mesh = wc
        w.rotation.z = deg_to_rad(90.0)
        w.position = Vector3(0.0, 0.16, wz)
        vespa.add_child(w)
        
    return vespa

func create_cabina_sip(pos: Vector3, rot_y: float) -> Node3D:
    var booth = Node3D.new()
    booth.position = pos
    booth.rotation.y = rot_y
    
    var sip_orange = StandardMaterial3D.new()
    sip_orange.albedo_color = Color(0.92, 0.40, 0.08) # Iconic SIP orange
    sip_orange.roughness = 0.50
    
    var sip_grey = StandardMaterial3D.new()
    sip_grey.albedo_color = Color(0.72, 0.74, 0.76)
    sip_grey.roughness = 0.60
    
    var glass = StandardMaterial3D.new()
    glass.albedo_color = Color(0.80, 0.90, 0.95, 0.45)
    glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    glass.roughness = 0.10
    
    # Concrete base plinth
    var plinth = MeshInstance3D.new()
    var pb = BoxMesh.new()
    pb.size = Vector3(1.05, 0.15, 1.05)
    pb.material = sip_grey
    plinth.mesh = pb
    plinth.position.y = 0.08
    booth.add_child(plinth)
    
    # Frame posts (4 orange corner pillars)
    for px in [-0.45, 0.45]:
        for pz in [-0.45, 0.45]:
            var pillar = MeshInstance3D.new()
            var pilb = BoxMesh.new()
            pilb.size = Vector3(0.08, 2.30, 0.08)
            pilb.material = sip_orange
            pillar.mesh = pilb
            pillar.position = Vector3(px, 1.25, pz)
            booth.add_child(pillar)
            
    # Glass panes
    for side in [0, 1, 2]:
        var pane = MeshInstance3D.new()
        var paneb = BoxMesh.new()
        if side == 0:
            paneb.size = Vector3(0.02, 1.65, 0.85)
            pane.position = Vector3(-0.45, 1.25, 0.0)
        elif side == 1:
            paneb.size = Vector3(0.02, 1.65, 0.85)
            pane.position = Vector3(0.45, 1.25, 0.0)
        else:
            paneb.size = Vector3(0.85, 1.65, 0.02)
            pane.position = Vector3(0.0, 1.25, 0.45)
        pane.mesh = paneb
        pane.material_override = glass
        booth.add_child(pane)
        
    # Orange Roof Canopy with SIP sign band
    var roof = MeshInstance3D.new()
    var rb = BoxMesh.new()
    rb.size = Vector3(1.02, 0.28, 1.02)
    rb.material = sip_orange
    roof.mesh = rb
    roof.position.y = 2.45
    booth.add_child(roof)
    
    # Internal yellow Rotor telephone
    var phone = MeshInstance3D.new()
    var phb = BoxMesh.new()
    phb.size = Vector3(0.24, 0.35, 0.18)
    var ph_mat = StandardMaterial3D.new()
    ph_mat.albedo_color = Color(0.95, 0.80, 0.10)
    phone.mesh = phb
    phone.material_override = ph_mat
    phone.position = Vector3(0.0, 1.35, 0.32)
    booth.add_child(phone)
    
    return booth

func create_bar_terrace(pos: Vector3, rot_y: float) -> Node3D:
    var terrace = Node3D.new()
    terrace.position = pos
    terrace.rotation.y = rot_y
    
    # 1. Porphyry terrace slab
    var slab = MeshInstance3D.new()
    var slb = BoxMesh.new()
    slb.size = Vector3(4.8, 0.18, 5.2)
    slb.material = rock_material
    slab.mesh = slb
    slab.position.y = 0.09
    terrace.add_child(slab)
    
    # Metal table material
    var metal_mat = StandardMaterial3D.new()
    metal_mat.albedo_color = Color(0.78, 0.80, 0.82)
    metal_mat.metallic = 0.80
    metal_mat.roughness = 0.35
    
    # Striped parasol material (Red and white)
    var parasol_mat = StandardMaterial3D.new()
    parasol_mat.albedo_color = Color(0.88, 0.20, 0.15)
    parasol_mat.roughness = 0.75
    
    # Two round cafe tables with chairs
    for tx in [-1.3, 1.3]:
        var table = Node3D.new()
        table.position = Vector3(tx, 0.18, 0.0)
        
        # Center pole & base
        var pole = MeshInstance3D.new()
        var pc = CylinderMesh.new()
        pc.top_radius = 0.03
        pc.bottom_radius = 0.22
        pc.height = 0.72
        pc.material = metal_mat
        pole.mesh = pc
        pole.position.y = 0.36
        table.add_child(pole)
        
        # Round tabletop
        var top = MeshInstance3D.new()
        var tc = CylinderMesh.new()
        tc.top_radius = 0.45
        tc.bottom_radius = 0.45
        tc.height = 0.04
        tc.material = metal_mat
        top.mesh = tc
        top.position.y = 0.74
        table.add_child(top)
        
        # 2 Bistro chairs around table
        for ca in [0.0, PI]:
            var chair = MeshInstance3D.new()
            var chb = BoxMesh.new()
            chb.size = Vector3(0.32, 0.42, 0.32)
            chb.material = metal_mat
            chair.mesh = chb
            chair.position = Vector3(cos(ca) * 0.65, 0.21, sin(ca) * 0.65)
            table.add_child(chair)
            
        terrace.add_child(table)
        
    # Large Bar Parasol
    var umbrella = Node3D.new()
    umbrella.position = Vector3(0.0, 0.18, -1.2)
    var u_pole = MeshInstance3D.new()
    var upc = CylinderMesh.new()
    upc.top_radius = 0.04
    upc.bottom_radius = 0.04
    upc.height = 2.45
    upc.material = metal_mat
    u_pole.mesh = upc
    u_pole.position.y = 1.22
    umbrella.add_child(u_pole)
    
    var u_top = MeshInstance3D.new()
    var uc = PrismMesh.new()
    uc.size = Vector3(2.4, 0.65, 2.4)
    uc.material = parasol_mat
    u_top.mesh = uc
    u_top.position.y = 2.50
    umbrella.add_child(u_top)
    terrace.add_child(umbrella)
    
    # Wooden bench on terrace perimeter
    var bench = MeshInstance3D.new()
    var b_box = BoxMesh.new()
    b_box.size = Vector3(1.6, 0.42, 0.45)
    b_box.material = chalet_timber_material
    bench.mesh = b_box
    bench.position = Vector3(0.0, 0.39, 1.8)
    terrace.add_child(bench)
    
    return terrace

func create_vintage_sign(pos: Vector3, rot_y: float, _title_text: String, _sub_text: String, bg_col: Color) -> Node3D:
    var sign_node = Node3D.new()
    sign_node.position = pos
    sign_node.rotation.y = rot_y
    
    var frame_mat = StandardMaterial3D.new()
    frame_mat.albedo_color = Color(0.15, 0.15, 0.16)
    frame_mat.metallic = 0.85
    frame_mat.roughness = 0.40
    
    var sign_mat = StandardMaterial3D.new()
    sign_mat.albedo_color = bg_col
    sign_mat.roughness = 0.45
    sign_mat.emission_enabled = true
    sign_mat.emission = bg_col * 0.4
    sign_mat.emission_energy_multiplier = 0.6
    
    # Iron hanging bracket
    var bracket = MeshInstance3D.new()
    var bb = BoxMesh.new()
    bb.size = Vector3(0.08, 0.08, 1.2)
    bracket.mesh = bb
    bracket.material_override = frame_mat
    bracket.position = Vector3(0.0, 0.35, 0.45)
    sign_node.add_child(bracket)
    
    # Signboard panel
    var board = MeshInstance3D.new()
    var b_box = BoxMesh.new()
    b_box.size = Vector3(0.06, 0.72, 1.35)
    board.mesh = b_box
    board.material_override = sign_mat
    board.position = Vector3(0.0, 0.0, 0.55)
    sign_node.add_child(board)
    
    # Golden border rim
    var rim = MeshInstance3D.new()
    var rb = BoxMesh.new()
    rb.size = Vector3(0.08, 0.76, 1.39)
    var rim_mat = StandardMaterial3D.new()
    rim_mat.albedo_color = Color(0.92, 0.80, 0.25)
    rim_mat.metallic = 0.80
    rim.mesh = rb
    rim.material_override = rim_mat
    rim.position = Vector3(0.0, 0.0, 0.55)
    sign_node.add_child(rim)
    
    return sign_node

func create_villager_silhouette(pos: Vector3, rot_y: float, is_sitting: bool) -> Node3D:
    var v = Node3D.new()
    v.position = pos
    v.rotation.y = rot_y
    
    var coat_mat = StandardMaterial3D.new()
    coat_mat.albedo_color = Color(0.24, 0.28, 0.34) if not is_sitting else Color(0.38, 0.26, 0.18)
    coat_mat.roughness = 0.85
    
    var skin_mat = StandardMaterial3D.new()
    skin_mat.albedo_color = Color(0.85, 0.68, 0.55)
    skin_mat.roughness = 0.60
    
    var hat_mat = StandardMaterial3D.new()
    hat_mat.albedo_color = Color(0.18, 0.25, 0.18) # Alpine green felt hat
    hat_mat.roughness = 0.90
    
    if is_sitting:
        # Torso & Alpine Coat
        var torso = MeshInstance3D.new()
        var tb = BoxMesh.new()
        tb.size = Vector3(0.38, 0.55, 0.28)
        torso.mesh = tb
        torso.material_override = coat_mat
        torso.position = Vector3(0.0, 0.70, 0.0)
        v.add_child(torso)
        
        # Head
        var head = MeshInstance3D.new()
        var hs = SphereMesh.new()
        hs.radius = 0.12
        hs.height = 0.24
        head.mesh = hs
        head.material_override = skin_mat
        head.position = Vector3(0.0, 1.10, 0.0)
        v.add_child(head)
        
        # Alpine Felt Hat
        var hat = MeshInstance3D.new()
        var hc = CylinderMesh.new()
        hc.top_radius = 0.10
        hc.bottom_radius = 0.18
        hc.height = 0.10
        hat.mesh = hc
        hat.material_override = hat_mat
        hat.position = Vector3(0.0, 1.22, 0.0)
        v.add_child(hat)
    else:
        # Standing villager
        var legs = MeshInstance3D.new()
        var lb = BoxMesh.new()
        lb.size = Vector3(0.28, 0.85, 0.22)
        legs.mesh = lb
        legs.material_override = coat_mat
        legs.position = Vector3(0.0, 0.42, 0.0)
        v.add_child(legs)
        
        var torso = MeshInstance3D.new()
        var tb = BoxMesh.new()
        tb.size = Vector3(0.42, 0.65, 0.28)
        torso.mesh = tb
        torso.material_override = coat_mat
        torso.position = Vector3(0.0, 1.15, 0.0)
        v.add_child(torso)
        
        var head = MeshInstance3D.new()
        var hs = SphereMesh.new()
        hs.radius = 0.13
        hs.height = 0.26
        head.mesh = hs
        head.material_override = skin_mat
        head.position = Vector3(0.0, 1.62, 0.0)
        v.add_child(head)
        
    return v

# =========================================================================
# 10. INCROCI STRADALI, SEMAFORI ITALIANI & SEGNALETICA A CHEVRON
# =========================================================================
func create_traffic_light(pos: Vector3, rot_y: float, state: String = "green") -> Node3D:
    var tl = Node3D.new()
    tl.position = pos
    tl.rotation.y = rot_y
    
    var pole_mat = StandardMaterial3D.new()
    pole_mat.albedo_color = Color(0.24, 0.26, 0.28) # Acciaio zincato
    pole_mat.metallic = 0.85
    pole_mat.roughness = 0.35
    
    # Palo verticale principale
    var mast = MeshInstance3D.new()
    var m_cyl = CylinderMesh.new()
    m_cyl.top_radius = 0.08; m_cyl.bottom_radius = 0.11; m_cyl.height = 4.4
    mast.mesh = m_cyl
    mast.material_override = pole_mat
    mast.position.y = 2.2
    tl.add_child(mast)
    
    # Braccio a sbalzo verso la carreggiata
    var arm = MeshInstance3D.new()
    var a_box = BoxMesh.new()
    a_box.size = Vector3(1.8, 0.09, 0.09)
    arm.mesh = a_box
    arm.material_override = pole_mat
    arm.position = Vector3(0.9, 4.2, 0.0)
    tl.add_child(arm)
    
    # Lanterna semaforica sospesa (nero antiriflesso)
    var casing_mat = StandardMaterial3D.new()
    casing_mat.albedo_color = Color(0.08, 0.09, 0.10)
    casing_mat.roughness = 0.80
    
    var casing = MeshInstance3D.new()
    var c_box = BoxMesh.new()
    c_box.size = Vector3(0.36, 1.25, 0.28)
    casing.mesh = c_box
    casing.material_override = casing_mat
    casing.position = Vector3(1.6, 3.7, 0.0)
    tl.add_child(casing)
    
    # Quadro di contrasto (bordo bianco rifrangente tipico italiano)
    var border = MeshInstance3D.new()
    var b_box = BoxMesh.new()
    b_box.size = Vector3(0.44, 1.35, 0.04)
    var b_mat = StandardMaterial3D.new()
    b_mat.albedo_color = Color(0.92, 0.94, 0.96)
    b_mat.roughness = 0.30
    border.mesh = b_box
    border.material_override = b_mat
    border.position = Vector3(1.6, 3.7, -0.12)
    tl.add_child(border)
    
    # 3 Luci (Rosso, Giallo, Verde) con visiere parasole
    var lens_configs = [
        { "y": 4.10, "col": Color(1.0, 0.12, 0.08), "active": (state == "red") },
        { "y": 3.70, "col": Color(1.0, 0.80, 0.10), "active": (state == "amber" or state == "amber_blink") },
        { "y": 3.30, "col": Color(0.12, 1.0, 0.25), "active": (state == "green") }
    ]
    
    for lc in lens_configs:
        var lens = MeshInstance3D.new()
        var sph = SphereMesh.new()
        sph.radius = 0.11; sph.height = 0.14
        var l_mat = StandardMaterial3D.new()
        if lc.active:
            l_mat.albedo_color = lc.col
            l_mat.emission_enabled = true
            l_mat.emission = lc.col
            l_mat.emission_energy_multiplier = 4.2
        else:
            l_mat.albedo_color = Color(0.15, 0.15, 0.15)
            l_mat.emission_enabled = false
        lens.mesh = sph
        lens.material_override = l_mat
        lens.position = Vector3(1.6, lc.y, 0.12)
        tl.add_child(lens)
        
        # Visiera parasole arcuata
        var visor = MeshInstance3D.new()
        var v_box = BoxMesh.new()
        v_box.size = Vector3(0.24, 0.04, 0.18)
        visor.mesh = v_box
        visor.material_override = casing_mat
        visor.position = Vector3(1.6, lc.y + 0.12, 0.08)
        visor.rotation.x = deg_to_rad(25.0)
        tl.add_child(visor)
        
        if lc.active:
            var light = OmniLight3D.new()
            light.light_color = lc.col
            light.light_energy = 2.4
            light.omni_range = 10.0
            light.position = Vector3(1.6, lc.y, 0.35)
            tl.add_child(light)
            
    return tl

func create_road_junction_prop(pos: Vector3, _rot_y: float, _dest_main: String, _dest_branch: String, is_right_side: bool) -> Node3D:
    var j_node = Node3D.new()
    j_node.position = pos
    
    var dir_side = 1.0 if is_right_side else -1.0
    
    # Materiali calibrati e armoniosi
    var j_asphalt_mat = StandardMaterial3D.new()
    j_asphalt_mat.albedo_color = Color(0.24, 0.25, 0.27)
    j_asphalt_mat.roughness = 0.88
    
    var j_stone_mat = cobblestone_material if cobblestone_material else StandardMaterial3D.new()
    if not cobblestone_material:
        j_stone_mat.albedo_color = Color(0.42, 0.40, 0.38)
        j_stone_mat.roughness = 0.90
        
    var mark_mat = StandardMaterial3D.new()
    mark_mat.albedo_color = Color(0.96, 0.96, 0.98)
    mark_mat.roughness = 0.50
    
    var curb_mat = StandardMaterial3D.new()
    curb_mat.albedo_color = Color(0.74, 0.72, 0.70)
    curb_mat.roughness = 0.82
    
    # --------------------------------------------------------------------------
    # 1. INNESTO STRADALE CURVILINEO PERFETTO (Segue get_road_info_at millimetro per millimetro)
    # --------------------------------------------------------------------------
    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    st.set_material(j_asphalt_mat)
    
    var z_half = 16.0
    var num_steps = 16
    var step_dz = (z_half * 2.0) / float(num_steps)
    
    var sections: Array = []
    for k in range(num_steps + 1):
        var z_rel = -z_half + float(k) * step_dz
        var z_world = pos.z + z_rel
        
        # Campiona la traiettoria reale della curva, quota e larghezza dal generatore
        var r = get_road_info_at(z_world)
        var rx = r.get("x", pos.x)
        var ry = r.get("y", pos.y)
        var hw = r.get("width", 7.4) * 0.5
        var r_ang = r.get("angle", 0.0)
        var n_x = cos(r_ang)
        var n_z = -sin(r_ang)
        
        var x_road_rel = rx - pos.x
        var y_road_rel = ry - pos.y
        
        # Curva di raccordo a campana conica (apertura progressiva della diramazione)
        var norm_z = clamp(z_rel / z_half, -1.0, 1.0)
        var flare = cos(norm_z * (PI * 0.5))
        
        # Bordo interno: combacia con il ciglio esterno della banchina (mai all'interno dell'asfalto!)
        var in_dist = (hw + 0.05) * dir_side
        var out_dist = (hw + 0.05 + flare * 8.5) * dir_side
        var x_inner = x_road_rel + n_x * in_dist
        var z_inner = z_rel + n_z * in_dist
        var x_outer = x_road_rel + n_x * out_dist
        var z_outer = z_rel + n_z * out_dist
        var y_outer = y_road_rel - 0.03 * flare
        
        sections.append({
            "z_in": z_inner,
            "z_out": z_outer,
            "y_in": y_road_rel - 0.005,
            "y_out": y_outer - 0.005,
            "x_in": x_inner,
            "x_out": x_outer
        })
        
    # Triangolazione superficie asfaltata
    for k in range(num_steps):
        var s1 = sections[k]
        var s2 = sections[k + 1]
        
        var v_in1 = Vector3(s1.x_in, s1.y_in, s1.z_in)
        var v_out1 = Vector3(s1.x_out, s1.y_out, s1.z_out)
        var v_in2 = Vector3(s2.x_in, s2.y_in, s2.z_in)
        var v_out2 = Vector3(s2.x_out, s2.y_out, s2.z_out)
        
        if is_right_side:
            st.add_vertex(v_in1); st.add_vertex(v_out1); st.add_vertex(v_out2)
            st.add_vertex(v_in1); st.add_vertex(v_out2); st.add_vertex(v_in2)
        else:
            st.add_vertex(v_in1); st.add_vertex(v_out2); st.add_vertex(v_out1)
            st.add_vertex(v_in1); st.add_vertex(v_in2); st.add_vertex(v_out2)
            
    st.generate_normals()
    var apron_mesh = st.commit()
    var apron_instance = MeshInstance3D.new()
    apron_instance.mesh = apron_mesh
    
    var apron_body = StaticBody3D.new()
    var apron_col = CollisionShape3D.new()
    apron_col.shape = apron_mesh.create_trimesh_shape()
    apron_body.add_child(apron_col)
    apron_instance.add_child(apron_body)
    j_node.add_child(apron_instance)
    
    # --------------------------------------------------------------------------
    # 2. SCARPATA NATURALE E BANCHINA IN PIETRA (Raccordo morbido al terreno montano)
    # --------------------------------------------------------------------------
    var st_wall = SurfaceTool.new()
    st_wall.begin(Mesh.PRIMITIVE_TRIANGLES)
    st_wall.set_material(j_stone_mat)
    
    for k in range(num_steps):
        var s1 = sections[k]
        var s2 = sections[k + 1]
        
        var v_top1 = Vector3(s1.x_out, s1.y_out, s1.z_out)
        var v_bot1 = Vector3(s1.x_out + dir_side * 0.75, s1.y_out - 1.6, s1.z_out)
        var v_top2 = Vector3(s2.x_out, s2.y_out, s2.z_out)
        var v_bot2 = Vector3(s2.x_out + dir_side * 0.75, s2.y_out - 1.6, s2.z_out)
        
        if is_right_side:
            st_wall.add_vertex(v_top1); st_wall.add_vertex(v_bot1); st_wall.add_vertex(v_bot2)
            st_wall.add_vertex(v_top1); st_wall.add_vertex(v_bot2); st_wall.add_vertex(v_top2)
        else:
            st_wall.add_vertex(v_top1); st_wall.add_vertex(v_bot2); st_wall.add_vertex(v_bot1)
            st_wall.add_vertex(v_top1); st_wall.add_vertex(v_top2); st_wall.add_vertex(v_bot2)
            
    st_wall.generate_normals()
    var wall_mesh = st_wall.commit()
    var wall_instance = MeshInstance3D.new()
    wall_instance.mesh = wall_mesh
    
    var wall_body = StaticBody3D.new()
    var wall_col = CollisionShape3D.new()
    wall_col.shape = wall_mesh.create_trimesh_shape()
    wall_body.add_child(wall_col)
    wall_instance.add_child(wall_body)
    j_node.add_child(wall_instance)
    
    # --------------------------------------------------------------------------
    # 3. SEGNALETICA ORIZZONTALE A RASO (Stop Line sul ramo secondario)
    # --------------------------------------------------------------------------
    var st_stop = SurfaceTool.new()
    st_stop.begin(Mesh.PRIMITIVE_TRIANGLES)
    st_stop.set_material(mark_mat)
    
    var stop_w = 0.40
    var stop_z_half = 1.8
    var stop_steps = 4
    var s_dz = (stop_z_half * 2.0) / float(stop_steps)
    
    for sk in range(stop_steps):
        var z1 = -stop_z_half + float(sk) * s_dz
        var z2 = z1 + s_dz
        
        var r1 = get_road_info_at(pos.z + z1)
        var r2 = get_road_info_at(pos.z + z2)
        var r1_hw = r1.get("width", 7.4) * 0.5
        var r2_hw = r2.get("width", 7.4) * 0.5
        var stop_x1 = (r1.get("x", pos.x) - pos.x) + dir_side * (r1_hw + 1.2)
        var stop_x2 = (r2.get("x", pos.x) - pos.x) + dir_side * (r2_hw + 1.2)
        var y1 = (r1.get("y", pos.y) - pos.y) + 0.008
        var y2 = (r2.get("y", pos.y) - pos.y) + 0.008
        
        var sv1 = Vector3(stop_x1 - dir_side * stop_w * 0.5, y1, z1)
        var sv2 = Vector3(stop_x1 + dir_side * stop_w * 0.5, y1, z1)
        var sv3 = Vector3(stop_x2 + dir_side * stop_w * 0.5, y2, z2)
        var sv4 = Vector3(stop_x2 - dir_side * stop_w * 0.5, y2, z2)
        
        if is_right_side:
            st_stop.add_vertex(sv1); st_stop.add_vertex(sv2); st_stop.add_vertex(sv3)
            st_stop.add_vertex(sv1); st_stop.add_vertex(sv3); st_stop.add_vertex(sv4)
        else:
            st_stop.add_vertex(sv1); st_stop.add_vertex(sv3); st_stop.add_vertex(sv2)
            st_stop.add_vertex(sv1); st_stop.add_vertex(sv4); st_stop.add_vertex(sv3)
            
    st_stop.generate_normals()
    var stop_line_inst = MeshInstance3D.new()
    stop_line_inst.mesh = st_stop.commit()
    j_node.add_child(stop_line_inst)
    
    # --------------------------------------------------------------------------
    # 4. CARTELLO DIREZIONALE ITALIANO STATALE SU PALO ANCORATO (Fuori dalla carreggiata)
    # --------------------------------------------------------------------------
    var pole_z = -7.5
    var r_pole = get_road_info_at(pos.z + pole_z)
    var p_ang = r_pole.get("angle", 0.0)
    var p_nx = cos(p_ang)
    var p_nz = -sin(p_ang)
    var p_dist = dir_side * (r_pole.get("width", 7.4) * 0.5 + 2.5)
    var pole_x = (r_pole.get("x", pos.x) - pos.x) + p_nx * p_dist
    var pole_z_real = pole_z + p_nz * p_dist
    var pole_yg = r_pole.get("y", pos.y) - pos.y
    
    var sign_pole = MeshInstance3D.new()
    var p_cyl = CylinderMesh.new()
    p_cyl.top_radius = 0.04; p_cyl.bottom_radius = 0.045; p_cyl.height = 3.6
    sign_pole.mesh = p_cyl
    sign_pole.material_override = curb_mat
    sign_pole.position = Vector3(pole_x, pole_yg + 1.2, pole_z_real)
    j_node.add_child(sign_pole)
    
    # Freccia Direzione Principale (Blu Statale ANAS)
    var f1 = MeshInstance3D.new()
    var fb1 = BoxMesh.new()
    fb1.size = Vector3(1.6, 0.36, 0.05)
    var f1_mat = StandardMaterial3D.new()
    f1_mat.albedo_color = Color(0.10, 0.28, 0.68)
    f1.mesh = fb1
    f1.material_override = f1_mat
    f1.position = Vector3(pole_x, pole_yg + 2.7, pole_z_real)
    j_node.add_child(f1)
    
    # Freccia Ramo secondario (Marrone Turistica / Località montana)
    var f2 = MeshInstance3D.new()
    var fb2 = BoxMesh.new()
    fb2.size = Vector3(1.6, 0.36, 0.05)
    var f2_mat = StandardMaterial3D.new()
    f2_mat.albedo_color = Color(0.48, 0.28, 0.16)
    f2.mesh = fb2
    f2.material_override = f2_mat
    f2.position = Vector3(pole_x, pole_yg + 2.25, pole_z_real)
    j_node.add_child(f2)
    
    # --------------------------------------------------------------------------
    # 5. CARTELLO STOP OTTAGONALE SU PALO SUL RAMO SECONDARIO (Ben arretrato)
    # --------------------------------------------------------------------------
    var stop_z = 3.0
    var r_stop = get_road_info_at(pos.z + stop_z)
    var s_ang = r_stop.get("angle", 0.0)
    var s_nx = cos(s_ang)
    var s_nz = -sin(s_ang)
    var s_dist = dir_side * (r_stop.get("width", 7.4) * 0.5 + 3.2)
    var stop_px = (r_stop.get("x", pos.x) - pos.x) + s_nx * s_dist
    var stop_z_real = stop_z + s_nz * s_dist
    var stop_yg = r_stop.get("y", pos.y) - pos.y
    
    var stop_group = Node3D.new()
    stop_group.position = Vector3(stop_px, stop_yg, stop_z_real)
    stop_group.rotation.y = dir_side * deg_to_rad(90.0)
    
    var stop_post = MeshInstance3D.new()
    var sp_cyl = CylinderMesh.new()
    sp_cyl.top_radius = 0.035; sp_cyl.bottom_radius = 0.04; sp_cyl.height = 3.2
    sp_cyl.material = curb_mat
    stop_post.mesh = sp_cyl
    stop_post.position.y = 1.0 # Affonda di -0.6m
    stop_group.add_child(stop_post)
    
    var stop_oct = MeshInstance3D.new()
    var so_cyl = CylinderMesh.new()
    so_cyl.top_radius = 0.38; so_cyl.bottom_radius = 0.38; so_cyl.height = 0.035
    so_cyl.radial_segments = 8
    var so_mat = StandardMaterial3D.new()
    so_mat.albedo_color = Color(0.85, 0.08, 0.08)
    so_mat.roughness = 0.35
    stop_oct.mesh = so_cyl
    stop_oct.material_override = so_mat
    stop_oct.position = Vector3(0.0, 2.1, 0.0)
    stop_oct.rotation.x = deg_to_rad(90.0)
    stop_group.add_child(stop_oct)
    
    var stop_rim = MeshInstance3D.new()
    var sr_box = BoxMesh.new()
    sr_box.size = Vector3(0.48, 0.14, 0.04)
    stop_rim.mesh = sr_box
    stop_rim.material_override = mark_mat
    stop_rim.position = Vector3(0.0, 2.1, 0.02)
    stop_group.add_child(stop_rim)
    j_node.add_child(stop_group)
    
    # --------------------------------------------------------------------------
    # 6. PARACARRI STORICI IN PIETRA MILIARE ANAS (Dimensioni realistiche: h=52cm, r=11cm)
    # --------------------------------------------------------------------------
    for curb_z in [-13.5, 13.5]:
        var r_cb = get_road_info_at(pos.z + curb_z)
        var cb_x = (r_cb.get("x", pos.x) - pos.x) + dir_side * (r_cb.get("width", 7.4) * 0.5 + 0.35)
        var cb_yg = r_cb.get("y", pos.y) - pos.y
        var cb_p = MeshInstance3D.new()
        var c_cyl = CylinderMesh.new()
        c_cyl.top_radius = 0.11; c_cyl.bottom_radius = 0.13; c_cyl.height = 0.55
        cb_p.mesh = c_cyl
        cb_p.material_override = curb_mat
        cb_p.position = Vector3(cb_x, cb_yg + 0.22, curb_z) # Base tocca terra con 22cm emersi
        j_node.add_child(cb_p)
        
    # --------------------------------------------------------------------------
    # 7. RAMO STRADALE SECONDARIO ESTESO (45 metri nel paesaggio montano / poderale)
    # --------------------------------------------------------------------------
    var branch_node = Node3D.new()
    var st_branch = SurfaceTool.new()
    st_branch.begin(Mesh.PRIMITIVE_TRIANGLES)
    st_branch.set_material(j_asphalt_mat)
    
    var num_b_steps = 12
    var b_hw = 2.6 # Larghezza 5.2m per carreggiata secondaria
    var b_sections: Array = []
    
    for bi in range(num_b_steps + 1):
        var t_dist = float(bi) * 3.6
        var bx = dir_side * (8.5 + t_dist)
        var bz = -1.5 + sin(float(bi) * 0.32) * 5.2
        var by = (get_terrain_elevation(pos.y, pos.z + bz, bx) - pos.y) + 0.04
        
        var next_dist = float(bi + 1) * 3.6
        var next_bx = dir_side * (8.5 + next_dist)
        var next_bz = -1.5 + sin(float(bi + 1) * 0.32) * 5.2
        var t_ang = atan2(next_bz - bz, next_bx - bx)
        var norm_x = -sin(t_ang) * b_hw
        var norm_z = cos(t_ang) * b_hw
        
        var b_left = Vector3(bx - norm_x, by, bz - norm_z)
        var b_right = Vector3(bx + norm_x, by, bz + norm_z)
        b_sections.append({"left": b_left, "right": b_right, "center": Vector3(bx, by, bz), "norm": Vector3(norm_x, 0, norm_z)})
        
        # Staccionata montana in legno rustico sui bordi del ramo
        if bi > 0 and bi % 2 == 0 and bi < num_b_steps:
            for f_side in [-1.0, 1.0]:
                var f_edge = Vector3(bx + f_side * norm_x, by, bz + f_side * norm_z)
                var post = MeshInstance3D.new()
                var pcyl = CylinderMesh.new()
                pcyl.top_radius = 0.06; pcyl.bottom_radius = 0.07; pcyl.height = 1.3
                pcyl.material = chalet_timber_material
                post.mesh = pcyl
                post.position = Vector3(f_edge.x, f_edge.y + 0.65, f_edge.z)
                branch_node.add_child(post)
                
    for bi in range(num_b_steps):
        var sec1 = b_sections[bi]
        var sec2 = b_sections[bi + 1]
        
        if dir_side > 0.0:
            st_branch.add_vertex(sec1.left); st_branch.add_vertex(sec2.left); st_branch.add_vertex(sec2.right)
            st_branch.add_vertex(sec1.left); st_branch.add_vertex(sec2.right); st_branch.add_vertex(sec1.right)
        else:
            st_branch.add_vertex(sec1.left); st_branch.add_vertex(sec2.right); st_branch.add_vertex(sec2.left)
            st_branch.add_vertex(sec1.left); st_branch.add_vertex(sec1.right); st_branch.add_vertex(sec2.right)
            
    st_branch.generate_normals()
    var b_mesh = st_branch.commit()
    var b_inst = MeshInstance3D.new()
    b_inst.mesh = b_mesh
    
    var b_body = StaticBody3D.new()
    var b_col = CollisionShape3D.new()
    b_col.shape = b_mesh.create_trimesh_shape()
    b_body.add_child(b_col)
    b_inst.add_child(b_body)
    branch_node.add_child(b_inst)
    j_node.add_child(branch_node)
    
    return j_node

func create_chevron_curve_sign(pos: Vector3, rot_y: float, num_chevrons: int, is_turn_right: bool) -> Node3D:
    var ch_group = Node3D.new()
    ch_group.position = pos
    ch_group.rotation.y = rot_y
    
    var panel_width = 1.1 * float(num_chevrons)
    
    # Support posts
    var post_mat = StandardMaterial3D.new()
    post_mat.albedo_color = Color(0.35, 0.38, 0.42)
    post_mat.metallic = 0.8
    
    for px in [-panel_width * 0.4, panel_width * 0.4]:
        var post = MeshInstance3D.new()
        var cyl = CylinderMesh.new()
        cyl.top_radius = 0.04; cyl.bottom_radius = 0.04; cyl.height = 1.8
        post.mesh = cyl
        post.material_override = post_mat
        post.position = Vector3(px, 0.9, 0.0)
        ch_group.add_child(post)
        
    # White reflective background board
    var board = MeshInstance3D.new()
    var b_box = BoxMesh.new()
    b_box.size = Vector3(panel_width, 0.65, 0.05)
    var b_mat = StandardMaterial3D.new()
    b_mat.albedo_color = Color(0.96, 0.96, 0.98)
    board.mesh = b_box
    board.material_override = b_mat
    board.position = Vector3(0.0, 1.35, 0.0)
    ch_group.add_child(board)
    
    # Black Chevrons
    var chev_mat = StandardMaterial3D.new()
    chev_mat.albedo_color = Color(0.08, 0.08, 0.10)
    
    for c in range(num_chevrons):
        var cx = -panel_width * 0.5 + 0.55 + float(c) * 1.1
        var bar1 = MeshInstance3D.new()
        var bb1 = BoxMesh.new()
        bb1.size = Vector3(0.14, 0.38, 0.06)
        bar1.mesh = bb1
        bar1.material_override = chev_mat
        bar1.position = Vector3(cx - (0.09 if is_turn_right else -0.09), 1.45, 0.01)
        bar1.rotation.z = deg_to_rad(35.0 if is_turn_right else -35.0)
        ch_group.add_child(bar1)
        
        var bar2 = MeshInstance3D.new()
        var bb2 = BoxMesh.new()
        bb2.size = Vector3(0.14, 0.38, 0.06)
        bar2.mesh = bb2
        bar2.material_override = chev_mat
        bar2.position = Vector3(cx - (0.09 if is_turn_right else -0.09), 1.25, 0.01)
        bar2.rotation.z = deg_to_rad(-35.0 if is_turn_right else 35.0)
        ch_group.add_child(bar2)
        
    return ch_group

func create_italian_danger_sign(pos: Vector3, rot_y: float, sign_type: String) -> Node3D:
    var sign_group = Node3D.new()
    sign_group.position = pos
    sign_group.rotation.y = rot_y
    
    # Palo tubolare zincato
    var post = MeshInstance3D.new()
    var cyl = CylinderMesh.new()
    cyl.top_radius = 0.035; cyl.bottom_radius = 0.038; cyl.height = 2.2
    cyl.material = post_material
    post.mesh = cyl
    post.position.y = 1.1
    sign_group.add_child(post)
    
    # Bordo triangolare rosso Anas
    var outer_tri = MeshInstance3D.new()
    var p_outer = PrismMesh.new()
    p_outer.size = Vector3(0.72, 0.65, 0.04)
    outer_tri.mesh = p_outer
    outer_tri.material_override = danger_sign_red_material
    outer_tri.position = Vector3(0.0, 1.85, 0.02)
    sign_group.add_child(outer_tri)
    
    # Fondo triangolare bianco rifrangente
    var inner_tri = MeshInstance3D.new()
    var p_inner = PrismMesh.new()
    p_inner.size = Vector3(0.54, 0.48, 0.042)
    inner_tri.mesh = p_inner
    inner_tri.material_override = danger_sign_white_material
    inner_tri.position = Vector3(0.0, 1.82, 0.022)
    sign_group.add_child(inner_tri)
    
    # Pittogramma nero Anas
    var sym = MeshInstance3D.new()
    var sym_box = BoxMesh.new()
    if sign_type == "dosso":
        sym_box.size = Vector3(0.32, 0.12, 0.045)
    elif sign_type == "strettoia":
        sym_box.size = Vector3(0.24, 0.22, 0.045)
    else:
        sym_box.size = Vector3(0.18, 0.26, 0.045)
    sym.mesh = sym_box
    sym.material_override = danger_sign_black_material
    sym.position = Vector3(0.0, 1.78, 0.025)
    sign_group.add_child(sym)
    
    return sign_group

func create_parabolic_mirror(pos: Vector3, rot_y: float) -> Node3D:
    var mirror_group = Node3D.new()
    mirror_group.position = pos
    mirror_group.rotation.y = rot_y
    
    # Palo di sostegno con collare
    var post = MeshInstance3D.new()
    var p_cyl = CylinderMesh.new()
    p_cyl.top_radius = 0.045; p_cyl.bottom_radius = 0.048; p_cyl.height = 2.6
    p_cyl.material = post_material
    post.mesh = p_cyl
    post.position.y = 1.3
    mirror_group.add_child(post)
    
    # Cornice circolare a settori bianchi e rossi
    var frame = MeshInstance3D.new()
    var f_cyl = CylinderMesh.new()
    f_cyl.top_radius = 0.44; f_cyl.bottom_radius = 0.44; f_cyl.height = 0.06
    frame.mesh = f_cyl
    frame.material_override = danger_sign_red_material
    frame.position = Vector3(0.0, 2.3, 0.0)
    frame.rotation.x = deg_to_rad(90.0)
    mirror_group.add_child(frame)
    
    # Calotta convessa a specchio riflettente ad alta fedeltà
    var mirror = MeshInstance3D.new()
    var m_sphere = SphereMesh.new()
    m_sphere.radius = 0.38; m_sphere.height = 0.25
    mirror.mesh = m_sphere
    mirror.material_override = mirror_chrome_material
    mirror.position = Vector3(0.0, 2.3, 0.04)
    mirror_group.add_child(mirror)
    
    return mirror_group

func create_olive_tree(pos: Vector3) -> Node3D:
    var tree = Node3D.new()
    tree.position = pos
    
    # Tronco nodoso e contorto tipico dell'ulivo secolare italiano (ancorato in profondità)
    var trunk = MeshInstance3D.new()
    var t_cyl = CylinderMesh.new()
    t_cyl.top_radius = 0.28; t_cyl.bottom_radius = 0.48; t_cyl.height = 3.2
    trunk.mesh = t_cyl
    trunk.material_override = olive_bark_material
    trunk.position.y = 0.6 # Sinks 1.0m into soil
    trunk.rotation.z = deg_to_rad(randf_range(-10.0, 10.0))
    tree.add_child(trunk)
    
    # Flared root collar at soil surface
    var flare = MeshInstance3D.new()
    var f_cyl = CylinderMesh.new()
    f_cyl.top_radius = 0.42; f_cyl.bottom_radius = 0.72; f_cyl.height = 0.60
    flare.mesh = f_cyl
    flare.material_override = olive_bark_material
    flare.position.y = 0.10
    tree.add_child(flare)
    
    # Chioma tondeggiante a nuvola con foglie argentee
    var foliage_centers = [
        Vector3(0.0, 2.2, 0.0),
        Vector3(-0.6, 2.0, 0.4),
        Vector3(0.65, 2.1, -0.3),
        Vector3(0.1, 2.5, 0.5)
    ]
    for fc in foliage_centers:
        var sphere = MeshInstance3D.new()
        var s_mesh = SphereMesh.new()
        s_mesh.radius = randf_range(0.85, 1.25)
        s_mesh.height = s_mesh.radius * 1.6
        sphere.mesh = s_mesh
        sphere.material_override = olive_leaf_material
        sphere.position = fc
        tree.add_child(sphere)
        
    return tree

func create_maritime_pine(pos: Vector3) -> Node3D:
    var pine = Node3D.new()
    pine.position = pos
    
    # Tronco slanciato dal colore rossiccio tipico del Pinus pinea (ancorato in profondità)
    var trunk = MeshInstance3D.new()
    var t_cyl = CylinderMesh.new()
    t_cyl.top_radius = 0.22; t_cyl.bottom_radius = 0.42; t_cyl.height = 10.0
    trunk.mesh = t_cyl
    trunk.material_override = maritime_pine_bark_material
    trunk.position.y = 3.5 # Sinks 1.5m into ground
    trunk.rotation.z = deg_to_rad(randf_range(-4.0, 4.0))
    pine.add_child(trunk)
    
    var flare = MeshInstance3D.new()
    var f_cyl = CylinderMesh.new()
    f_cyl.top_radius = 0.38; f_cyl.bottom_radius = 0.68; f_cyl.height = 0.80
    flare.mesh = f_cyl
    flare.material_override = maritime_pine_bark_material
    flare.position.y = 0.20
    pine.add_child(flare)
    
    # Iconica chioma a ombrello aperta verso il cielo
    var umbrella = MeshInstance3D.new()
    var u_cyl = CylinderMesh.new()
    u_cyl.top_radius = 4.2; u_cyl.bottom_radius = 1.8; u_cyl.height = 1.6
    umbrella.mesh = u_cyl
    umbrella.material_override = pine_material
    umbrella.position.y = 7.4
    pine.add_child(umbrella)
    
    var top_dome = MeshInstance3D.new()
    var d_sphere = SphereMesh.new()
    d_sphere.radius = 3.6; d_sphere.height = 1.4
    top_dome.mesh = d_sphere
    top_dome.material_override = pine_material
    top_dome.position.y = 8.1
    pine.add_child(top_dome)
    
    return pine

func get_safe_roadside_point(target_z: float, side: float, clearance: float, pts: Array = []) -> Dictionary:
    var info: Dictionary
    var found_in_pts = false
    if pts.size() > 0 and target_z >= pts[0].z and target_z <= pts[pts.size() - 1].z:
        info = sample_chunk_road(pts, target_z)
        found_in_pts = true
    if not found_in_pts:
        var r = get_road_info_at(target_z)
        if r.get("found", false):
            info = r
        elif pts.size() > 0:
            var p_clamp = pts[0] if target_z < pts[0].z else pts[pts.size() - 1]
            info = { "x": p_clamp.x, "y": p_clamp.y, "width": p_clamp.width, "angle": p_clamp.angle }
        else:
            info = { "x": 0.0, "y": 0.0, "width": base_width, "angle": 0.0 }
            
    var rx: float = info.x
    var ry: float = info.y
    var rw: float = info.width
    var r_ang: float = info.angle
    
    var t_dx = sin(r_ang)
    var t_dz = cos(r_ang)
    var n_x = t_dz
    var n_z = -t_dx
    
    var dist = side * (rw * 0.5 + clearance)
    var pos = Vector3(rx + n_x * dist, ry, target_z + n_z * dist)
    return { "pos": pos, "angle": r_ang, "x": rx, "y": ry, "width": rw }

func spawn_road_junctions_and_traffic_lights(root: Node3D, points: Array, start_z: float):
    var num_pts = points.size()
    var mid_p = points[int(num_pts * 0.5)]
    var p0 = points[0]
    
    # 1. Bivio Cascina San Rocco & Val Saviore (Z in [580, 700])
    if start_z >= 580.0 and start_z < 700.0:
        var j_pos = Vector3(mid_p.x, mid_p.y, mid_p.z)
        var junction = create_road_junction_prop(j_pos, mid_p.angle, "PASSO DEL VALICO", "CASCINA SAN ROCCO", true)
        root.add_child(junction)
        
        # Specchio parabolico stradale per incrocio cieco montano (posizionato in banchina esterna)
        var mirror_pt = get_safe_roadside_point(mid_p.z - 3.0, 1.0, 2.4, points)
        var mirror = create_parabolic_mirror(mirror_pt.pos, mirror_pt.angle + PI * 0.8)
        root.add_child(mirror)
        
        # Semaforo a luce gialla lampeggiante d'attenzione per incrocio montano
        var tl_pt = get_safe_roadside_point(mid_p.z - 6.0, 1.0, 1.8, points)
        var tl = create_traffic_light(tl_pt.pos, tl_pt.angle, "amber_blink")
        root.add_child(tl)
        
    # 2. Semaforo e Ingresso Storico Borgo San Cristoforo (Z in [840, 960])
    elif start_z >= 840.0 and start_z < 960.0:
        # Cartello di pericolo strettoia / centro abitato 25m prima dell'arco (in banchina sicura)
        var d_pt = get_safe_roadside_point(p0.z - 25.0, 1.0, 2.2, points)
        var danger_entry = create_italian_danger_sign(d_pt.pos, d_pt.angle, "strettoia")
        root.add_child(danger_entry)
        
        # Specchio parabolico per visibilità angolo cieco mura
        var m_pt = get_safe_roadside_point(p0.z + 2.0, -1.0, 2.2, points)
        var mirror_entry = create_parabolic_mirror(m_pt.pos, m_pt.angle - PI * 0.25)
        root.add_child(mirror_entry)
        
        # Semaforo di regolazione all'ingresso del borgo
        var tl_pt = get_safe_roadside_point(p0.z + 4.0, 1.0, 1.8, points)
        var tl_entry = create_traffic_light(tl_pt.pos, tl_pt.angle, "green")
        root.add_child(tl_entry)
        
        # Strisce pedonali (Zebra crossing) all'ingresso del borgo
        var zebra_group = Node3D.new()
        var z_info = sample_chunk_road(points, p0.z + 8.0)
        zebra_group.position = Vector3(z_info.x, z_info.y + 0.016, p0.z + 8.0)
        zebra_group.rotation.y = z_info.angle
        var z_mat = StandardMaterial3D.new()
        z_mat.albedo_color = Color(0.96, 0.96, 0.98)
        for s in range(7):
            var stripe = MeshInstance3D.new()
            var sb = BoxMesh.new()
            sb.size = Vector3(0.55, 0.015, 2.6)
            stripe.mesh = sb
            stripe.material_override = z_mat
            stripe.position = Vector3(-z_info.width * 0.40 + float(s) * (z_info.width * 0.80 / 6.0), 0.0, 0.0)
            zebra_group.add_child(stripe)
        root.add_child(zebra_group)
        
    # 3. Strettoia Forra dell'Appennino / Ponte dei Ciclopi (Z in [1400, 1520])
    elif start_z >= 1400.0 and start_z < 1520.0:
        var tl_pt = get_safe_roadside_point(p0.z + 12.0, 1.0, 1.8, points)
        var tl_bridge = create_traffic_light(tl_pt.pos, tl_pt.angle, "green")
        root.add_child(tl_bridge)
        
        # Cartello di pericolo ponte stretto sulla banchina a monte
        var db_pt = get_safe_roadside_point(p0.z - 20.0, 1.0, 2.2, points)
        var danger_bridge = create_italian_danger_sign(db_pt.pos, db_pt.angle, "strettoia")
        root.add_child(danger_bridge)
        
    # 4. Bivio Cava di Marmo & Forra Appennino (Z in [1680, 1800])
    elif start_z >= 1680.0 and start_z < 1800.0:
        var j_pos = Vector3(mid_p.x, mid_p.y, mid_p.z)
        var junction = create_road_junction_prop(j_pos, mid_p.angle, "FORRA DEI CICLOPI", "CAVA DI MARMO", false)
        root.add_child(junction)
        
        var m_pt = get_safe_roadside_point(mid_p.z - 2.5, -1.0, 2.4, points)
        var mirror = create_parabolic_mirror(m_pt.pos, m_pt.angle - PI * 0.82)
        root.add_child(mirror)
        
        var dj_pt = get_safe_roadside_point(p0.z - 25.0, -1.0, 2.2, points)
        var danger_junc = create_italian_danger_sign(dj_pt.pos, dj_pt.angle, "incrocio")
        root.add_child(danger_junc)
        
    # 5. Bivio Valico del Duca & 14 Tornanti dei Larici (Z in [3360, 3480])
    elif start_z >= 3360.0 and start_z < 3480.0:
        var j_pos = Vector3(mid_p.x, mid_p.y, mid_p.z)
        var junction = create_road_junction_prop(j_pos, mid_p.angle, "I 14 TORNANTI", "VALICO DEL DUCA", false)
        root.add_child(junction)
        
        var m_pt = get_safe_roadside_point(mid_p.z - 2.5, -1.0, 2.4, points)
        var mirror = create_parabolic_mirror(m_pt.pos, m_pt.angle - PI * 0.82)
        root.add_child(mirror)
        
        var dj_pt = get_safe_roadside_point(p0.z - 25.0, -1.0, 2.2, points)
        var danger_junc = create_italian_danger_sign(dj_pt.pos, dj_pt.angle, "incrocio")
        root.add_child(danger_junc)
        
    # 6. Bivio Tenuta Agricola e Podere San Pietro (Z in [5040, 5160])
    elif start_z >= 5040.0 and start_z < 5160.0:
        var j_pos = Vector3(mid_p.x, mid_p.y, mid_p.z)
        var junction = create_road_junction_prop(j_pos, mid_p.angle, "BORGO ALTOPIANO", "PODERE SAN PIETRO", true)
        root.add_child(junction)
        
        var m_pt = get_safe_roadside_point(mid_p.z - 2.5, 1.0, 2.4, points)
        var mirror = create_parabolic_mirror(m_pt.pos, m_pt.angle + PI * 0.80)
        root.add_child(mirror)
        
        var dj_pt = get_safe_roadside_point(p0.z - 25.0, 1.0, 2.2, points)
        var danger_junc = create_italian_danger_sign(dj_pt.pos, dj_pt.angle, "incrocio")
        root.add_child(danger_junc)
        
    # 4. Curve a gomito e tornanti: Delineatori modulari a Chevron & Cartelli Curva Pericolosa (Anti-Punti Ciechi)
    var p_last = points[num_pts - 1]
    var angle_diff = p_last.angle - p0.angle
    if abs(angle_diff) > 0.08 and start_z > 80.0:
        var is_right = angle_diff > 0.0
        var outer_side = -1.0 if is_right else 1.0 # Delineatore sul lato esterno della curva
        var ch_pt = get_safe_roadside_point(mid_p.z, outer_side, 2.2, points)
        var chevrons = create_chevron_curve_sign(ch_pt.pos, ch_pt.angle, 3, is_right)
        root.add_child(chevrons)
        
        # Cartello triangolare di pericolo prima della curva cieca per visibilità preventiva
        var ds_pt = get_safe_roadside_point(p0.z - 15.0, 1.0, 2.2, points)
        var d_sign = create_italian_danger_sign(ds_pt.pos, ds_pt.angle, "curva_destra" if is_right else "curva_sinistra")
        root.add_child(d_sign)
        
    # 5. Dossi e cambi di pendenza ripidi: Segnale pericolo Dosso per eliminare punti ciechi verticali
    var elev_change = p_last.y - p0.y
    if abs(elev_change) > 1.8 and start_z > 120.0 and int(start_z) % 240 == 0:
        var dosso_pt = get_safe_roadside_point(p0.z - 20.0, 1.0, 2.2, points)
        var dosso_sign = create_italian_danger_sign(dosso_pt.pos, dosso_pt.angle, "dosso")
        root.add_child(dosso_sign)
        
    # 6. Vegetazione Mediterranea Iconica (Ulivi e Pini Marittimi nelle zone collinari/rurali)
    var b_info = get_biome_at(start_z)
    var b_type = b_info.get("type", BiomeGraph.BiomeType.ALPINE_MEADOWS)
    if b_type == BiomeGraph.BiomeType.GOLDEN_PLATEAU or b_type == BiomeGraph.BiomeType.TUSCAN_HILLS or b_type == BiomeGraph.BiomeType.COASTAL_RIVIERA:
        if int(start_z) % 120 == 0:
            var olive_lat = -(mid_p.width * 0.5 + randf_range(7.0, 16.0))
            var olive_y = get_terrain_elevation(mid_p.y, mid_p.z + 10.0, olive_lat)
            var olive_pos = Vector3(mid_p.x + olive_lat, olive_y, mid_p.z + 10.0)
            var olive = create_olive_tree(olive_pos)
            root.add_child(olive)
            
            var pine_lat = mid_p.width * 0.5 + randf_range(9.0, 22.0)
            var pine_y = get_terrain_elevation(mid_p.y, mid_p.z - 15.0, pine_lat)
            var pine_pos = Vector3(mid_p.x + pine_lat, pine_y, mid_p.z - 15.0)
            var pine = create_maritime_pine(pine_pos)
            root.add_child(pine)


