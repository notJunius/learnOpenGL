package engine

import "base:runtime"
import "core:fmt"
import "core:math"
import gl "vendor:OpenGL"
import "vendor:glfw"


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

	//shaders
	vertex_shader: u32 = gl.CreateShader(gl.VERTEX_SHADER)
	gl.ShaderSource(vertex_shader, 1, &vertex_shader_source, nil)
	gl.CompileShader(vertex_shader)

	fragment_shader: u32 = gl.CreateShader(gl.FRAGMENT_SHADER)
	gl.ShaderSource(fragment_shader, 1, &fragment_shader_source, nil)
	gl.CompileShader(fragment_shader)

	yellow_shader: u32 = gl.CreateShader(gl.FRAGMENT_SHADER)
	gl.ShaderSource(yellow_shader, 1, &fragment_shader_source_yellow, nil)
	gl.CompileShader(yellow_shader)

	// put both the vertex and fragment shaders into a program
	shader_program: u32 = gl.CreateProgram()
	gl.AttachShader(shader_program, vertex_shader)
	gl.AttachShader(shader_program, fragment_shader)
	gl.LinkProgram(shader_program)
	gl.DeleteShader(fragment_shader)

	yellow_program: u32 = gl.CreateProgram()
	gl.AttachShader(yellow_program, vertex_shader)
	gl.AttachShader(yellow_program, yellow_shader)
	gl.LinkProgram(yellow_program)
	gl.DeleteShader(vertex_shader)
	gl.DeleteShader(yellow_shader)


	//vbos and vaos
	vbo, vao: [2]u32
	gl.GenVertexArrays(2, &vao[0])
	gl.GenBuffers(2, &vbo[0])
	defer gl.DeleteVertexArrays(2, &vao[0])
	defer gl.DeleteBuffers(2, &vbo[0])
	defer gl.DeleteProgram(shader_program)
	// for first triangle
	// bind the VAO first,
	gl.BindVertexArray(vao[0])
	//then bind and set VBO
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo[0])
	gl.BufferData(gl.ARRAY_BUFFER, size_of(first_vertices), &first_vertices, gl.STATIC_DRAW)
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
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)
	// second triangle
	// bind the second VAO
	gl.BindVertexArray(vao[1])
	// bind and set the second VBO
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo[1])
	gl.BufferData(gl.ARRAY_BUFFER, size_of(second_vertices), &second_vertices, gl.STATIC_DRAW)
	// configure second vertex attributes
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)


	// uncomment this is you want to draw in wireframe polygons
	// gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)


	// render loop
	for !glfw.WindowShouldClose(window) {

		//input
		process_input(window)

		// update values
		time_value := glfw.GetTime()
		green_value: f32 = math.sin(f32(time_value) / 2) + .5
		// set uniform value to a variable
		vertex_color_location := gl.GetUniformLocation(shader_program, "our_color")

		// rendering commands here
		gl.Clear(gl.COLOR_BUFFER_BIT)
		// program you want to use
		gl.UseProgram(shader_program)
		// begin changing values in shader
		// the uniform 4f means the first parameter has 4 float values
		// so in this case, vertex_color_location is a vec4, and the next 4
		// values, are the vec4 color values -> vec4(0, green_value, 0, 1)
		// so if you change the first zero or second zero, you are changing
		// the red and blue value respectively, and the last value is the opacity
		gl.Uniform4f(vertex_color_location, 0, green_value, 0, 1)
		// data you want to draw
		// bind first triangle
		gl.BindVertexArray(vao[0])
		gl.DrawArrays(gl.TRIANGLES, 0, 3)
		//gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)
		// bind second triangle
		//gl.UseProgram(yellow_program)
		gl.BindVertexArray(vao[1])
		gl.DrawArrays(gl.TRIANGLES, 0, 3)


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
