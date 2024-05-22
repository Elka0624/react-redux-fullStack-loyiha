precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_albedo;
uniform vec4 u_ScreenParams;
uniform vec2 u_K;
uniform float u_Progress;
varying vec2 offset;



void main()
{
    gl_FragColor = vec4(0.0);
    // gl_FragColor = vec4(blockNoise.y);
    // gl_FragColor = color;
}
