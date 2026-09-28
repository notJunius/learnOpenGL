package engine

import "base:runtime"
import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:glfw"
//import stb_i "vendor:stb/image"


// 4.1 is the latest compatible version on macos
GL_MAJOR_VERSION :: 4
GL_MINOR_VERSION :: 6


main :: proc() {
	// init glfw
	glfw.Init()
	defer glfw.Terminate()

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	// include this on macos
	//glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, glfw.TRUE)

	// create window object
	window := glfw.CreateWindow(800, 600, "opengl", nil, nil)
	if window == nil {
		fmt.println("Failed to create GLFW window")
		glfw.Terminate()
	}
	glfw.MakeContextCurrent(window)

	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)
	gl.Viewport(0, 0, 800, 600)
	glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)

	// set background color
	gl.ClearColor(.2, .3, .3, 1)

	//vbos and vaos
	vbo, vao: u32
	gl.GenVertexArrays(1, &vao)
	gl.GenBuffers(1, &vbo)
	defer gl.DeleteVertexArrays(1, &vao)
	defer gl.DeleteBuffers(1, &vbo)
	// for first triangle
	// bind the VAO first,
	gl.BindVertexArray(vao)
	//then bind and set VBO
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		size_of(hello_triangle_with_color),
		&hello_triangle_with_color,
		gl.STATIC_DRAW,
	)
	// ebo (for drawing a rectangle)
	// ebo: u32
	// gl.GenBuffers(1, &ebo)
	// gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	// gl.BufferData(
	// 	gl.ELEMENT_ARRAY_BUFFER,
	// 	size_of(trapezoid_indices),
	// 	&trapezoid_indices,
	// 	gl.STATIC_DRAW,
	// )
	//then configure vertex attributes
	// first attribute of first triangle
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 6 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 6 * size_of(f32), 3 * size_of(f32))
	gl.EnableVertexAttribArray(1)

	// uncomment this is you want to draw in wireframe polygons
	// gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)

	hello_shader := make_shader("./shaders/v_shader.vs", "./shaders/f_shader.fs")
	ud_shader := make_shader("./shaders/upside_down.vs", "./shaders/f_shader.fs")
	move_right := make_shader("./shaders/move_right.vs", "./shaders/f_shader.fs")

	// textures ------------------------------------------
	//width, height, nr_channels: i32
	////load image
	//texture_data: [^]u8 = stb_i.load("./textures/wall.jpg", &width, &height, &nr_channels, 0)
	//defer stb_i.image_free(texture_data)
	// gen texture
	//texture: u32
	//gl.GenTextures(1, &texture)
	//// bind texture
	//gl.BindTexture(gl.TEXTURE_2D, texture)
	//// gen texture from image
	//gl.TexImage2D(
	//	gl.TEXTURE_2D,
	//	0,
	//	gl.RGB,
	//	width,
	//	height,
	//	0,
	//	gl.RGB,
	//	gl.UNSIGNED_BYTE,
	//	texture_data,
	//)
	//gl.GenerateMipmap(gl.TEXTURE_2D)

	xoffset: f32 = .5


	// render loop
	for !glfw.WindowShouldClose(window) {

		//input
		process_input(window)

		// rendering commands here
		gl.Clear(gl.COLOR_BUFFER_BIT)
		// bind first triangle
		gl.BindVertexArray(vao)
		use_shader(&hello_shader)
		gl.DrawArrays(gl.TRIANGLES, 0, 3)
		use_shader(&move_right)
		set_shader_float(&move_right, "x_adjust", .5)
		gl.DrawArrays(gl.TRIANGLES, 0, 3)
		//gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)


		//check call events and swap the buffers
		glfw.PollEvents()
		glfw.SwapBuffers(window)
	}


}


// has to be a c style signature
framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
	// lets us use odin function calls withing this c function
	context = runtime.default_context()
	gl.Viewport(0, 0, width, height)
	fmt.printfln("Framebuffer resized to: %dx%d", width, height)
}

process_input :: proc(window: glfw.WindowHandle) {
	if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}
}
