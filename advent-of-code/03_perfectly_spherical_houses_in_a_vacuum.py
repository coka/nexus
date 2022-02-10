import operator
import unittest

instruction_to_delta = {
    "^": (0, 1),
    "v": (0, -1),
    ">": (1, 0),
    "<": (-1, 0),
}


class Entity:  # :^)
    def __init__(self):
        self.position = (0, 0)

    def move(self, instruction):
        self.position = tuple(
            map(operator.add, self.position, instruction_to_delta[instruction])
        )
        return self.position


def num_of_visited_houses(instructions):
    santa = Entity()
    visited_positions = set([santa.position])
    for i in instructions:
        visited_positions.add(santa.move(i))
    return len(visited_positions)


def num_of_visited_houses_with_robo_santa(instructions):
    santa = Entity()
    robo_santa = Entity()
    visited_positions = set([santa.position, robo_santa.position])
    for idx, instr in enumerate(instructions):
        if idx % 2 == 0:
            visited_positions.add(santa.move(instr))
        else:
            visited_positions.add(robo_santa.move(instr))
    return len(visited_positions)


class TestDay2(unittest.TestCase):
    def setUp(self):
        self.file = open("input/03.txt")
        self.input = self.file.read()

    def tearDown(self):
        self.file.close()

    def test_num_of_visited_houses(self):
        self.assertEqual(num_of_visited_houses(">"), 2)
        self.assertEqual(num_of_visited_houses("^>v<"), 4)
        self.assertEqual(num_of_visited_houses("^v^v^v^v^v"), 2)
        self.assertEqual(num_of_visited_houses(self.input), 2592)

    def test_num_of_visited_houses_with_robo_santa(self):
        self.assertEqual(num_of_visited_houses_with_robo_santa("^v"), 3)
        self.assertEqual(num_of_visited_houses_with_robo_santa("^>v<"), 3)
        self.assertEqual(num_of_visited_houses_with_robo_santa("^v^v^v^v^v"), 11)
        self.assertEqual(num_of_visited_houses_with_robo_santa(self.input), 2360)


if __name__ == "__main__":
    unittest.main()
