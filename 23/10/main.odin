package d2310

import "../../utils"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

Vec2 :: [2]int
Dir :: enum {
	U,
	R,
	D,
	L,
}

// Used to draw the grid if needed...
grid : [140][140]rune = {}

move_clockwise :: proc(p: ^Vec2, dir: ^Dir, lines: ^[]string) -> bool {
	// handle down
	if dir^ == .D {
		p.y += 1
		l := lines[p.y][p.x]
		if l == 'J' {
			dir^ = .L
		} else if l == 'L' {
			dir^ = .R
		} else if l == '|' {
			dir^ = .D
		} else {
			if l != 'S' do fmt.panicf("Going down incorrectly: {} and {}\n", p, dir)
		}
		return true
	}
	// handle up
	if dir^ == .U {
		p.y -= 1
		l := lines[p.y][p.x]
		if l == '7' {
			dir^ = .L
		} else if l == 'F' {
			dir^ = .R
		} else if l == '|' {
			dir^ = .U
		} else {
			if l != 'S' do fmt.panicf("Going up incorrectly: {} and {}\n", p, rune(lines[p.y][p.x]))
		}
		return true
	}
	// handle right
	if dir^ == .R {
		p.x += 1
		l := lines[p.y][p.x]
		if l == '7' {
			dir^ = .D
		} else if l == 'J' {
			dir^ = .U
		} else if l == '-' {
			dir^ = .R
		} else {
			if l != 'S' do fmt.panicf("Going right incorrectly: {} and {}\n", p, rune(lines[p.y][p.x]))
		}
		return true
	}
	// handle left
	if dir^ == .L {
		p.x -= 1
		l := lines[p.y][p.x]
		if l == 'F' {
			dir^ = .D
		} else if l == 'L' {
			dir^ = .U
		} else if l == '-' {
			dir^ = .L
		} else {
			if l != 'S' do fmt.panicf("Going left incorrectly: {} and {}\n", p, rune(lines[p.y][p.x]))
		}
		return true
	}
	return false
}

find_start_dir :: proc(p: ^Vec2, lines: ^[]string) -> Dir {
	u := rune(lines[p.y - 1][p.x])
	d := rune(lines[p.y + 1][p.x])
	l := rune(lines[p.y][p.x - 1])
	r := rune(lines[p.y][p.x + 1])
	if d == '|' || d == 'J' || d == 'L' do return .D
	if r == '-' || r == 'J' || r == '7' do return .R
	if l == '-' || l == 'F' || l == 'L' do return .L
	return .U
}


day :: proc(filepath: string) {
	fmt.printf("day 23/10\n")
	input, err := os.read_entire_file(filepath)
	defer delete(input)

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	part_2 := 0

	p: Vec2
	for l, y in lines {
		for c, x in l do if c == 'S' do p = {x, y}
	}

	pipe_outline: map[Vec2]bool
	defer delete(pipe_outline)

	// fill grid
	// for &line in grid {
	// 	for &c in line {
	// 		c = ' '
	// 	}
	// }

	dir := find_start_dir(&p, &lines)
	start_pos := p
	steps := 0
	for true {
		steps += 1
		pipe_outline[p] = true
		grid[p.y][p.x] = rune(lines[p.y][p.x])
		move_clockwise(&p, &dir, &lines)
		if p == start_pos {
			fmt.printf("Part one: {}\n", steps / 2)
			break
		}
	}

	for line, y in lines {
		pipes := 0
		last_char : rune
		for c, x in line {

			if c == '|' && pipe_outline[{x, y}] {
				last_char = '|'
				pipes += 1
			} 
			if c == 'F' && pipe_outline[{x, y}] {
				last_char = 'F'
			} 
			if c == 'J' && pipe_outline[{x, y}] {
				if last_char == 'F' do pipes += 1
				last_char = 'J'
			}
			if c == 'L' && pipe_outline[{x, y}] {
				last_char = 'L'
			}
			if c == '7' && pipe_outline[{x, y}] {
				if last_char == 'L' do pipes += 1
				last_char = '7'
			} 

			// TODO: Update depending on your start position...
			if c == 'S' && pipe_outline[{x, y}] {
				last_char = 'F'
			} 

			if !pipe_outline[{x, y}] && pipes % 2 == 1 {
				// fmt.printf("Here: {} {} \n", x, y)
				grid[y][x] = '.'
				part_2 += 1
			}


		}
	}

	fmt.printf("Part two: {}\n", part_2)

	// Uncomment to draw grid...
	// for line in grid {
	// 	for c in line {
	// 		fmt.printf("{}", rune(c))
	// 	}
	// 	fmt.printf("\n")
	// }
}
