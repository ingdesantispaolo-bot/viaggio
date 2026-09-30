shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// THE LONG MERIDIAN - Tiny Glade / Dorfromantik Stylized Foliage Shader
// Provides organic wind waving in breeze, subtle vertical color gradients,
// and warm sunlight transmission (subsurface scattering) for lush trees and vegetation.

uniform vec4 base_foliage_color : source_color = vec4(0.12, 0.28, 0.16, 1.0);
uniform vec4 tip_foliage_color : source_color = vec4(0.24, 0.48, 0.22, 1.0);
uniform vec4 sss_sun_transmission : source_color = vec4(0.45, 0.65, 0.20, 1.0);

uniform float wind_speed : hint_range(0.5, 5.0) = 2.2;
uniform float wind_amplitude : hint_range(0.0, 0.4) = 0.08;
uniform float roughness : hint_range(0.0, 1.0) = 0.85;

void vertex() {
    // Sway branches proportionally to height above ground
    float height_weight = clamp(VERTEX.y * 0.25, 0.0, 1.0);
    float wave_time = TIME * wind_speed;
    
    float wave_x = sin(wave_time + VERTEX.z * 0.4) * wind_amplitude * height_weight;
    float wave_z = cos(wave_time * 0.8 + VERTEX.x * 0.4) * (wind_amplitude * 0.7) * height_weight;
    
    VERTEX.x += wave_x;
    VERTEX.z += wave_z;
    
    // Pass normalized local height to fragment
    COLOR = vec4(height_weight, 0.0, 0.0, 1.0);
}

void fragment() {
    float h = clamp(COLOR.r, 0.0, 1.0);
    vec3 col = mix(base_foliage_color.rgb, tip_foliage_color.rgb, h);
    
    ALBEDO = col;
    ROUGHNESS = roughness;
    SPECULAR = 0.2;
    
    // Subsurface translucency approximation facing the sun
    BACKLIGHT = sss_sun_transmission.rgb * 0.35;
}
