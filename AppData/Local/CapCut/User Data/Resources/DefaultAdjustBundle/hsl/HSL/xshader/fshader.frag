precision highp float;
varying vec2 uv0;
uniform sampler2D inputImageTexture;

uniform vec3 hsl_param_0; // red
uniform vec3 hsl_param_1; // orange
uniform vec3 hsl_param_2; // yellow
uniform vec3 hsl_param_3; // green
uniform vec3 hsl_param_4; // cyan
uniform vec3 hsl_param_5; // blue
uniform vec3 hsl_param_6; // purple
uniform vec3 hsl_param_7; // magenta
// uniform vec3 hsl_param_8; // skin tone

vec3 RGB2HSL(vec3 rgb) {
    float rc = rgb.r;
    float gc = rgb.g;
    float bc = rgb.b;

    float h = 0.0;
    float s = 0.0;
    float v = 0.0;

    float max_v = max(rc, max(gc, bc));
    float min_v = min(rc, min(gc, bc));
    float delta = max_v - min_v;

    v = max_v;

    if (max_v != 0.0) {
        s = delta / max_v;
    } else {
        s = 0.0;
    }

    if (s == 0.0) {
        h = 0.0;
    } else {
        if (rc == max_v) {
            h = (gc - bc) / delta;
        } else if (gc == max_v) {
            h = 2.0 + (bc - rc) / delta;
        } else if (bc == max_v) {
            h = 4.0 + (rc - gc) / delta;
        }

        h *= 60.0;
        if (h < 0.0) {
            h += 360.0;
        }
    }
    return vec3(h, s, v);
}

vec3 HSL2RGB(vec3 rgb) {
    float h;
    float s;
    float v;
    float r;
    float g;
    float b;

    h = rgb.r;
    s = rgb.g;
    v = rgb.b;
    int i = 0;
    float f;
    float p;
    float q;
    float t;
    if (s == 0.0) {
        // achromatic (grey)
        r = g = b = v;
    } else {
        h /= 60.0;   // sector 0 to 5
        i = int(floor(h));
        f = h - float(i);   // factorial part of h
        p = v * (1.0 - s);
        q = v * (1.0 - s * f);
        t = v * (1.0 - s * (1.0 - f));

        if (i == 0) {
            r = v;
            g = t;
            b = p;
        } else if (i == 1) {
            r = q;
            g = v;
            b = p;
        } else if (i == 2) {
            r = p;
            g = v;
            b = t;
        } else if (i == 3) {
            r = p;
            g = q;
            b = v;
        } else if (i == 4) {
            r = t;
            g = p;
            b = v;

        } else {
            r = v;
            g = p;
            b = q;
        }
    }
    return vec3(r, g, b);
}

vec3 hueAdjust(vec3 hsb, vec3 maskHsb, float standHue, float deltaRange, vec3 hueParam, float offset, int LV_ColorType) {
    if ((hueParam.x == 0.0) && (hueParam.y == 0.0) && (hueParam.z == 0.0))
        return hsb;
    // hsb adjust
    vec3 tmpHSB;
    float fAlpha;
    float standHue0;
    float minHue;
    float maxHue;
    float currHue;
    // Red
    if (LV_ColorType == 3)
        hueParam.x = hueParam.x * 0.7 + 10.0;
    else
        hueParam.x = hueParam.x * 0.3;

    float saturation;
    saturation = hueParam.y;
    hueParam.y = hueParam.y * 2.0 / 100.0;

    if ((LV_ColorType == 0) && (saturation > 0.0)) {
        hueParam.y = saturation / 100.0;
    } else if ((LV_ColorType == 1) && (saturation > 0.0)) {
        hueParam.y = saturation * 1.2 / 100.0;
    }

    if (LV_ColorType == 1)
        hueParam.z = hueParam.z / 200.0;
    else
        hueParam.z = hueParam.z / 100.0;

    // init data
    standHue0 = standHue + offset;
    minHue = standHue0 - deltaRange;
    maxHue = standHue0 + deltaRange;
    tmpHSB = hsb;
    // check range

    if (offset > 0.0) {
        if (maskHsb.r > 180.0)
            currHue = maskHsb.r - 360.0 + offset;
        else
            currHue = maskHsb.r + offset;
    } else
        currHue = maskHsb.r;
    if ((currHue >= minHue) && (currHue <= maxHue)) {
        // get alpha
        fAlpha = abs(currHue - standHue0);
        // fAlpha=1.0-fAlpha/deltaRange;
        fAlpha = 1.0 - fAlpha / deltaRange;

        // hue
        tmpHSB.x = hsb.r + hueParam.x * fAlpha;
        if (tmpHSB.x >= 360.0)
            tmpHSB.x = tmpHSB.x - 360.0;
        // saturation
        tmpHSB.y = hsb.y + hsb.y * hueParam.y * fAlpha;
        tmpHSB.y = clamp(tmpHSB.y, 0.0, 1.0);
        // bright
        tmpHSB.z = hsb.z + hsb.z * hsb.y * hueParam.z * fAlpha;
        // tmpHSB.z=hsb.z+hsb.z*hsb.y*hueParam.z*0.5; //
        tmpHSB.z = clamp(tmpHSB.z, 0.0, 1.0);
    }

    return tmpHSB;
}

void main() {
    vec3 clO;
    vec3 clA;
    vec3 lumCoeff;

    vec4 baseColor;
    baseColor = texture2D(inputImageTexture, uv0);
    clO = baseColor.rgb;
    clA = clO;
    lumCoeff = vec3(0.2125, 0.7154, 0.0721);

    // Highlight and Shadow
    float fTmpGamma;
    float lumBlur;
    lumBlur = dot(clO, lumCoeff);
    lumBlur = lumBlur * 2.0 - 1.0;

    if (lumBlur < 0.0) {
        fTmpGamma = pow(10.0, 0.0);
        clA = vec3(1.0 - pow(vec3(1.0 - clO), vec3(fTmpGamma)));
    } else
    // Highlight
    {
        fTmpGamma = pow(10.0, 0.0);
        clA = pow(clO, vec3(fTmpGamma));
    }

    vec3 hsb;
    hsb = RGB2HSL(clA);
    vec3 hsbGuass;
    // hsb adjust
    hsbGuass = hsb;

    hsb = hueAdjust(hsb, hsbGuass, -12.5, 32.5, hsl_param_0, 360.0, 0);

    hsb = hueAdjust(hsb, hsbGuass, 25.0, 35.0, hsl_param_1, 0.0, 1);

    hsb = hueAdjust(hsb, hsbGuass, 57.5, 32.5, hsl_param_2, 0.0, 2);

    hsb = hueAdjust(hsb, hsbGuass, 120.0, 70.0, hsl_param_3, 0.0, 3);

    hsb = hueAdjust(hsb, hsbGuass, 180.0, 45.0, hsl_param_4, 0.0, 4);

    hsb = hueAdjust(hsb, hsbGuass, 207.5, 62.5, hsl_param_5, 0.0, 5);

    hsb = hueAdjust(hsb, hsbGuass, 275.0, 40.0, hsl_param_6, 0.0, 6);

    hsb = hueAdjust(hsb, hsbGuass, 310.0, 55.0, hsl_param_7, 0.0, 7);

    clA = HSL2RGB(hsb);
    gl_FragColor = vec4(clA, baseColor.a);
}