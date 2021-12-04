#ifndef CIRCLE_CROSS
#define CIRCLE_CROSS

void circle_float(float2 pt, float2 center, float radius, out float result){
    float line_width = radius * 0.1;
    float edge_thickness = radius * 0.01;
    float2 p = pt - center;
    float len = length(p);
    float half_line_width = line_width/2.0;
    result = smoothstep(radius-half_line_width-edge_thickness, radius-half_line_width, len) - smoothstep(radius + half_line_width, radius + half_line_width + edge_thickness, len);
}

void cross_float(float2 pt, float2 center, float radius, out float result){
    float line_width = radius * 0.1;
    float edge_thickness = radius * 0.01;
	float2 p = pt - center;
	float len = length(p);
	float half_line_width = line_width/2.0;
	result = 0;
	if (len<radius){
		float horz = smoothstep(-half_line_width-edge_thickness, -half_line_width, p.y) - smoothstep( half_line_width, half_line_width + edge_thickness, p.y);
		float vert = smoothstep(-half_line_width-edge_thickness, -half_line_width, p.x) - smoothstep( half_line_width, half_line_width + edge_thickness, p.x);
		result = saturate(horz + vert);
	}
}

#endif