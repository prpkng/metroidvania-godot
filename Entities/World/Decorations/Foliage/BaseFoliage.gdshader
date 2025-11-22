shader_type canvas_item;

instance uniform vec2 world_position;
instance uniform float bias;

uniform float y_multiplier : hint_range(0.0, 5.0, 0.1);
uniform float y_pow = 2;
uniform float force = 4;
uniform float frequency = 2;
uniform vec2 position_offset_multiplier = vec2(10.0, 10.0);

uniform float bias_force = 0.4;
uniform float bias_y_multiplier : hint_range(0.0, 5.0, 0.1);
uniform float bias_y_pow = 2;


void fragment() {
	float time_multiplier = TIME * frequency + 
		world_position.x * position_offset_multiplier.x + 
		world_position.y * position_offset_multiplier.y;
	float time_val = cos(time_multiplier) * (pow((1.0-UV.y), y_pow) * y_multiplier * 100.0) * (force/100.0);
	float bias_val = -bias * (pow((1.0-UV.y), bias_y_pow) * bias_y_multiplier * 100.0) * (bias_force/100.0);
		
	vec2 uv = UV + vec2(bias_val + time_val, 0);

	COLOR = texture(TEXTURE, uv);
}