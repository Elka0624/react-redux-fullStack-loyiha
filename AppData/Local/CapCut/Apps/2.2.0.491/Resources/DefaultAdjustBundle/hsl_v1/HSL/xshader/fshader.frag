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
    float h = 0.0, s = 0.0, l = 0.0;
    float r = rgb.r;
    float g = rgb.g;
    float b = rgb.b;
    float cmax = max(r, max(g, b));
    float cmin = min(r, min(g, b));
    float delta = cmax - cmin;
    l = (cmax + cmin) / 2.0;
    if (delta == 0.0) {
        s = 0.0;
        h = 0.0;
    } else {
        if (l <= 0.5)
            s = delta / (cmax + cmin);
        else
            s = delta / (2.0 - (cmax + cmin));
        if (cmax == r) {
            if (g >= b)
                h = 60.0 * (g - b) / delta;
            else
                h = 60.0 * (g - b) / delta + 360.0;
        } else if (cmax == g) {
            h = 60.0 * (b - r) / delta + 120.0;
        } else {
            h = 60.0 * (r - g) / delta + 240.0;
        }
    }
    return vec3(h, s, l);
}

float hueToRgb(float p, float q, float t) {
    if (t < 0.0)
        t += 1.0;
    if (t > 1.0)
        t -= 1.0;
    if (t < 1.0 / 6.0)
        return p + (q - p) * 6.0 * t;
    if (t < 1.0 / 2.0)
        return q;
    if (t < 2.0 / 3.0)
        return p + (q - p) * (2.0 / 3.0 - t) * 6.0;
    return p;
}

vec3 HSL2RGB(vec3 hsl) {
    float r, g, b;
    float h = hsl.x / 360.0;
    if (hsl.y == 0.0) {
        r = g = b = hsl.z;   // gray
    } else {
        float q = hsl.z < 0.5 ? hsl.z * (1.0 + hsl.y) : (hsl.z + hsl.y - hsl.z * hsl.y);
        float p = 2.0 * hsl.z - q;
        r = hueToRgb(p, q, h + 1.0 / 3.0);
        g = hueToRgb(p, q, h);
        b = hueToRgb(p, q, h - 1.0 / 3.0);
    }
    return vec3(r, g, b);
}

vec3 pixel_adjust(float h, float hue, float saturation, float brightness, float left_left, float left, float right, float right_right, vec3 delta_hsb) {
    if (left_left < left && left > right && right < right_right) {
        if (h >= left && h <= 360.0) {
            delta_hsb.x += hue;
            delta_hsb.y += saturation;
            delta_hsb.z += brightness;
            return delta_hsb;
        }
        if (h >= 0.0 && h <= right) {
            delta_hsb.x += hue;
            delta_hsb.y += saturation;
            delta_hsb.z += brightness;
            return delta_hsb;
        }
        if (h >= left_left && h <= left) {
            delta_hsb.x += hue * (h - left_left) / (left - left_left);
            delta_hsb.y += saturation * (h - left_left) / (left - left_left);
            delta_hsb.z += brightness * (h - left_left) / (left - left_left);
            return delta_hsb;
        }
        if (h >= right && h <= right_right) {
            delta_hsb.x += hue * (right_right - h) / (right_right - right);
            delta_hsb.y += saturation * (right_right - h) / (right_right - right);
            delta_hsb.z += brightness * (right_right - h) / (right_right - right);
            return delta_hsb;
        }
    }
    if (left_left > left && left < right && right < right_right) {
        if (h >= left && h <= right) {
            delta_hsb.x += hue;
            delta_hsb.y += saturation;
            delta_hsb.z += brightness;
            return delta_hsb;
        }
        if (h >= 0.0 && h <= left) {
            delta_hsb.x += hue * (h + 360.0 - left_left) / (left + 360.0 - left_left);
            delta_hsb.y += saturation * (h + 360.0 - left_left) / (left + 360.0 - left_left);
            delta_hsb.z += brightness * (h + 360.0 - left_left) / (left + 360.0 - left_left);
            return delta_hsb;
        }
        if (h >= left_left && h <= 360.0) {
            delta_hsb.x += hue * (h - left_left) / (left + 360.0 - left_left);
            delta_hsb.y += saturation * (h - left_left) / (left + 360.0 - left_left);
            delta_hsb.z += brightness * (h - left_left) / (left + 360.0 - left_left);
            return delta_hsb;
        }
        if (h >= right && h <= right_right) {
            delta_hsb.x += hue * (right_right - h) / (right_right - right);
            delta_hsb.y += saturation * (right_right - h) / (right_right - right);
            delta_hsb.z += brightness * (right_right - h) / (right_right - right);
            return delta_hsb;
        }
    }
    if (left_left <= left && left < right && right <= right_right) {

        if (h >= left && h <= right) {
            delta_hsb.x += hue;
            delta_hsb.y += saturation;
            delta_hsb.z += brightness;
            return delta_hsb;
        }
        if (h >= left_left && h <= left) {
            delta_hsb.x += hue * (h - left_left) / (left - left_left);
            delta_hsb.y += saturation * (h - left_left) / (left - left_left);
            delta_hsb.z += brightness * (h - left_left) / (left - left_left);
            return delta_hsb;
        }
        if (h >= right && h <= right_right) {
            delta_hsb.x += hue * (right_right - h) / (right_right - right);
            delta_hsb.y += saturation * (right_right - h) / (right_right - right);
            delta_hsb.z += brightness * (right_right - h) / (right_right - right);
            return delta_hsb;
        }
    }
    if (left_left < left && left < right && right > right_right) {
        if (h >= left && h <= right) {
            delta_hsb.x += hue;
            delta_hsb.y += saturation;
            delta_hsb.z += brightness;
            return delta_hsb;
        }
        if (h >= left_left && h <= left) {
            delta_hsb.x += hue * (h - left_left) / (left - left_left);
            delta_hsb.y += saturation * (h - left_left) / (left - left_left);
            delta_hsb.z += brightness * (h - left_left) / (left - left_left);
            return delta_hsb;
        }
        if (h >= right && h <= 360.0) {
            delta_hsb.x += hue * (right_right + 360.0 - h) / (right_right + 360.0 - right);
            delta_hsb.y += saturation * (right_right + 360.0 - h) / (right_right + 360.0 - right);
            delta_hsb.z += brightness * (right_right + 360.0 - h) / (right_right + 360.0 - right);
            return delta_hsb;
        }
        if (h >= 0.0 && h <= right_right) {
            delta_hsb.x += hue * (right_right - h) / (right_right + 360.0 - right);
            delta_hsb.y += saturation * (right_right - h) / (right_right + 360.0 - right);
            delta_hsb.z += brightness * (right_right - h) / (right_right + 360.0 - right);
            return delta_hsb;
        }
    }
    return delta_hsb;
}

void main() {
    vec3 clO;
    vec3 clA;
    vec3 RedHSL;
    vec3 OrangeHSL;
    vec3 YellowHSL;
    vec3 GreenHSL;
    vec3 CyanHSL;
    vec3 BlueHSL;
    vec3 PurpleHSL;
    vec3 MagentaHSL;

    // TODO：数值调整移动到业务层
    RedHSL = vec3(hsl_param_0.x * 0.25, hsl_param_0.y, hsl_param_0.z / 2.7);
    OrangeHSL = vec3(hsl_param_1.x * 0.15, hsl_param_1.y, hsl_param_1.z / 2.7);
    YellowHSL = vec3(hsl_param_2.x * 0.3, hsl_param_2.y, hsl_param_2.z / 2.7);
    GreenHSL = vec3(hsl_param_3.x * 0.3, hsl_param_3.y * 1.1, hsl_param_3.z / 2.7);
    CyanHSL = vec3(hsl_param_4.x * 0.4, hsl_param_4.y, hsl_param_4.z / 2.2);
    BlueHSL = vec3(hsl_param_5.x * 0.4, hsl_param_5.y * 1.2, hsl_param_5.z / 2.0);
    PurpleHSL = vec3(hsl_param_6.x * 0.4, hsl_param_6.y, hsl_param_6.z / 2.7);
    MagentaHSL = vec3(hsl_param_7.x * 0.4, hsl_param_7.y, hsl_param_7.z / 2.7);

    vec4 baseColor;
    baseColor = texture2D(inputImageTexture, uv0);
    clO = baseColor.rgb;

    vec3 hsb;
    hsb = RGB2HSL(clO);
    // adjust each channel
    vec3 delta_hsb = vec3(0.0);
    delta_hsb = pixel_adjust(hsb.x, RedHSL.x, RedHSL.y, RedHSL.z, 315.0, 330.0, 5.0, 20.0, delta_hsb);
    delta_hsb = pixel_adjust(hsb.x, OrangeHSL.x, OrangeHSL.y, OrangeHSL.z, 350.0, 20.0, 40.0, 60.0, delta_hsb);
    delta_hsb = pixel_adjust(hsb.x, YellowHSL.x, YellowHSL.y, YellowHSL.z, 25.0, 50.0, 70.0, 90.0, delta_hsb);
    delta_hsb = pixel_adjust(hsb.x, GreenHSL.x, GreenHSL.y, GreenHSL.z, 50.0, 70.0, 160.0, 190.0, delta_hsb);
    delta_hsb = pixel_adjust(hsb.x, CyanHSL.x, CyanHSL.y, CyanHSL.z, 135.0, 165., 195.0, 225.0, delta_hsb);
    delta_hsb = pixel_adjust(hsb.x, BlueHSL.x, 0.0, 0.0, 145.0, 180., 235.0, 275.0, delta_hsb);
    delta_hsb = pixel_adjust(hsb.x, 0.0, BlueHSL.y, BlueHSL.z, 145.0, 180., 235.0, 270.0, delta_hsb);
    delta_hsb = pixel_adjust(hsb.x, PurpleHSL.x, PurpleHSL.y, PurpleHSL.z, 235.0, 255.0, 315.0, 335.0, delta_hsb);
    delta_hsb = pixel_adjust(hsb.x, MagentaHSL.x, MagentaHSL.y, MagentaHSL.z, 255.0, 285.0, 335.0, 5.0, delta_hsb);

    // adjust hue
    hsb.x = hsb.x + delta_hsb.x;
    for (float j = 0.1; j >= 0.0; j += 1.0) {
        if (hsb.x > 360.0) {
            hsb.x -= 360.0;
        }
        if (hsb.x < 0.0) {
            hsb.x += 360.0;
        }
        if (hsb.x <= 360.0 && hsb.x >= 0.0)
            break;
    }

    // adjust saturation
    delta_hsb.y = clamp(delta_hsb.y / 100.0, -1.0, 1.0);
    if (delta_hsb.y < 0.0) {
        hsb.y = hsb.y * (1.0 + delta_hsb.y);
    } else {
        delta_hsb.y = delta_hsb.y / 2.0;   // TODO：移到业务层
        float temp = hsb.y * (1.0 - delta_hsb.y);
        hsb.y = hsb.y + (hsb.y - temp);
    }

    // adjust brightness
    delta_hsb.z = clamp(delta_hsb.z / 100.0, -1.0, 1.0);
    if (delta_hsb.z <= 0.0) {
        float radio = hsb.y;
        if (hsb.z >= 0.5) {
            radio = hsb.y * 1.0;
        }
        if (hsb.z < 0.5) {
            radio = hsb.y * 2.0 * hsb.z;
        }
        float temp = hsb.z - radio * (1.0 - hsb.z) * delta_hsb.z;
        hsb.z = hsb.z + (hsb.z - temp);
    } else {
        float radio = hsb.y;
        if (hsb.z >= 0.5) {
            radio = hsb.y * 1.0;
        }
        if (hsb.z < 0.5) {
            radio = hsb.y * 2.0 * hsb.z;
        }
        delta_hsb.z = (1.0 - delta_hsb.y) * delta_hsb.z;
        hsb.z = hsb.z + radio * (1.15 - hsb.z) * delta_hsb.z;
    }
    hsb.y = clamp(hsb.y, 0.0, 1.0);
    hsb.z = clamp(hsb.z, 0.0, 1.0);

    clO = HSL2RGB(hsb);
    gl_FragColor = vec4(clO, baseColor.a);
}
