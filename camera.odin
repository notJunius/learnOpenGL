package engine

import "core:math/linalg"
import "core:math/linalg/glsl"
CAMERA_MOVEMENT :: enum {
	FORWARD,
	BACKWARD,
	LEFT,
	RIGHT,
}


YAW: f32 : -90
PITCH: f32 : 0
SPEED: f32 : 2.5
SENSITIVITY: f32 : .1
ZOOM: f32 : 45


Camera :: struct {
	// camera attributes
	position:          [3]f32,
	front:             [3]f32,
	up:                [3]f32,
	right:             [3]f32,
	world_up:          [3]f32,
	// euler angles
	yaw:               f32,
	pitch:             f32,
	// camera options
	movement_speed:    f32,
	mouse_sensitivity: f32,
	zoom:              f32,
}


// init function with vectors
init_camera_vec :: proc(
	pos: [3]f32 = {0, 0, 0},
	up: [3]f32 = {0, 1, 0},
	yaw: f32 = YAW,
	pitch: f32 = PITCH,
) -> Camera {
	c: Camera
	c.position = pos
	c.world_up = up
	c.yaw = yaw
	c.pitch = pitch
	c.movement_speed = SPEED
	c.mouse_sensitivity = SENSITIVITY
	c.zoom = ZOOM
	// compute initial front, right, and up vectors
	update_camera_vectors(&c)
	return c
}

get_view_matrix :: proc(c: ^Camera) -> glsl.mat4 {
	return linalg.matrix4_look_at(c.position, c.position + c.front, c.up)
}

process_keyboard :: proc(c: ^Camera, direction: CAMERA_MOVEMENT, dt: f32) {
	velocity: f32 = c.movement_speed * dt
	if direction == .FORWARD {
		c.position += c.front * velocity
	}
	if direction == .BACKWARD {
		c.position -= c.front * velocity
	}
	if direction == .LEFT {
		c.position -= c.right * velocity
	}
	if direction == .RIGHT {
		c.position += c.right * velocity
	}
}

process_mouse_movement :: proc(c: ^Camera, x_offset, y_offset: f32, constrain_pitch := true) {
	x_offset := x_offset
	y_offset := y_offset
	x_offset *= c.mouse_sensitivity
	y_offset *= c.mouse_sensitivity

	c.yaw += x_offset
	c.pitch += y_offset

	// make sure that when pitch is out of bounds, screen doesn't get flipped
	if constrain_pitch {
		if c.pitch > 89 {
			c.pitch = 89
		}
		if c.pitch < -89 {
			c.pitch = -89
		}
	}
	// update front, right, and up vectors using the updated euler angles
	update_camera_vectors(c)
}

process_mouse_scroll :: proc(c: ^Camera, y_offset: f32) {
	c.zoom -= y_offset
	if c.zoom < 1 {
		c.zoom = 1
	}
	if c.zoom > 45 {
		c.zoom = 45
	}
}


update_camera_vectors :: proc(c: ^Camera) {
	front: [3]f32
	front.x = linalg.cos(linalg.to_radians(c.yaw)) * linalg.cos(linalg.to_radians(c.pitch))
	front.y = linalg.sin(linalg.to_radians(c.pitch))
	front.z = linalg.sin(linalg.to_radians(c.yaw)) * linalg.cos(linalg.to_radians(c.pitch))
	c.front = linalg.normalize(front)
	// also re-calculate the Right and Up vector
	c.right = linalg.normalize(linalg.cross(c.front, c.world_up))
	c.up = linalg.normalize(linalg.cross(c.right, c.front))
}
