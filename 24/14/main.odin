package d2414

import "../../utils"
import "core:c/libc"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:time"
import "core:unicode/utf8"

Robot :: struct {
	p: [2]int,
	v: [2]int,
}

W :: 101
H :: 103

find_tree_pattern :: proc(robots: []Robot) -> bool {
	canvas: [H][W]u8 = {}
	added_in_rows : [H]u8

	for r in robots {
		canvas[r.p.y][r.p.x] = '#'
		added_in_rows[r.p.y] += 1
	}

	// let's just find a long row of robots!
	return find_pattern_in_canvas({'#', '#', '#', '#', '#', '#', '#'}, &canvas, &added_in_rows)
}

find_pattern_in_canvas :: proc(pattern: []u8, canvas: ^[H][W]u8, added_in_rows: ^[H]u8) -> bool {
	l := len(pattern)
	row_len := len(canvas[0])
	for &row, y in canvas {
		// let's only check lines with at least 20 robots (for perf...) SILLY
		if added_in_rows[y] < 20 do continue
		for _, x in row {
			if x + l > row_len do continue
			if slice.equal(row[x:x + l][:], pattern[:]) do return true
		}

	}
	return false
}

day :: proc(input: string) {
	fmt.printf("day 24/14\n")

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	part_1 := 0
	part_2 := 0

	robots: [dynamic]Robot
	defer delete(robots)

	for l in lines {
		parts, _ := strings.split(l, " ")
		defer delete(parts)
		r: Robot

		// p
		rp, _ := strings.split(parts[0], ",")
		defer delete(rp)
		r.p.x, _ = strconv.parse_int(rp[0][2:])
		r.p.y, _ = strconv.parse_int(rp[1])

		// v
		rv, _ := strings.split(parts[1], ",")
		defer delete(rv)
		r.v.x, _ = strconv.parse_int(rv[0][2:])
		r.v.y, _ = strconv.parse_int(rv[1])

		append(&robots, r)
	}

	qs: [4]int

	for &r in robots {
		np := r.p + (r.v * 100)
		r.p.x = np.x % W
		r.p.y = np.y % H
		if r.p.x < 0 {
			r.p.x += W
		}
		if r.p.y < 0 {
			r.p.y += H
		}
		if r.p.x < W / 2 && r.p.y < H / 2 {
			qs.r += 1
		} else if r.p.x < W / 2 && r.p.y > H / 2 {
			qs.g += 1
		} else if r.p.x > W / 2 && r.p.y > H / 2 {
			qs.b += 1
		} else if r.p.x > W / 2 && r.p.y < H / 2 {
			qs.a += 1
		}
	}

	fmt.printf("Part one: {}\n", qs[0] * qs[1] * qs[2] * qs[3])
	i := 100
	for true {
		i += 1
		for &r in robots {
			np := r.p + r.v
			r.p.x = np.x % W
			r.p.y = np.y % H
			if r.p.x < 0 do r.p.x += W
			if r.p.y < 0 do r.p.y += H
		}
		if find_tree_pattern(robots[:]) {
			fmt.printf("Part two: {}\n", i)
			break
		}
	}

}
