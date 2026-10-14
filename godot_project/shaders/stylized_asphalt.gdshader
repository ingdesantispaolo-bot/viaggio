shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

// THE LONG MERIDIAN - High-Fidelity Alpine Weathered Tarmac Shader
// Features:
// 1. Dual-octave mineral bituminous aggregate texture
// 2. Twin burnished tire rut wear tracks
// 3. Dynamic Italian Codice della Strada road markings:
//    - Outer continuous white boundary lines
//    - Dashed center line on straights VS Double solid white lines on curves/passes
// 4. Bitumen "tar snake" crack sealant repairs (sigillature fessure a caldo)
// 5. Retroreflective road studs / cat's eyes (occhi di gatto catadiottrici)
// 6. Smooth gravel shoulder transition to roadside grass
// 7. Dynamic wetness gloss with realistic specular puddles

global uniform float global_wetness;

uniform vec4 asphalt_color : source_color = vec4(0.20, 0.21, 0.23, 1.0);
uniform vec4 worn_asphalt_color : source_color = vec4(0.28, 0.29, 0.31, 1.0);
uniform vec4 gravel_shoulder_color : source_color = vec4(0.38, 0.35, 0.30, 1.0);
uniform vec4 grass_blend_color : source_color = vec4(0.20, 0.32, 0.15, 1.0);
uniform vec4 paint_yellow : source_color = vec4(0.94, 0.72, 0.18, 1.0);
uniform vec4 paint_white : source_color = vec4(0.88, 0.90, 0.92, 1.0);
uniform vec4 tar_snake_color : source_color = vec4(0.09, 0.09, 0.10, 1.0);

uniform bool is_double_line = false;
uniform bool is_wet_gorge = false;

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
    return noise2D(p) * 0.65 + noise2D(p * 2.13 + vec2(1.7, 3.2)) * 0.35;
}

void fragment() {
    float u = UV.x;
    float v = UV.y;
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    
    // Texture procedurale uniforme e isotropa senza striature direzionali
    float micro_grain = noise2D(world_pos.xz * 24.0) * 0.12;
    float med_grain = noise2D(world_pos.xz * 8.0) * 0.15;
    float macro_noise = fbm2D(world_pos.xz * 1.2) * 0.18;
    
    // 1. Base asfalto montano (granulometria minerale)
    vec3 base_tarmac = is_wet_gorge ? (asphalt_color.rgb * 0.65) : asphalt_color.rgb;
    vec3 worn_tarmac = is_wet_gorge ? (worn_asphalt_color.rgb * 0.70) : worn_asphalt_color.rgb;
    vec3 col = mix(base_tarmac, worn_tarmac, med_grain * 1.4 + macro_noise * 0.3);
    col += vec3((micro_grain - 0.06) * 0.12);
    float rough = (is_wet_gorge ? 0.35 : 0.88) + med_grain * 0.10;
    float spec = is_wet_gorge ? 0.55 : 0.14;
    
    // 2. Tracce di passaggio pneumatici (brunite e leggermente scurite dal rotolamento)
    float rut1 = smoothstep(0.12, 0.0, abs(u - 0.32));
    float rut2 = smoothstep(0.12, 0.0, abs(u - 0.68));
    float rut_mask = max(rut1, rut2);
    col = mix(col, col * 0.82, rut_mask * 0.38);
    rough = mix(rough, is_wet_gorge ? 0.22 : 0.68, rut_mask * 0.35);
    spec = mix(spec, is_wet_gorge ? 0.70 : 0.22, rut_mask * 0.30);
    
    // 3. Sigillature fessure con bitume liquido (Tar Snakes tipiche alpine)
    if (!is_wet_gorge) {
        float tar_n = abs(noise2D(world_pos.xz * 0.75 + vec2(4.1, 8.7)) - 0.5);
        float tar_snake = smoothstep(0.012, 0.003, tar_n) * smoothstep(0.10, 0.25, u) * smoothstep(0.90, 0.75, u);
        if (tar_snake > 0.05) {
            col = mix(col, tar_snake_color.rgb, tar_snake * 0.85);
            rough = mix(rough, 0.32, tar_snake);
            spec = mix(spec, 0.45, tar_snake);
        }
    }
    
    // 4. Strisce continue laterali bianche (Segnaletica orizzontale Anas)
    // u = 0.122 e u = 0.878 corrispondono esattamente alle linee di corsia
    float left_line = smoothstep(0.016, 0.004, abs(u - 0.122));
    float right_line = smoothstep(0.016, 0.004, abs(u - 0.878));
    float outer_line = clamp(left_line + right_line, 0.0, 1.0);
    if (outer_line > 0.02) {
        col = mix(col, paint_white.rgb, outer_line * 0.95);
        rough = mix(rough, 0.52, outer_line);
        spec = mix(spec, 0.28, outer_line);
    }
    
    // 5. Linea di mezzeria: Doppia Continua in curva VS Tratteggiata su rettilineo
    if (is_double_line) {
        // Doppia striscia continua bianca (Divieto di sorpasso in tornanti e passi)
        float d_line1 = smoothstep(0.010, 0.003, abs(u - 0.485));
        float d_line2 = smoothstep(0.010, 0.003, abs(u - 0.515));
        float double_mask = clamp(d_line1 + d_line2, 0.0, 1.0);
        if (double_mask > 0.02) {
            col = mix(col, paint_white.rgb, double_mask * 0.95);
            rough = mix(rough, 0.50, double_mask);
            spec = mix(spec, 0.32, double_mask);
        }
    } else {
        // Striscia tratteggiata di mezzeria (Tratteggio regolare lungo coordinata V)
        float center_line = smoothstep(0.015, 0.004, abs(u - 0.50));
        float dash_mask = step(0.40, fract(v * 0.52));
        if (center_line > 0.02 && dash_mask > 0.5) {
            col = mix(col, paint_yellow.rgb, center_line * 0.95);
            rough = mix(rough, 0.50, center_line);
            spec = mix(spec, 0.30, center_line);
        }
    }
    
    // 6. Catadiottri rifrangenti di mezzeria ("Occhi di gatto" ogni ~10 metri)
    float stud_v = fract(v * 0.10);
    float stud_mask = smoothstep(0.012, 0.003, abs(u - 0.50)) * smoothstep(0.035, 0.008, abs(stud_v - 0.50));
    if (stud_mask > 0.05) {
        col = mix(col, vec3(0.95, 0.95, 0.98), stud_mask);
        rough = mix(rough, 0.05, stud_mask);
        spec = mix(spec, 0.98, stud_mask);
    }
    
    // 7. Raccordo banchina in ghiaia e ciglio stradale (Asfalto -> Brecciolino -> Erba)
    float dist_from_center = abs(u - 0.5) * 2.0; // 0.0 centro, 1.0 bordo esterno
    float shoulder_mask = smoothstep(0.88, 0.98, dist_from_center);
    if (shoulder_mask > 0.01) {
        vec3 shoulder_col = gravel_shoulder_color.rgb + vec3((micro_grain - 0.06) * 0.20);
        col = mix(col, shoulder_col, shoulder_mask);
        rough = mix(rough, 0.95, shoulder_mask);
    }
    
    float grass_mask = smoothstep(0.97, 1.00, dist_from_center);
    if (grass_mask > 0.01) {
        col = mix(col, grass_blend_color.rgb, grass_mask);
    }
    
    // 8. Bagnato e pozzanghere dinamiche da meteo
    float wet = clamp(is_wet_gorge ? max(0.85, global_wetness) : global_wetness, 0.0, 1.0);
    if (wet > 0.01) {
        float puddle_mask = clamp(rut_mask * 1.2 + macro_noise * 0.5, 0.0, 1.0) * wet;
        col = mix(col, col * 0.45, wet * 0.50);
        col = mix(col, vec3(0.08, 0.10, 0.12), puddle_mask * 0.60);
        rough = mix(rough, 0.08, puddle_mask * 0.92 + wet * 0.35);
        spec = mix(spec, 0.90, puddle_mask * 0.85 + wet * 0.35);
    }
    
    ALBEDO = col;
    ROUGHNESS = rough;
    SPECULAR = spec;
}
