shader_type canvas_item;

uniform float offset: hint_range(0.00, 0.02);
uniform float intensity: hint_range(0.00, 1);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

vec4 blur(sampler2D text, vec2 uv){
	vec4 sum = texture(text, uv) * 4.0;

	sum += texture(text, uv + vec2(1,1) * offset);
	sum += texture(text, uv + vec2(-1,1) * offset);
	sum += texture(text, uv + vec2(1,-1) * offset);
	sum += texture(text, uv + vec2(-1,-1) * offset);


	return sum / 8.0;
}

vec4 screen(vec4 base, vec4 blend){
	return 1.0 - (1.0 - base) * (1.0 - blend);
}

vec4 overlay(vec4 base, vec4 blend){
	vec4 limit = step(0.5, base);
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}

vec4 add(vec4 base, vec4 blend){
	return base+blend;
}

vec4 soft_light(vec4 base, vec4 blend){
	vec4 limit = step(0.5, blend);
	return mix(2.0 * base * blend + base * base * (1.0 - 2.0 * blend), sqrt(base) * (2.0 * blend - 1.0) + (2.0 * base) * (1.0 - blend), limit);
}



void fragment() {
	
	vec4 bgPixel=texture(SCREEN_TEXTURE, UV);

	
	vec4 b = blur(TEXTURE, UV);
	b.a*=intensity;
	
	//blend mode is function :
	// screen, add, overlay, soft_light
	//Best result with screen
	COLOR = screen(COLOR, b);
	COLOR.a*=intensity;
}

