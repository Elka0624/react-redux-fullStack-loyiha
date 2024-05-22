attribute vec3 attPosition;     //vertex coordinate, y is flipped!
attribute vec2 attStandardUV;   //uv coordinate of standard face

varying vec2 texCoord;
varying vec2 sucaiTexCoord;
varying vec2 textureShift_1;
varying vec2 textureShift_2;
varying vec2 textureShift_3;
varying vec2 textureShift_4;

uniform mat4 uMVPMatrix;
uniform mat4 uSTMatrix;
uniform float texelWidthOffset;
uniform float texelHeightOffset;

#define USE_SEG 1
#ifdef USE_SEG
varying vec2 segCoord;
uniform mat4 uSegMatrix;
#endif

void main(){
    gl_Position = uMVPMatrix * vec4(attPosition, 1.0);
    texCoord = 0.5 * gl_Position.xy + 0.5;
    sucaiTexCoord = (uSTMatrix * vec4(attStandardUV.xy, 0.0, 1.0)).xy;

#ifdef USE_SEG
    segCoord = (uSegMatrix * vec4(attPosition, 1.0)).xy;
#endif

    textureShift_1 = vec2(texCoord + 0.25 * vec2(texelWidthOffset, texelHeightOffset));
    textureShift_2 = vec2(texCoord + 0.25 * vec2(-texelWidthOffset, -texelHeightOffset));
    textureShift_3 = vec2(texCoord + 0.25 * vec2(-texelWidthOffset, texelHeightOffset));
    textureShift_4 = vec2(texCoord + 0.25 * vec2(texelWidthOffset, -texelHeightOffset));
}