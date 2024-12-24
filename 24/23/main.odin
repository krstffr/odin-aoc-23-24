package d2423

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

// a name of a computer
Name :: [2]u8

// all connections
conns: map[Name][dynamic]Name

// silly helper function to sort names...
sort_names :: proc(a, b: Name) -> slice.Ordering {
	if a[0] == b[0] {
		if a[1] == b[1] do return .Equal
		if a[1] > b[1] do return slice.Ordering.Greater
		return slice.Ordering.Less
	}
	if a[0] > b[0] do return slice.Ordering.Greater
	return slice.Ordering.Less
}

// store largest group string here
longest : [32]Name
longest_len := 0
// function to find largest group
find_group :: proc(from: Name, must_be_there: ^[dynamic]Name) {
	if len(must_be_there) > longest_len {
		slice.sort_by_cmp(must_be_there[:], sort_names)
		for n, i in must_be_there do longest[i] = n
		longest_len = len(must_be_there)
	}
	outer: for name in conns[from] {
		for mb in must_be_there {
			if !slice.contains(conns[name][:], mb) do continue outer
		}
		append(must_be_there, name)
		find_group(name, must_be_there)
	}

}

triples: map[[3]Name]struct {}

day :: proc(input: string) {
	fmt.printf("day 24/23\n")

	part_1 := 0
	part_2 := 0

	lines, _ := strings.split_lines(input)
	defer delete(lines)

	// cleanup!
	defer delete(triples)
	defer {
		for name, cs in conns do delete(cs)
		delete(conns)
	}

	// setup connections
	for l in lines {
		from: Name
		from[0] = l[0]
		from[1] = l[1]

		to: Name
		to[0] = l[3]
		to[1] = l[4]
		if !(to in conns) do conns[to] = make([dynamic]Name)
		if !(from in conns) do conns[from] = make([dynamic]Name)
		append(&conns[to], from)
		append(&conns[from], to)
	}

	// find triples beginning with 't'
	for from in conns {
		if from[0] != 't' do continue
		for to in conns[from] {
			for third in conns[to] {
				if slice.contains(conns[third][:], from) {
					key: [3]Name
					key[0] = from
					key[1] = to
					key[2] = third
					slice.sort_by_cmp(key[:], sort_names)
					triples[key] = {}
				}
			}
		}
	}

	// find largest group
	mbt: [dynamic]Name
	defer delete(mbt)
	for n in conns {
		clear(&mbt)
		append(&mbt, n)
		find_group(n, &mbt)
	}

	fmt.printf("Part one: {}\n", len(triples))
	fmt.printf("Part two: ")
	for n, i in longest[:longest_len] {
		if i > 0 do fmt.printf(",")
		fmt.printf("{}{}", rune(n[0]), rune(n[1]))
		longest[i] = n
	}
	fmt.printf("\n")

}
