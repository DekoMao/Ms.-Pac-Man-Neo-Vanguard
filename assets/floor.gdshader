shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;
uniform vec4 base_color : source_color = vec4(0.018,0.024,0.055,1.0);
void fragment() {
	vec2 tile = abs(fract(UV * vec2(17.0,13.0))-0.5);
	float line = smoothstep(0.482,0.496,max(tile.x,tile.y));
	ALBEDO = mix(base_color.rgb,vec3(0.05,0.11,0.17),line);
	METALLIC=0.65;
	ROUGHNESS=0.22;
	EMISSION=vec3(0.03,0.15,0.20)*line*0.30;
	ALPHA=0.73;
}
