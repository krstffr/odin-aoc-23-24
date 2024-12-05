package d2404

import "../../utils"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

find_diag :: proc(x, y: int, lines: ^[]string, part_1: ^int) {
	str: [dynamic]u8
	defer delete(str)
	for i in 0 ..= 3 {
		if y + i > len(lines) - 1 do break
		if x + i > len(lines[0]) - 1 do break
		append(&str, lines[y + i][x + i])
	}
	if slice.equal(str[:], []u8{'X', 'M', 'A', 'S'}) do part_1^ += 1
	if slice.equal(str[:], []u8{'S', 'A', 'M', 'X'}) do part_1^ += 1
}

find_diag_inv :: proc(x, y: int, lines: ^[]string, part_1: ^int) {
	str: [dynamic]u8
	defer delete(str)
	curr_x := x
	curr_y := y
	for i in 0 ..= 3 {
		curr_x = x - i
		curr_y = y + i
		if curr_y > len(lines) - 1 do break
		if curr_x < 0 do break
		append(&str, lines[curr_y][curr_x])
	}
	if slice.equal(str[:], []u8{'X', 'M', 'A', 'S'}) do part_1^ += 1
	if slice.equal(str[:], []u8{'S', 'A', 'M', 'X'}) do part_1^ += 1
}

find_vert :: proc(x, y: int, lines: ^[]string, part_1: ^int) {
	str: [dynamic]u8
	defer delete(str)
	curr_x := x
	curr_y := y
	for i in 0 ..= 3 {
		curr_y = y + i
		if curr_y > len(lines) - 1 do break
		if curr_x < 0 do break
		append(&str, lines[curr_y][curr_x])
	}
	if slice.equal(str[:], []u8{'X', 'M', 'A', 'S'}) do part_1^ += 1
	if slice.equal(str[:], []u8{'S', 'A', 'M', 'X'}) do part_1^ += 1
}

find_cross :: proc(from_x, from_y: int, lines: ^[]string, part_2: ^int) {
	g: [3][3]u8
	for yd in 0 ..< 3 {
		for xd in 0 ..< 3 {
			y := from_y + yd
			x := from_x + xd
			if y > len(lines) - 1 do break
			if x > len(lines[0]) - 1 do break
			if yd == 0 && xd == 0 do g[yd][xd] = u8(lines[y][x])
			if yd == 0 && xd == 2 do g[yd][xd] = u8(lines[y][x])
			if yd == 1 && xd == 1 do g[yd][xd] = u8(lines[y][x])
			if yd == 2 && xd == 0 do g[yd][xd] = u8(lines[y][x])
			if yd == 2 && xd == 2 do g[yd][xd] = u8(lines[y][x])
		}
	}
	variations: [][3][3]u8 = {
		{{'M', '.', 'M'}, {'.', 'A', ','}, {'S', '.', 'S'}},
		{{'S', '.', 'M'}, {'.', 'A', ','}, {'S', '.', 'M'}},
		{{'S', '.', 'S'}, {'.', 'A', ','}, {'M', '.', 'M'}},
		{{'M', '.', 'S'}, {'.', 'A', ','}, {'M', '.', 'S'}},
	}
	for v in variations {
		all_good := true
		for row, y in v {
			for c, x in row {
				if y == 1 && x == 0 || y == 1 && x == 2 || y == 0 && x == 1 || y == 2 && x == 1 {
					continue
				}
				if c != g[y][x] do all_good = false
			}
		}
		if all_good do part_2^ += 1
	}
}

day :: proc(input: string) {
	fmt.printf("day 24/04\n")

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	part_1 := 0
	part_2 := 0

	// horiz
	for line, y in lines {
		for _, i in line {
			if i + 4 > len(line) do break
			if line[i:i + 4] == "XMAS" do part_1 += 1
			if line[i:i + 4] == "SAMX" do part_1 += 1
		}
	}

	// all the rest...
	for _, x in lines[0] {
		for _, y in lines {
			find_diag(x, y, &lines, &part_1)
			find_diag_inv(x, y, &lines, &part_1)
			find_vert(x, y, &lines, &part_1)
			find_cross(x, y, &lines, &part_2)
		}
	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)

}
