package d2408

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

Antenna :: struct {
	p: [2]int,
	v: rune
}

// this is for the test input...
// GRID_S :: 12
GRID_S :: 50
grid : [GRID_S][GRID_S]rune

within_bounds :: proc(p: [2]int) -> bool {
	return p.x >= 0 && p.y >= 0 && p.y < GRID_S && p.x < GRID_S
}

day :: proc(input: string) {
	fmt.printf("day 24/08\n")

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	part_1 := 0
	part_2 := 0

	antennas : [dynamic]Antenna
	defer delete(antennas)

	// add all antennas
	for line, y in lines {
		for c, x in line {
			if c != '.' {
				a: Antenna
				a.v = c
				a.p = {x, y}
				append(&antennas, a)
			}
			grid[y][x] = c
		}
	}

	// solve part 1
	for a, i in antennas {
		for b in antennas[i + 1:] {
			if a.v == b.v {
				diff := a.p - b.p
				diff2 := b.p - a.p
				ap := a.p - diff2
				bp := b.p - diff
				if within_bounds(ap) do grid[ap.y][ap.x] = '#'
				if within_bounds(bp) do grid[bp.y][bp.x] = '#'
			}
		}
	}

	// count all '#' squares for part 1
	for l in grid {
		for x in l {
			if x == '#' do part_1 += 1
		}
	}

	fmt.printf("Part one: {}\n", part_1)

	// part 2
	for a, i in antennas {
		for b in antennas[i + 1:] {
			if a.v == b.v {
				diff := a.p - b.p
				diff2 := b.p - a.p
				tempa := a.p
				tempb := b.p
				for within_bounds(tempa) {
					tempa -= diff2
					if within_bounds(tempa) do grid[tempa.y][tempa.x] = '#'
				}
				for within_bounds(tempb) {
					tempb += diff2
					if within_bounds(tempb) do grid[tempb.y][tempb.x] = '#'
				}
			}
		}
	}

	// count all non '.' squares for part 2
	for l in grid {
		for x in l {
			if x != '.' do part_2 += 1
		}
	}

	fmt.printf("Part two: {}\n", part_2)

}
