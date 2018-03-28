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

vec3 lightPos = vec3(100.0,100.0,100.0);

vec3 applyGaussian() {

  vec4 gb0 = texture(u_gb0, fs_UV);
  vec4 gb1 = texture(u_gb1, fs_UV);
  vec4 gb2 = texture(u_gb2, fs_UV);

  const int size = 64;
  float sigma = 100.0 * smoothstep(0.0, 1.0, gb0[3]);
  float W = sqrt(float(size));
  float gaussian[size];
  float mean = float(W) / 2.0;
  float sum = 0.0;

  int index = 0;
  for (float x = 0.0; x < W; x += 1.0) {
    for (float y = 0.0; y < W; y += 1.0) {
        gaussian[index] = exp( -0.5 * (pow((x-mean)/sigma, 2.0) + pow((y-mean)/sigma,2.0)) )
                         / (2.0 * 3.1415 * sigma * sigma);

        // Accumulate the kernel values
        sum += gaussian[index];
        index += 1;
    }
  }

  for(int x = 0; x < size; x++) {
    gaussian[x] /= sum;
  }

  vec2 dimensions = vec2(gb1[0], gb1[1]);
  vec2 startCoord = vec2(float(int(dimensions[0] * fs_UV[0])) - 1.0, float(int(dimensions[1] * fs_UV[1])) - 1.0);

  vec3 color = vec3(0.0f);

  vec2 curCoord = startCoord;
  for(int i = 0; i < size; ++i) {
    if(i != 0 && i % int(sqrt(float(size))) == 0) {
      curCoord[0] = startCoord[0];
      curCoord[1] += 1.0;
    }

    vec3 textureColor = vec3(texture(u_gb2, vec2(curCoord[0] / dimensions[0], curCoord[1] / dimensions[1])));
    color += gaussian[i] * textureColor;

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

  if(gb2.xyz == vec3(0.0)) {
    out_Col = vec4(0.5);
  }
}
