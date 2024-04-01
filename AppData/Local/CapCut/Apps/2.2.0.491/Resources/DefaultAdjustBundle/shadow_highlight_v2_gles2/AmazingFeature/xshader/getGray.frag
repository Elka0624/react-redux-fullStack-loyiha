precision lowp float;
varying highp vec2 uv0;
uniform sampler2D u_albedo;
const vec3 grayVec =  vec3(0.2126, 0.7152, 0.0722);
void main()
{
    vec4 color = texture2D(u_albedo, uv0);
    gl_FragColor = vec4(dot(grayVec,color.rgb));
}
