precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_albedo;
uniform float sat;
uniform vec3 factor1;
void main ()
{
  vec3 temp1_1;
  lowp vec4 res_2;
  vec3 tmpvar_3;
  tmpvar_3 = (factor1 / ((
    (factor1.x + factor1.y)
   + factor1.z) / 0.02));
  float tmpvar_4;
  tmpvar_4 = (50.0 - sat);
  lowp vec4 tmpvar_5;
  tmpvar_5 = texture2D (u_albedo, uv0);
  res_2.w = tmpvar_5.w;
  vec3 tmpvar_6;
  tmpvar_6.x = 0.0;
  tmpvar_6.y = (tmpvar_3.x * tmpvar_4);
  tmpvar_6.z = (tmpvar_3.y * tmpvar_4);
  temp1_1.yz = tmpvar_6.yz;
  temp1_1.x = ((1.0 - tmpvar_6.z) - tmpvar_6.y);
  res_2.x = dot (tmpvar_5.xyz, temp1_1);
  vec3 tmpvar_7;
  tmpvar_7.y = 0.0;
  tmpvar_7.x = (tmpvar_3.z * tmpvar_4);
  tmpvar_7.z = (tmpvar_3.y * tmpvar_4);
  temp1_1.xz = tmpvar_7.xz;
  temp1_1.y = ((1.0 - tmpvar_7.x) - tmpvar_7.z);
  res_2.y = dot (tmpvar_5.xyz, temp1_1);
  vec3 tmpvar_8;
  tmpvar_8.z = 0.0;
  tmpvar_8.x = (tmpvar_3.z * tmpvar_4);
  tmpvar_8.y = (tmpvar_3.x * tmpvar_4);
  temp1_1.xy = tmpvar_8.xy;
  temp1_1.z = ((1.0 - tmpvar_8.x) - tmpvar_8.y);
  res_2.z = dot (tmpvar_5.xyz, temp1_1);
  gl_FragColor = res_2;
}

