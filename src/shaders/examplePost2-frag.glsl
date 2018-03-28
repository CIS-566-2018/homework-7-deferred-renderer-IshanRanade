#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;

uniform vec2 u_Dimensions;





vec3 applyGaussian() {

  const int size = 72;
  float sigma = 1000.0;
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

  vec2 startCoord = vec2(float(int(u_Dimensions[0] * fs_UV[0])) - 1.0, float(int(u_Dimensions[1] * fs_UV[1])) - 1.0);

  vec3 color = vec3(0.0f);

  vec2 curCoord = startCoord;
  for(int i = 0; i < size; ++i) {
    if(i != 0 && i % int(sqrt(float(size))) == 0) {
      curCoord[0] = startCoord[0];
      curCoord[1] += 1.0;
    }


    vec3 textureColor = texture(u_frame, vec2(curCoord[0] / u_Dimensions[0], curCoord[1] / u_Dimensions[1])).xyz;
    color += gaussian[i] * textureColor;

    curCoord[0] += 1.0;
  }

  return color;
}





// Interpolate between regular color and channel-swizzled color
// on right half of screen. Also scale color to range [0, 5].
void main() {
	vec3 color = applyGaussian();
  out_Col = vec4(color, 1.0);
}
