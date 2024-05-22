precision highp float;

varying vec2 uv0;

uniform sampler2D mainTex;
uniform vec2 u_ScreenParams;

void main()
{
    vec2 uv1 = uv0;
    vec4 mainCol = texture2D(mainTex, uv1);
    vec4 res = mainCol;
    // res = vec4(uv0,0,1);
    gl_FragColor = res;
}