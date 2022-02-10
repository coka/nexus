import unittest


def get_final_floor(input):
    floor = 0
    for char in input:
        if char == "(":
            floor += 1
        elif char == ")":
            floor -= 1
    return floor


def get_first_basement_position(input):
    floor = 0
    position = 0
    for char in input:
        position += 1
        if char == "(":
            floor += 1
        elif char == ")":
            floor -= 1
            if floor < 0:
                return position
    return None


class TestDay1(unittest.TestCase):
    def setUp(self):
        self.file = open("input/01.txt")
        self.input = self.file.read()

    def tearDown(self):
        self.file.close()

    def test_get_final_floor(self):
        self.assertEqual(get_final_floor(self.input), 138)

    def test_get_first_basement_position(self):
        self.assertEqual(get_first_basement_position(self.input), 1771)


if __name__ == "__main__":
    unittest.main()
