precision highp float;
varying highp vec2 uv0;
uniform sampler2D edgeTex;

void main()
{
    gl_FragColor = texture2D(edgeTex, uv0);
}
