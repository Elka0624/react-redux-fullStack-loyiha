
#define USE_NORMAL_TEXTURE
precision highp float;

attribute vec4 position;
attribute vec4 posoffset;
attribute vec2 uv;

uniform mat4 u_MVP;
varying vec2 v_src_uv;

void main()
{
    gl_Position = u_MVP * (position + posoffset);
    vec4 screenPos = u_MVP * position;
    v_src_uv = screenPos.xy / screenPos.w * 0.5 + 0.5;
}
