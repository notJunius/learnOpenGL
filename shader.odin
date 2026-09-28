package engine

import "core:fmt"
import "core:os"
import "core:strings"
import gl "vendor:OpenGL"

Shader :: struct {
	id: u32,
}

make_shader :: proc(vertex_path, fragment_path: string) -> Shader {
	// 1. reading from a file baby
	// saving data to variable, and checking to make sure it worked
	v_shader_data, v_err := os.read_entire_file_from_path(vertex_path, context.allocator)
	if v_err != nil {
		fmt.eprintln("ERROR::SHADER::FILE_NOT_SUCCESSFULLY_READ:", vertex_path)
	}
	defer delete(v_shader_data)
	f_shader_data, f_err := os.read_entire_file_from_path(fragment_path, context.allocator)
	if f_err != nil {
		fmt.eprintln("ERROR::SHADER::FILE_NOT_SUCCESSFULLY_READ:", fragment_path)
	}
	defer delete(f_shader_data)

	// converting strings to c_strings
	v_shader_code := strings.clone_to_cstring(string(v_shader_data), context.allocator)
	f_shader_code := strings.clone_to_cstring(string(f_shader_data), context.allocator)

	// 2. compile shaders
	vertex, fragment: u32
	success: i32
	info_log: [512]u8
	// vertex shader ------------------------------
	vertex = gl.CreateShader(gl.VERTEX_SHADER)
	defer gl.DeleteShader(vertex)
	gl.ShaderSource(vertex, 1, &v_shader_code, nil)
	gl.CompileShader(vertex)
	// print compile errors if any
	gl.GetShaderiv(vertex, gl.COMPILE_STATUS, &success)
	if success == 0 {
		gl.GetShaderInfoLog(vertex, 512, nil, &info_log[0])
		fmt.eprintln("ERROR::SHADER::VERTEX::COMPILATION_FAILED", info_log)
	}
	// fragment shader --------------------------------------
	fragment = gl.CreateShader(gl.FRAGMENT_SHADER)
	defer gl.DeleteShader(fragment)
	gl.ShaderSource(fragment, 1, &f_shader_code, nil)
	gl.CompileShader(fragment)
	// print compile errors if any
	gl.GetShaderiv(fragment, gl.COMPILE_STATUS, &success)
	if success == 0 {
		gl.GetShaderInfoLog(fragment, 512, nil, &info_log[0])
		fmt.eprintln("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED", info_log)
	}
	// shader program ------------------------------------------
	id := gl.CreateProgram()
	gl.AttachShader(id, vertex)
	gl.AttachShader(id, fragment)
	gl.LinkProgram(id)
	// print linking errors if any
	gl.GetProgramiv(id, gl.LINK_STATUS, &success)
	if success == 0 {
		gl.GetProgramInfoLog(id, 512, nil, &info_log[0])
		fmt.eprintln("ERROR::SHADER::PROGRAM::LINKING_FAILED", info_log)
	}


	return Shader{id = id}


}

destroy_shader :: proc(shader: ^Shader)

use_shader :: proc(shader: ^Shader) {
	gl.UseProgram(shader.id)
}


set_shader_bool :: proc(shader: ^Shader, name: string, value: bool) {
	gl.Uniform1i(gl.GetUniformLocation(shader.id, strings.clone_to_cstring(name)), i32(value))
}
set_shader_int :: proc(shader: ^Shader, name: string, value: i32) {
	gl.Uniform1i(gl.GetUniformLocation(shader.id, strings.clone_to_cstring(name)), value)
}
set_shader_float :: proc(shader: ^Shader, name: string, value: f32) {
	gl.Uniform1f(gl.GetUniformLocation(shader.id, strings.clone_to_cstring(name)), value)
}
