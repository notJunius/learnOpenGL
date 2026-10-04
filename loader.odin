package engine
import gl "vendor:OpenGL"

vaos: [dynamic]u32
vbos: [dynamic]u32


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
