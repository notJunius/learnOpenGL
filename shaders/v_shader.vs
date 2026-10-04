#version 460 core
layout(location = 0) in vec3 aPos;
out vec3 our_color;
void main()
{
    gl_Position = vec4(aPos, 1.0);
    our_color = aPos;
}
