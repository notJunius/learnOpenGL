package engine

import gl "vendor:OpenGL"

prepare :: proc() {
	gl.ClearColor(.2, .3, .3, 1)
	gl.Clear(gl.COLOR_BUFFER_BIT)
}

render :: proc(m: ^raw_model) {
	gl.BindVertexArray(get_model_vao_id(m))
	gl.EnableVertexAttribArray(0)
	gl.DrawArrays(gl.TRIANGLES, 0, get_model_vertex_count(m))
	gl.DisableVertexAttribArray(0)
	gl.BindVertexArray(0)
}
