import math
import time
import unittest


def parse(snailfish_string):
    trimmed = snailfish_string[1:-1]
    i = 0
    if trimmed[i] == "[":
        stack = 1
        while stack != 0:
            i += 1
            if trimmed[i] == "[":
                stack += 1
            elif trimmed[i] == "]":
                stack -= 1
        while trimmed[i] != ",":
            i += 1
        return trimmed[:i], trimmed[i + 1 :]
    else:
        s = trimmed.split(",")
        return s[0], s[1]


class Carry:
    def __init__(self, value: int, direction: str):
        self.value = value
        assert direction == "left" or direction == "right"
        self.direction = direction

    def is_left(self) -> bool:
        return self.direction == "left"

    def is_right(self) -> bool:
        return self.direction == "right"

    def expended(self) -> bool:
        return self.value == 0


class LeftCarry(Carry):
    def __init__(self, value: int):
        super().__init__(value, "left")


class RightCarry(Carry):
    def __init__(self, value: int):
        super().__init__(value, "right")


class ExpendedCarry(LeftCarry):
    def __init__(self):
        super().__init__(0)


class Tree:
    def __init__(self, snailfish_string, nesting=0):
        assert nesting < 5
        self.nesting = nesting

        left, right = parse(snailfish_string)

        if len(left) == 1:
            self.left = int(left)
        else:
            self.left = Tree(left, nesting + 1)

        if len(right) == 1:
            self.right = int(right)
        else:
            self.right = Tree(right, nesting + 1)

    def add(self, tree):
        selfstr = str(self)
        treestr = str(tree)
        return Tree("[{},{}]".format(selfstr, treestr))

    def explode(self):
        if self.nesting == 4:
            assert type(self.left) is int
            assert type(self.right) is int
            return self.left, self.right

        if self.nesting == 3:
            # either explode left
            if type(self.left) is Tree:
                lvalue, rvalue = self.left.explode()
                self.left = 0
                if type(self.right) is int:
                    self.right += rvalue
                else:
                    self.right.apply_from_left(rvalue)
                return LeftCarry(lvalue)
            # or explode right
            if type(self.right) is Tree:
                lvalue, rvalue = self.right.explode()
                self.right = 0
                if type(self.left) is int:
                    self.left += lvalue
                else:
                    self.left.apply_from_right(lvalue)
                return RightCarry(rvalue)
            # or don't explode
            else:
                return None

        # try exploding left
        if type(self.left) is Tree:
            carry = self.left.explode()
            if carry is not None:  # got some carry
                if not carry.expended():  # can still apply
                    if carry.is_left():
                        return carry
                    else:
                        if type(self.right) is int:
                            self.right += carry.value
                            return ExpendedCarry()
                        else:
                            self.right.apply_from_left(carry.value)
                            return ExpendedCarry()

        # didn't get a carry until now, might explode right
        if type(self.right) is Tree:
            carry = self.right.explode()
            if carry is not None:
                if not carry.expended():  # can still apply
                    if carry.is_right():
                        return carry
                    else:
                        if type(self.left) is int:
                            self.left += carry.value
                            return ExpendedCarry()
                        else:
                            self.left.apply_from_right(carry.value)
                            return ExpendedCarry()

        # or don't explode
        return None

    def apply_from_right(self, value: int):
        if type(self.right) is int:
            self.right += value
        elif type(self.right) is Tree:
            self.right.apply_from_left(value)
        elif type(self.left) is int:
            self.left += value
        else:
            self.left.apply_from_right(value)

    def apply_from_left(self, value: int):
        if type(self.left) is int:
            self.left += value
        elif type(self.left) is Tree:
            self.left.apply_from_right(value)
        elif type(self.right) is int:
            self.right += value
        else:
            self.right.apply_from_left(value)

    def split(self):
        if type(self.left) is int and self.left >= 10:
            left = math.floor(self.left / 2)
            right = math.ceil(self.left / 2)
            treestr = "[{},{}]".format(left, right)
            self.left = Tree(treestr, self.nesting + 1)
            return True
        if type(self.left) is Tree:
            has_split = self.left.split()
            if has_split:
                return True
        if type(self.right) is Tree:
            has_split = self.right.split()
            if has_split:
                return True
        if type(self.right) is int and self.right >= 10:
            left = math.floor(self.right / 2)
            right = math.ceil(self.right / 2)
            treestr = "[{},{}]".format(left, right)
            self.right = Tree(treestr, self.nesting + 1)
            return True
        return False

    def reduce(self):
        state = "try_explode"
        print("Reducing this tree: {}".format(self))
        while state != "stop":
            if state == "try_explode":
                print("Explode! (first time) {}".format(self))
                current_tree = str(self)
                self.explode()
                if str(self) == current_tree:
                    state = "stop"
                else:
                    state = "exploded"
            if state == "exploded":
                print("Explode!")
                current_tree = str(self)
                self.explode()
                if str(self) == current_tree:
                    state = "try_split"
                else:
                    state = "exploded"
            if state == "try_split":
                print("Split! (first time) {}".format(self))
                has_split = self.split()
                if has_split:
                    state = "split"
                else:
                    state = "stop"
            if state == "split":
                print("Split! {}".format(self))
                has_split = self.split()
                if has_split:
                    state = "split"
                else:
                    state = "try_explode"
        print("Reducing done tree: {}".format(self))
        return self

    def add_with_automation(self, tree):
        return self.add(tree).reduce()

    def __str__(self):
        return "[{},{}]".format(self.left, self.right)


sn1 = "[1,2]"
sn2 = "[[1,2],3]"
sn3 = "[9,[8,7]]"
sn4 = "[[1,9],[8,5]]"
sn5 = "[[[[1,2],[3,4]],[[5,6],[7,8]]],9]"
sn6 = "[[[9,[3,8]],[[0,9],6]],[[[3,7],[4,9]],3]]"
sn7 = "[[[[1,3],[5,3]],[[1,3],[8,7]]],[[[4,9],[6,9]],[[8,2],[7,3]]]]"
example_snailfish_numbers = [sn1, sn2, sn3, sn4, sn5, sn6, sn7]


class TestDay18(unittest.TestCase):
    def test_parse_splits_correctly(self):
        left_part, right_part = parse(sn1)
        self.assertEqual(left_part, "1")
        self.assertEqual(right_part, "2")

        left_part, right_part = parse(sn2)
        self.assertEqual(left_part, "[1,2]")
        self.assertEqual(right_part, "3")

        left_part, right_part = parse(sn3)
        self.assertEqual(left_part, "9")
        self.assertEqual(right_part, "[8,7]")

        left_part, right_part = parse(sn4)
        self.assertEqual(left_part, "[1,9]")
        self.assertEqual(right_part, "[8,5]")

        left_part, right_part = parse(sn5)
        self.assertEqual(left_part, "[[[1,2],[3,4]],[[5,6],[7,8]]]")
        self.assertEqual(right_part, "9")

        left_part, right_part = parse(sn6)
        self.assertEqual(left_part, "[[9,[3,8]],[[0,9],6]]")
        self.assertEqual(right_part, "[[[3,7],[4,9]],3]")

        left_part, right_part = parse(sn7)
        self.assertEqual(left_part, "[[[1,3],[5,3]],[[1,3],[8,7]]]")
        self.assertEqual(right_part, "[[[4,9],[6,9]],[[8,2],[7,3]]]")

    def test_parse_maintains_length_invariant(self):
        for sn in example_snailfish_numbers:
            left_part, right_part = parse(sn)
            self.assertEqual(len(left_part) + len(right_part), len(sn) - 3)

    def test_tree_string_representation_invariant(self):
        for sn in example_snailfish_numbers:
            self.assertEqual(str(Tree(sn)), sn)

    def test_tree_addition(self):
        t1 = Tree("[1,2]")
        t2 = Tree("[[3,4],5]")
        result = t1.add(t2)
        self.assertEqual(str(result), "[[1,2],[[3,4],5]]")

    def test_tree_explosion(self):
        tree = Tree("[[[[[9,8],1],2],3],4]")
        tree.explode()
        self.assertEqual(str(tree), "[[[[0,9],2],3],4]")

        tree = Tree("[7,[6,[5,[4,[3,2]]]]]")
        tree.explode()
        self.assertEqual(str(tree), "[7,[6,[5,[7,0]]]]")

        tree = Tree("[[6,[5,[4,[3,2]]]],1]")
        tree.explode()
        self.assertEqual(str(tree), "[[6,[5,[7,0]]],3]")

        tree = Tree("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]")
        tree.explode()
        self.assertEqual(str(tree), "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")

        tree = Tree("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")
        tree.explode()
        self.assertEqual(str(tree), "[[3,[2,[8,0]]],[9,[5,[7,0]]]]")

    # def test_tree_example_process(self):
    #     tree = Tree("[[[[4,3],4],4],[7,[[8,4],9]]]")
    #     tree = tree.add(Tree("[1,1]"))
    #     self.assertEqual(str(tree), "[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]")
    #     tree.explode()
    #     self.assertEqual(str(tree), "[[[[0,7],4],[7,[[8,4],9]]],[1,1]]")
    #     tree.explode()
    #     self.assertEqual(str(tree), "[[[[0,7],4],[15,[0,13]]],[1,1]]")
    #     tree.split()
    #     self.assertEqual(str(tree), "[[[[0,7],4],[[7,8],[0,13]]],[1,1]]")
    #     tree.split()
    #     self.assertEqual(str(tree), "[[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]")
    #     tree.explode()
    #     self.assertEqual(str(tree), "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")

    # def test_tree_automated_process(self):
    #     tree = Tree("[[[[4,3],4],4],[7,[[8,4],9]]]")
    #     tree = tree.add_with_automation("[1,1]")
    #     self.assertEqual(str(tree), "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")

    # def test_sanity_checks(self):
    #     tree = Tree("[1,1]")
    #     numbers = ["[2,2]", "[3,3]", "[4,4]"]
    #     for n in numbers:
    #         tree = tree.add_with_automation(n)
    #     self.assertEqual(str(tree), "[[[[1,1],[2,2]],[3,3]],[4,4]]")
    #     tree = tree.add_with_automation("[5,5]")
    #     self.assertEqual(str(tree), "[[[[3,0],[5,3]],[4,4]],[5,5]]")
    #     tree = tree.add_with_automation("[6,6]")
    #     self.assertEqual(str(tree), "[[[[5,0],[7,4]],[5,5]],[6,6]]")

    def test_larger_example(self):
        tree = Tree("[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]")
        numbers = [
            "[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]",
            # "[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]",
            # "[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]",
            # "[7,[5,[[3,8],[1,4]]]]",
            # "[[2,[2,2]],[8,[8,1]]]",
            # "[2,9]",
            # "[1,[[[9,3],9],[[9,0],[0,7]]]]",
            # "[[[5,[7,4]],7],1]",
            # "[[[[4,2],2],6],[8,7]]",
        ]
        # for n in numbers:
        #     ntree = Tree(n)
        #     tree = tree.add(ntree)
        #     print("Before reduction:   {}".format(tree))
        #     tree = tree.reduce()
        #     print("After reduction: ", tree)
        tt = Tree("[[[[4,0],[9,0]],[[7,7],[0,[6,7]]]],[[5,[5,5]],[[0,19],[0,7]]]]")
        # tree = tree.add(ntree)
        # tree = tree.reduce()
        # self.assertEqual(
        #     str(tree), "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]"
        # )


if __name__ == "__main__":
    unittest.main()

# every snailfish number is a pair
# elements can be either a regular number or a pair
# [x, y] denotes a pair
# addition is pairing [x1, x2] + [y1, y2] = [[x1, x2], [y1, y2]]
# snailfish numbers must be reduced, by:
#     * if any pair is nested in four pairs, leftmost explodes
#     * if any regular number is 10 or more, leftmost one splits
# reduced until neither reduction rule applies
# only one action can be applied in each reduction

# Exploding:
#
# add left and right values to the closest left and right regular numbers
# !!! the closest regular numbers can be more than one nesting level outside !!!
# can even be in a different pair
# exploded pair is replaced with 0
# exploding pair will always consist of two regular numbers

# Splitting:
#
# replace with a pair, with /2 rounded down to the left and /2 rounded up to the right

# result of the addition is the snailfish number that remains
