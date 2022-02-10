import math
import unittest


def parse(dimensions):
    return [int(dim) for dim in dimensions.split("x")]


def calculate_wrapping_area(input):
    result = 0
    for line in input.splitlines():
        l, w, h = parse(line)
        sides = [l * w, w * h, h * l]
        wrapping = 2 * sum(sides)
        slack = min(sides)
        result += wrapping + slack
    return result


def calculate_ribbon_length(input):
    result = 0
    for line in input.splitlines():
        dimensions = parse(line)
        wrapping = 2 * sum(sorted(dimensions)[:-1])
        ribbon = math.prod(dimensions)
        result += wrapping + ribbon
    return result


class TestDay2(unittest.TestCase):
    def setUp(self):
        self.file = open("input/02.txt")
        self.input = self.file.read()

    def tearDown(self):
        self.file.close()

    def test_parse(self):
        self.assertEqual(parse("2x3x4"), [2, 3, 4])
        self.assertEqual(parse("1x1x10"), [1, 1, 10])

    def test_calculate_wrapping_area(self):
        self.assertEqual(calculate_wrapping_area(self.input), 1586300)

    def test_calculate_ribbon_length(self):
        self.assertEqual(calculate_ribbon_length(self.input), 3737498)


if __name__ == "__main__":
    unittest.main()
