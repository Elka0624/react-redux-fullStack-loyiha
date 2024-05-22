
#define USE_NORMAL_TEXTURE
precision highp float;

attribute vec4 position;
attribute vec4 posoffset;
attribute vec2 uv;

uniform mat4 u_MVP;

varying vec2 v_src_uv;
varying vec2 v_material_uv;

void main()
{
    if (posoffset.z > 0.0) {
        gl_Position = u_MVP * (position + posoffset * 2.0);
    }
    else {
        gl_Position = u_MVP * (position + posoffset);
    }
    v_src_uv = gl_Position.xy / gl_Position.w * 0.5 + 0.5;
    v_material_uv = uv;
}