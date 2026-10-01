extends Node
class_name BiomeDirector

# THE LONG MERIDIAN - Atmospheric & Biome Director (Godot 4 Vulkan)
# Coordinates dynamic lighting, sky gradients, volumetric fog density,
# and regional atmospheric transitions as the vehicle travels along the meridian.

signal biome_changed(biome_name)

@export var world_environment: WorldEnvironment
@export var sun_light: DirectionalLight3D

var current_biome_index: int = -1
var current_biome_name: String = ""

# Biome definitions along the Z progression
var biomes = [
    {
        "start_z": 0.0,
        "name": "PASSO DELLE ALPI - QUOTA 1840M",
        "fog_density": 0.005,
        "fog_color": Color(0.82, 0.88, 0.95),
        "sun_color": Color(1.0, 0.95, 0.88),
        "sun_energy": 1.35,
        "sun_angle_x": -38.0,
        "sun_angle_y": 28.0,
        "sky_top": Color(0.22, 0.44, 0.74),
        "sky_horizon": Color(0.78, 0.70, 0.60)
    },
    {
        "start_z": 1400.0,
        "name": "GOLA DEL MERIDIANO - NEBBIA VOLUMETRICA",
        "fog_density": 0.024,
        "fog_color": Color(0.70, 0.82, 0.90),
        "sun_color": Color(0.98, 0.92, 0.82),
        "sun_energy": 1.50,
        "sun_angle_x": -26.0,
        "sun_angle_y": 42.0,
        "sky_top": Color(0.35, 0.50, 0.68),
        "sky_horizon": Color(0.68, 0.74, 0.78)
    },
    {
        "start_z": 3000.0,
        "name": "VALICO DEI LARICI - QUOTA 1420M",
        "fog_density": 0.008,
        "fog_color": Color(0.85, 0.88, 0.82),
        "sun_color": Color(1.0, 0.90, 0.75),
        "sun_energy": 1.25,
        "sun_angle_x": -22.0,
        "sun_angle_y": 55.0,
        "sky_top": Color(0.24, 0.42, 0.65),
        "sky_horizon": Color(0.82, 0.68, 0.52)
    },
    {
        "start_z": 4800.0,
        "name": "ALTOPIANO DORATO - ORA D'ORO",
        "fog_density": 0.012,
        "fog_color": Color(0.95, 0.78, 0.65),
        "sun_color": Color(1.0, 0.68, 0.42),
        "sun_energy": 1.45,
        "sun_angle_x": -14.0,
        "sun_angle_y": 72.0,
        "sky_top": Color(0.32, 0.28, 0.55),
        "sky_horizon": Color(0.95, 0.58, 0.35)
    }
]

func update_biome(player_z: float, delta: float):
    # Find active biome index
    var active_idx = 0
    for i in range(biomes.size()):
        if player_z >= biomes[i].start_z:
            active_idx = i
            
    if active_idx != current_biome_index:
        current_biome_index = active_idx
        current_biome_name = biomes[active_idx].name
        emit_signal("biome_changed", current_biome_name)
        
    var b = biomes[active_idx]
    
    # 1. Update Volumetric Fog smoothly
    if world_environment and world_environment.environment:
        var env = world_environment.environment
        env.volumetric_fog_density = lerp(env.volumetric_fog_density, float(b.fog_density), delta * 0.4)
        env.volumetric_fog_albedo = env.volumetric_fog_albedo.lerp(b.fog_color, delta * 0.4)
        
        # Sky material colors if procedural sky
        if env.sky and env.sky.sky_material is ProceduralSkyMaterial:
            var sky_mat = env.sky.sky_material as ProceduralSkyMaterial
            sky_mat.sky_top_color = sky_mat.sky_top_color.lerp(b.sky_top, delta * 0.3)
            sky_mat.sky_horizon_color = sky_mat.sky_horizon_color.lerp(b.sky_horizon, delta * 0.3)
            
    # 2. Update Sun Light Color and Direction
    if sun_light:
        sun_light.light_color = sun_light.light_color.lerp(b.sun_color, delta * 0.5)
        sun_light.light_energy = lerp(sun_light.light_energy, float(b.sun_energy), delta * 0.5)
        
        var target_rot_x = deg_to_rad(b.sun_angle_x)
        var target_rot_y = deg_to_rad(b.sun_angle_y)
        sun_light.rotation.x = lerp_angle(sun_light.rotation.x, target_rot_x, delta * 0.25)
        sun_light.rotation.y = lerp_angle(sun_light.rotation.y, target_rot_y, delta * 0.25)
