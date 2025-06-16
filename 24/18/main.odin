#+feature dynamic-literals

package d2418

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

GS :: 71
grid: [GS][GS]int

Qitem :: struct {
	p: [2]int,
	t: int,
}

maybe_add_to_q :: proc(p: [2]int, t: int, q: ^[dynamic]Qitem, v: ^map[[2]int]int) -> bool {
	if p.x < 0 do return false
	if p.y < 0 do return false
	if p.y >= GS do return false
	if p.x >= GS do return false
	if grid[p.y][p.x] != 0 do return false
	if v[p] != 0 do return false
	append(q, Qitem{p = p, t = t + 1})
	v[p] = t + 1
	return true
}

bfs :: proc() -> int {
	// queue and visited...
	q: [dynamic]Qitem = {{p = {0, 0}, t = 1}}
	v: map[[2]int]int

	defer {
		delete(q)
		delete(v)
	}

	for len(q) > 0 {
		n := pop_front(&q)
		v[n.p] = n.t
		// have we reached the end?
		if n.p == {GS - 1, GS - 1} do break
		maybe_add_to_q(n.p + {0, -1}, n.t, &q, &v)
		maybe_add_to_q(n.p + {0, +1}, n.t, &q, &v)
		maybe_add_to_q(n.p + {-1, 0}, n.t, &q, &v)
		maybe_add_to_q(n.p + {+1, 0}, n.t, &q, &v)
	}

	return v[[2]int{GS - 1, GS - 1}] - 1
}

check_time :: proc(time: int, lines: ^[]string) -> (x, y, t: int) {
	// reset grid
	grid = {}
	// keep ints in this (UGLY)
	ns: [dynamic]int
	defer delete(ns)
	// fill up grid
	for l, time in lines[:time] {
		clear(&ns)
		utils.get_numbers_in_string(l, {","}, &ns)
		grid[ns[1]][ns[0]] = time + 1
	}
	// check result
	time_to_end := bfs()
	if time_to_end < 0 do return ns[0], ns[1], time_to_end
	return 0, 0, time_to_end
}

day :: proc(input: string) {
	fmt.printf("day 24/18\n")

	lines, _ := strings.split_lines(string(input))
	defer delete(lines)

	_,_, part_1 := check_time(1024, &lines)
	fmt.printf("Part one: {}\n", part_1)
	part_2 := 0

	lo := 0
	hi := len(lines)

	for lo <= hi {
		time := lo + (hi - lo) / 2
		x, y, _ := check_time(time, &lines)
		px, py, _ := check_time(time - 1, &lines)
		if (x + y != 0 && px + py == 0) {
			fmt.printf("Part two: {},{}\n", x, y)
			break
		}
		if x + y == 0 do lo = time + 1
		else do hi = time - 1
	}


}
