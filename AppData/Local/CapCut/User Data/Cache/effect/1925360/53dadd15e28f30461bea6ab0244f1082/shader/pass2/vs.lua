local shader = [[
attribute vec4 position;
attribute vec2 texcoord0;
varying vec2 uv0;

void main()
{
    gl_Position = vec4(texcoord0 * 2.0 - 1.0, 0.0, 1.0);
    gl_Position.z = 0.;
    uv0 = texcoord0;
}
]]
return shader