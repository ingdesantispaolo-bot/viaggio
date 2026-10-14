shader_type spatial;
render_mode blend_mix, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

// THE LONG MERIDIAN - Art of Rally / Tiny Glade Organic Alpine Pasture Shader
// Delivers soft painterly pasture colors, micro-normal blade relief, floral colonies,
// rock strata, and weather-reactive dampness.

global uniform float global_wetness;

uniform vec4 grass_color : source_color = vec4(0.20, 0.32, 0.15, 1.0);
uniform vec4 grass_dry_color : source_color = vec4(0.34, 0.36, 0.18, 1.0);
uniform vec4 wildflower_gold : source_color = vec4(0.88, 0.74, 0.28, 1.0);
uniform vec4 wildflower_blue : source_color = vec4(0.28, 0.44, 0.82, 1.0);
uniform vec4 rock_slope_color : source_color = vec4(0.46, 0.45, 0.42, 1.0);
uniform vec4 dirt_path_color : source_color = vec4(0.36, 0.28, 0.20, 1.0);

float hash21(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
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
    vec3 world_normal = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
    
    float flatness = clamp(world_normal.y, 0.0, 1.0);
    
    // Multi-frequency organic pasture noise
    float macro_noise = noise2D(world_pos.xz * 0.035);
    float p_noise = noise2D(world_pos.xz * 0.11);
    float detail_noise = noise2D(world_pos.xz * 0.42);
    float micro_noise = noise2D(world_pos.xz * 1.6);
    
    // Soft painterly meadow blending (Lush pasture -> Dry mountain fescue)
    float blend_weight = clamp(macro_noise * 0.52 + p_noise * 0.34 + detail_noise * 0.14, 0.0, 1.0);
    vec3 meadow = mix(grass_color.rgb, grass_dry_color.rgb, blend_weight);
    
    // Tactile micro-mottling (Tiny Glade hand-painted brush stroke feel)
    meadow *= (0.93 + micro_noise * 0.14);
    
    // Steep slope rocky outcrop transition (Dorfromantik limestone/granite cliffs)
    float slope_mask = smoothstep(0.82, 0.38, flatness);

    // Colorful wildflower colonies (buttercup gold and gentian blue patches - organic painterly soft blending)
    float floral_field = noise2D(world_pos.xz * 0.08);
    float gold_mask = smoothstep(0.62, 0.88, floral_field * 0.70 + detail_noise * 0.30) * (1.0 - slope_mask);
    float blue_mask = smoothstep(0.66, 0.92, (1.0 - floral_field) * 0.65 + p_noise * 0.35) * (1.0 - slope_mask);
    meadow = mix(meadow, wildflower_gold.rgb, gold_mask * 0.45);
    meadow = mix(meadow, wildflower_blue.rgb, blue_mask * 0.38);
    
    float strata = sin(world_pos.y * 1.6 + world_pos.x * 0.22) * 0.06;
    float rock_grain = noise2D(world_pos.xz * 3.2) * 0.07;
    vec3 rock_col = rock_slope_color.rgb + vec3(strata + rock_grain);
    vec3 col = mix(meadow, rock_col, slope_mask);
    
    // Dynamic rain / wetness response
    float wet = clamp(global_wetness, 0.0, 1.0);
    col *= (1.0 - wet * 0.26);
    float rough = mix(0.92, 0.20, wet * 0.80);
    float spec = mix(0.10, 0.60, wet * 0.80);
    
    // Tactile micro-normal relief for grass blade glints and soil grain
    vec2 n_uv = world_pos.xz * 14.0;
    float h_c = noise2D(n_uv);
    float h_r = noise2D(n_uv + vec2(0.10, 0.0));
    float h_u = noise2D(n_uv + vec2(0.0, 0.10));
    vec3 norm_pert = normalize(vec3((h_c - h_r) * 1.5 * (1.0 - slope_mask * 0.5), 1.0, (h_c - h_u) * 1.5 * (1.0 - slope_mask * 0.5)));
    NORMAL = normalize(mix(NORMAL, (VIEW_MATRIX * vec4(norm_pert, 0.0)).xyz, 0.32));
    
    ALBEDO = col;
    ROUGHNESS = rough;
    SPECULAR = spec;
    
    // Subsurface Backlight (warm mountain sun transmission through grass tips)
    BACKLIGHT = mix(vec3(0.14, 0.22, 0.09), vec3(0.0), slope_mask);
}
