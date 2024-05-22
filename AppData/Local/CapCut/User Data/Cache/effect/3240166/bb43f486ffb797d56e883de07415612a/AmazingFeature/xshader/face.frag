#define USE_NORMAL_TEXTURE
precision highp float;

uniform sampler2D u_video;

varying vec2 v_src_uv;

void main()
{
    gl_FragColor = vec4(texture2D(u_video, v_src_uv).rgb, 1.0);
}
