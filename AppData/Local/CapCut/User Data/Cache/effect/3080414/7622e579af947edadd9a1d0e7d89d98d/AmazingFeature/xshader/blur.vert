precision highp float;
attribute vec3 attPosition;
attribute vec2 attUV;

varying vec2 textureCoordinate;
varying vec4 textureShift_1;
varying vec4 textureShift_2;

uniform float texelWidthOffset;
uniform float texelHeightOffset;

#define USE_SEG 1
#ifdef USE_SEG
uniform float scaleOffset;
uniform mat4 uSegMatrix;
uniform vec2 inputSize;
varying vec4 textureShift_3;
#endif

void main(void)
{
    gl_Position = vec4(attPosition.xy, 0., 1.);
    textureCoordinate = attUV;

    vec2 singleStepOffset = 4.2 * vec2(texelWidthOffset, texelHeightOffset);
    vec2 doubleStepOffset = singleStepOffset * 2.0;
    
    textureShift_1 = vec4(attUV - singleStepOffset, attUV + singleStepOffset);
    textureShift_2 = vec4(attUV - doubleStepOffset, attUV + doubleStepOffset);
#ifdef USE_SEG
    vec2 newXY2 = vec2((attUV.x - scaleOffset * singleStepOffset.x) * inputSize.x, (1.0 - (attUV.y - scaleOffset * singleStepOffset.y)) * inputSize.y);
    vec2 newXY3 = vec2((attUV.x + scaleOffset * singleStepOffset.x) * inputSize.x, (1.0 - (attUV.y + scaleOffset * singleStepOffset.y)) * inputSize.y);
    newXY2 = (uSegMatrix * vec4(newXY2.xy, 0.0, 1.0)).xy;
    newXY3 = (uSegMatrix * vec4(newXY3.xy, 0.0, 1.0)).xy;
    textureShift_3 = vec4(newXY2, newXY3.x, newXY3.y);
#endif
}