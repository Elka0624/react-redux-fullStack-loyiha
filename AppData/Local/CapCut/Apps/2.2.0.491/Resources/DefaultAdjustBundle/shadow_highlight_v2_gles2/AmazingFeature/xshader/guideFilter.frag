precision lowp float;
varying highp vec2 uv0;
uniform sampler2D u_albedo;
uniform sampler2D u_albedo1;
uniform float sigma;
const vec3 grayVec =  vec3(0.2126, 0.7152, 0.0722);
void main()
{
    vec4 color = texture2D(u_albedo,uv0);
    vec4 colorAB = texture2D(u_albedo1,uv0);
    float gray = dot(color.rgb,grayVec);
    float filterGray = gray * colorAB.r + colorAB.g;
    gl_FragColor.rgb = vec3(filterGray);
    gl_FragColor.a = 1.;
    // gl_FragColor.rgb = vec3(color.r);
    // gl_FragColor.a = 1.;
    // gl_FragColor = vec4(1.);
}
