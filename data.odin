package engine

first_vertices: [9]f32 = {-.9, -.5, 0, 0, -.5, 0, -.45, .5, 0}
second_vertices: [9]f32 = {0, -.5, 0, .9, -.5, 0, .45, .5, 0}


hello_triangle_with_color: [18]f32 = {.5, -.5, 0, 1, 0, 0, -.5, -.5, 0, 0, 1, 0, 0, .5, 0, 0, 0, 1}
triangle_tex_coords: [6]f32 = {0, 0, 1, 0, .5, 1}

// fmt: off
first_vertices_with_color: [18]f32 = {
	-.9,
	-.5,
	0, // vertex
	1,
	0,
	0, // rgb value (red)
	0,
	-.5,
	0, // vertex
	0,
	1,
	0, // rgb value (green)
	-.45,
	.5,
	0, // vertex
	0,
	0,
	1, // rgb value (blue)
}
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
rect_vertices_with_color_and_texture: [32]f32 = {
	.5,
	.5,
	0,
	1,
	0,
	0,
	1,
	1, // top right
	.5,
	-.5,
	0,
	0,
	1,
	0,
	1,
	0, // bottom right
	-.5,
	-.5,
	0,
	0,
	0,
	1,
	0,
	0, // bottom left
	-.5,
	.5,
	0,
	1,
	1,
	0,
	0,
	1, // bottom right
}

rect_indices: [6]u32 = { 	// note that we start from zero
	0,
	1,
	3, // first triangle
	1,
	2,
	3, // second triangle
}
