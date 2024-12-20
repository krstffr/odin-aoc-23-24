package d2420

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

GRID_SIZE :: 141

// grid with walls
grid: [GRID_SIZE][GRID_SIZE]bool

// grid but with distance travelled at each cell
dists: [GRID_SIZE][GRID_SIZE]int

// track all possible shortcuts
dist_counts: [GRID_SIZE * GRID_SIZE]int

QItem :: struct {
	p: [2]int,
	d: int,
}

maybe_add_to_q :: proc(p: [2]int, v: ^map[[2]int]bool) -> bool {
	if p.x < 0 do return false
	if p.y < 0 do return false
	if p.x >= GRID_SIZE do return false
	if p.y >= GRID_SIZE do return false
	if grid[p.y][p.x] do return false
	if v[p] do return false
	return true
}

ds: [4][2]int = {{0, -1}, {0, +1}, {-1, 0}, {+1, 0}}

setup_dists :: proc(s: [2]int, e: [2]int) -> int {
	q: [dynamic]QItem = {{p = s, d = 0}}
	v: map[[2]int]bool
	v[s] = true
	defer {
		delete(q)
		delete(v)
	}

	for len(q) > 0 {
		n := pop_front(&q)
		dists[n.p.y][n.p.x] = n.d
		if n.p == e do return n.d
		for d in ds {
			if maybe_add_to_q(n.p + d, &v) {
				append(&q, QItem{p = n.p + d, d = n.d + 1})
				v[n.p + d] = true
			}
		}
	}
	return -1
}

find_shortcuts :: proc(p: [2]int, max_dist: int) {
	for y := max(1, p.y - max_dist); y <= min(GRID_SIZE - 1, p.y + max_dist); y += 1 {
		for x := max(1, p.x - max_dist); x <= min(GRID_SIZE - 1, p.x + max_dist); x += 1 {
			if p == {x, y} do continue
			if grid[y][x] do continue
			m_dist := utils.manhattan_dist(p, {x, y})
			if m_dist <= max_dist {
				dist := dists[y][x] - dists[p.y][p.x]
				if dist > 0 do dist_counts[dist - m_dist] += 1
			}
		}
	}
}

day :: proc(input: string) {
	fmt.printf("day 24/20\n")

	lines, _ := strings.split_lines(input)
	defer delete(lines)

	parts_1 := 0
	parts_2 := 0

	// start end end positions
	s: [2]int
	e: [2]int

	// setup grid and start/end point
	for line, y in lines {
		for c, x in line {
			if c == '#' do grid[y][x] = true
			if c == 'S' do s = {x, y}
			if c == 'E' do e = {x, y}
		}
	}

	// setups dists grid, walls should be -1
	for r, y in dists {
		for c, x in r {
			dists[y][x] = -1
		}
	}

	setup_dists(s, e)

	fmt.printfln("Starting: {}\n", dists[3][1])

	// part 1
	for line, y in grid {
		for c, x in line {
			if c do continue
			find_shortcuts({x, y}, 2)
		}
	}

	for x, i in dist_counts do if i >= 100 do parts_1 += x
	fmt.printf("Part one: {}\n", parts_1)

	// part 2
	dist_counts = {}
	for line, y in grid {
		for c, x in line {
			if c do continue
			find_shortcuts({x, y}, 20)
		}
	}

	for x, i in dist_counts do if i >= 100 do parts_2 += x
	fmt.printf("Part two: {}\n", parts_2)

}
