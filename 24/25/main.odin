package d2425

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

Key :: struct {
	shape: [5]u8,
}
Lock :: struct {
	shape: [5]u8,
}

keys: [dynamic]Key
locks: [dynamic]Lock

day :: proc(input: string) {
	fmt.printf("day 24/25\n")

	part_1 := 0
	part_2 := 0

	parts := strings.split(input, "\n\n")
	defer delete(parts)

	defer {
		delete(keys)
		delete(locks)
	}

	for part in parts {
		lines := strings.split_lines(part)
		defer delete(lines)
		if string(lines[0]) == "#####" {
			k: Key
			for line, y in lines {
				if y == 0 do continue
				if y == 6 do continue
				for c, x in line {
					if c == '#' do k.shape[x] += 1
				}
			}
			append(&keys, k)
		} else if string(lines[6]) == "#####" {
			lock: Lock
			for line, y in lines {
				if y == 0 do continue
				if y == 6 do continue
				for c, x in line {
					if c == '#' do lock.shape[x] += 1
				}
			}
			append(&locks, lock)
		} else {
			fmt.panicf("unknown shape: {}\n", lines[6])
		}

	}

	for k in keys {
		locks_loop: for l in locks {
			for i in 0 ..< 5 {
				if l.shape[i] + k.shape[i] > 5 {
					continue locks_loop
				}
			}
			part_1 += 1

		}
	}

	// 18850 too high
	// 2997  too low
	fmt.printf("p1: {}\n", part_1)
	fmt.printf("p2: {}\n", part_2)

}
