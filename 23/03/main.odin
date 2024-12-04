package day2303

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

Number :: struct {
	row:             int,
	start:           int,
	end:             int,
	value:           int,
	connect_to_gear: [2]int,
}

day :: proc(input: string) {
	fmt.printf("day 23/03\n")

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	part_1 := 0
	part_2 := 0

	numbers: [dynamic]Number
	defer delete(numbers)

	max_len_line := len(lines[0])

	for line, row in lines {
		adding_number := false
		n: Number
		for r, x in line {
			if r >= '0' && r <= '9' {
				if !adding_number {
					adding_number = true
					n.row = row
					n.start = x
				}
			} else {
				if adding_number {
					adding_number = false
					n.end = x
					n.value, _ = strconv.parse_int(line[n.start:n.end])
					// fmt.printf("n: {}, n: {}\n", line[n.start:n.end], n)
					append(&numbers, n)
					n.value = 0
				}
			}
		}
		if adding_number {
			adding_number = false
			n.end = max_len_line
			n.value, _ = strconv.parse_int(line[n.start:n.end])
			// fmt.printf("n: {}, n: {}\n", line[n.start:n.end], n)
			append(&numbers, n)
			n.value = 0
		}
	}

	adj_runes: map[rune]bool = {
		'/' = true,
		'@' = true,
		'*' = true,
		'#' = true,
		'$' = true,
		'&' = true,
		'+' = true,
		'%' = true,
		'=' = true,
		'-' = true,
	}
	defer delete(adj_runes)

	for n in numbers {
		adj := false
		if n.row > 0 {
			for r in lines[n.row - 1][max(0, n.start - 1):min(max_len_line, n.end + 1)] {
				if r in adj_runes do adj = true
			}
		}
		for r in lines[n.row + 0][max(0, n.start - 1):min(max_len_line, n.end + 1)] {
			if r in adj_runes do adj = true
		}
		if n.row < len(lines) - 1 {
			for r in lines[n.row + 1][max(0, n.start - 1):min(max_len_line, n.end + 1)] {
				if r in adj_runes do adj = true
			}
		}
		if adj {
			part_1 += n.value
		}
	}

	gears: map[[2]int][dynamic]int
	defer for k, g in gears {
		delete(g)
	}
	defer delete(gears)

	for &n in numbers {
		start := max(0, n.start - 1)
		end := min(max_len_line, n.end + 1)
		if n.row > 0 {
			start := max(0, n.start - 1)
			for r, x in lines[n.row - 1][start:end] {
				if r == '*' do n.connect_to_gear = {x + start, n.row - 1}
			}
		}
		for r, x in lines[n.row + 0][start:end] {
			if r == '*' do n.connect_to_gear = {x + start, n.row}
		}
		if n.row < len(lines) - 1 {
			for r, x in lines[n.row + 1][start:end] {
				if r == '*' do n.connect_to_gear = {x + start, n.row + 1}
			}
		}
		if n.connect_to_gear.x > 0 && n.connect_to_gear.y > 0 {
			if !(n.connect_to_gear in gears) {
				gears[n.connect_to_gear] = {}
			}
			append(&gears[n.connect_to_gear], n.value)
		}
	}

	for a, b in gears {
		if len(b) >= 2 {
			part_2 += b[0] * b[1]
		}
	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)

}
