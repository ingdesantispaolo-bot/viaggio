shader_type spatial;
render_mode blend_mix, depth_draw_opaque, diffuse_burley, specular_disabled, unshaded;

// THE LONG MERIDIAN - Handcrafted Diorama Cumulus Cloud Shader
// Renders soft, luminous clouds with directional top-light shading and warm ambient rim.

uniform vec4 cloud_color : source_color = vec4(1.0, 0.98, 0.96, 0.95);
uniform vec4 shadow_color : source_color = vec4(0.72, 0.78, 0.88, 0.95);

void fragment() {
    float shade = clamp(NORMAL.y * 0.55 + 0.45, 0.0, 1.0);
    vec3 col = mix(shadow_color.rgb, cloud_color.rgb, shade);
    ALBEDO = col;
    ALPHA = cloud_color.a;
}
