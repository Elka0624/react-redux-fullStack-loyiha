local shader = [[
    precision highp float;
    precision highp int;
    attribute vec4 position;
    attribute vec2 texcoord0;
    varying vec2 uv0;
    uniform mat4 u_MVP;
    uniform int flag;
    uniform float userSX;
    uniform vec4 u_ScreenParams;
    void main()
    {
        vec4 newPos = position;
        gl_Position = u_MVP * newPos;
        if(flag == 1)
            gl_Position.x = texcoord0.x * 2.0 - 1.0;
        uv0 = texcoord0;
        uv0.y = 1.0 - uv0.y;
    }
    ]]
return shader