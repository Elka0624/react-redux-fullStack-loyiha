precision highp float;
varying highp vec2 uv0;
uniform sampler2D _MainTex;
uniform float scale;

void main()
{
    vec2 uv1 = uv0;
    uv1 -= 0.5;
    uv1 /= scale;
    uv1 += 0.5;
    gl_FragColor = texture2D(_MainTex, uv1);
}
