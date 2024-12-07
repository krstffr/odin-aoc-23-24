package d2406

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

Guard :: struct {
	p:   [2]int,
	dir: [2]int,
}

GRID_SIZE :: 130

visited: [GRID_SIZE][GRID_SIZE]bool = {}
grid: [GRID_SIZE][GRID_SIZE]bool = {}
visited_grid_dirs: [GRID_SIZE][GRID_SIZE][4]bool = {}

dir_to_int :: proc(d: [2]int) -> int {
	if d.x == +1 do return 0
	if d.x == -1 do return 1
	if d.y == +1 do return 2
	return 3
}

can_guard_move :: proc(g: Guard) -> bool {
	np := g.p + g.dir
	if np.x >= GRID_SIZE || np.y >= GRID_SIZE do return false
	if np.x < 0 || np.y < 0 do return false
	return !grid[np.y][np.x]
}

rotate_guard :: proc(g: ^Guard) {
	if g.dir.y == -1 {
		g.dir.y = 0
		g.dir.x = 1
	} else if g.dir.y == 1 {
		g.dir.y = 0
		g.dir.x = -1
	} else if g.dir.x == 1 {
		g.dir.y = 1
		g.dir.x = 0
	} else {
		g.dir.y = -1
		g.dir.x = 0
	}
}

day :: proc(input: string) {
	fmt.printf("day 24/06\n")

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	part_1 := 0
	part_2 := 0

	g: Guard

	// find the guard
	for line, y in lines {
		for c, x in line {
			if c == '^' {
				g.p.y = y
				g.p.x = x
				g.dir = {0, -1}
			} else do grid[y][x] = c == '#'
		}
	}

	for g.p.x > 0 && g.p.x < len(lines[0]) - 1 && g.p.y > 0 && g.p.y < len(lines) - 1 {
		visited[g.p.y][g.p.x] = true
		if can_guard_move(g) {
			g.p += g.dir
			if g.p.x < 0 || g.p.y < 0 || g.p.x >= GRID_SIZE || g.p.y >= GRID_SIZE do break
		} else do rotate_guard(&g)
	}
	visited[g.p.y][g.p.x] = true

	for row, y in visited {
		for v, x in row {
			if v do part_1 += 1
		}
	}

	fmt.printf("Part one: {}\n", part_1)

	for row, test_y in visited {
		for been_here, test_x in row {
			if !been_here do continue
			grid[test_y][test_x] = true
			grid = {}
			visited_grid_dirs = {}

			// reset state
			for line, y in lines {
				for c, x in line {
					if c == '^' {
						g.p.y = y
						g.p.x = x
						g.dir = {0, -1}
					} else do grid[y][x] = c == '#'
				}
			}
			grid[test_y][test_x] = true

			for g.p.x > 0 && g.p.x < len(lines[0]) - 1 && g.p.y > 0 && g.p.y < len(lines) - 1 {
				visited_grid_dirs[g.p.y][g.p.x][dir_to_int(g.dir)] = true
				if can_guard_move(g) {
					g.p += g.dir
					if visited_grid_dirs[g.p.y][g.p.x][dir_to_int(g.dir)] {
						part_2 += 1
						break
					}
					if g.p.x < 0 || g.p.y < 0 || g.p.x >= GRID_SIZE || g.p.y >= GRID_SIZE {
						break
					}
				} else do rotate_guard(&g)
			}
			visited[g.p.y][g.p.x] = true
		}
	}

	fmt.printf("Part two: {}\n", part_2)

}
