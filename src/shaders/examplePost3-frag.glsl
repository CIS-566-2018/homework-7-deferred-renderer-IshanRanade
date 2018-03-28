#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform sampler2D u_frame2;
uniform float u_Time;

// Interpolate between regular color and channel-swizzled color
// on right half of screen. Also scale color to range [0, 5].
void main() {

	vec3 color1 = texture(u_frame, fs_UV).xyz;
  vec3 color2 = texture(u_frame2, fs_UV).xyz;
  color2 *= 2.0;

  out_Col = vec4((color1 + color2) * 0.5, 1.0);
}
