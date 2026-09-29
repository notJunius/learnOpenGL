#version 460 core
out vec4 FragColor;

in vec3 our_color;
in vec2 tex_coord;

uniform sampler2D our_texture;
uniform sampler2D our_texture2;

void main()
{
    FragColor = mix(texture(our_texture, tex_coord), texture(our_texture2, tex_coord), 0.2) * vec4(our_color, 1.0);
}
