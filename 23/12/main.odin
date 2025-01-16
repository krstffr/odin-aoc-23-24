package d2312

import "../../utils"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

Pattern :: struct {
	pattern: []u8,
	groups:  [dynamic]int,
}

not_invalid :: proc(p: Pattern) -> bool {
	idx := 0
	in_group := false
	curr_group := 0
	for r in p.pattern {
		if r == '#' {
			if !in_group {
				curr_group = 0
				in_group = true
			}
			curr_group += 1
		} else {
			if p.groups[idx] != curr_group do return false
		}
	}
	return true
}

f :: proc(pattern: []u8, fields: []int) -> int {
	res := 0
	fmt.printf("Looking at: {}\n", string(pattern))
	m_key := strings.clone_from(string(pattern), context.temp_allocator)

	found_q := false
	for r, i in pattern {
		if r == '?' {
			found_q = true
			pattern[i] = '.'
			res += f(pattern, fields[:])
			pattern[i] = '#'
			res += f(pattern, fields[:])
			pattern[i] = '?'
		}
	}
	if !found_q {
		groups :[dynamic]int
		defer delete(groups)
		in_group := false
		for r in pattern {
			if r == '#' {
				if !in_group {
					append(&groups, 0)
					in_group = true
				}
				groups[len(groups)-1] +=1
			} else {
				in_group = false
			}
		}
		if slice.equal(groups[:], fields[:]) do return 1
	}
	return res
}

solve_p :: proc(p: Pattern) -> int {
	// return f(p.pattern, p.fields[:])
	// perms, _ := slice.make_permutation_iterator(p.pattern)
	// fmt.printf("Perms: {}\n", perms)
	// for slice.permute(&perms) {
	// 	fmt.printf("Perms: {}\n", string(p.pattern))
	// }



	maybe_valid := not_invalid(p)
	fmt.printf("Huh? {} for {}\n", maybe_valid, string(p.pattern))
	return 0
}

find_perms :: proc(pattern: []u8) {
	parts: [dynamic]string
	defer delete(parts)
	
}

day :: proc(input: string) {
	fmt.printf("day 23/11\n")

	find_perms(transmute([]u8)string("???.###"))

	// clean up
	defer free_all(context.temp_allocator)

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	part_1 := 0
	part_2 := 0

	patterns :[dynamic]Pattern
	defer {
		for p in patterns do delete(p.groups)
		delete(patterns)
	}


	for line in lines {
		split, _ := strings.split(line, " ")
		defer delete(split)
		p : Pattern
		p.pattern = transmute([]u8)split[0]
		utils.get_numbers_in_string(split[1], {","}, &p.groups)
		append(&patterns, p)
	}

	for p in patterns {
		res := solve_p(p)
		fmt.printf("P: {}: {}\n", p, res)

		part_1 += res
	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)

}
