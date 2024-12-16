package d2416

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

Dir :: enum {
	U,
	D,
	L,
	R,
	Unkown,
}

moves: map[Dir][2]int = {
	.U = {+0, -1},
	.D = {+0, +1},
	.R = {+1, +0},
	.L = {-1, +0},
}

// S :: 141
// S :: 5
// S :: 17
S :: 15
grid: [S][S]rune

GSitem :: struct {
	score: int,
	dir:   Dir,
}
GSitems :: struct {
	p:     [2]int,
	paths: [4]GSitem,
}
grid_scores: [S][S]GSitems

visited: map[[2]int]bool

next :: proc() -> (res: [2]int, found: bool) {
	min := max(int)
	for r, y in grid_scores {
		for s, x in r {
			if visited[{x, y}] do continue
			for p in s.paths {
				if p.score < min {
					min = p.score
					res = [2]int{x, y}
					found = true
				}
			}
		}
	}
	return res, found
}

update_next :: proc(ps: ^GSitems) {
	// find smallest rotation
	smallest_dir: Dir
	min_score := max(int)
	for p in ps.paths {
		if p.score < min_score {
			min_score = p.score
			smallest_dir = p.dir
		}
	}
	// rotate 90 degs and update score
	if smallest_dir == .R {
		ps.paths[Dir.U].score = min(ps.paths[Dir.U].score, ps.paths[Dir.R].score + 1000)
		ps.paths[Dir.D].score = min(ps.paths[Dir.D].score, ps.paths[Dir.R].score + 1000)
	}
	if smallest_dir == .U {
		ps.paths[Dir.L].score = min(ps.paths[Dir.L].score, ps.paths[Dir.U].score + 1000)
		ps.paths[Dir.R].score = min(ps.paths[Dir.R].score, ps.paths[Dir.U].score + 1000)
	}
	if smallest_dir == .D {
		ps.paths[Dir.L].score = min(ps.paths[Dir.L].score, ps.paths[Dir.D].score + 1000)
		ps.paths[Dir.R].score = min(ps.paths[Dir.R].score, ps.paths[Dir.D].score + 1000)
	}
	if smallest_dir == .L {
		ps.paths[Dir.U].score = min(ps.paths[Dir.U].score, ps.paths[Dir.L].score + 1000)
		ps.paths[Dir.D].score = min(ps.paths[Dir.D].score, ps.paths[Dir.L].score + 1000)
	}

	for p in ps.paths {
		if p.score == max(int) do continue
		n := moves[p.dir] + ps.p
		if grid[n.y][n.x] == '.' {
			if grid_scores[n.y][n.x].paths[p.dir].score > p.score + 1 {
				visited[n] = false
				// fmt.printf("Updating {}: {} from \n", n, p.score + 1, ps.p)
				grid_scores[n.y][n.x].paths[p.dir].score = p.score + 1
			}
		}
	}
}

visited_pt_2: map[[2]int]bool
Possible_item :: struct {
	p:   [2]int,
	dir: Dir,
}
add_lowest_ns_to_q :: proc(p: [2]int, max_cost: int, q: ^[dynamic][2]int) {
	possible: [4]Possible_item = {
		{p = p + {-1, 0}, dir = .R},
		{p = p + {+1, 0}, dir = .L},
		{p = p + {0, -1}, dir = .D},
		{p = p + {0, +1}, dir = .U},
	}
	for pos in possible {
		for path in grid_scores[pos.p.y][pos.p.x].paths {
			fmt.printf("Cost at {}: {} vs {}\n", [2]int{pos.p.x, pos.p.y}, path.score, max_cost)
			if max_cost > path.score && !(pos.p in visited_pt_2) {
				fmt.printf("Adding: {}\n", pos)
				append(q, pos.p)
				visited_pt_2[pos.p] = true
			}
		}
	}
}

find_path_backwards :: proc(from: [2]int) {
	// just dfs backwards to the points with the lowest score??
	q: [dynamic][2]int = {from}
	defer delete(q)
	defer delete(visited_pt_2)
	for len(q) > 0 {
		n := pop(&q)
		visited_pt_2[n] = true
		fmt.printf("At: {}\n", n)
		cost := max(int)
		for path in grid_scores[n.y][n.x].paths {
			cost = min(path.score, cost)
		}
		// look a ns
		add_lowest_ns_to_q(n, cost, &q)
	}
	fmt.printf("Size: {}\n", len(visited_pt_2))
	for row, y in grid {
		for c, x in row {
			if ([2]int{x, y} in visited_pt_2) do fmt.printf("O")
			else {
				fmt.printf("{}", grid[y][x])
			}
		}
		fmt.printf("\n")
	}
}

day :: proc(input: string) {
	fmt.printf("day 24/16\n")

	lines, _ := strings.split_lines(string(input))
	defer delete(lines)

	part_1 := max(int)
	part_2 := 0

	start: [2]int
	end: [2]int

	defer delete(visited)

	for l, y in lines {
		for c, x in l {
			for d in Dir {
				if d == .Unkown do break
				gi: GSitem
				gi.dir = d
				gi.score = max(int)
				grid_scores[y][x].paths[d] = gi
				grid_scores[y][x].p = {x, y}
			}
			if c == 'S' {
				gi: GSitem
				start = {x, y}
				grid[y][x] = '.'
				gi.score = 0
				gi.dir = .R
				grid_scores[y][x].paths[Dir.R] = gi
			} else if c == 'E' {
				end = {x, y}
				grid[y][x] = '.'
			} else do grid[y][x] = c
		}
	}

	for true {
		n, f := next()
		if !f do break
		// fmt.printf("Next: {}\n", n)
		update_next(&grid_scores[n.y][n.x])
		// fmt.printf("Next: {}\n", grid_scores[n.y][n.x])
		visited[n] = true
	}

	// not 136592
	// not 134596 too low!!
	// not 135596 too high!!

	for p in grid_scores[end.y][end.x].paths {
		part_1 = min(part_1, p.score)
	}

	fmt.printf("5/7: {}\n", grid_scores[7][5])

	fmt.printf("Part one: {}\n", part_1)

	// search backwards...
	find_path_backwards(end)
	fmt.printf("Part two: {}\n", part_2)

}
