package d2424

import "../../utils"
import "core:c/libc"
import "core:fmt"
import "core:math"
import "core:mem"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:time"
import "core:unicode/utf8"
import rl "vendor:raylib"

Operation :: enum {
	NONE,
	AND,
	OR,
	XOR,
}

Gate :: struct {
	l:      string,
	r:      string,
	op:     Operation,
	output: string,
}

Node :: Gate

Input :: struct {
	n:  int,
	xy: u8,
	on: bool,
}

inputs: map[string]Input
nodes: map[string]Node

resolve_node :: proc(name: string) -> bool {
	n := nodes[name]

	switch n.op {
	case .AND:
		return resolve_node(n.l) && resolve_node(n.r)
	case .OR:
		return resolve_node(n.l) || resolve_node(n.r)
	case .XOR:
		return resolve_node(n.l) != resolve_node(n.r)
	case .NONE:
		return inputs[name].on
	}
	return false
}

solve :: proc() -> (res: uint) {
	z: [64]bool

	for k, n in nodes {
		if k[0] == 'z' {
			// fmt.printf("At k: {}\n", k)
			idx, _ := strconv.parse_int(string(k[1:]))
			visited: map[string]struct {}
			z[idx] = resolve_node(k)
			delete(visited)
		}
	}

	for v, i in z {
		n: uint = v ? 1 : 0
		res |= n << uint(i)
	}
	return res
}

swap :: proc(a, b: string) {
	temp := nodes[a]
	nodes[a] = nodes[b]
	nodes[b] = temp
}

PADDING_LEFT :: 30

find_zs :: proc(name: string) {
	if name[0] == 'z' {
		fmt.printf("\tFound: {}\n", name)
	} else {
		for k, n in nodes {
			if n.l == name {
				find_zs(n.output)
			}
			if n.r == name {
				find_zs(n.output)
			}
		}
	}
}

node_positions: map[string][2]f32
rendered_this_frame: [dynamic]string

day_2 :: proc(input: string) {
	fmt.printf("day 24/24\n")

	part_1 := 0
	part_2 := 0

	defer {
		delete(nodes)
		delete(inputs)
		delete(node_positions)
		delete(rendered_this_frame)
	}

	parts := strings.split(input, "\n\n")
	defer delete(parts)

	initial_values, _ := strings.split_lines(parts[0])
	defer delete(initial_values)

	gates_string, _ := strings.split_lines(parts[1])
	defer delete(gates_string)

	x_val: uint = 0
	y_val: uint = 0

	for l in initial_values {
		name := string(l[0:3])
		idx, _ := strconv.parse_int(string(name[1:]))
		val: bool = l[5] == '1'
		inputs[name] = {
			xy = l[0],
			n  = idx,
			on = val,
		}
		// nodes[name] = val

		if name[0] == 'x' {
			idx, _ := strconv.parse_int(string(name[1:]))
			n: uint = val ? 1 : 0
			y_val |= n << uint(idx)
		} else if name[0] == 'y' {
			idx, _ := strconv.parse_int(string(name[1:]))
			n: uint = val ? 1 : 0
			x_val |= n << uint(idx)
		}
	}

	target := x_val + y_val
	fmt.printf("Targets: {} & {} = {}\n", x_val, y_val, x_val & y_val)

	ops: [dynamic]string
	defer delete(ops)

	for l in gates_string {
		parts := strings.split(l, " ")
		defer delete(parts)
		// setup left gate
		_, l_ok := nodes[parts[0]]
		if !l_ok {
			gate: Gate
			gate.output = parts[0]
			nodes[parts[0]] = gate
		}
		_, r_ok := nodes[parts[2]]
		if !r_ok {
			gate: Gate
			gate.output = parts[2]
			nodes[parts[2]] = gate
		}
		gate: Gate
		gate.output = parts[4]
		gate.l = parts[0]
		gate.r = parts[2]
		op: Operation
		switch parts[1] {
		case "AND":
			op = .AND
		case "OR":
			op = .OR
		case "XOR":
			op = .XOR
		}
		gate.op = op
		nodes[parts[4]] = gate
		append(&ops, parts[4])
	}

	for k, v in nodes {
		fmt.printf("{} = {}\n", k, v)
	}

	fmt.printf("ops: {}\n", ops[0:8])

	part_1 = int(solve())

	chars: [2]string = {"x", "y"}
	for char in chars {
		for i in 0 ..< 2 {
			// buf: [2]u8
			key := fmt.tprintf("{}%02d", char, i)
			// n_str := strconv.itoa(buf[:], i)
			// key := strings.concatenate({char, strings.trim_null(string(buf[:]))})
			fmt.printf("Key: {}\n", key)
			find_zs(key)
		}
	}

	n := 0
	min_diff: uint = max(uint)

	rl.InitWindow(1500, 1200, "day 24 2024")
	rl.SetTargetFPS(144)

	camera: rl.Camera2D
	camera.offset = {0, 600}
	camera.rotation = 0.0
	camera.zoom = 0.8

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		rl.BeginMode2D(camera)

		camera_speed: f32 = 10 / camera.zoom
		if rl.IsKeyDown(rl.KeyboardKey.RIGHT) do camera.target += {camera_speed, 0}
		else if rl.IsKeyDown(rl.KeyboardKey.LEFT) do camera.target -= {camera_speed, 0}
		if rl.IsKeyDown(rl.KeyboardKey.UP) do camera.target -= {0, camera_speed}
		else if rl.IsKeyDown(rl.KeyboardKey.DOWN) do camera.target += {0, camera_speed}

		if rl.IsKeyDown(rl.KeyboardKey.Z) do camera.zoom *= 1.02
		else if rl.IsKeyDown(rl.KeyboardKey.X) do camera.zoom *= 0.98

		for k, v in nodes {
			if k[0] == 'y' || k[0] == 'x' {
				i, _ := strconv.parse_int(string(k[1:]))
				v := get_input_position(k[0] == 'x', i)
				c: rl.Color
				if inputs[k].on do c = rl.GREEN
				else do c = rl.RED
				r: rl.Rectangle
				r.height = 10
				r.width = 5
				r.x = v.x
				r.y = v.y
				rl.DrawRectangleRec(r, c)
			} else if k[0] == 'z' {
				// if k[1] != '0' do continue
				// if k[2] != '0' && k[2] != '1' && k[2] != '2' && k[2] != '3' && k[2] != '4' && k[2] != '5' do continue
				// render_tree_from_z(k)
			}
			render_target(x_val + y_val)
		}

		for i in 0 ..< 10 {
			render_tree_from_z(fmt.tprintf("z0{}", i))
		}
		for i in 10 ..< 46 {
			render_tree_from_z(fmt.tprintf("z{}", i))
		}
		clear(&rendered_this_frame)

		rl.EndMode2D()
		rl.DrawFPS(2, 2)
		rl.EndDrawing()
	}

	rl.CloseWindow()

	fmt.printf("p1: {}\n", part_1)
	fmt.printf("p2: {}\n", part_2)

}

get_output_position :: proc(i: int, offset: f32 = 0) -> [2]f32 {
	return {(f32(i) * 100) + PADDING_LEFT, 20 + offset}
}

get_input_position :: proc(is_x: bool, n: int) -> (v: [2]f32) {
	return {(is_x ? 5 : 0) + ((f32(n) * 25)) + PADDING_LEFT, 120 + (f32(n) * 17)}
}

render_target :: proc(target: uint) {
	for i in 0 ..< 46 {
		p := get_output_position(i, -10)
		r: rl.Rectangle
		r.height = 10
		r.width = 10
		r.x = p.x
		r.y = p.y
		if (target & (1 << uint(i))) == (1 << uint(i)) {
			rl.DrawRectangleRec(r, rl.GREEN)
		} else {
			rl.DrawRectangleRec(r, rl.RED)
		}
	}
}

render_tree_from_z :: proc(name: string) {
	i, _ := strconv.parse_int(string(name[1:]))
	p := get_output_position(i)
	r: rl.Rectangle
	r.height = 10
	r.width = 10
	r.x = p.x
	r.y = p.y
	color := resolve_node(name) ? rl.GREEN : rl.RED
	render_node(name, p + {5, 10})
	rl.DrawRectangleRec(r, color)
}

render_node :: proc(name: string, from_p: [2]f32, d: int = 1) {
	if slice.contains(rendered_this_frame[:], name) {
		node_p := node_positions[name]
		rl.DrawLineV(from_p, node_p, rl.GREEN)
	} else {
		append(&rendered_this_frame, name)
		node, ok := nodes[name]
		if ok {
			if !(name in node_positions) {
				node_positions[name] = {from_p.x, from_p.y + 5}
			}
			node_p := node_positions[name]
			rl.DrawLineV(from_p, node_p, rl.GREEN)
			color: rl.Color
			switch node.op {
			case .AND:
				color = rl.YELLOW
			case .OR:
				color = rl.BLUE
			case .XOR:
				color = rl.PURPLE
			case .NONE:
				color = rl.WHITE
			}

			if node.r[0] == 'x' || node.r[0] == 'y' {
				i, _ := strconv.parse_int(string(node.r[1:]))
				p := get_input_position(node.r[0] == 'x', i)
				rl.DrawLineV(p, node_p, rl.Color{0, 255, 255, 255})
			} else {
				r_fork := node_p + {+f32(15 / d) * 1.5, 5}
				rl.DrawLineV(r_fork, node_p, rl.GREEN)
				render_node(node.r, r_fork, d + 1)
			}

			if node.l[0] == 'x' || node.l[0] == 'y' {
				i, _ := strconv.parse_int(string(node.l[1:]))
				p := get_input_position(node.l[0] == 'x', i)
				rl.DrawLineV(p, node_p, rl.Color{0, 255, 255, 255})
			} else {
				l_fork := node_p + {-f32(15 / d) * 1.5, 5}
				rl.DrawLineV(l_fork, node_p, rl.GREEN)
				render_node(node.l, l_fork, d + 1)
			}
			// draw the dot..
			rl.DrawCircleV(node_p, 2, color)
			rl.DrawText(fmt.ctprint("{}", name), i32(node_p.x + 5), i32(node_p.y), 2, rl.WHITE)

			// FROM JUST LOOKING AT WHAT THIS ALL LOOKED LIKE
			// I GATHERED THAT THOSE ARE THE ONES:
			// z05 AND
			// z09 OR
			// css OR
			// z37 AND
			// pqt XOR PROBABLY!
			// jmv AND
			// cwt XOR PROBABLY
			// gdd XOR maybe?
		}
	}
}