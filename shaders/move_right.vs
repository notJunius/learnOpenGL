#version 460 core
layout(location = 0) in vec3 aPos;
layout(location = 1) in vec3 aColor;
out vec3 our_color;
uniform float x_adjust;
void main()
{
    gl_Position = vec4(aPos.x + x_adjust, aPos.y, aPos.z, 1.0);
    our_color = aColor;
}
