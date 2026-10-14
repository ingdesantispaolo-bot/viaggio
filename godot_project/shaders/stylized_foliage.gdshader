shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

// THE LONG MERIDIAN - Art of Rally / Tiny Glade Stylized Foliage Shader
// Features:
// 1. Organic polygonal shading with vertex-height gradient & vertical ambient occlusion
// 2. Translucent subsurface scattering (warm sunlight passing through needles/leaves)
// 3. Synchronized wind sway & aerodynamic vehicle wake response
// 4. Velvet micro-specular sheen

global uniform vec3 player_car_pos;
global uniform float player_car_speed;
global uniform float global_wind_strength;

uniform vec4 base_foliage_color : source_color = vec4(0.12, 0.22, 0.12, 1.0);
uniform vec4 tip_foliage_color : source_color = vec4(0.28, 0.44, 0.22, 1.0);
uniform vec4 sss_sun_transmission : source_color = vec4(0.48, 0.68, 0.20, 1.0);

uniform float wind_speed : hint_range(0.5, 6.0) = 2.2;
uniform float wind_amplitude : hint_range(0.0, 0.6) = 0.14;
uniform float wake_sensitivity : hint_range(0.0, 3.0) = 1.30;
uniform float roughness : hint_range(0.0, 1.0) = 0.85;

void vertex() {
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    
    // Normalized height factor (handles both centered meshes and ground-anchored meshes)
    float h_factor = clamp(VERTEX.y * 0.5 + 0.5, 0.0, 1.0);
    
    // If mesh has baked vertex color, blend with it
    if (COLOR.a > 0.1) {
        h_factor = clamp(h_factor * 0.4 + COLOR.r * 0.6, 0.0, 1.0);
    }
    
    // 1. Synchronized Ambient Wind Wave
    float wind_time = TIME * wind_speed;
    float spatial_phase = world_pos.x * 0.12 + world_pos.z * 0.08;
    float main_wave = sin(wind_time + spatial_phase) * cos(wind_time * 0.5 + spatial_phase * 0.4);
    float gust = sin(wind_time * 0.3 + world_pos.z * 0.015) * 0.35;
    
    float wind_power = (global_wind_strength > 0.001) ? global_wind_strength : 1.0;
    vec3 wind_offset = vec3(
        (main_wave + gust) * wind_amplitude,
        -abs(main_wave) * wind_amplitude * 0.12,
        (main_wave * 0.65 + gust) * wind_amplitude
    ) * h_factor * wind_power;
    
    // 2. Aerodynamic Vehicle Wake Displacement
    vec2 diff_xz = world_pos.xz - player_car_pos.xz;
    float dist_to_car = length(diff_xz);
    float wake_radius = 8.5;
    
    vec3 wake_offset = vec3(0.0);
    if (dist_to_car < wake_radius) {
        float speed_factor = clamp(player_car_speed / 50.0, 0.0, 2.0);
        float wake_intensity = pow(1.0 - (dist_to_car / wake_radius), 1.5) * speed_factor * wake_sensitivity;
        vec2 push_dir = (dist_to_car > 0.001) ? (diff_xz / dist_to_car) : vec2(1.0, 0.0);
        float flutter = sin(TIME * 22.0 + dist_to_car * 4.0) * 0.20;
        
        wake_offset = vec3(
            push_dir.x * (1.0 + flutter),
            -0.25,
            push_dir.y * (1.0 + flutter)
        ) * wake_intensity * h_factor;
    }
    
    world_pos += wind_offset + wake_offset;
    VERTEX = (inverse(MODEL_MATRIX) * vec4(world_pos, 1.0)).xyz;
    
    COLOR = vec4(h_factor, 0.0, 0.0, 1.0);
}

void fragment() {
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    float h = clamp(COLOR.r, 0.0, 1.0);
    
    // Subtle organic needle noise to break up flat polygon faces
    float needle_noise = sin(world_pos.x * 6.0) * cos(world_pos.y * 6.0 + world_pos.z * 5.0) * 0.5 + 0.5;
    
    // Color gradient: dark ambient-occluded undersides -> sunlit vibrant tips
    vec3 col = mix(base_foliage_color.rgb, tip_foliage_color.rgb, h * 0.80 + needle_noise * 0.20);
    
    // Underside contact ambient shadow
    float ao_shadow = smoothstep(0.0, 0.45, h);
    col *= mix(0.72, 1.0, ao_shadow);
    
    ALBEDO = col;
    ROUGHNESS = roughness;
    SPECULAR = 0.14;
    
    // Warm sun translucency (Subsurface Scattering through needles/leaves)
    BACKLIGHT = sss_sun_transmission.rgb * 0.40;
}
