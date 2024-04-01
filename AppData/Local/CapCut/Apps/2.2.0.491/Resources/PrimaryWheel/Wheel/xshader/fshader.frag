precision highp float;
varying highp vec2 uv0;

uniform sampler2D inputImageTexture;
uniform float Intensity;
uniform float LiftY;
uniform float LiftR;
uniform float LiftG;
uniform float LiftB;
uniform float LiftS;
uniform float GammaY;
uniform float GammaR;
uniform float GammaG;
uniform float GammaB;
uniform float GammaS;
uniform float GainY;
uniform float GainR;
uniform float GainG;
uniform float GainB;
uniform float GainS;
uniform float OffsetR;
uniform float OffsetG;
uniform float OffsetB;
uniform float OffsetS;
uniform float LumaMix;


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

float processWheel(float srcColor, float lift, float gamma, float gain)
{
    float lift_x = lift/(lift-0.5);
    float gain_x = 1.0/(gain);

    if (lift >= 0.5)
    {
        lift_x = -1e6;
    }
    if (gain == 0.)
    {
        gain_x = 1e6;
    }
    if (lift_x >= gain_x)
    {
        gain_x = lift_x + 1e-6;
    }

    float resColor = (srcColor - lift_x)/(gain_x - lift_x);

    // resColor = clamp(resColor, 0.0, 1.0);
    if(resColor>0.0)
    {
        resColor = exp(gamma * log(resColor));
    }
    return resColor;
}

void main(void) {
    vec4 oriColor = texture2D(inputImageTexture, uv0);

    vec4 srcColor = oriColor;
    srcColor += vec4(OffsetR, OffsetG, OffsetB, 0.);
    vec4 resColor = srcColor;

    resColor.r = processWheel(srcColor.r, LiftR, GammaR, GainR);
    resColor.g = processWheel(srcColor.g, LiftG, GammaG, GainG);
    resColor.b = processWheel(srcColor.b, LiftB, GammaB, GainB);

    float srcY = 0.2126 * srcColor.r + 0.7152 * srcColor.g + 0.0722 * srcColor.b;
    float resY = 0.2126 * resColor.r + 0.7152 * resColor.g + 0.0722 * resColor.b;
    float dstY = processWheel(srcY, LiftY, GammaY, GainY);
    resColor.rgb += (dstY - resY) * LumaMix;
    
    resColor = clamp(resColor, 0.0, 1.0);

    vec3 hsb = rgb2hsl(resColor.rgb);
    // //adjust saturation
    resY = 0.2126 * resColor.r + 0.7152 * resColor.g + 0.0722 * resColor.b;
    float delta_s = OffsetS;
    delta_s += (processWheel(resY, LiftS, 1.0, 1.0) - resY);
    delta_s += (processWheel(resY, 0.0, GammaS, 1.0) - resY);
    delta_s += (processWheel(resY, 0.0, 1.0, GainS) - resY);
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
        resColor.rgb = hsl2rgb(hsb);
    }

    gl_FragColor = mix(oriColor, resColor, Intensity);
}
