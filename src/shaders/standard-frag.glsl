#version 300 es
precision highp float;

in vec4 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_Col;
in vec2 fs_UV;
in vec2 fs_Dimensions;

out vec4 fragColor[3]; // The data in the ith index of this array of outputs
                       // is passed to the ith index of OpenGLRenderer's
                       // gbTargets array, which is an array of textures.
                       // This lets us output different types of data,
                       // such as albedo, normal, and position, as
                       // separate images from a single render pass.

uniform sampler2D tex_Color;

vec3 applyGaussian() {
  const int size = 9;
  float gaussian[size] = float [size]( 
    0.110741,	0.111296,	0.110741,
    0.111296,	0.111853,	0.111296,
    0.110741,	0.111296,	0.110741 );

  vec2 startCoord = vec2(float(int(fs_Dimensions[0] * fs_UV[0])) - 1.0, float(int(fs_Dimensions[1] * fs_UV[1])) - 1.0);

  vec3 color = vec3(0.0f);

  float sum = 0.0;
  vec2 curCoord = startCoord;
  for(int i = 0; i < size; ++i) {
    if(i % 11 == 0) {
      curCoord[0] = startCoord[0];
      curCoord[1] += 1.0;
    }

    sum += gaussian[i];
    color += gaussian[i] * vec3(texture(tex_Color, vec2(curCoord[0] / fs_Dimensions[0], curCoord[1] / fs_Dimensions[1])));

    curCoord[0] += 1.0;
  }

  return color;
}

void main() {
    // TODO: pass proper data into gbuffers
    // Presently, the provided shader passes "nothing" to the first
    // two gbuffers and basic color to the third.

    //vec3 col = texture(tex_Color, fs_UV + vec2(1.0 / fs_Dimensions[0], 1.0 / fs_Dimensions[1])).rgb;
    vec3 col = texture(tex_Color, fs_UV).rgb;

    // if using textures, inverse gamma correct
    col = pow(col, vec3(2.2));

    fragColor[0] = fs_Nor;
    fragColor[1] = vec4(fs_Dimensions, 1.0, 1.0);
    //fragColor[2] = vec4(applyGaussian(), 1.0);
    fragColor[2] = vec4(col, 1.0);
}
