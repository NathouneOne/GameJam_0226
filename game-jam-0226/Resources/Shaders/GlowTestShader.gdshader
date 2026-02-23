shader_type canvas_item;
uniform float glowSize: hint_range(0.0, 300) = 15.0; // Size of glow
uniform float Threshold: hint_range(0.0, 1.0) =  0.2; 
void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	
	vec4 neibghourColors1 = texture(TEXTURE, UV+vec2(TEXTURE_PIXEL_SIZE.x, TEXTURE_PIXEL_SIZE.y));
	vec4 neibghourColors2 = texture(TEXTURE, UV+vec2(-TEXTURE_PIXEL_SIZE.x, TEXTURE_PIXEL_SIZE.y));
	vec4 neibghourColors3 = texture(TEXTURE, UV+vec2(TEXTURE_PIXEL_SIZE.x, -TEXTURE_PIXEL_SIZE.y));
	vec4 neibghourColors4 = texture(TEXTURE, UV*vec2(-TEXTURE_PIXEL_SIZE.x, -TEXTURE_PIXEL_SIZE.y));
	vec4 neighbourColorSum = (neibghourColors1+neibghourColors2+neibghourColors3+neibghourColors4)/vec4(4,4,4,4);
	color.rgb=mix(color.rgb, neighbourColorSum.rgb, 0.6);
	
	COLOR=color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
