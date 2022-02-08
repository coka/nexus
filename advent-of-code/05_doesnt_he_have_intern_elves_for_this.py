import re
import unittest

vowels = set(["a", "e", "i", "o", "u"])


def contains_three_vowels(string):
    count = 0
    for char in string:
        if char in vowels:
            count += 1
            if count == 3:
                return True
    return False


def has_double_letters(string):
    previous_letter = None
    for char in string:
        if char == previous_letter:
            return True
        else:
            previous_letter = char
    return False


forbidden_pattern = re.compile("ab|cd|pq|xy")


def is_nice(string):
    return (
        contains_three_vowels(string)
        and has_double_letters(string)
        and forbidden_pattern.search(string) is None
    )


def count_nice_strings(input):
    return len([s for s in input.splitlines() if is_nice(s)])


def get_non_overlapping_pair(string):
    pairs = set()
    previous_pair = string[0:2]
    pairs.add(previous_pair)
    overlapped = False
    for letter in string[2:]:
        pair = previous_pair[1] + letter
        if pair == previous_pair:
            if overlapped:
                return True
            else:
                overlapped = True
        elif pair in pairs:
            return True
        else:
            pairs.add(pair)
            previous_pair = pair
            overlapped = False
    return False


def has_repeat_with_letter_between(string):
    target = string[0]
    between = string[1]
    for letter in string[2:]:
        if letter == target:
            return True
        else:
            target = between
            between = letter
    return False


def is_actually_nice(string):
    return get_non_overlapping_pair(string) and has_repeat_with_letter_between(string)


def count_actually_nice_strings(input):
    return len([s for s in input.splitlines() if is_actually_nice(s)])


class TestDay2(unittest.TestCase):
    def setUp(self):
        self.file = open("input/05.txt")
        self.input = self.file.read()

    def tearDown(self):
        self.file.close()

    def test_is_nice(self):
        self.assertTrue(is_nice("ugknbfddgicrmopn"))
        self.assertTrue(is_nice("aaa"))
        self.assertFalse(is_nice("jchzalrnumimnmhp"))
        self.assertFalse(is_nice("haegwjzuvuyypxyu"))
        self.assertFalse(is_nice("dvszwmarrgswjxmb"))

    def test_count_nice_strings(self):
        self.assertEqual(count_nice_strings(self.input), 255)

    def test_is_actually_nice_examples(self):
        self.assertTrue(is_actually_nice("qjhvhtzxzqqjkmpb"))
        self.assertTrue(is_actually_nice("xxyxx"))
        self.assertFalse(is_actually_nice("uurcxstgmygtbstg"))
        self.assertFalse(is_actually_nice("ieodomkazucvgmuy"))

    def test_is_actually_nice_tricky_stuff(self):
        self.assertFalse(is_actually_nice("aa"))
        self.assertFalse(is_actually_nice("aaa"))
        self.assertTrue(is_actually_nice("aaaa"))

    def test_count_actually_nice_strings(self):
        self.assertEqual(count_actually_nice_strings(self.input), 55)


if __name__ == "__main__":
    unittest.main()
