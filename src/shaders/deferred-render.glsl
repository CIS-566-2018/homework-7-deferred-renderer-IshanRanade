#version 300 es
precision highp float;

#define EPS 0.0001
#define PI 3.1415962

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_gb0;
uniform sampler2D u_gb1;
uniform sampler2D u_gb2;

uniform float u_Time;

uniform mat4 u_View;
uniform vec4 u_CamPos;

vec3 applyGaussian() {
  const int size = 9;
  float gaussian[size] = float [size]( 
    0.110741,	0.111296,	0.110741,
    0.111296,	0.111853,	0.111296,
    0.110741,	0.111296,	0.110741 );

  vec4 gb0 = texture(u_gb0, fs_UV);
  vec4 gb1 = texture(u_gb1, fs_UV);
  vec4 gb2 = texture(u_gb2, fs_UV);
  
  vec2 dimensions = vec2(gb1[0], gb1[1]);
  vec2 startCoord = vec2(float(int(dimensions[0] * fs_UV[0])) - 1.0, float(int(dimensions[1] * fs_UV[1])) - 1.0);

  vec3 color = vec3(0.0f);

  float sum = 0.0;
  vec2 curCoord = startCoord;
  for(int i = 0; i < size; ++i) {
    if(i % 11 == 0) {
      curCoord[0] = startCoord[0];
      curCoord[1] += 1.0;
    }

    sum += gaussian[i];
    color += gaussian[i] * vec3(texture(u_gb2, vec2(curCoord[0] / dimensions[0], curCoord[1] / dimensions[1])));

    curCoord[0] += 1.0;
  }

  return color;
}

void main() { 
	// read from GBuffers

	
  vec4 gb0 = texture(u_gb0, fs_UV);
  vec4 gb1 = texture(u_gb1, fs_UV);
  vec4 gb2 = texture(u_gb2, fs_UV);

	vec3 col = gb2.xyz;
	col = gb2.xyz;

	out_Col = vec4(applyGaussian(), 1.0);
}
