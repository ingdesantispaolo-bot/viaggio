shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

// THE LONG MERIDIAN - Dorfromantik / Art of Rally Alpine Mountain Shader
// Delivers rich alpine massifs with stratified granite crags, lush foothill slopes,
// soft snow blankets, and atmospheric depth.

uniform vec4 rock_color : source_color = vec4(0.48, 0.49, 0.52, 1.0);
uniform vec4 cliff_color : source_color = vec4(0.32, 0.33, 0.37, 1.0);
uniform vec4 foothill_grass_color : source_color = vec4(0.32, 0.48, 0.24, 1.0);
uniform vec4 snow_color : source_color = vec4(0.96, 0.98, 1.0, 1.0);
uniform float snow_height_threshold = 42.0;
uniform float snow_blend_softness = 14.0;
uniform float snow_slope_min = 0.20;

float hash21(vec2 p) {
    p = fract(p * vec2(154.34, 432.345));
    p += dot(p, p + 28.23);
    return fract(p.x * p.y);
}

float noise2D(vec2 p) {
    vec2 id = floor(p);
    vec2 lv = fract(p);
    lv = lv * lv * (3.0 - 2.0 * lv);
    
    float bl = hash21(id);
    float br = hash21(id + vec2(1.0, 0.0));
    float tl = hash21(id + vec2(0.0, 1.0));
    float tr = hash21(id + vec2(1.0, 1.0));
    
    return mix(mix(bl, br, lv.x), mix(tl, tr, lv.x), lv.y);
}

void fragment() {
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    
    // Low-poly faceted flat normal calculation (Art of Rally crystalline mountain ridges)
    vec3 faceted_normal = normalize(cross(dFdy(VERTEX), dFdx(VERTEX)));
    if (faceted_normal.z < 0.0) {
        faceted_normal = -faceted_normal;
    }
    NORMAL = faceted_normal;
    vec3 world_normal = normalize((INV_VIEW_MATRIX * vec4(faceted_normal, 0.0)).xyz);
    
    float flatness = clamp(world_normal.y, 0.0, 1.0);
    
    // Multi-scale mountain terrain noise
    float rock_noise = noise2D(world_pos.xz * 0.04);
    float ridge_noise = noise2D(vec2(world_pos.x * 0.015, world_pos.y * 0.08));
    
    // Altitude and slope snow mask (snow settles on high slopes and gentle upper ledges)
    float height_factor = smoothstep(snow_height_threshold, snow_height_threshold + snow_blend_softness, world_pos.y + ridge_noise * 4.0);
    float slope_factor = smoothstep(snow_slope_min, snow_slope_min + 0.35, flatness);
    float snow_mask = clamp(height_factor * (slope_factor * 0.85 + 0.15), 0.0, 1.0);
    
    // Rich faceted limestone & granite rock palette
    vec3 base_rock = mix(cliff_color.rgb, rock_color.rgb, clamp(flatness * 1.3 + rock_noise * 0.35, 0.0, 1.0));
    
    // Subtle vertical height gradient (darker ambient grounding at base, sun-warmed peaks)
    float height_gradient = clamp(world_pos.y / 60.0, 0.0, 1.0);
    base_rock = mix(base_rock * 0.85, base_rock * 1.12, height_gradient);
    
    // Foothill grass on lower gentle slopes
    float foothill_mask = (1.0 - smoothstep(10.0, 32.0, world_pos.y)) * smoothstep(0.35, 0.70, flatness);
    base_rock = mix(base_rock, foothill_grass_color.rgb, foothill_mask * 0.90);
    
    // Final snow blend
    vec3 final_color = mix(base_rock, snow_color.rgb, snow_mask);
    
    ALBEDO = final_color;
    ROUGHNESS = mix(0.90, 0.35, snow_mask);
    SPECULAR = mix(0.12, 0.38, snow_mask);
    BACKLIGHT = cliff_color.rgb * 0.30;
}
