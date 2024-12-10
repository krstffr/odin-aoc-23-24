package d2410

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

GRID_SIZE :: 41
grid: [GRID_SIZE][GRID_SIZE]u8

add_ns_to_q :: proc(p: [2]int, q: ^[dynamic][2]int, visited: ^map[[2]int]bool) {
	if p.x > 0 && !([2]int{p.x - 1, p.y} in visited) {
		if grid[p.y][p.x - 1] - grid[p.y][p.x] == 1 {
			append(q, [2]int{p.x - 1, p.y})
			visited[[2]int{p.x - 1, p.y}] = true
		}
	}
	if p.y > 0 && !([2]int{p.x, p.y - 1} in visited) {
		if grid[p.y - 1][p.x] - grid[p.y][p.x] == 1 {
			append(q, [2]int{p.x, p.y - 1})
			visited[[2]int{p.x, p.y - 1}] = true
		}
	}
	if p.x < GRID_SIZE - 1 && !([2]int{p.x + 1, p.y} in visited) {
		if grid[p.y][p.x + 1] - grid[p.y][p.x] == 1 {
			append(q, [2]int{p.x + 1, p.y})
			visited[[2]int{p.x + 1, p.y}] = true
		}
	}
	if p.y < GRID_SIZE - 1 && !([2]int{p.x, p.y + 1} in visited) {
		if grid[p.y + 1][p.x] - grid[p.y][p.x] == 1 {
			append(q, [2]int{p.x, p.y + 1})
			visited[[2]int{p.x, p.y + 1}] = true
		}
	}
}

search :: proc(x, y: int) -> (score : int) {
	visited: map[[2]int]bool
	q: [dynamic][2]int = {{x, y}}
	defer delete(q)
	defer delete(visited)

	for len(q) > 0 {
		n := pop(&q)
		if grid[n.y][n.x] == '9' do score += 1
		visited[n] = true
		add_ns_to_q(n, &q, &visited)
	}

	return score
}

search_2 :: proc(x, y: int) -> (score : int) {
	if grid[y][x] == '9' do return 1
	if x > 0 {
		if grid[y][x - 1] - grid[y][x] == 1 do score += search_2(x - 1, y)
	}
	if y > 0 {
		if grid[y - 1][x] - grid[y][x] == 1 do score += search_2(x, y - 1)
	}
	if x < GRID_SIZE - 1 {
		if grid[y][x + 1] - grid[y][x] == 1 do score += search_2(x + 1, y)
	}
	if y < GRID_SIZE - 1 {
		if grid[y + 1][x] - grid[y][x] == 1 do score += search_2(x, y + 1)
	}
	return score
}

day :: proc(input: string) {
	fmt.printf("day 24/10\n")

	part_1 := 0
	part_2 := 0

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	// setup grid
	for l, y in lines {
		for c, x in l do grid[y][x] = u8(c)
	}

	// search!
	for l, y in lines {
		for c, x in l {
			if c == '0' {
				part_1 += search(x, y)
				part_2 += search_2(x, y)
			}
		}
	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)

}
