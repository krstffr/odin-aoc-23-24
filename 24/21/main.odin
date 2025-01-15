package d2421

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

find_shortest_from_keypad_target :: proc(target: string, d: int = 0) -> (result: int = max(int)) {

	// fill all possible string paths here...
	possible_parts: [dynamic][dynamic]string
	defer {
		for &r in possible_parts do delete(r)
		delete(possible_parts)
	}

	// fill up the possible paths here
	from: u8 = 'A'
	for c in target {
		key: [2]u8 = {from, u8(c)}
		curr: [dynamic]string
		for s in paths_keypad[key] do append(&curr, s)
		append(&possible_parts, curr)
		from = u8(c)
	}

	// test all possible strings
	for p in possible_parts[0] {

		temp: [dynamic]string
		defer delete(temp)
		find_possible_strings(p, possible_parts[1:], &temp)

		for t in temp {
			current_res := 0
			last := 'A'
			for c in t {
				current_res += shortest_robo_path(u8(c), u8(d), u8(last))
				last = c
			}
			result = min(result, current_res)
		}
	}
	return result
}

find_possible_strings :: proc(root: string, paths: [][dynamic]string, result: ^[dynamic]string) {
	if len(paths) == 0 do append(result, root)
	else do for p in paths[0] {
		// temp allocated strings FTW! ❤️
		new_root := fmt.tprintf("{}{}", root, p)
		find_possible_strings(new_root, paths[1:], result)
	}
}

robo_cache: map[[3]u8]int
shortest_robo_path :: proc(to: u8, depth: u8, from: u8 = 'A') -> (result: int) {
	// check cache
	cache_key: [3]u8 = {from, to, depth}
	if cache_key in robo_cache do return robo_cache[cache_key]

	// key for the robo paths
	key: [2]u8 = {from, to}

	if depth > 0 {
		shortest_path := max(int)
		inner_from: u8 = 'A'
		for p, i in paths_robo[key] {
			res := 0
			for c in p {
				res += shortest_robo_path(u8(c), depth - 1, inner_from)
				inner_from = u8(c)
			}
			shortest_path = min(shortest_path, res)
		}
		result += shortest_path
	} else {
		result = len(paths_robo[key][0])
	}
	// store in cache!
	robo_cache[cache_key] = result
	return result
}

// this was a function I used to find where i was missing input...
parse_result :: proc(resulting_string: string, d: int = 0) {
	// example:        v<<A>>^A<A>AvA<^AA>A<vAAA>^A
	// should become:  <A^A>^^AvvvA

	fmt.printf("Looking at: {}\n", resulting_string)

	temp_s: [dynamic]rune
	defer delete(temp_s)

	last: u8 = 'A'
	for r in resulting_string {
		append(&temp_s, r)
		if r == 'A' {
			s := utf8.runes_to_string(temp_s[:])
			defer delete(s)
			found := false
			outer: for k, vs in paths_robo {
				if k[0] != last do continue
				for v in vs {
					if v == s {
						found = true
						fmt.printf("{}", rune(k[1]))
						last = u8(k[1])
						break outer
					}
				}
			}
			// report the error!
			if !found do fmt.panicf("Could not find: {}, last: {}. THIS IS A BUG!\n", s, rune(last))
			clear(&temp_s)
		}
	}

	fmt.printf("\n")
}


day :: proc(input: string) {

	// clean up
	defer delete(robo_cache)

	fmt.printf("day 24/21\n")

	assert(find_shortest_from_keypad_target("029A", 1) == 68)
	assert(find_shortest_from_keypad_target("980A", 1) == 60)
	assert(find_shortest_from_keypad_target("179A", 1) == 68)
	assert(find_shortest_from_keypad_target("456A", 1) == 64)
	assert(find_shortest_from_keypad_target("379A", 1) == 64)

	// part 1
	robots := 2
	part_1 := 0
	part_1 += find_shortest_from_keypad_target("826A", robots - 1) * 826
	part_1 += find_shortest_from_keypad_target("341A", robots - 1) * 341
	part_1 += find_shortest_from_keypad_target("582A", robots - 1) * 582
	part_1 += find_shortest_from_keypad_target("983A", robots - 1) * 983
	part_1 += find_shortest_from_keypad_target("670A", robots - 1) * 670

	// part 2
	robots = 25
	part_2 := 0
	part_2 += find_shortest_from_keypad_target("826A", robots - 1) * 826
	part_2 += find_shortest_from_keypad_target("341A", robots - 1) * 341
	part_2 += find_shortest_from_keypad_target("582A", robots - 1) * 582
	part_2 += find_shortest_from_keypad_target("983A", robots - 1) * 983
	part_2 += find_shortest_from_keypad_target("670A", robots - 1) * 670

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part one: {}\n", part_2)

}
