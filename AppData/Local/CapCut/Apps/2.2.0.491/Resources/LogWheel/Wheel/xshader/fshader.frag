precision highp float;
varying highp vec2 uv0;

uniform sampler2D inputImageTexture;
uniform float Intensity;
uniform float ShadowR;
uniform float ShadowG;
uniform float ShadowB;
uniform float ShadowS;
uniform float MidtoneR;
uniform float MidtoneG;
uniform float MidtoneB;
uniform float MidtoneS;
uniform float HightlightsR;
uniform float HightlightsG;
uniform float HightlightsB;
uniform float HightlightsS;
uniform float OffsetR;
uniform float OffsetG;
uniform float OffsetB;
uniform float OffsetS;
uniform float RugDown;
uniform float RugUP;


vec3 rgb2hsl(vec3 rgb) {
    float h = 0., s = 0., l = 0.;
    float r = rgb.r;
    float g = rgb.g;
    float b = rgb.b;
    float cmax = max(r, max(g, b));
    float cmin = min(r, min(g, b));
    float delta = cmax - cmin;
    l = (cmax + cmin) / 2.;
    if (delta < .00001) {
        s = 0.;
        h = 0.;
    } else {
        if (l <= .5)
            s = delta / (cmax + cmin);
        else
            s = delta / (2. - (cmax + cmin));
        if (cmax - r < .00001) {
            if (g >= b)
                h = 60. * (g - b) / delta;
            else
                h = 60. * (g - b) / delta + 360.;
        } else if (cmax - g < .00001) {
            h = 60. * (b - r) / delta + 120.;
        } else {
            h = 60. * (r - g) / delta + 240.;
        }
    }
    return vec3(h, s, l);
}

float hueToRgb(float p, float q, float t) {
    if (t < 0.)
        t += 1.;
    if (t > 1.)
        t -= 1.;
    if (t < 1. / 6.)
        return p + (q - p) * 6. * t;
    if (t < 1. / 2.)
        return q;
    if (t < 2. / 3.)
        return p + (q - p) * (2. / 3. - t) * 6.;
    return p;
}

vec3 hsl2rgb(vec3 hsl) {
    float r, g, b;
    float h = hsl.x / 360.;
    if (hsl.y == 0.) {
        r = g = b = hsl.z; // gray
    } else {
        float q = hsl.z < .5 ? hsl.z * (1. + hsl.y) : (hsl.z + hsl.y - hsl.z * hsl.y);
        float p = 2. * hsl.z - q;
        r = hueToRgb(p, q, h + 1. / 3.);
        g = hueToRgb(p, q, h);
        b = hueToRgb(p, q, h - 1. / 3.);
    }
    return vec3(r, g, b);
}

float LogFuncS(float curColor, float ShadowWeight, float MidtoneWeight, float HightlightWeight, float Offset)
{
    float shadowsInc=0.;
    float MidtoneInc=0.;
    float HightlightsInc=0.;

    float shadowsWidth = RugDown*1.3 ;//+ min((RugUP-RugDown)*0.05, RugDown*0.05);
    if(curColor<shadowsWidth)
    {
        shadowsInc = (shadowsWidth - curColor);
        if (ShadowWeight < 0.) shadowsInc *= 0.75;
    }

    float RugDown_2 = max(RugDown*0.75, 0.0);
    float RugUP_2 = min(RugUP*1.25, 1.0);
    if (curColor > RugDown_2 && curColor < RugUP_2 && (MidtoneWeight < 0.))
    {
        MidtoneInc = -4.0*(curColor - RugUP_2) * (curColor -RugDown_2) * (curColor -RugDown_2) / (RugUP_2-RugDown_2)/ (RugUP_2-RugDown_2);
    }
    else if (curColor > RugDown_2 && curColor < RugUP_2)
    {
         MidtoneInc = 4.0*(curColor - RugUP_2) * (curColor -RugUP_2) * (curColor -RugDown_2) / (RugUP_2-RugDown_2)/ (RugUP_2-RugDown_2);
    }

    float highsWidth = (1.0-RugUP)*1.3;// + min((RugUP-RugDown)*0.05, (1.0-RugUP)*0.05);
    if(curColor>(1.0 - highsWidth))
    {
        HightlightsInc = (curColor - (1.0 - highsWidth));
        if (HightlightWeight > 0.) HightlightsInc *= 0.75;
    }

    curColor += (shadowsInc * ShadowWeight + MidtoneInc * MidtoneWeight + HightlightsInc * HightlightWeight);
    return curColor;
}

float LogFunc2(float curColor, float ShadowWeight, float MidtoneWeight, float HightlightWeight, float Offset)
{   
    curColor += Offset;
    float shadowsInc=0.;
    float MidtoneInc=0.;
    float HightlightsInc=0.;

    float shadowsWidth = RugDown ;//+ min((RugUP-RugDown)*0.05, RugDown*0.05);
    if(curColor<shadowsWidth)
    {
        shadowsInc = (shadowsWidth - curColor);
        if (ShadowWeight < 0.) shadowsInc *= 2.0;
    }

    float RugDown_2 = max(RugDown - (RugUP-RugDown)*0.1, 0.0);
    float RugUP_2 = min(RugUP + (RugUP-RugDown)*0.1, 1.0);
    if (curColor > RugDown_2 && curColor < RugUP_2 && (MidtoneWeight < 0.))
    {
        MidtoneInc = -3.0*(curColor - RugUP_2) * (curColor -RugDown_2) * (curColor -RugDown_2) / (RugUP_2-RugDown_2)/ (RugUP_2-RugDown_2);
    }
    else if (curColor > RugDown_2 && curColor < RugUP_2)
    {
         MidtoneInc = 3.0*(curColor - RugUP_2) * (curColor -RugUP_2) * (curColor -RugDown_2) / (RugUP_2-RugDown_2)/ (RugUP_2-RugDown_2);
    }

    float highsWidth = (1.0-RugUP);// + min((RugUP-RugDown)*0.05, (1.0-RugUP)*0.05);
    if(curColor>(1.0 - highsWidth))
    {
        HightlightsInc = (curColor - (1.0 - highsWidth));
        if (HightlightWeight > 0.) HightlightsInc *= 2.0;
    }

    curColor += shadowsInc * ShadowWeight + MidtoneInc * MidtoneWeight + HightlightsInc * HightlightWeight;
    return curColor;
}

void main(void){
    vec4 curColor=texture2D(inputImageTexture,uv0);

    vec4 res = curColor;
    res.r = LogFunc2(curColor.r, ShadowR, MidtoneR, HightlightsR, OffsetR);
    res.g = LogFunc2(curColor.g, ShadowG, MidtoneG, HightlightsG, OffsetG);
    res.b = LogFunc2(curColor.b, ShadowB, MidtoneB, HightlightsB, OffsetB);
    res = clamp(res, 0.0, 1.0);

    vec3 hsb = rgb2hsl(res.rgb);
    // //adjust saturation
    float resY = 0.2126 * res.r + 0.7152 * res.g + 0.0722 * res.b;
    float delta_s = (LogFuncS(resY, ShadowS, MidtoneS, HightlightsS, 0.) - resY) * 6.0 + OffsetS;
    delta_s = clamp(delta_s, -1., 1.);
    if (delta_s < 0.) {
        hsb.y = hsb.y * (1. + delta_s);
    } else {
        float temp = hsb.y * (1. - delta_s);
        hsb.y = hsb.y + (hsb.y - temp);
    }
    hsb.y = clamp(hsb.y, 0., 1.);
    if (abs(delta_s)>0.00001)
    {
        res.rgb = hsl2rgb(hsb);
    }

    gl_FragColor = mix(curColor, res, Intensity);
}