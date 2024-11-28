package day2304

import "../../utils"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

Card :: struct {
	winning:  [dynamic]int,
	numbers:  [dynamic]int,
	matching: int,
	copies:   int,
}

cards: [dynamic]Card = {}

parse_line :: proc(line: string) {
	card: Card
	card.copies = 1

	parts, _ := strings.split(line, ": ")
	defer delete(parts)
	number_parts, _ := strings.split(parts[1], " | ")
	defer delete(number_parts)

	utils.get_numbers_in_string(number_parts[0], {" ", "  ", "   "}, &card.winning)
	utils.get_numbers_in_string(number_parts[1], {" ", "  ", "   "}, &card.numbers)

	append(&cards, card)
}

day :: proc(filepath: string) {
	fmt.printf("day 23/04\n")

	input, err := os.read_entire_file(filepath)
	defer delete(input)

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	// Clean up...
	defer {
		for card in cards {
			delete(card.winning)
			delete(card.numbers)
		}
		delete(cards)
	}

	part_1 := 0
	part_2 := 0

	for line in lines do parse_line(line)
	for &card in cards {
		value := 0
		for number in card.numbers {
			if slice.contains(card.winning[:], number) {
				// The value...
				if value == 0 do value = 1
				else do value *= 2
				
				// But also keep track of all matches...
				card.matching += 1
			}
		}
		part_1 += value
	}

	// part 2
	for card, x in cards {
		for n in 1 ..= card.matching {
			cards[n + x].copies += card.copies
		}
		part_2 += card.copies
	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)

}
