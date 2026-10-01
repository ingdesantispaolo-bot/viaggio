shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

// THE LONG MERIDIAN - Dorfromantik / Tiny Glade Synchronized Foliage & Wake Shader
// Features:
// 1. Synchronized large-scale ambient wind waves across entire terrain
// 2. Dynamic aerodynamic vehicle wake displacement (plants bend away from passing car)
// 3. Tiny Glade vertical color grading and warm sunlight translucency (subsurface scattering)

global uniform vec3 player_car_pos;
global uniform float player_car_speed;
global uniform float global_wind_strength;

uniform vec4 base_foliage_color : source_color = vec4(0.14, 0.26, 0.16, 1.0);
uniform vec4 tip_foliage_color : source_color = vec4(0.32, 0.52, 0.22, 1.0);
uniform vec4 sss_sun_transmission : source_color = vec4(0.48, 0.68, 0.18, 1.0);

uniform float wind_speed : hint_range(0.5, 6.0) = 2.4;
uniform float wind_amplitude : hint_range(0.0, 0.6) = 0.18;
uniform float wake_sensitivity : hint_range(0.0, 3.0) = 1.35;
uniform float roughness : hint_range(0.0, 1.0) = 0.82;

void vertex() {
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    
    // Normalized height factor (ground 0.0, tree canopy / crop tip 1.0)
    float height_weight = clamp(VERTEX.y * 0.28, 0.0, 1.0);
    
    // 1. Synchronized Global Ambient Wind Wave
    float wind_time = TIME * wind_speed;
    float spatial_phase = world_pos.x * 0.14 + world_pos.z * 0.09;
    float main_wave = sin(wind_time + spatial_phase) * cos(wind_time * 0.55 + spatial_phase * 0.5);
    float gust = sin(wind_time * 0.35 + world_pos.z * 0.02) * 0.40;
    
    float wind_power = (global_wind_strength > 0.001) ? global_wind_strength : 1.0;
    vec3 wind_offset = vec3(
        (main_wave + gust) * wind_amplitude,
        -abs(main_wave) * wind_amplitude * 0.2,
        (main_wave * 0.7 + gust) * wind_amplitude
    ) * height_weight * wind_power;
    
    // 2. Aerodynamic Vehicle Wake Displacement
    // Crops and roadside foliage react directly to the air pushed by the car
    vec2 diff_xz = world_pos.xz - player_car_pos.xz;
    float dist_to_car = length(diff_xz);
    float wake_radius = 8.5; // Influence radius in meters
    
    vec3 wake_offset = vec3(0.0);
    if (dist_to_car < wake_radius) {
        float speed_factor = clamp(player_car_speed / 50.0, 0.0, 2.2);
        float wake_intensity = (1.0 - (dist_to_car / wake_radius)) * speed_factor * wake_sensitivity;
        wake_intensity = pow(wake_intensity, 1.5);
        
        vec2 push_dir = (dist_to_car > 0.001) ? (diff_xz / dist_to_car) : vec2(1.0, 0.0);
        float flutter = sin(TIME * 22.0 + dist_to_car * 4.0) * 0.22;
        
        wake_offset = vec3(
            push_dir.x * (1.0 + flutter),
            -0.35,
            push_dir.y * (1.0 + flutter)
        ) * wake_intensity * height_weight;
    }
    
    // Apply combined displacements in world space
    world_pos += wind_offset + wake_offset;
    
    // Convert back to local vertex coordinate
    VERTEX = (inverse(MODEL_MATRIX) * vec4(world_pos, 1.0)).xyz;
    
    // Pass height weight to fragment for Tiny Glade style gradient
    COLOR = vec4(height_weight, 0.0, 0.0, 1.0);
}

void fragment() {
    float h = clamp(COLOR.r, 0.0, 1.0);
    vec3 col = mix(base_foliage_color.rgb, tip_foliage_color.rgb, h);
    
    ALBEDO = col;
    ROUGHNESS = roughness;
    SPECULAR = 0.25;
    
    // Subsurface translucency facing the sun (SSS)
    BACKLIGHT = sss_sun_transmission.rgb * 0.42;
}
