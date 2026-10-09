package engine
import "core:fmt"
import "core:strings"
import gl "vendor:OpenGL"
import "vendor:stb/image"

vaos: [dynamic]u32
vbos: [dynamic]u32
textures: [dynamic]u32


load_to_vao :: proc(positions: []f32) -> raw_model {
	m: raw_model
	vao_id := create_vao()
	store_data_in_attribute_list(0, positions)
	unbind_vao()
	m.vao_id = vao_id
	m.vertex_count = i32(len(positions) / 3)
	return m
}
create_vao :: proc() -> u32 {
	vao_id: u32
	gl.GenVertexArrays(1, &vao_id)
	append(&vaos, vao_id)
	gl.BindVertexArray(vao_id)
	return vao_id
}

load_texture :: proc(file_name: string) -> u32 {
	texture: u32
	gl.GenTextures(1, &texture)
	gl.BindTexture(gl.TEXTURE_2D, texture)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
	width, height, nr_channels: i32
	texture_data: [^]u8 = image.load(
		strings.clone_to_cstring(file_name),
		&width,
		&height,
		&nr_channels,
		0,
	)
	defer image.image_free(texture_data)
	if texture_data != nil {
		gl.TexImage2D(
			gl.TEXTURE_2D,
			0,
			gl.RGBA,
			width,
			height,
			0,
			gl.RGBA,
			gl.UNSIGNED_BYTE,
			texture_data,
		)
		gl.GenerateMipmap(gl.TEXTURE_2D)
	} else {
		fmt.println("Failed to load texture")
	}
	return texture
}

store_data_in_attribute_list :: proc(attribute_number: u32, data: []f32) {
	vbo_id: u32
	gl.GenBuffers(1, &vbo_id)
	append(&vbos, vbo_id)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo_id)
	// we are using a slice rather than a fixed array, which is why this is gonna look different from what you are used to
	gl.BufferData(gl.ARRAY_BUFFER, size_of(f32) * len(data), raw_data(data), gl.STATIC_DRAW)
	gl.VertexAttribPointer(attribute_number, 3, gl.FLOAT, false, 0, 0)
	unbind_vbo()
}

// unbinds vao by binding it to 0
unbind_vao :: proc() {
	gl.BindVertexArray(0)
}

// unbinds vbo by binding it to 0
unbind_vbo :: proc() {
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
}


// deletes all vaos and vbos from memory
clean_up :: proc() {
	if len(vaos) > 0 {
		gl.DeleteVertexArrays(i32(len(vaos)), raw_data(vaos))
		delete(vaos)
	}
	if len(vbos) > 0 {
		gl.DeleteBuffers(i32(len(vbos)), raw_data(vbos))
		delete(vbos)
	}
}
