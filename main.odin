package main

import "core:fmt"
import "core:mem"
import "core:os"
import "core:time"

import d2301 "23/01"
import d2302 "23/02"
import d2303 "23/03"

time_func :: proc(p: proc(filepath: string), filepath: string) {
	fmt.printf("\n")
	start := time.now()
	p(filepath)
	fmt.printf("time: {} ms\n", (time.now()._nsec - start._nsec) / 1_000_000)
}

main :: proc() {
	// setup tracking allocator...
	fmt.printf("Setting up tracking allocator\n")
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)

	defer {
		if len(track.allocation_map) > 0 {
			fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
			for _, entry in track.allocation_map {
				fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
			}
		}
		if len(track.bad_free_array) > 0 {
			fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
			for entry in track.bad_free_array {
				fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
			}
		}
		mem.tracking_allocator_destroy(&track)
	}

	if len(os.args) < 2 || os.args[1] == "1" do time_func(d2301.day, "23/01/input.txt")
	if len(os.args) < 2 || os.args[1] == "2" do time_func(d2302.day, "23/02/input.txt")
	if len(os.args) < 2 || os.args[1] == "3" do time_func(d2303.day, "23/03/input.txt")

	fmt.printf("\n\nRan all day...!\n")
}
