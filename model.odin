package engine


raw_model :: struct {
	vao_id:       u32,
	vertex_count: i32,
}

init_model :: proc(vao_id: u32, vertex_count: i32) -> raw_model {
	m: raw_model
	m.vao_id = vao_id
	m.vertex_count = vertex_count
	return m
}

get_model_vao_id :: proc(m: ^raw_model) -> u32 {
	return m.vao_id
}
get_model_vertex_count :: proc(m: ^raw_model) -> i32 {
	return m.vertex_count
}
