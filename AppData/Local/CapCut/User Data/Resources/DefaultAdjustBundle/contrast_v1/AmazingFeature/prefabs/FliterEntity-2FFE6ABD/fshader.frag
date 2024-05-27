precision highp float;
varying highp vec2 uv0;
uniform sampler2D inputImageTexture;
uniform float center;
uniform float saturation;
uniform float sParamR;
uniform float sParamG;
uniform float sParamB;
uniform float rParamR;
uniform float rParamG;
uniform float rParamB;

// vec4 correctorPreLUTKernel(sampler2D input, vec2 uv)
// {
//     vec4 color = texture2D(input, uv);
//     color.a = 0.0;
//     color.a = dot(color.rgb, grayFactor);

//     color.r = texture2D(colorSpine, vec2(color.r, 0.5));
//     color.g = texture2D(colorSpine, vec2(color.g, 0.5));
//     color.b = texture2D(colorSpine, vec2(color.b, 0.5));
//     color.a = texture2D(colorSpine, vec2(color.a, 0.5));

// }

float getColorSpine(float saturation, float x)
{
    float saturation_tmp = saturation - 1.0;
    vec2 p[7];
    float z = saturation_tmp * saturation_tmp;
    float b = saturation_tmp;
    p[0] = vec2(0, 0);
    p[1] = vec2(0.375 * center * (1.0 - z) + 0.75 * center * z, 0.375 * center * (1.0 - b));
    p[2] = vec2(0.625 * center * (1.0 - z) + z * center, 0.625 * center * (1.0 - b) + 0.25 * center * b);
    p[3] = vec2(center, center);
    p[4] = vec2((1.0 - p[2].x / center * (1.0 - center)), (1.0 - p[2].y / center * (1.0 - center)));
    p[5] = vec2((1.0 - p[1].x / center * (1.0 - center)), (1.0 - p[1].y / center * (1.0 - center)));
    p[6] = vec2(1.0, 1.0);

    float result = 0.0;
    if (x <= p[1].x)
    {
        result = mix(p[0].y, p[1].y, (x - p[0].x) / (p[1].x - p[0].x));
    }
    else if (x <= p[2].x)
    {
        result = mix(p[1].y, p[2].y, (x - p[1].x) / (p[2].x - p[1].x));
    }
    else if (x <= p[3].x)
    {
        result = mix(p[2].y, p[3].y, (x - p[2].x) / (p[3].x - p[2].x));
    }
    else if (x <= p[4].x)
    {
        result = mix(p[3].y, p[4].y, (x - p[3].x) / (p[4].x - p[3].x));
    }
    else if (x <= p[5].x)
    {
        result = mix(p[4].y, p[5].y, (x - p[4].x) / (p[5].x - p[4].x));
    }
    else if (x <= p[6].x)
    {
        result = mix(p[5].y, p[6].y, (x - p[5].x) / (p[6].x - p[5].x));
    }
    return result;
}

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 rgb2hsl(vec3 c) {
    float h = 0.0;
    float s = 0.0;
    float l = 0.0;
    float r = c.r;
    float g = c.g;
    float b = c.b;
    float cMin = min(r, min(g, b));
    float cMax = max(r, max(g, b));
    l = (cMax + cMin) / 2.0;
    if (cMax > cMin) {
        float cDelta = cMax - cMin;
        s = l < .5 ? cDelta / (cMax + cMin) : cDelta / (2.0 - (cMax + cMin));
        if (r == cMax) {
            h = (g - b) / cDelta;
        } else if (g == cMax) {
            h = 2.0 + (b - r) / cDelta;
        } else {
            h = 4.0 + (r - g) / cDelta;
        }
        if (h < 0.0) {
            h += 6.0;
        }
        h = h / 6.0;
    }
    return vec3(h, s, l);
}
vec3 hsl2rgb(in vec3 c) {
    vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    return c.z + c.y * (rgb - 0.5) * (1.0 - abs(2.0 * c.z - 1.0));
}

mat4 saturationMatrix(float saturation)
{
    vec3 luminance = vec3(0.3086, 0.6094, 0.0820);

    float oneMinusSat = 1.0 - saturation;

    vec3 red = vec3(luminance.x * oneMinusSat);
    red += vec3(saturation, 0, 0);

    vec3 green = vec3(luminance.y * oneMinusSat);
    green += vec3(0, saturation, 0);

    vec3 blue = vec3(luminance.z * oneMinusSat);
    blue += vec3(0, 0, saturation);

    return mat4(red, 0,
        green, 0,
        blue, 0,
        0, 0, 0, 1);
}

vec3 Unity_Saturation_float(vec3 In, float Saturation)
{
    vec3 Out = vec3(0);
    float luma = dot(In, vec3(0.2126729, 0.7151522, 0.0721750));
    Out = luma + Saturation * (In - luma);
    return Out;
}

mat4 contrastMatrix(float contrast, float center)
{
    float t = (1.0 - contrast) * center;

    return mat4(contrast, 0, 0, 0,
        0, contrast, 0, 0,
        0, 0, contrast, 0,
        t, t, t, 1);
}

vec3 Unity_Contrast_float(vec3 In, float Contrast)
{
    vec3 Out;
    float midpoint = 0.435;
    Out = (In - midpoint) * Contrast + midpoint;
    return Out;
}

float GetGray(vec4 inColor)
{
    return dot(inColor, vec4(0.299, 0.587, 0.114, 1.0));
}

vec4 GetContrast(vec4 inColor, float _Contrast)
{
    return (inColor + (GetGray(inColor) - 0.5) * _Contrast);
}

void main()
{
    if (saturation <= 1.0)
    {
        vec4 color = texture2D(inputImageTexture, uv0);
        gl_FragColor = contrastMatrix(saturation, center) * color;

        // vec4 newColor = (color - center) * saturation + center;
        // vec3 grayFactor = vec3(0.2126, 0.7152, 0.0722);
        // float gray = dot(color.rgb, grayFactor);
        // gl_FragColor = mix(newColor, color, gray);

        // gl_FragColor.rgb = Unity_Contrast_float(color.rgb,saturation);
        // gl_FragColor.a = 1.0;

        // gl_FragColor = GetContrast(color,saturation);
    }
    else if (saturation <= 2.0)
    {
        float saturation_tmp = saturation - 1.0;
        // vec2 p[7];
        // float z = saturation_tmp * saturation_tmp;
        // float b = saturation_tmp;
        // p[0] = vec2(0, 0);
        // p[1] = vec2(0.375 * center * (1.0 - z) + 0.75 * center * z, 0.375 * center * (1.0 - b));
        // p[2] = vec2(0.625 * center * (1.0 - z) + z * center, 0.625 * center * (1.0 - b) + 0.25 * center * b);
        // p[3] = vec2(center, center);
        // p[4] = vec2((1.0 - p[2].x / center * (1.0 - center)), (1.0 - p[2].y / center * (1.0 - center)));
        // p[5] = vec2((1.0 - p[1].x / center * (1.0 - center)), (1.0 - p[1].y / center * (1.0 - center)));
        // p[6] = vec2(1.0, 1.0);

        // vec3 grayFactor = vec3(0.2126, 0.7152, 0.0722);
        // vec4 color = texture2D(inputImageTexture, uv0);
        // color.a = 0.0;
        // color.a = dot(color.rgb, grayFactor);

        // color.r = texture2D(colorSpine, vec2(color.r, 0.5));
        // color.g = texture2D(colorSpine, vec2(color.g, 0.5));
        // color.b = texture2D(colorSpine, vec2(color.b, 0.5));
        // color.a = texture2D(colorSpine, vec2(color.a, 0.5));
        // color.r = getColorSpine(saturation, color.r);
        // color.g = getColorSpine(saturation, color.g);
        // color.b = getColorSpine(saturation, color.b);
        // color.a = getColorSpine(saturation, color.a);
        vec4 color = texture2D(inputImageTexture, uv0);
        // color = clamp(contrastMatrix(saturation, center) * color,0.0,1.0);
        color = clamp(mix(vec4(center), color, saturation), 0.0, 1.0);

        vec3 hsv = rgb2hsl(color.rgb);
        float tmp = hsv.g;
        hsv.g = tmp * (1.0 - saturation_tmp * sParamR);
        color.r = hsl2rgb(hsv).r;
        // color.r = 0.0;

        hsv.g = tmp * (1.0 - saturation_tmp * sParamG);
        color.g = hsl2rgb(hsv).g;
        // color.g = 0.0;

        hsv.g = tmp * (1.0 - saturation_tmp * sParamB);
        color.b = hsl2rgb(hsv).b;
        // color.b = 0.0;

        color.r = color.r * (1.0 - saturation_tmp * rParamR);
        color.g = color.g * (1.0 - saturation_tmp * rParamG);
        color.b = color.b * (1.0 - saturation_tmp * rParamB);

        gl_FragColor = color;
    }
}
