#version 300 es
precision highp float;

in vec4 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_Col;
in vec2 fs_UV;
in vec2 fs_Dimensions;
in float fs_NearClip;
in float fs_FarClip;
in float fs_MeshPart;
in vec3 fs_CameraPos;

out vec4 fragColor[4]; // The data in the ith index of this array of outputs
                       // is passed to the ith index of OpenGLRenderer's
                       // gbTargets array, which is an array of textures.
                       // This lets us output different types of data,
                       // such as albedo, normal, and position, as
                       // separate images from a single render pass.

uniform sampler2D tex_Color;

void main() {
    // TODO: pass proper data into gbuffers
    // Presently, the provided shader passes "nothing" to the first
    // two gbuffers and basic color to the third.

    //vec3 col = texture(tex_Color, fs_UV + vec2(1.0 / fs_Dimensions[0], 1.0 / fs_Dimensions[1])).rgb;
    vec3 col = texture(tex_Color, fs_UV).rgb;

    // if using textures, inverse gamma correct
    col = pow(col, vec3(2.2));

    if(col[0] == 0.0) {
      col[0] = 0.01;
    }
    if(col[1] == 0.0) {
      col[1] = 0.01;
    }
    if(col[2] == 0.0) {
      col[2] = 0.01;
    }

    fragColor[0] = fs_Nor;
    fragColor[1] = vec4(fs_Dimensions, fs_NearClip, fs_FarClip);
    fragColor[2] = vec4(col, fs_MeshPart);
    fragColor[3] = vec4(fs_CameraPos, 1.0);
}
