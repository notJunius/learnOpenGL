package engine

first_vertices: [9]f32 = {-.9, -.5, 0, 0, -.5, 0, -.45, .5, 0}
second_vertices: [9]f32 = {0, -.5, 0, .9, -.5, 0, .45, .5, 0}
two_triangles_vertices: [18]f32 = {
	-.9,
	-.5,
	0,
	0,
	-.5,
	0,
	-.45,
	.5,
	0, // first triangle
	0,
	-.5,
	0,
	.9,
	-.5,
	0,
	.45,
	.5,
	0, // second triangle
}
trapezoid_vertices: [12]f32 = {
	-.9,
	-.5,
	0, // bottom left
	-.45,
	.5,
	0, // top left
	.9,
	-.5,
	0, // bottom right
	.45,
	.5,
	0, // top right
}

trapezoid_indices: [6]u32 = {0, 1, 2, 1, 2, 3}

rect_vertices: [12]f32 = {
	.5,
	.5,
	0, // top right
	.5,
	-.5,
	0, // bottom right
	-.5,
	-.5,
	0, // bottom left
	-.5,
	.5,
	0, // bottom right
}

rect_indices: [6]u32 = { 	// note that we start from zero
	0,
	1,
	3, // first triangle
	1,
	2,
	3, // second triangle
}

vertex_shader_source: cstring = `
#version 460 core
layout (location = 0) in vec3 aPos;
out vec4 vertex_color;
void main()
{
	gl_Position = vec4(aPos,1.0);
	vertex_color = vec4(0.5, 0.0, 0.0, 1.0);
}
`

fragment_shader_source: cstring = `
#version 460 core
out vec4 FragColor;
in vec4 vertex_color;

void main()
{
    FragColor = vertex_color;
}
`

fragment_shader_source_yellow: cstring = `
#version 460 core
out vec4 FragColor;

void main()
{
    FragColor = vec4(1.0f, 1.0f, 0.0f, 1.0f);
}
`
