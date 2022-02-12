def fix_expense_report2(numbers, target):
    """
    Given an array of numbers, find two numbers that sum to the target
    number, and return their product.
    """
    complements = {}
    for n in numbers:
        complements[target - n] = n
        if n in complements:
            return complements[n] * n


def fix_expense_report3(numbers, target):
    """
    Given an array of numbers, find three numbers that sum to the target
    number, and return their product.
    """
    for index, n in enumerate(numbers):
        maybe_fix = fix_expense_report2(numbers[index:], target - n)
        if maybe_fix is not None:
            return n * maybe_fix

example_input = [1721, 979, 366, 299, 675, 1456]
input = map(lambda line: int(line.strip()), open("input/1.txt").readlines())
target = 2020

print fix_expense_report2(example_input, target) # 514579
print fix_expense_report3(example_input, target) # 241861950

print fix_expense_report2(input, target) # 800139
print fix_expense_report3(input, target) # 59885340
