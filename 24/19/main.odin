package d2419

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

towels: [dynamic]string
c: map[string]int

can_make :: proc(pattern: string) -> int {
	if pattern == "" do return 1
	if pattern in c do return c[pattern]
	res := 0
	for t in towels {
		if len(t) > len(pattern) do continue
		if t == pattern[:len(t)] do res += can_make(pattern[len(t):])
	}
	c[pattern] = res
	return c[pattern]
}

day :: proc(input: string) {
	fmt.printf("day 24/19\n")

	// clean up globals...
	defer delete(towels)
	defer delete(c)

	parts := strings.split(input, "\n\n")
	defer delete(parts)

	towels_, _ := strings.split(parts[0], ", ")
	defer delete(towels_)

	for t in towels_ do append(&towels, t)

	patterns, _ := strings.split_lines(parts[1])
	defer delete(patterns)

	parts_1 := 0
	parts_2 := 0

	for pattern in patterns {
		res := can_make(pattern)
		if res > 0 {
			parts_1 += 1
			parts_2 += res
		}
	}

	fmt.printf("Part one: {}\n", parts_1)
	fmt.printf("Part two: {}\n", parts_2)

}
