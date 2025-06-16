#+feature dynamic-literals

package d2412

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

get_ns :: proc(
	p: [2]int,
	lines: ^[]string,
	visited: ^map[[2]int]struct {},
	q: ^[dynamic][2]int,
	perimter: ^int,
	perim_positions: ^map[PerimPosition]struct {},
) {
	if p.x > 0 && (lines[p.y][p.x] == lines[p.y][p.x - 1]) {
		n: [2]int = {p.x - 1, p.y}
		if !(n in visited) {
			append(q, n)
			visited[n] = {}
		}
	} else {
		// fmt.printf("Adding: {}/{}\n", p.x - 1, p.y)
		perimter^ += 1
		pp : PerimPosition
		pp.p = [2]int{p.y, p.x - 1}
		pp.from = .W
		perim_positions[pp] = {}
	}
	if p.y > 0 && (lines[p.y][p.x] == lines[p.y - 1][p.x]) {
		n: [2]int = {p.x, p.y - 1}
		if !(n in visited) {
			append(q, n)
			visited[n] = {}
		}
	} else {
		// fmt.printf("Adding: {}/{}\n", p.x, p.y - 1)
		perimter^ += 1
		pp : PerimPosition
		pp.p = [2]int{p.y - 1, p.x}
		pp.from = .N
		perim_positions[pp] = {}
	}
	if p.y < len(lines) - 1 && (lines[p.y][p.x] == lines[p.y + 1][p.x]) {
		n: [2]int = {p.x, p.y + 1}
		if !(n in visited) {
			append(q, n)
			visited[n] = {}
		}
	} else {
		// fmt.printf("Adding: {}/{}\n", p.x, p.y + 1)
		perimter^ += 1
		pp : PerimPosition
		pp.p = [2]int{p.y + 1, p.x}
		pp.from = .S
		perim_positions[pp] = {}
	}
	if p.x < len(lines[0]) - 1 && (lines[p.y][p.x] == lines[p.y][p.x + 1]) {
		n: [2]int = {p.x + 1, p.y}
		if !(n in visited) {
			append(q, n)
			visited[n] = {}
		}
	} else {
		perimter^ += 1
		pp : PerimPosition
		pp.p = [2]int{p.y, p.x + 1}
		pp.from = .E
		perim_positions[pp] = {}
	}
}

get_ns_perim :: proc(
	p: PerimPosition,
	q: ^[dynamic]PerimPosition,
	perim_positions: ^map[PerimPosition]struct {},
	visited_perim_ps: ^map[PerimPosition]struct {},
) {
	for p2 in perim_positions {
		if p2.p == p.p do continue
		if p2 in visited_perim_ps do continue
		if utils.manhattan_dist(p.p, p2.p) == 1 && p.from == p2.from {
			append(q, p2)
			visited_perim_ps[p2] = {}
		}
	}

}

perims_bfs :: proc(
	p: PerimPosition,
	perim_positions: ^map[PerimPosition]struct {},
	visited_perim_ps: ^map[PerimPosition]struct {},
) {
	q: [dynamic]PerimPosition = {p}
	defer delete(q)

	for len(q) > 0 {
		p := pop(&q)
		get_ns_perim(p, &q, perim_positions, visited_perim_ps)
	}
}


Dir :: enum {
	N,
	S,
	W,
	E,
}

PerimPosition :: struct {
	p:    [2]int,
	from: Dir,
}


search :: proc(p: [2]int, lines: ^[]string, visited: ^map[[2]int]struct {}) -> (int, int) {
	q: [dynamic][2]int = {p}
	defer delete(q)

	visited_here: map[[2]int]struct {}
	visited_here[p] = {}
	defer delete(visited_here)

	perim_positions: map[PerimPosition]struct {}
	defer delete(perim_positions)

	visited[p] = {}

	perimeter := 0

	for len(q) > 0 {
		p := pop(&q)
		visited_here[p] = {}
		get_ns(p, lines, visited, &q, &perimeter, &perim_positions)
	}

	visited_perim_ps: map[PerimPosition]struct {}
	defer delete(visited_perim_ps)

	fences := 0

	for pp, i in perim_positions {
		if pp in visited_perim_ps do continue
		fences += 1
		perims_bfs(pp, &perim_positions, &visited_perim_ps)
	}

	return len(visited_here) * perimeter, len(visited_here) * fences
}

day :: proc(input: string) {
	fmt.printf("day 24/12\n")

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	part_1 := 0
	part_2 := 0

	visited: map[[2]int]struct {}
	defer delete(visited)

	for l, y in lines {
		for c, x in l {
			if !([2]int{x, y} in visited) {
				r1, r2 := search({x, y}, &lines, &visited)

				part_1 += r1
				part_2 += r2
			}

		}
	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)


}
