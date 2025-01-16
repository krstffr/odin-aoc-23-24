package d2415

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

// MAZE_SIZE :: 7
// MAZE_SIZE :: 10
MAZE_SIZE :: 50
maze: [MAZE_SIZE][MAZE_SIZE]u8
maze2: [MAZE_SIZE][MAZE_SIZE * 2]u8
maze2_temp: [MAZE_SIZE][MAZE_SIZE * 2]u8

sum_boxes :: proc() -> (res: int) {
	for l, y in maze {
		for c, x in l {
			if c == 'O' {
				res += y * 100 + x
			}
		}
	}
	return res
}

sum_boxes_2 :: proc() -> (res: int) {
	for l, y in maze2 {
		for c, x in l {
			if c == '[' {
				res += y * 100 + x
			}
		}
	}
	return res
}

// the robots...
r: [2]int
r2: [2]int

process_moves :: proc(moves: string) {
	for m, i in moves do process_move(m)
}

swap :: proc(p1, p2: [2]int) {
	temp := maze[p1.y][p1.x]
	maze[p1.y][p1.x] = maze[p2.y][p2.x]
	maze[p2.y][p2.x] = temp
}

process_move :: proc(m: rune) {
	// fmt.printf("\n\nProcess: {}\n", m)
	dots := 0
	os := 0
	end_p: [2]int
	moved_robot := false
	switch m {
	case '<':
		for x := r.x - 1; x > 0; x -= 1 {
			c := maze[r.y][x]
			if c == 'O' do os += 1
			if c == '#' do break
			end_p = {x, r.y}
			if c == '.' {
				dots += 1
				break
			}
		}
		if dots == 0 do break
		end := r.x
		r.x -= 1
		for x := end_p.x; x < end; x += 1 {
			if os > 0 {
				os -= 1
				maze[r.y][x] = 'O'
			} else {
				// if !moved_robot do r.x = x
				// moved_robot = true
				maze[r.y][x] = '.'
			}
		}

	case '^':
		for y := r.y - 1; y > 0; y -= 1 {
			c := maze[y][r.x]
			if c == 'O' do os += 1
			if c == '#' do break
			end_p = {r.x, y}
			if c == '.' {
				dots += 1
				break
			}
		}
		if dots == 0 do break
		end := r.y
		r.y -= 1
		for y := end_p.y; y < end; y += 1 {
			if os > 0 {
				os -= 1
				maze[y][r.x] = 'O'
			} else {
				// if !moved_robot do r.y = y
				// moved_robot = true
				maze[y][r.x] = '.'
			}
		}

	case '>':
		for x := r.x + 1; x < MAZE_SIZE - 1; x += 1 {
			c := maze[r.y][x]
			// fmt.printf("at {} {}: {}\n", r.y, x, rune(maze[r.y][x]))
			if c == 'O' do os += 1
			if c == '#' do break
			end_p = {x, r.y}
			if c == '.' {
				dots += 1
				break
			}
		}
		if dots == 0 do break
		end := r.x
		r.x += 1
		for x := end_p.x; x > end; x -= 1 {
			if os > 0 {
				os -= 1
				maze[r.y][x] = 'O'
			} else {
				// if !moved_robot do r.x = x
				// moved_robot = true
				maze[r.y][x] = '.'

			}
		}

	case 'v':
		for y := r.y + 1; y < MAZE_SIZE - 1; y += 1 {
			c := maze[y][r.x]
			// if c == '.' do dots += 1
			if c == 'O' do os += 1
			if c == '#' do break
			end_p = {r.x, y}
			if c == '.' {
				dots += 1
				break
			}
		}
		if dots == 0 do break
		end := r.y
		r.y += 1
		for y := end_p.y; y > end; y -= 1 {
			if os > 0 {
				os -= 1
				maze[y][r.x] = 'O'
			} else {
				// if !moved_robot do r.y = y
				// moved_robot = true
				maze[y][r.x] = '.'
			}
		}
	}
}

Dir :: enum {
	U,
	D,
	L,
	R,
}

can_apply_force :: proc(d: Dir, p: [2]int) -> bool {
	if maze2[p.y][p.x] == '.' do return true
	if maze2[p.y][p.x] == '#' do return false

	switch d {
	case .L:
		return can_apply_force(d, p + {-1, 0})
	case .R:
		return can_apply_force(d, p + {+1, 0})
	case .D:
		if maze2[p.y][p.x] == '[' {
			return can_apply_force(d, p + {0, +1}) && can_apply_force(d, p + {+1, +1})
		} else {
			return can_apply_force(d, p + {0, +1}) && can_apply_force(d, p + {-1, +1})
		}
	case .U:
		if maze2[p.y][p.x] == '[' {
			return can_apply_force(d, p + {0, -1}) && can_apply_force(d, p + {+1, -1})
		} else {
			return can_apply_force(d, p + {0, -1}) && can_apply_force(d, p + {-1, -1})
		}
	case:
		fmt.panicf("Unreachable")
	}
}

Maze_cell :: struct {
	// position to move
	p: [2]int,
	// the rune to move
	v: u8,
}

apply_force :: proc(d: Dir, p: [2]int, to_move: ^[dynamic]Maze_cell) {
	c := maze2[p.y][p.x]
	if c == '[' || c == ']' {
		switch d {
		case .L:
			m: Maze_cell
			m.p = {p.x, p.y}
			m.v = maze2[p.y][p.x]
			append(to_move, m)
			apply_force(d, p + {-1, 0}, to_move)
		case .R:
			m: Maze_cell
			m.p = {p.x, p.y}
			m.v = maze2[p.y][p.x]
			append(to_move, m)
			apply_force(d, p + {+1, 0}, to_move)
		case .U:
			if c == '[' {
				m: Maze_cell
				m.p = {p.x, p.y}
				m.v = '['
				append(to_move, m)
				apply_force(d, p + {0, -1}, to_move)

				m2: Maze_cell
				m2.p = {p.x + 1, p.y}
				m2.v = ']'
				append(to_move, m2)
				apply_force(d, p + {1, -1}, to_move)
			} else {
				m: Maze_cell
				m.p = {p.x, p.y}
				m.v = ']'
				append(to_move, m)
				apply_force(d, p + {0, -1}, to_move)

				m2: Maze_cell
				m2.p = {p.x - 1, p.y}
				m2.v = '['
				append(to_move, m2)
				apply_force(d, p + {-1, -1}, to_move)
			}
		case .D:
			if c == '[' {
				m: Maze_cell
				m.p = {p.x, p.y}
				m.v = '['
				append(to_move, m)
				apply_force(d, p + {0, +1}, to_move)

				m2: Maze_cell
				m2.p = {p.x + 1, p.y}
				m2.v = ']'
				append(to_move, m2)
				apply_force(d, p + {1, +1}, to_move)
			} else {
				m: Maze_cell
				m.p = {p.x, p.y}
				m.v = ']'
				append(to_move, m)
				apply_force(d, p + {0, +1}, to_move)

				m2: Maze_cell
				m2.p = {p.x - 1, p.y}
				m2.v = '['
				append(to_move, m2)
				apply_force(d, p + {-1, +1}, to_move)
			}
		}
	}
}

process_move_pt2 :: proc(m: rune) {

	to_move: [dynamic]Maze_cell
	move_vector : [2]int
	dir : Dir
	switch m {
	case '<':
		c := maze2[r2.y][r2.x - 1]
		if c == '.' {
			r2.x -= 1
		} else if c != '#' {
			if can_apply_force(.L, r2 + {-1, 0}) {
				r2.x -= 1
				apply_force(.L, r2, &to_move)
			}
		}

	case '>':
		c := maze2[r2.y][r2.x + 1]
		if c == '.' {
			r2.x += 1
		} else if c != '#' {
			if can_apply_force(.R, r2 + {+1, 0}) {
				r2.x += 1
				apply_force(.R, r2, &to_move)
			}
		}

	case 'v':
		c := maze2[r2.y + 1][r2.x]
		if c == '.' {
			r2.y += 1
		} else if c != '#' {
			if can_apply_force(.D, r2 + {+0, +1}) {
				r2.y += 1
				apply_force(.D, r2, &to_move)
			}
		}

	case '^':
		c := maze2[r2.y - 1][r2.x]
		if c == '.' {
			r2.y -= 1
		} else if c != '#' {
			if can_apply_force(.U, r2 + {+0, -1}) {
				r2.y -= 1
				apply_force(.U, r2, &to_move)
			}
		}
	}

	if len(to_move) > 0 {
		switch m {
		case '<':
			move_in_grid({-1, 0}, &to_move)
		case '>':
			move_in_grid({+1, 0}, &to_move)
		case '^':
			move_in_grid({0, -1}, &to_move)
		case 'v':
			move_in_grid({0, +1}, &to_move)
		}
	}

	defer delete(to_move)
}

move_in_grid :: proc(offset: [2]int, to_move: ^[dynamic]Maze_cell) {
	for m in to_move {
		maze2[m.p.y][m.p.x] = '.'
	}
	for m in to_move {
		maze2[m.p.y + offset.y][m.p.x + offset.x] = m.v
	}
}

day :: proc(input: string) {
	fmt.printf("day 24/15\n")

	parts, _ := strings.split(string(input), "\n\n")
	defer delete(parts)

	moves := parts[1]

	maze_string := parts[0]
	maze_lines, _ := strings.split(maze_string, "\n")
	defer delete(maze_lines)

	// setup part 1 and 2
	for l, y in maze_lines {
		for c, x in l {
			// pt 1
			maze[y][x] = u8(c)
			if c == '@' {
				maze[y][x] = '.'
				r = {x, y}
				// pt 2
				r2 = {x * 2, y}
				maze2[y][x * 2] = '.'
				maze2[y][x * 2 + 1] = '.'
			}

			// pt 2
			if c == '.' {
				maze2[y][x * 2] = '.'
				maze2[y][x * 2 + 1] = '.'
			}
			if c == '#' {
				maze2[y][x * 2] = '#'
				maze2[y][x * 2 + 1] = '#'
			}
			if c == 'O' {
				maze2[y][x * 2] = '['
				maze2[y][x * 2 + 1] = ']'
			}
		}
	}

	process_moves(moves)
	part_1 := sum_boxes()
	fmt.printf("Part one: {}\n", part_1)

	// part 2
	for m, i in moves do process_move_pt2(m)
	part_2 := sum_boxes_2()

	fmt.printf("Part two: {}\n", part_2)

}
