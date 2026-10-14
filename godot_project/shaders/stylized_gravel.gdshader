shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

// THE LONG MERIDIAN - Tuscan "Strada Bianca" & Packed Rural Gravel Shader
// Recreates iconic Italian unpaved scenic roads (L'Eroica / Val d'Orcia):
// 1. Warm chalky limestone & compacted white gravel (calcarenite e tufo)
// 2. Twin compressed wheel ruts (tracce levigate di rotolamento pneumatici)
// 3. Central gravel ridge with loose pebbles & occasional wild grass tufts
// 4. Soft dusty shoulders blending into rural verge vegetation
// 5. Dynamic wet mud & rut puddles when raining

global uniform float global_wetness;

uniform vec4 gravel_light : source_color = vec4(0.80, 0.76, 0.68, 1.0);
uniform vec4 gravel_dark : source_color = vec4(0.62, 0.56, 0.47, 1.0);
uniform vec4 rut_compact_color : source_color = vec4(0.54, 0.48, 0.40, 1.0);
uniform vec4 grass_border_color : source_color = vec4(0.24, 0.36, 0.16, 1.0);

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
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

float fbm2D(vec2 p) {
    return noise2D(p) * 0.62 + noise2D(p * 2.2 + vec2(1.8, 3.4)) * 0.38;
}

void fragment() {
    float u = UV.x;
    float v = UV.y;
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    
    // Multiscale gravel grain (fine limestone dust + coarse pebbles)
    float pebble_noise = noise2D(world_pos.xz * 32.0);
    float dust_noise = noise2D(world_pos.xz * 8.0);
    float macro_var = fbm2D(world_pos.xz * 1.4);
    
    // Base white gravel tone
    vec3 base_col = mix(gravel_light.rgb, gravel_dark.rgb, dust_noise * 0.7 + macro_var * 0.3);
    base_col += vec3((pebble_noise - 0.5) * 0.14);
    float rough = 0.92 + dust_noise * 0.06;
    float spec = 0.10;
    
    // Twin compacted wheel tracks (corsie levigate e compresse dal transito continuo)
    float rut1 = smoothstep(0.14, 0.0, abs(u - 0.32));
    float rut2 = smoothstep(0.14, 0.0, abs(u - 0.68));
    float rut_mask = max(rut1, rut2);
    
    // Compacted ruts are darker, slightly browner and smoother
    vec3 rut_col = mix(rut_compact_color.rgb, base_col, 0.25);
    base_col = mix(base_col, rut_col, rut_mask * 0.75);
    rough = mix(rough, 0.68, rut_mask * 0.50);
    spec = mix(spec, 0.22, rut_mask * 0.40);
    
    // Central ridge and dusty edges: accumulate loose pebbles
    float center_ridge = smoothstep(0.18, 0.0, abs(u - 0.50));
    base_col += vec3((pebble_noise - 0.48) * 0.18) * center_ridge;
    
    // Soft organic blend to rural roadside vegetation
    float dist_center = abs(u - 0.5) * 2.0;
    float grass_edge = smoothstep(0.86, 1.0, dist_center);
    if (grass_edge > 0.01) {
        float edge_noise = noise2D(world_pos.xz * 4.0) * 0.15;
        vec3 g_col = grass_border_color.rgb + vec3(edge_noise);
        base_col = mix(base_col, g_col, grass_edge);
        rough = mix(rough, 0.95, grass_edge);
    }
    
    // Dynamic rain: White gravel turns into damp Tuscan clay/tarmac mud
    float wet = clamp(global_wetness, 0.0, 1.0);
    if (wet > 0.01) {
        float mud_puddles = clamp(rut_mask * 1.3 + macro_var * 0.4, 0.0, 1.0) * wet;
        base_col = mix(base_col, base_col * 0.55, wet * 0.65); // Darkens when wet
        base_col = mix(base_col, vec3(0.24, 0.18, 0.12), mud_puddles * 0.75); // Wet clay puddles
        rough = mix(rough, 0.12, mud_puddles * 0.88 + wet * 0.3);
        spec = mix(spec, 0.75, mud_puddles * 0.80 + wet * 0.3);
    }
    
    ALBEDO = base_col;
    ROUGHNESS = rough;
    SPECULAR = spec;
}
