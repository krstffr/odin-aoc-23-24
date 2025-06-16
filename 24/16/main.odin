#+feature dynamic-literals

package d2416

import "../../utils"
import "core:c/libc"
import pq "core:container/priority_queue"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:time"
import "core:unicode/utf8"

Dir :: enum {
	N,
	S,
	E,
	W,
	Unkown,
}

moves: map[Dir][2]int = {
	.N = {+0, -1},
	.S = {+0, +1},
	.E = {+1, +0},
	.W = {-1, +0},
}

S :: 141
// S :: 5
// S :: 15
// S :: 17

grid: [S][S]bool
costs: [S][S][Dir]int
dirs: [S][S]Dir

CellCost :: struct {
	cost:      int,
	pos:       [2]int,
	dir:       Dir,
	came_from: [2]int,
}

start: [2]int
end: [2]int

check_pos :: proc(p: [2]int) -> bool {
	return grid[p.y][p.x]
}

maybe_add_to_queue :: proc(p: [2]int, dir: Dir, cost: int, q: ^pq.Priority_Queue(CellCost)) {
	if costs[p.y][p.x][dir] > cost {
		costs[p.y][p.x][dir] = cost
		pq.push(q, CellCost{pos = p, cost = cost, dir = dir})
	}
}

add_moves :: proc(cc: CellCost, q: ^pq.Priority_Queue(CellCost)) {
	if cc.dir == .N {
		if check_pos(cc.pos + moves[.N]) do maybe_add_to_queue(cc.pos + moves[.N], .N, cc.cost + 1, q)
		maybe_add_to_queue(cc.pos, .E, cc.cost + 1000, q)
		maybe_add_to_queue(cc.pos, .W, cc.cost + 1000, q)
	}
	if cc.dir == .S {
		if check_pos(cc.pos + moves[.S]) do maybe_add_to_queue(cc.pos + moves[.S], .S, cc.cost + 1, q)
		maybe_add_to_queue(cc.pos, .E, cc.cost + 1000, q)
		maybe_add_to_queue(cc.pos, .W, cc.cost + 1000, q)
	}
	if cc.dir == .E {
		if check_pos(cc.pos + moves[.E]) do maybe_add_to_queue(cc.pos + moves[.E], .E, cc.cost + 1, q)
		maybe_add_to_queue(cc.pos, .S, cc.cost + 1000, q)
		maybe_add_to_queue(cc.pos, .N, cc.cost + 1000, q)
	}
	if cc.dir == .W {
		if check_pos(cc.pos + moves[.W]) do maybe_add_to_queue(cc.pos + moves[.W], .W, cc.cost + 1, q)
		maybe_add_to_queue(cc.pos, .S, cc.cost + 1000, q)
		maybe_add_to_queue(cc.pos, .N, cc.cost + 1000, q)
	}
}

day :: proc(input: string) {
	fmt.printf("day 24/16\n")

	lines, _ := strings.split_lines(string(input))
	defer delete(lines)

	part_1 := max(int)
	part_2 := 0

	for l, y in lines {
		for c, x in l {
			dirs[y][x] = .Unkown
			if c == 'S' {
				start = {x, y}
				grid[y][x] = true
			} else if c == 'E' {
				end = {x, y}
				grid[y][x] = true
			} else {
				grid[y][x] = c == '.'
			}
			for d in Dir {
				costs[y][x][d] = max(int)
			}
		}
	}

	costs[start.y][start.x][.E] = 0
	dirs[start.y][start.x] = .E

	queue: pq.Priority_Queue(CellCost)
	pq.init(&queue, proc(a, b: CellCost) -> bool {
		return a.cost < b.cost
	}, proc(q: []CellCost, a, b: int) {
		temp := q[a]
		q[a] = q[b]
		q[b] = temp
	})
	defer pq.destroy(&queue)

	pq.push(&queue, CellCost{cost = 0, pos = start, dir = .E})

	for pq.len(queue) > 0 {
		cc := pq.pop(&queue)
		add_moves(cc, &queue)
	}

	for d in costs[end.y][end.x] do part_1 = min(part_1, d)
	fmt.printf("Part 1: {}\n", part_1)

	// part 2...

	// start at the end node...
	// fmt.printf("{}\n", costs[end.y][end.x])
	QI :: struct {
		p: [2]int,
		d: Dir,
	}
	q: [dynamic]QI
	visited_p2: map[[2]int]struct {}
	defer {
		delete(q)
		delete(visited_p2)
	}
	dir: Dir
	min_cost := max(int)
	for c, d in costs[end.y][end.x] {
		if c < min_cost {
			min_cost = c
			dir = d
		}
	}
	append(&q, QI{p = end, d = dir})

	p2_grid: [S][S]bool
	for len(q) > 0 {
		next := pop_front(&q)
		if next.p.x < 1 do continue
		if next.p.y < 1 do continue
		visited_p2[next.p] = {}
		p2_grid[next.p.y][next.p.x] = true
		cost := costs[next.p.y][next.p.x][next.d]
		// this is horrible...
		if next.d == .N {
			np := next.p + {0, 1}
			ep := next.p + {-1, 0}
			wp := next.p + {+1, 0}
			if costs[np.y][np.x][.N] == cost - 1 {
				append(&q, QI{p = np, d = .N})
				visited_p2[np] = {}
			}
			if costs[ep.y][ep.x][.E] == cost - 1001 {
				append(&q, QI{p = ep, d = .E})
				visited_p2[ep] = {}
			}
			if costs[wp.y][wp.x][.W] == cost - 1001 {
				append(&q, QI{p = wp, d = .W})
				visited_p2[wp] = {}
			}
		}
		if next.d == .S {
			sp := next.p + {0, -1}
			ep := next.p + {-1, 0}
			wp := next.p + {+1, 0}
			if costs[sp.y][sp.x][.S] == cost - 1 {
				append(&q, QI{p = sp, d = .S})
				visited_p2[sp] = {}
			}
			if costs[ep.y][ep.x][.E] == cost - 1001 {
				append(&q, QI{p = ep, d = .E})
				visited_p2[ep] = {}
			}
			if costs[wp.y][wp.x][.W] == cost - 1001 {
				append(&q, QI{p = wp, d = .W})
				visited_p2[wp] = {}
			}
		}
		if next.d == .E {
			np := next.p + {0, 1}
			ep := next.p + {-1, 0}
			sp := next.p + {0, -1}
			if costs[np.y][np.x][.N] == cost - 1001 {
				append(&q, QI{p = np, d = .N})
				visited_p2[np] = {}
			}
			if costs[ep.y][ep.x][.E] == cost - 1 {
				append(&q, QI{p = ep, d = .E})
				visited_p2[ep] = {}
			}
			if costs[sp.y][sp.x][.S] == cost - 1001 {
				append(&q, QI{p = sp, d = .S})
				visited_p2[sp] = {}
			}
		}
		if next.d == .W {
			np := next.p + {0, 1}
			wp := next.p + {1, 0}
			sp := next.p + {0, -1}
			if costs[np.y][np.x][.N] == cost - 1001 {
				append(&q, QI{p = np, d = .N})
				visited_p2[np] = {}
			}
			if costs[wp.y][wp.x][.W] == cost - 1 {
				append(&q, QI{p = wp, d = .W})
				visited_p2[wp] = {}
			}
			if costs[sp.y][sp.x][.S] == cost - 1001 {
				append(&q, QI{p = sp, d = .S})
				visited_p2[sp] = {}
			}
		}
		min := max(int)
	}

	// option to draw the grid for part 2...
	// for row, y in p2_grid {
	// 	for cell, x in row {
	// 		if cell {
	// 			if grid[y][x] do fmt.printf("O")
	// 		} else {
	// 			if grid[y][x] do fmt.printf(".")
	// 			if !grid[y][x] do fmt.printf("#")
	// 		}
	// 	}
	// 	fmt.printf("\n")
	// }

	fmt.printf("Part 2: {}\n", len(visited_p2))

}
