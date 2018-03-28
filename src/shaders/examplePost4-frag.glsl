#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;

uniform vec2 u_Dimensions;

const float WORLEY_SIZE = 100.0;

vec2 getWorleyPoint(const vec2 seed, int spaceBetweenX, int spaceBetweenY) {
    vec2 n = fract(sin(vec2(dot(seed,vec2(127.1,311.7)),dot(seed,vec2(269.5,183.3))))*43758.5453);

    float scaleX = (n[0] + 1.0)/2.0;
    float scaleY = (n[1] + 1.0)/2.0;

    float sign = (fract(sin(dot(seed, vec2(12.9898,78.233))) * 43758.5453123) > 0.5) ? 1.0 : -1.0;

    n[0] += scaleX * sin(sign * 1.0*(u_Time + n[0] * 100.0)/20.0);
    n[1] += scaleY * cos(sign * 1.0*(u_Time + n[1] * 100.0)/20.0);

    return vec2(seed[0] + float(spaceBetweenX) * ((n[0] + 1.0)/2.0), seed[1] + float(spaceBetweenY) * ((n[1] + 1.0)/2.0));
}

vec2 getSeedPoint(const vec2 pixel, int spaceBetweenX, int spaceBetweenY) {
    return vec2( float(int(pixel.x / float(spaceBetweenX))) * float(spaceBetweenX),
                 float(int(pixel.y / float(spaceBetweenY))) * float(spaceBetweenY)
               );
}


// Interpolate between regular color and channel-swizzled color
// on right half of screen. Also scale color to range [0, 5].
void main() {

  vec2 thisPixel = vec2(int(fs_UV[0] * u_Dimensions[0]), int(fs_UV[1] * u_Dimensions[1]));

  int spaceBetweenX = int(1.0 * u_Dimensions[0] / WORLEY_SIZE);
  int spaceBetweenY = int(1.0 * u_Dimensions[1] / WORLEY_SIZE);

  vec2 thisSeed = getSeedPoint(thisPixel, spaceBetweenX, spaceBetweenY);

  int X = int(thisSeed.x) - spaceBetweenX;
  int Y = int(thisSeed.y) + spaceBetweenY;
  vec2 closestWorley = getWorleyPoint(thisSeed, spaceBetweenX, spaceBetweenY);
  vec2 closestSeed = vec2(X, Y);
  float bestDistance = 1.0 / 0.0;

  // Search the surroundimng boxes for the closest worley point
  for(int i = 0; i < 9; i++) {
      if(i % 3 == 0 && i != 0) {
          X = int(thisSeed.x) - spaceBetweenX;
          Y -= spaceBetweenY;
      }

      vec2 tempWorley = getWorleyPoint(vec2(X, Y), spaceBetweenX, spaceBetweenY);
      if(distance(thisPixel, tempWorley) < bestDistance) {
          closestWorley = tempWorley;
          bestDistance = distance(thisPixel, tempWorley);
          closestSeed = vec2(X, Y);
      }

      X += spaceBetweenX;
  }

  vec3 color = texture(u_frame, vec2(closestWorley[0] / u_Dimensions[0], closestWorley[1] / u_Dimensions[1])).xyz;
  float luminence = dot(color, vec3(0.299, 0.587, 0.114));

  if(distance(thisPixel, closestWorley) < max(1.0, 3.0 * luminence)) {
    out_Col = vec4(color, 1.0);
  } else {
    out_Col = vec4(color * 0.1, 1.0);
  }

}
