precision highp float;
varying vec2 uv0;

const float PI = 3.1415926535;
const float SQ3 = 1.73205;

uniform sampler2D inputImageTexture;

uniform vec4 selectedColour;
uniform float inputIntensity;
uniform float inputShadow;
uniform float it;           // converted inputIntensity
uniform float sh;           // converted inputShadow

// uniform float ColorStrength;
// uniform int blendMode;
// uniform float opacity;

/////////////////////////////////

const mat3 rgb2yuv_mat = mat3(
	0.299, -0.147, 0.615, 
    0.587,  -0.289, -0.515, 
	0.114,  0.436, -0.100
);
const mat3 yuv2rgb_mat = mat3(
	1.0, 1.0, 1.0,
	0.0, -0.39, 2.03,
	1.14, -0.58, 0.0
);

vec3 yuv2rgb(vec3 c) {
    return yuv2rgb_mat * c;
}
vec3 rgb2yuv(vec3 c) {
    return rgb2yuv_mat * c;
}

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 hsv2xyz(vec3 hsv) {        //  柱体
    float z = hsv.z;
    float hsvy = hsv.y;
    // float hsvy = pow(hsv.y, 0.5);
    float x = cos(hsv.x * 2.0 * PI) * hsvy;
    float y = sin(hsv.x * 2.0 * PI) * hsvy;
    return vec3(x,y,z);
}

const float height = SQ3 / 3.0;
vec3 hsv2xyz2(vec3 hsv) {       //  锥体
    float z = hsv.z * height;
    float x = cos(hsv.x * 2.0 * PI) * hsv.y * hsv.z;
    float y = sin(hsv.x * 2.0 * PI) * hsv.y * hsv.z;
    return vec3(x,y,z);
}

float pure(vec3 rgb) {
    float maxx = max(max(rgb.r, rgb.g), rgb.b);
    float minn = min(min(rgb.r, rgb.g), rgb.b);
    float midd = rgb.r + rgb.g + rgb.b - maxx - minn;
    return maxx - midd;
}
float softEdge(float factor, float diff, float intensity) {
    return min(exp(factor * (diff - intensity)), 1.0);
}

float logistic(float x0, float xOffset, float xScale) {
    float x = (x0 - xOffset) * xScale;
    return 1.0 / (1.0 + exp(-x));
}
void main() {
    const float EPS = 0.001;
    vec4 rgba = texture2D(inputImageTexture, uv0);
    float  alpha = rgba.a;
    if (inputIntensity < EPS) {
        gl_FragColor = rgba;
    }
    else {
        vec3 hsv = rgb2hsv(rgba.rgb);
        vec3 hsv0 = rgb2hsv(selectedColour.rgb);

        //float it = pow(inputIntensity, 0.25);    //  inputIntensity是在[0,1]范围内，用幂函数变换一下

        vec3 xyz0 = hsv2xyz(hsv0);
        float intensity = it * (length(xyz0.xy) + 0.4);
        intensity -= 0.8 * pure(selectedColour.rgb);

        float dis1 = length(hsv2xyz(hsv).xy - xyz0.xy);
        float factor1 = softEdge(40.0, dis1, intensity);
        rgba *= factor1;

        if (factor1 < 1.0 - EPS && inputShadow > EPS) {

            float dis2 = length(hsv2xyz2(hsv) - vec3(0.0, 0.0, SQ3 * 1.33333333));
            float shadow = mix(SQ3 * 1.33333333, 2.0, sh);
            // float shadow = mix(SQ3 * 1.33333333, 2.0, logistic(inputShadow, 0.3, 4.0));
            float factor2 = softEdge(30.0, shadow, dis2);
            rgba = mix(vec4(0.0,0.0,0.0,1.0), rgba, factor2);
        }
        gl_FragColor = rgba;
        gl_FragColor.a *= alpha;
    }
}