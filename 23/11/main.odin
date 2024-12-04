package d2311

import "../../utils"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

Vec2 :: [2]int

day :: proc(input: string) {
	fmt.printf("day 23/11\n")

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	part_1 := 0
	part_2_extra := 0

	galaxies: [dynamic]Vec2
	galaxies_y: map[int]bool
	galaxies_x: map[int]bool
	holes_y: map[int]bool
	holes_x: map[int]bool
	defer {
		delete(galaxies)
		delete(holes_x)
		delete(holes_y)
		delete(galaxies_y)
		delete(galaxies_x)
	}

	for line, y in lines {
		for c, x in line {
			if c == '#' {
				append(&galaxies, Vec2{x, y})
				galaxies_y[y] = true
				galaxies_x[x] = true
			}
		}
	}

	for y in 0 ..< len(lines) {
		if y in galaxies_y do continue
		else do holes_y[y] = true
	}
	for x in 0 ..< len(lines[0]) {
		if x in galaxies_x do continue
		else do holes_x[x] = true
	}

	for g1, i in galaxies {
		for g2, j in galaxies {
			if i <= j do continue
			part_1 += utils.manhattan_dist(g1, g2)

			// find holes and fill up...
			for y in min(g1.y, g2.y) ..< max(g1.y, g2.y) {
				if holes_y[y] {
					part_1 += 1
					part_2_extra += 999_998
				}
			}
			for x in min(g1.x, g2.x) ..< max(g1.x, g2.x) {
				if holes_x[x] {
					part_1 += 1
					part_2_extra += 999_998
				}
			}
		}
	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_1 + part_2_extra)

}
