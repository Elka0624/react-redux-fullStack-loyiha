precision highp float;

attribute vec2 position;
attribute vec2 texcoord0;
varying vec2 uv0;
//uniform mat4 u_MVP;
uniform mat4 u_InvModel;
uniform mat4 u_Model;
void main() 
{ 
    //gl_Position = u_MVP * position;
    gl_Position = (vec4(texcoord0.xy * 2.0 - 1.0, 0.0, 1.0));
    uv0 = (texcoord0);// + vec2(u_InvModel[3][0], u_InvModel[3][1]) * 0.5;
}
