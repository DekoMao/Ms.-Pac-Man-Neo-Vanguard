shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled;
uniform vec4 tint : source_color = vec4(0.1,0.9,1.0,1.0);
uniform float strength = 0.25;
void fragment() {
	vec2 p=UV*2.0-1.0;
	float falloff=pow(max(0.0,1.0-dot(p,p)),2.0);
	ALBEDO=tint.rgb;
	ALPHA=falloff*strength;
}
