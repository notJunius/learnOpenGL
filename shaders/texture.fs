#version 460 core
out vec4 FragColor;

in vec2 tex_coord;

uniform sampler2D our_texture;
uniform sampler2D our_texture2;

void main()
{
    FragColor = mix(texture(our_texture, tex_coord), texture(our_texture2, vec2(tex_coord.x, tex_coord.y)), 0.2);
}
