precision lowp float;
varying highp vec2 uv0;
uniform sampler2D u_Albedo;
uniform vec3 u_RVec3;
uniform vec3 u_GVec3;
uniform vec3 u_BVec3;
void main()
{
    vec4 oriColor = texture2D(u_Albedo, uv0);
    vec4 resColor = vec4(0.0);
    resColor.a = oriColor.a;
    resColor.r = dot(oriColor.rgb, u_RVec3);
    resColor.g = dot(oriColor.rgb, u_GVec3);
    resColor.b = dot(oriColor.rgb, u_BVec3);
    gl_FragColor = resColor;
}
