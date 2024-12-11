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

add_ns_to_q :: proc(p: [2]int, q: ^[dynamic][2]int) {
	if p.x > 0 {
		if grid[p.y][p.x - 1] - grid[p.y][p.x] == 1 {
			append(q, [2]int{p.x - 1, p.y})
		}
	}
	if p.y > 0 {
		if grid[p.y - 1][p.x] - grid[p.y][p.x] == 1 {
			append(q, [2]int{p.x, p.y - 1})
		}
	}
	if p.x < GRID_SIZE - 1 {
		if grid[p.y][p.x + 1] - grid[p.y][p.x] == 1 {
			append(q, [2]int{p.x + 1, p.y})
		}
	}
	if p.y < GRID_SIZE - 1 {
		if grid[p.y + 1][p.x] - grid[p.y][p.x] == 1 {
			append(q, [2]int{p.x, p.y + 1})
		}
	}
}

search :: proc(x, y: int) -> (int, int) {
	q: [dynamic][2]int = {{x, y}}
	defer delete(q)
	// NOTE: Nasty "set" workaround haha. Store 0 bytes instead of size of bool!
	nines: map[[2]int]struct{}
	defer delete(nines)
	ways_to_nine := 0

	for len(q) > 0 {
		n := pop(&q)
		if grid[n.y][n.x] == '9' {
			ways_to_nine += 1
			nines[{n.x, n.y}] = {}
		}
		add_ns_to_q(n, &q)
	}

	return len(nines), ways_to_nine
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
				one, two := search(x, y)
				part_1 += one
				part_2 += two
			}
		}
	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)

}
