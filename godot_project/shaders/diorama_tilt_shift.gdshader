shader_type canvas_item;

// THE LONG MERIDIAN - Art of Rally / Dorfromantik Tilt-Shift Miniature Diorama Lens
// Simulates an optical tilt-shift camera lens with a horizontal focal plane,
// soft circular bokeh depth of field, and subtle peripheral vignetting.

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float focus_plane_y : hint_range(0.0, 1.0) = 0.52;
uniform float focus_band_width : hint_range(0.02, 0.4) = 0.16;
uniform float max_blur_radius : hint_range(0.0, 12.0) = 5.5;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.35;
uniform vec4 vignette_color : source_color = vec4(0.04, 0.06, 0.09, 1.0);

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Distance from the horizontal focal plane band
    float dist_from_focus = abs(uv.y - focus_plane_y);
    float blur_factor = smoothstep(focus_band_width * 0.5, focus_band_width * 1.8, dist_from_focus);
    
    // Non-linear blur growth for authentic bokeh circle of confusion
    blur_factor = pow(blur_factor, 1.35);
    
    vec4 sum_color = vec4(0.0);
    float total_weight = 0.0;
    
    // Circular Bokeh 12-tap Poisson disk distribution
    vec2 samples[12] = vec2[](
        vec2( 0.00,  1.00), vec2( 0.86,  0.50), vec2( 0.86, -0.50),
        vec2( 0.00, -1.00), vec2(-0.86, -0.50), vec2(-0.86,  0.50),
        vec2( 0.00,  0.50), vec2( 0.43,  0.25), vec2( 0.43, -0.25),
        vec2( 0.00, -0.50), vec2(-0.43, -0.25), vec2(-0.43,  0.25)
    );
    
    vec2 blur_step = (blur_factor * max_blur_radius) * SCREEN_PIXEL_SIZE;
    
    // Center sample
    sum_color += texture(SCREEN_TEXTURE, uv) * 2.0;
    total_weight += 2.0;
    
    for (int i = 0; i < 12; i++) {
        vec2 offset_uv = uv + samples[i] * blur_step;
        float sample_weight = 1.0 - (float(i) / 24.0);
        sum_color += texture(SCREEN_TEXTURE, offset_uv) * sample_weight;
        total_weight += sample_weight;
    }
    
    vec4 final_color = sum_color / total_weight;
    
    // Soft peripheral diorama vignette
    vec2 vig_uv = (uv - 0.5) * vec2(1.0, 0.85);
    float vig_dist = length(vig_uv);
    float vig_mask = smoothstep(0.42, 0.78, vig_dist);
    final_color = mix(final_color, vignette_color, vig_mask * vignette_strength);
    
    COLOR = final_color;
}
