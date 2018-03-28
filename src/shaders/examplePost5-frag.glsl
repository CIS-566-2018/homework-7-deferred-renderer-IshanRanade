#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;
uniform vec2 u_Dimensions;

float rand(float n){return fract(sin(n) * 43758.5453123);}

// Interpolate between regular color and channel-swizzled color
// on right half of screen. Also scale color to range [0, 5].
void main() {

  vec3 c = vec3(texture(u_frame, fs_UV));
  out_Col = vec4(c, 1.0);
  return;

  vec2 thisPixel = vec2(int(fs_UV[0] * u_Dimensions[0]), int(fs_UV[1] * u_Dimensions[1]));

  float v = dot(c, c);

  // Change the diagonal of the line over time
  float sign = sin(u_Time/10.0) > 0.5 ? 1.0 : -1.0;

  // Gives appearance of being redrawn over time
  float random = rand(u_Time/10.0);

  const float n = 8.0;

  // Get the coordinates of
  vec2 p = vec2(int(fs_UV[0] * u_Dimensions[0]), int(fs_UV[1] * u_Dimensions[1]));
  p.x += floor(sin(p.x * 0.04 + random * 5.0) * 10.0 + sin(p.y * 0.09 + p.x * 0.07));
  p = mod(p.xx + vec2(sign * p.y, -sign * p.y), vec2(n));

  // Choose to color a point or leave it blank
  if (((v > 1.00) || (p.x != 0.0)) && ((v > 0.70) || (p.y != 0.0)) && ((v > 0.4) || (p.x != n / 2.0)) &&
          ((v > 0.18) || (p.y != n / 2.0)) && ((v > 0.10) || (p.x != n / 4.0)) && ((v > 0.02) || (p.y != n / 4.0))) {
      out_Col = vec4(1.0,1.0,1.0,1.0);
  } else {
      out_Col = vec4(0.0,0.0,0.0,1.0);
  }

  // Add lines to make it look like notebook paper
  int notebookLines = 50;
  int redLine = 50;
  if(out_Col == vec4(1.0,1.0,1.0,1.0)) {
      if(abs(int(thisPixel.y) % notebookLines) < 3) {
        out_Col = vec4(153.0/255.0,221.0/255.0,255.0/255.0, 1.0);
      } else {
        out_Col = vec4(244.0/255.0,255.0/255.0,179.0/255.0, 1.0);
      }

      if(abs(int(thisPixel.x) - redLine) < 3) {
          out_Col = vec4(255.0/255.0,153.0/255.0,128.0/255.0,1.0);
      }
  }
}
