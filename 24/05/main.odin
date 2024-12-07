package d2405

import "../../utils"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

Rules :: struct {
	smaller: [dynamic]int,
	larger:  [dynamic]int,
}

// globals, cause i need rules in scope of a sort 😬
rules_map: map[int]Rules

day :: proc(input: string) {
	fmt.printf("day 24/05\n")

	part_1 := 0
	part_2 := 0

	rules_and_lists := strings.split(input, "\n\n")
	defer delete(rules_and_lists)

	// clean up rules_map
	defer {
		for k, v in rules_map {
			delete(v.smaller)
			delete(v.larger)
		}
		delete(rules_map)
	}

	// setup rules
	rules_s := strings.split_lines(rules_and_lists[0])
	defer delete(rules_s)
	for rule in rules_s {
		ns: [dynamic]int
		defer delete(ns)
		utils.get_numbers_in_string(rule, {"|"}, &ns)
		m1 := rules_map[ns[0]]
		m2 := rules_map[ns[1]]
		append(&m1.larger, ns[1])
		append(&m2.smaller, ns[0])
		rules_map[ns[0]] = m1
		rules_map[ns[1]] = m2
	}

	// lists data
	lists_s := strings.split_lines(rules_and_lists[1])
	lists: [dynamic][dynamic]int
	sorted_lists: [dynamic][]int

	// clean up lists data
	defer {
		delete(lists_s)
		for l in lists do delete(l)
		delete(lists)
		for l in sorted_lists do delete(l)
		delete(sorted_lists)
	}

	// setup lists
	for l in lists_s {
		// read list
		ns: [dynamic]int
		utils.get_numbers_in_string(l, {","}, &ns)

		// append to list
		append(&lists, ns)

		// sort and append to sorted_list
		c := slice.clone(ns[:])
		// This rancid loop was needed to solve "poisoned" input!
		for _ in 0 ..< len(ns) {
			slice.sort_by_cmp(c[:], proc(a, b: int) -> slice.Ordering {
				if slice.contains(rules_map[a].larger[:], b) do return .Less
				if slice.contains(rules_map[a].smaller[:], b) do return .Greater
				return .Less
			})
		}
		append(&sorted_lists, c)
	}

	// solve both parts
	for list, i in lists {
		sorted_list := sorted_lists[i]
		if slice.equal(list[:], sorted_list[:]) do part_1 += list[len(list) / 2]
		else do part_2 += sorted_list[len(sorted_list) / 2]
	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)

}
