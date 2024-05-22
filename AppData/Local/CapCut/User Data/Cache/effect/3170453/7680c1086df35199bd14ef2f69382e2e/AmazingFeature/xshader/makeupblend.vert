attribute vec3 attPosition;     //vertex coordinate, y is flipped!
attribute vec2 attStandardUV;   //uv coordinate of standard face

varying vec2 maskTexCoord;

uniform mat4 uMVPMatrix;
uniform mat4 uSTMatrix;

void main() {
    gl_Position = uMVPMatrix * vec4(attPosition, 1.0);
    maskTexCoord = (uSTMatrix * vec4(attStandardUV.xy, 0.0, 1.0)).xy;

    gl_Position.y = -gl_Position.y;
}