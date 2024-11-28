package d2307

import "../../utils"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

Rank :: enum {
	r2,
	r3,
	r4,
	r5,
	r6,
	r7,
	r8,
	r9,
	rT,
	rJ,
	rQ,
	rK,
	rA,
}

Rank2 :: enum {
	rJ,
	r2,
	r3,
	r4,
	r5,
	r6,
	r7,
	r8,
	r9,
	rT,
	rQ,
	rK,
	rA,
}

Hand :: struct {
	cards:   [5]Rank,
	cards_pt2:   [5]Rank2,
	n_cards: map[Rank]int,
	count:   int,
	bet:     int,
	j_count: int,
}

HandStrength :: enum {
	HighCard,
	Pair,
	TwoPair,
	ThreeOfAKind,
	FullHouse,
	FourOfAKind,
	FiveOfAKind,
}

parse_hand_string :: proc(hand: string, h: ^Hand) {
	for r in hand {
		if r == '2' {
			h.cards[h.count] = Rank.r2
			h.cards_pt2[h.count] = Rank2.r2
		}
		if r == '3' {
			h.cards[h.count] = Rank.r3
			h.cards_pt2[h.count] = Rank2.r3
		}
		if r == '4' {
			h.cards[h.count] = Rank.r4
			h.cards_pt2[h.count] = Rank2.r4
		}
		if r == '5' {
			h.cards[h.count] = Rank.r5
			h.cards_pt2[h.count] = Rank2.r5
		}
		if r == '6' {
			h.cards[h.count] = Rank.r6
			h.cards_pt2[h.count] = Rank2.r6
		}
		if r == '7' {
			h.cards[h.count] = Rank.r7
			h.cards_pt2[h.count] = Rank2.r7
		}
		if r == '8' {
			h.cards[h.count] = Rank.r8
			h.cards_pt2[h.count] = Rank2.r8
		}
		if r == '9' {
			h.cards[h.count] = Rank.r9
			h.cards_pt2[h.count] = Rank2.r9
		}
		if r == 'T' {
			h.cards[h.count] = Rank.rT
			h.cards_pt2[h.count] = Rank2.rT
		}
		if r == 'J' {
			h.cards[h.count] = Rank.rJ
			h.cards_pt2[h.count] = Rank2.rJ
			h.j_count += 1
		}
		if r == 'Q' {
			h.cards[h.count] = Rank.rQ
			h.cards_pt2[h.count] = Rank2.rQ
		}
		if r == 'K' {
			h.cards[h.count] = Rank.rK
			h.cards_pt2[h.count] = Rank2.rK
		}
		if r == 'A' {
			h.cards[h.count] = Rank.rA
			h.cards_pt2[h.count] = Rank2.rA
		}
		h.count += 1
	}
	for r in h.cards {
		if !(r in h.n_cards) do h.n_cards[r] = 0
		h.n_cards[r] += 1
	}
}

is_pair :: proc(h: Hand) -> bool {
	for k, v in h.n_cards {
		if v == 2 do return true
	}
	return false
}

is_two_pair :: proc(h: Hand) -> bool {
	found_pair := false
	for k, v in h.n_cards {
		if v == 2 && found_pair do return true
		if v == 2 do found_pair = true
	}
	return false
}

is_three_of_a_kind :: proc(h: Hand) -> bool {
	for k, v in h.n_cards {
		if v == 3 do return true
	}
	return false
}

is_full_house :: proc(h: Hand) -> bool {
	found_pair := false
	found_triple := false
	for k, v in h.n_cards {
		if v == 3 do found_triple = true
		if v == 2 do found_pair = true
	}
	return found_pair && found_triple
}

is_four_of_a_kind :: proc(h: Hand) -> bool {
	for k, v in h.n_cards {
		if v == 4 do return true
	}
	return false
}

is_five_of_a_kind :: proc(h: Hand) -> bool {
	for k, v in h.n_cards {
		if v == 5 do return true
	}
	return false
}

is_two_pair_pt2 :: proc(h: Hand) -> bool {
	// are there any jokers??
	if h.j_count > 0 {
		if h.j_count >= 2 do return true
		if h.j_count == 1 && len(h.n_cards) == 5 do return false
		return true
	} else {
		return is_two_pair(h)
	}
}

is_full_house_pt2 :: proc(h: Hand) -> bool {
	// are there any jokers??
	if h.j_count > 0 {
		if h.j_count == 1 {
			found_pair := false
			for k, v in h.n_cards {
				if k == .rJ do continue
				if v >= 2 && found_pair do return true
				if v >= 2 do found_pair = true
			}
			return false
		}
		if h.j_count == 2 {
			for k, v in h.n_cards {
				if k == .rJ do continue
				if v >= 2 do return true
			}
			return false
		}
		return true
	} else {
		return is_full_house(h)
	}
}

is_pair_pt2 :: proc(h: Hand) -> bool {
	for k, v in h.n_cards {
		if k == .rJ {
			if v == 2 do return true
		} else {
			if v + h.j_count == 2 do return true
		}
	}
	return false
}

is_three_of_a_kind_pt2 :: proc(h: Hand) -> bool {
	for k, v in h.n_cards {
		if k == .rJ {
			if v == 3 do return true
		} else {
			if v + h.j_count == 3 do return true
		}
	}
	return false
}

is_four_of_a_kind_pt2 :: proc(h: Hand) -> bool {
	for k, v in h.n_cards {
		if k == .rJ {
			if v == 4 do return true
		} else {
			if v + h.j_count == 4 do return true
		}
	}
	return false
}

is_five_of_a_kind_pt2 :: proc(h: Hand) -> bool {
	for k, v in h.n_cards {
		if k == .rJ {
			if v == 5 do return true
		} else {
			if v + h.j_count == 5 do return true
		}
	}
	return false
}

get_hand_str :: proc(h: Hand) -> HandStrength {
	if is_five_of_a_kind(h) do return .FiveOfAKind
	if is_four_of_a_kind(h) do return .FourOfAKind
	if is_full_house(h) do return .FullHouse
	if is_three_of_a_kind(h) do return .ThreeOfAKind
	if is_two_pair(h) do return .TwoPair
	if is_pair(h) do return .Pair
	return .HighCard
}

eval_hands :: proc(h1, h2: Hand) -> bool {
	s1 := get_hand_str(h1)
	s2 := get_hand_str(h2)
	if s1 == s2 {
		for c, x in h1.cards {
			if c > h2.cards[x] do return true
			if c < h2.cards[x] do return false
		}
	}
	return s1 > s2
}

get_hand_str_pt2 :: proc(h: Hand) -> HandStrength {
	if is_five_of_a_kind_pt2(h) do return .FiveOfAKind
	if is_four_of_a_kind_pt2(h) do return .FourOfAKind
	if is_full_house_pt2(h) do return .FullHouse
	if is_three_of_a_kind_pt2(h) do return .ThreeOfAKind
	if is_two_pair_pt2(h) do return .TwoPair
	if is_pair_pt2(h) do return .Pair
	return .HighCard
}

eval_hands_pt_2 :: proc(h1, h2: Hand) -> bool {
	s1 := get_hand_str_pt2(h1)
	s2 := get_hand_str_pt2(h2)
	if s1 == s2 {
		for c, x in h1.cards_pt2 {
			if c > h2.cards_pt2[x] do return true
			if c < h2.cards_pt2[x] do return false
		}
	}
	return s1 > s2
}

day :: proc(filepath: string) {
	fmt.printf("day 23/07\n")

	input, err := os.read_entire_file(filepath)
	defer delete(input)

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	hands: [dynamic]Hand
	defer {
		for h in hands {
			delete(h.n_cards)
		}
		delete(hands)
	}

	for line in lines {
		cards, _ := strings.split(line, " ")
		defer delete(cards)
		h: Hand
		parse_hand_string(cards[0], &h)
		h.bet, _ = strconv.parse_int(cards[1])
		append(&hands, h)
	}

	// Part one..
	slice.sort_by(hands[:], proc(h1, h2: Hand) -> bool {
		return !eval_hands(h1, h2)
	})
	part_one := 0
	for hand, x in hands {
		part_one += hand.bet * (x + 1)
	}
	fmt.printf("Part one: {}\n", part_one)

	// Part two...
	slice.sort_by(hands[:], proc(h1, h2: Hand) -> bool {
		return !eval_hands_pt_2(h1, h2)
	})
	part_two := 0
	for hand, x in hands {
		part_two += hand.bet * (x + 1)
	}
	fmt.printf("Part one: {}\n", part_two)

}
