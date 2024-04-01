precision highp float;

attribute vec4 position;
attribute vec2 texcoord0;
varying vec2 uv0;
varying vec2 uv1;
uniform mat4 u_MVP;
void main() 
{ 
    gl_Position = u_MVP * position;
    uv0 = texcoord0;
    uv0.y = 1.0 - uv0.y;
    uv1 = gl_Position.xy * 0.5 + 0.5;
}
