extends Node
class_name BiomeDirector

# THE LONG MERIDIAN - Atmospheric & Biome Director (Godot 4 Vulkan)
# Coordinates dynamic lighting, sky gradients, volumetric fog density,
# and regional atmospheric transitions as the vehicle travels along the meridian.

signal biome_changed(biome_name)

@export var world_environment: WorldEnvironment
@export var sun_light: DirectionalLight3D
@export var road_generator: Node3D

var current_biome_index: int = -1
var current_biome_name: String = ""

var current_wetness: float = 0.15
var current_wind: float = 1.0

# Biome definitions along the Z progression
var biomes = [
	{
		"start_z": 0.0,
		"name": "PASSO DELLE ALPI & DOLOMITI - QUOTA 2244M",
		"fog_density": 0.00028,
		"fog_color": Color(0.82, 0.88, 0.96),
		"sun_color": Color(1.0, 0.95, 0.88),
		"sun_energy": 1.28,
		"sun_angle_x": -35.0,
		"sun_angle_y": 140.0,
		"sky_top": Color(0.16, 0.38, 0.75),
		"sky_horizon": Color(0.75, 0.84, 0.94),
		"wetness": 0.10,
		"wind": 1.0
	},
	{
		"start_z": 1400.0,
		"name": "FORRA DELL'APPENNINO & PONTE DEI CICLOPI",
		"fog_density": 0.00065,
		"fog_color": Color(0.48, 0.54, 0.62),
		"sun_color": Color(0.72, 0.78, 0.86),
		"sun_energy": 0.45,
		"sun_angle_x": -45.0,
		"sun_angle_y": 135.0,
		"sky_top": Color(0.14, 0.18, 0.24),
		"sky_horizon": Color(0.32, 0.38, 0.44),
		"wetness": 0.95,
		"wind": 1.8
	},
	{
		"start_z": 3000.0,
		"name": "VALICO DEI LARICI - MILLE MIGLIA & TORNANTI",
		"fog_density": 0.00035,
		"fog_color": Color(0.82, 0.84, 0.80),
		"sun_color": Color(1.0, 0.92, 0.80),
		"sun_energy": 1.30,
		"sun_angle_x": -26.0,
		"sun_angle_y": 150.0,
		"sky_top": Color(0.22, 0.38, 0.62),
		"sky_horizon": Color(0.85, 0.72, 0.56),
		"wetness": 0.35,
		"wind": 1.2
	},
	{
		"start_z": 4800.0,
		"name": "COLLINE TOSCANE & VAL D'ORCIA - ORA D'ORO",
		"fog_density": 0.00028,
		"fog_color": Color(0.88, 0.78, 0.70),
		"sun_color": Color(1.0, 0.88, 0.68),
		"sun_energy": 1.32,
		"sun_angle_x": -18.0,
		"sun_angle_y": 165.0,
		"sky_top": Color(0.25, 0.26, 0.52),
		"sky_horizon": Color(0.92, 0.64, 0.45),
		"wetness": 0.18,
		"wind": 0.85
	},
	{
		"start_z": 5600.0,
		"name": "VALICO GLACIALE DELLE ALPI - QUOTA 2650M",
		"fog_density": 0.00038,
		"fog_color": Color(0.86, 0.92, 1.0),
		"sun_color": Color(0.92, 0.96, 1.0),
		"sun_energy": 1.25,
		"sun_angle_x": -14.0,
		"sun_angle_y": 175.0,
		"sky_top": Color(0.14, 0.24, 0.48),
		"sky_horizon": Color(0.80, 0.88, 0.98),
		"wetness": 0.85,
		"wind": 1.8
	}
]

func update_biome(player_z: float, delta: float):
    var b = {}
    if road_generator and road_generator.has_method("get_biome_at"):
        b = road_generator.get_biome_at(player_z)
        
    if b.is_empty():
        # Fallback to local biomes array
        var active_idx = 0
        for i in range(biomes.size()):
            if player_z >= biomes[i].start_z:
                active_idx = i
        b = biomes[active_idx]
        
    var b_name = b.get("name", "VIA DEL MERIDIANO")
    if b_name != current_biome_name:
        current_biome_name = b_name
        emit_signal("biome_changed", current_biome_name)
    
    # 1. Update Volumetric Fog smoothly
    if world_environment and world_environment.environment:
        var env = world_environment.environment
        var w_fog = clamp(delta * 0.4, 0.0, 1.0)
        env.volumetric_fog_density = lerp(env.volumetric_fog_density, float(b.fog_density), w_fog)
        env.volumetric_fog_albedo = env.volumetric_fog_albedo.lerp(b.fog_color, w_fog)
        
        # Sky material colors if procedural sky
        if env.sky and env.sky.sky_material is ProceduralSkyMaterial:
            var sky_mat = env.sky.sky_material as ProceduralSkyMaterial
            var w_sky = clamp(delta * 0.3, 0.0, 1.0)
            sky_mat.sky_top_color = sky_mat.sky_top_color.lerp(b.sky_top, w_sky)
            sky_mat.sky_horizon_color = sky_mat.sky_horizon_color.lerp(b.sky_horizon, w_sky)
            
    # 2. Update Sun Light Color and Direction
    if sun_light:
        var w_sun = clamp(delta * 0.5, 0.0, 1.0)
        sun_light.light_color = sun_light.light_color.lerp(b.sun_color, w_sun)
        sun_light.light_energy = lerp(sun_light.light_energy, float(b.sun_energy), w_sun)
        
        var target_rot_x = deg_to_rad(b.sun_angle_x)
        var target_rot_y = deg_to_rad(b.sun_angle_y)
        var w_rot = clamp(delta * 0.25, 0.0, 1.0)
        sun_light.rotation.x = lerp_angle(sun_light.rotation.x, target_rot_x, w_rot)
        sun_light.rotation.y = lerp_angle(sun_light.rotation.y, target_rot_y, w_rot)
        
    # 3. Dynamic road wetness, puddle accumulation, and wind fields
    var w_env = clamp(delta * 0.25, 0.0, 1.0)
    current_wetness = lerp(current_wetness, float(b.wetness), w_env)
    current_wind = lerp(current_wind, float(b.wind), clamp(delta * 0.35, 0.0, 1.0))
    
    RenderingServer.global_shader_parameter_set("global_wetness", current_wetness)
    RenderingServer.global_shader_parameter_set("global_wind_strength", current_wind)
