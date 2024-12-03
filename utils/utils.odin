package utils

import "core:fmt"
import "core:mem"
import "core:strconv"
import "core:strings"

get_numbers_in_string :: proc(s: string, splitter: []string, a: ^[dynamic]int) {
	winning, err := strings.split_multi(s, splitter)
	if err != mem.Allocator_Error.None do fmt.panicf("Error in get_numbers_in_string using: {} and {}", s, splitter)
	defer delete(winning)
	for s in winning {
		if s == "" do continue
		n, _ := strconv.parse_int(s)
		append(a, n)
	}
}

manhattan_dist :: proc(a, b: [2]int) -> int {
	return abs(a.x - b.x) + abs(a.y - b.y)
}

shoelace_area :: proc(points: [][2]int) -> (area: f32) {
	l := len(points)
	last := points[l - 1]
	xy_sum: f32 = 0
	yx_sum: f32 = 0
	for p, i in points {
		xy_sum += f32(p.x * last.y)
		yx_sum += f32(p.y * last.x)
		last = p
	}
	return abs(xy_sum - yx_sum) / 2.0
}
