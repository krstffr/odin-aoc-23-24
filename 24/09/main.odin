package d2409

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

Space :: struct {
	id:      int,
	size:    int,
	is_file: bool,
}

day :: proc(input: string) {
	fmt.printf("day 24/09\n")

	part_1 := 0
	part_2 := 0

	// used for part 2
	space: [dynamic]int
	defer delete(space)

	// used for part 1, should be refactored
	files: [dynamic]Space
	defer delete(files)

	id := 1

	for c, i in input {
		s := utf8.runes_to_string({c})
		n, _ := strconv.parse_int(s)
		defer delete(s)
		f: Space
		f.is_file = i % 2 == 0
		f.id = -1
		f.size = n
		if i % 2 == 0 {
			f.id = id - 1
			append(&files, f)
			for _ in 0 ..< n do append(&space, int(id))
			id += 1
		} else {
			append(&files, f)
			for _ in 0 ..< n do append(&space, 0)
		}

	}

	for n, i in space {
		if n == 0 {
			to_put: int = 0
			for to_put == 0 {
				to_put = pop(&space)
			}
			space[i] = to_put
		}
		space[i] -= 1
	}

	for n, i in space do part_1 += n * i

	outer: for i in 0 ..< len(files) {
		s := files[i]
		if !s.is_file {
			// find a fitting file
			inner: for j := len(files) - 1; j > i; j -= 1 {
				t := files[j]
				if t.is_file && t.size <= s.size {
					// now files[j] is actually space!
					files[j].is_file = false
					files[j].id = -1
					// and the space a files[i] is the t file...
					files[i] = t
					if t.size < s.size {
						// also add space after the moved file if there is any...
						inject_at(
							&files,
							i + 1,
							Space{is_file = false, size = s.size - t.size, id = -1},
						)
					}
					break inner
				}
			}
		}
	}

	// "recreate" the space again from the files structure
	space_2: [dynamic]int
	defer delete(space_2)

	for f, i in files {
		for j in 0 ..< f.size {
			append(&space_2, f.id)
		}
	}

	for n, i in space_2 {
		if n > -1 do part_2 += n * i
	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)

}
