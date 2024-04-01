precision highp float;
uniform sampler2D inputTex;
uniform sampler2D guidedFilterTex;
uniform float pMax;
uniform float pMin;
uniform float pGain;
uniform float pOffset;
uniform float contrast;
uniform highp int flag;
uniform highp int flag1;
uniform float shadow;
uniform float highlight;
uniform float thr;
uniform float lf;
uniform float sf1;
uniform float sf2;
varying vec2 uv;
void main ()
{
  lowp vec4 tmpvar_1;
  lowp float tmp1_2;
  lowp vec4 color_3;
  float tmpvar_4;
  tmpvar_4 = (pMax - pMin);
  float tmpvar_5;
  tmpvar_5 = (1.0/(tmpvar_4));
  lowp vec4 tmpvar_6;
  tmpvar_6 = texture2D (inputTex, uv);
  color_3.w = tmpvar_6.w;
  color_3.xyz = (tmpvar_5 * (tmpvar_6.xyz - pMin));
  lowp vec3 hsl_7;
  hsl_7.x = 0.0;
  hsl_7.z = dot (color_3.xyz, vec3(0.2126, 0.7152, 0.0722));
  lowp float tmpvar_8;
  tmpvar_8 = (((color_3.x * 0.5) - (color_3.y * 0.25)) - (color_3.z * 0.25));
  lowp float tmpvar_9;
  tmpvar_9 = ((color_3.y * 0.4330127) - (color_3.z * 0.4330127));
  hsl_7.y = sqrt(((tmpvar_8 * tmpvar_8) + (tmpvar_9 * tmpvar_9)));
  lowp float tmpvar_10;
  lowp float tmpvar_11;
  tmpvar_11 = (min (abs(
    (tmpvar_9 / tmpvar_8)
  ), 1.0) / max (abs(
    (tmpvar_9 / tmpvar_8)
  ), 1.0));
  lowp float tmpvar_12;
  tmpvar_12 = (tmpvar_11 * tmpvar_11);
  tmpvar_12 = (((
    ((((
      ((((-0.01213232 * tmpvar_12) + 0.05368138) * tmpvar_12) - 0.1173503)
     * tmpvar_12) + 0.1938925) * tmpvar_12) - 0.3326756)
   * tmpvar_12) + 0.9999793) * tmpvar_11);
  tmpvar_12 = (tmpvar_12 + (float(
    (abs((tmpvar_9 / tmpvar_8)) > 1.0)
  ) * (
    (tmpvar_12 * -2.0)
   + 1.570796)));
  tmpvar_10 = (tmpvar_12 * sign((tmpvar_9 / tmpvar_8)));
  if ((abs(tmpvar_8) > (1e-08 * abs(tmpvar_9)))) {
    if ((tmpvar_8 < 0.0)) {
      if ((tmpvar_9 >= 0.0)) {
        tmpvar_10 += 3.141593;
      } else {
        tmpvar_10 = (tmpvar_10 - 3.141593);
      };
    };
  } else {
    tmpvar_10 = (sign(tmpvar_9) * 1.570796);
  };
  hsl_7.x = (tmpvar_10 / 6.283185);
  if ((hsl_7.x < 0.0)) {
    hsl_7.x = (hsl_7.x + 1.0);
  };
  lowp float tmpvar_13;
  tmpvar_13 = (tmpvar_5 * (texture2D (guidedFilterTex, uv).x - pMin));
  lowp float tmpvar_14;
  tmpvar_14 = (hsl_7.z - tmpvar_13);
  tmp1_2 = 0.0;
  if ((flag == 1)) {
    lowp float mappingColor_15;
    lowp float n_16;
    float h3_17;
    float b_18;
    float a_19;
    float h2_20;
    float h1_21;
    float tmpvar_22;
    tmpvar_22 = (highlight * 0.015);
    float tmpvar_23;
    tmpvar_23 = exp2(-((shadow * 0.0075)));
    float tmpvar_24;
    tmpvar_24 = pow (thr, tmpvar_23);
    h1_21 = tmpvar_22;
    h2_20 = 1.0;
    if ((flag1 == 1)) {
      h2_20 = ((abs(tmpvar_22) * -0.2) + 1.0);
    };
    a_19 = 1.0;
    b_18 = 1.0;
    h3_17 = 0.0;
    if ((flag1 == 1)) {
      h3_17 = (0.2 * tmpvar_22);
      if ((tmpvar_22 <= 0.0)) {
        a_19 = (1.0/((1.0 - h3_17)));
      } else {
        a_19 = (h3_17 + 1.0);
      };
      h1_21 = tmpvar_22;
      b_18 = (1.0 - pow ((1.0 - h2_20), exp2(tmpvar_22)));
    };
    lowp float tmpvar_25;
    tmpvar_25 = (((1.0 - 
      pow ((1.0 - (h2_20 * tmpvar_13)), exp2(h1_21))
    ) / b_18) * a_19);
    n_16 = tmpvar_13;
    if ((tmpvar_13 <= thr)) {
      n_16 = ((pow (tmpvar_13, tmpvar_23) / tmpvar_24) * thr);
    };
    lowp float tmpvar_26;
    tmpvar_26 = mix (n_16, tmpvar_25, tmpvar_13);
    mappingColor_15 = tmpvar_26;
    if ((tmpvar_13 > 1.0)) {
      mappingColor_15 = (tmpvar_26 + ((
        (101.6 - tmpvar_26)
       / 100.6) * (tmpvar_13 - 1.0)));
    } else {
      if ((tmpvar_13 < 0.0)) {
        mappingColor_15 = (mappingColor_15 + tmpvar_13);
      };
    };
    tmp1_2 = mappingColor_15;
  } else {
    lowp float mappingColor_27;
    lowp float n_28;
    float h3_29;
    float b_30;
    float a_31;
    float h2_32;
    float h1_33;
    float tmpvar_34;
    tmpvar_34 = (highlight * 0.015);
    float tmpvar_35;
    tmpvar_35 = exp2(-((shadow * 0.0075)));
    float tmpvar_36;
    tmpvar_36 = pow (thr, tmpvar_35);
    h1_33 = tmpvar_34;
    h2_32 = 1.0;
    if ((flag1 == 1)) {
      h2_32 = ((abs(tmpvar_34) * -0.2) + 1.0);
    };
    a_31 = 1.0;
    b_30 = 1.0;
    h3_29 = 0.0;
    if ((flag1 == 1)) {
      h3_29 = (0.2 * tmpvar_34);
      if ((tmpvar_34 <= 0.0)) {
        a_31 = (1.0/((1.0 - h3_29)));
      } else {
        a_31 = (h3_29 + 1.0);
      };
      h1_33 = tmpvar_34;
      b_30 = (1.0 - pow ((1.0 - h2_32), exp2(tmpvar_34)));
    };
    lowp float tmpvar_37;
    tmpvar_37 = (((1.0 - 
      pow ((1.0 - (h2_32 * tmpvar_13)), exp2(h1_33))
    ) / b_30) * a_31);
    n_28 = tmpvar_13;
    if ((tmpvar_13 <= thr)) {
      n_28 = ((pow (tmpvar_13, tmpvar_35) / tmpvar_36) * thr);
    };
    lowp float tmpvar_38;
    tmpvar_38 = mix (n_28, tmpvar_37, tmpvar_13);
    mappingColor_27 = tmpvar_38;
    if ((tmpvar_13 > 1.0)) {
      float n_39;
      float h3_40;
      float b_41;
      float a_42;
      float h2_43;
      float h1_44;
      float tmpvar_45;
      tmpvar_45 = (highlight * 0.015);
      float tmpvar_46;
      tmpvar_46 = exp2(-((shadow * 0.0075)));
      float tmpvar_47;
      tmpvar_47 = pow (thr, tmpvar_46);
      h1_44 = tmpvar_45;
      h2_43 = 1.0;
      if ((flag1 == 1)) {
        h2_43 = ((abs(tmpvar_45) * -0.2) + 1.0);
      };
      a_42 = 1.0;
      b_41 = 1.0;
      h3_40 = 0.0;
      if ((flag1 == 1)) {
        h3_40 = (0.2 * tmpvar_45);
        if ((tmpvar_45 <= 0.0)) {
          a_42 = (1.0/((1.0 - h3_40)));
        } else {
          a_42 = (h3_40 + 1.0);
        };
        h1_44 = tmpvar_45;
        b_41 = (1.0 - pow ((1.0 - h2_43), exp2(tmpvar_45)));
      };
      float tmpvar_48;
      tmpvar_48 = (((1.0 - 
        pow ((1.0 - (h2_43 * 0.875)), exp2(h1_44))
      ) / b_41) * a_42);
      n_39 = 0.875;
      if ((0.875 <= thr)) {
        n_39 = ((pow (0.875, tmpvar_46) / tmpvar_47) * thr);
      };
      mappingColor_27 = (tmpvar_38 + ((
        (tmpvar_38 - mix (n_39, tmpvar_48, 0.875))
       / 0.125) * (tmpvar_13 - 1.0)));
    } else {
      if ((tmpvar_13 < 0.0)) {
        float n_49;
        float h3_50;
        float b_51;
        float a_52;
        float h2_53;
        float h1_54;
        float tmpvar_55;
        tmpvar_55 = (highlight * 0.015);
        float tmpvar_56;
        tmpvar_56 = exp2(-((shadow * 0.0075)));
        float tmpvar_57;
        tmpvar_57 = pow (thr, tmpvar_56);
        h1_54 = tmpvar_55;
        h2_53 = 1.0;
        if ((flag1 == 1)) {
          h2_53 = ((abs(tmpvar_55) * -0.2) + 1.0);
        };
        a_52 = 1.0;
        b_51 = 1.0;
        h3_50 = 0.0;
        if ((flag1 == 1)) {
          h3_50 = (0.2 * tmpvar_55);
          if ((tmpvar_55 <= 0.0)) {
            a_52 = (1.0/((1.0 - h3_50)));
          } else {
            a_52 = (h3_50 + 1.0);
          };
          h1_54 = tmpvar_55;
          b_51 = (1.0 - pow ((1.0 - h2_53), exp2(tmpvar_55)));
        };
        float tmpvar_58;
        tmpvar_58 = (((1.0 - 
          pow ((1.0 - (h2_53 * 0.125)), exp2(h1_54))
        ) / b_51) * a_52);
        n_49 = 0.125;
        if ((0.125 <= thr)) {
          n_49 = ((pow (0.125, tmpvar_56) / tmpvar_57) * thr);
        };
        mappingColor_27 = (mappingColor_27 + ((
          (mix (n_49, tmpvar_58, 0.125) - mappingColor_27)
         / 0.125) * tmpvar_13));
      };
    };
    tmp1_2 = mappingColor_27;
  };
  lowp float ratio_59;
  lowp vec3 ret_60;
  ret_60 = hsl_7;
  ratio_59 = 1.0;
  lowp float tmpvar_61;
  tmpvar_61 = abs(tmpvar_13);
  if ((tmpvar_61 > 1e-05)) {
    ratio_59 = clamp ((tmp1_2 / tmpvar_13), 1.0, 4.0);
  };
  ret_60.z = (tmp1_2 + (ratio_59 * tmpvar_14));
  ret_60.y = (hsl_7.y * ratio_59);
  lowp vec3 ret_62;
  ret_62.xy = ret_60.xy;
  ret_62.z = (ret_60.z + ((
    (tmpvar_14 * lf)
   * 
    max (0.0, (ret_60.z * (1.0 - ret_60.z)))
  ) * 4.0));
  float w_63;
  lowp vec3 ret_64;
  ret_64 = ret_62;
  w_63 = sf1;
  if ((sf1 >= 0.0)) {
    w_63 = (sf1 * 0.7);
  };
  ret_64.y = max (0.0, (ret_60.y + (
    (pow (ret_60.y, 0.4) * w_63)
   * 0.25)));
  lowp vec3 ret_65;
  ret_65.xz = ret_64.xz;
  ret_65.y = max (0.0, (ret_64.y * (1.0 + sf2)));
  lowp vec3 rgb_66;
  rgb_66 = ret_65.zzz;
  if ((ret_65.y > 0.0)) {
    lowp float tmpvar_67;
    tmpvar_67 = (6.283185 * hsl_7.x);
    lowp float tmpvar_68;
    tmpvar_68 = (ret_65.y * cos(tmpvar_67));
    lowp float tmpvar_69;
    tmpvar_69 = (ret_65.y * sin(tmpvar_67));
    rgb_66.x = (ret_62.z + (tmpvar_68 * 1.333333));
    rgb_66.y = (ret_62.z + ((tmpvar_68 * -0.6666667) + (tmpvar_69 * 1.154701)));
    rgb_66.z = (ret_62.z + ((tmpvar_68 * -0.6666667) - (tmpvar_69 * 1.154701)));
    rgb_66 = (rgb_66 + (ret_62.z - dot (rgb_66, vec3(0.2126, 0.7152, 0.0722))));
  };
  color_3.xyz = ((tmpvar_4 * rgb_66) + pMin);
  color_3.xyz = ((contrast * (color_3.xyz - 0.5)) + 0.5);
  tmpvar_1 = ((color_3 * pGain) + pOffset);
  gl_FragColor = tmpvar_1;
}

