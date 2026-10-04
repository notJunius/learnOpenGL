package engine

import "base:runtime"
import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/linalg/glsl"
import "core:strings"
import gl "vendor:OpenGL"
import "vendor:glfw"
import stb_i "vendor:stb/image"


// 4.1 is the latest compatible version on macos
GL_MAJOR_VERSION :: 4
GL_MINOR_VERSION :: 6


// globals
screen_height :: 600
screen_width :: 800

last_x: f64 = screen_width / 2
last_y: f64 = screen_height / 2
first_mouse := true

visibility: f32 = .2


// calculating delta time
delta_time: f32 = 0
last_frame: f32 = 0
current_frame: f32

camera: Camera


main :: proc() {

	// camera
	camera = init_camera_vec({0, 0, 3})


	// init glfw
	glfw.Init()
	defer glfw.Terminate()

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	// include this on macos
	//glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, glfw.TRUE)

	// create window object
	window := glfw.CreateWindow(screen_width, screen_height, "opengl", nil, nil)
	if window == nil {
		fmt.println("Failed to create GLFW window")
		glfw.Terminate()
	}
	glfw.MakeContextCurrent(window)

	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)
	gl.Viewport(0, 0, 800, 600)
	glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)

	glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
	glfw.SetCursorPosCallback(window, mouse_callback)
	glfw.SetScrollCallback(window, scroll_callback)


	hello_shader := make_shader("./shaders/v_shader.vs", "./shaders/f_shader.fs")
	ud_shader := make_shader("./shaders/upside_down.vs", "./shaders/f_shader.fs")
	move_right := make_shader("./shaders/move_right.vs", "./shaders/f_shader.fs")
	texture_shader := make_shader("./shaders/texture.vs", "./shaders/texture.fs")
	transform_shader := make_shader("./shaders/transform.vs", "./shaders/texture.fs")


	// textures ------------------------------------------
	// gen texture
	texture: u32
	gl.GenTextures(1, &texture)
	// bind texture
	gl.BindTexture(gl.TEXTURE_2D, texture)
	// set wrapping/filtering options
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
	// define values for image load function
	width, height, nr_channels: i32
	//load image
	texture_data: [^]u8 = stb_i.load(
		strings.clone_to_cstring("./textures/wall.jpg"),
		&width,
		&height,
		&nr_channels,
		0,
	)
	defer stb_i.image_free(texture_data)
	// check if image loaded
	if texture_data != nil {
		// gen texture from image
		// because the texture declared earlier was bound, the function
		// is going to put this image into that texture
		gl.TexImage2D(
			gl.TEXTURE_2D,
			0,
			gl.RGB,
			width,
			height,
			0, // always zero, (legacy stuff)
			gl.RGB,
			gl.UNSIGNED_BYTE,
			texture_data,
		)
		gl.GenerateMipmap(gl.TEXTURE_2D)
	} else {
		fmt.println("Failed to load texture")
	}
	// gen texture
	texture2: u32
	gl.GenTextures(1, &texture2)
	// bind texture
	gl.BindTexture(gl.TEXTURE_2D, texture2)
	// set wrapping/filtering options
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
	//load image
	// flip image before loading
	stb_i.set_flip_vertically_on_load(1)
	texture_data = stb_i.load(
		strings.clone_to_cstring("./textures/awesomeface.png"),
		&width,
		&height,
		&nr_channels,
		0,
	)
	// check if image loaded
	if texture_data != nil {
		// gen texture from image
		// because the texture declared earlier was bound, the function
		// is going to put this image into that texture
		gl.TexImage2D(
			gl.TEXTURE_2D,
			0,
			gl.RGB,
			width,
			height,
			0, // always zero, (legacy stuff)
			gl.RGBA,
			gl.UNSIGNED_BYTE,
			texture_data,
		)
		gl.GenerateMipmap(gl.TEXTURE_2D)
	} else {
		fmt.println("Failed to load texture")
	}
	use_shader(&transform_shader)
	set_shader_int(&transform_shader, "our_texture", 0)
	set_shader_int(&transform_shader, "our_texture2", 1)

	two_triangles := load_to_vao(two_triangles_vertices[:])
	first := load_to_vao(first_vertices[:])
	second := load_to_vao(second_vertices[:])
	models := [2]^raw_model{&first, &second}

	// render loop
	for !glfw.WindowShouldClose(window) {

		// get dt
		current_frame = f32(glfw.GetTime())
		delta_time = current_frame - last_frame
		last_frame = current_frame

		//input
		process_input(&camera, window, delta_time)

		prepare()

		use_shader(&hello_shader)
		for model in models {
			render(model)
		}


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

process_input :: proc(c: ^Camera, window: glfw.WindowHandle, dt: f32) {
	if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}
	CAMERA_SPEED: f32 = 3 * dt
	if glfw.GetKey(window, glfw.KEY_W) == glfw.PRESS {
		process_keyboard(c, .FORWARD, dt)
	}
	if glfw.GetKey(window, glfw.KEY_S) == glfw.PRESS {
		process_keyboard(c, .BACKWARD, dt)
	}
	if glfw.GetKey(window, glfw.KEY_A) == glfw.PRESS {
		process_keyboard(c, .LEFT, dt)
	}
	if glfw.GetKey(window, glfw.KEY_D) == glfw.PRESS {
		process_keyboard(c, .RIGHT, dt)
	}
}


mouse_callback :: proc "c" (window: glfw.WindowHandle, x_pos, y_pos: f64) {
	context = runtime.default_context()

	if first_mouse {
		last_x = x_pos
		last_y = y_pos
		first_mouse = false
	}


	x_offset := x_pos - last_x
	y_offset := last_y - y_pos
	last_x = x_pos
	last_y = y_pos

	process_mouse_movement(&camera, f32(x_offset), f32(y_offset))


}


scroll_callback :: proc "c" (window: glfw.WindowHandle, x_offset, y_offset: f64) {
	context = runtime.default_context()
	process_mouse_scroll(&camera, f32(y_offset))
}
