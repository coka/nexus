import math
import unittest

# TODO Parse input.


example = {
    "left": 20,
    "right": 30,
    "top": -5,
    "bottom": -10,
}


real = {
    "left": 288,
    "right": 330,
    "top": -50,
    "bottom": -96,
}


def max_height(bottom):
    max_y_velocity = abs(bottom) - 1
    return (max_y_velocity * (max_y_velocity + 1)) / 2


# def count_initial_velocities(input):
#     left = input["left"]
#     right = input["right"]
#     x_targets = right - left

#     top = input["top"]
#     bottom = input["bottom"]
#     direct_minus_y_throws = abs(bottom - top)
#     y_possibilities = {}
#     for i in range(bottom, -bottom):
#         height = 0
#         steps = 0
#         velocity = 0
#         if i > 0:
#             steps = (2 * i) + 1
#             velocity = i + 1

#     velocities = x_targets * direct_minus_y_throws

#     sss = set()
#     for i in range(direct_minus_y_throws):
#         v = -i - 1
#         steps_to_target = bottom // v
#         if steps_to_target in sss:
#             continue
#         else:
#             sss.add(steps_to_target)
#             targets = x_targets // steps_to_target
#             velocities += steps_to_target * targets

#     for i in range(direct_minus_y_throws):
#         height = 0
#         velocity = -i - 1
#         s = (2 * i) + 1
#         while True:
#             height += velocity
#             velocity += 1
#             if height <= top and height >= bottom:
#                 break
#             s += 1
#         targets = x_targets // s
#         velocities += s * targets

#     return velocities


def count_initial_velocities(input):
    top = input["top"]
    bottom = input["bottom"]
    y_possibilities = {}  # initial y-velocity to number of times it hits
    for vy in range(bottom, -bottom):
        height = 0
        steps = 0
        velocity = vy
        if vy > 0:  # can get the number of steps until at 0 again directly
            steps = (2 * vy) + 1
            velocity = -vy - 1
        while True:
            # if vy == 3:
            #     print("Trying for 3!")
            steps += 1
            # if vy == 3:
            #     print("Velocity is: ", velocity)
            height += velocity
            # if vy == 3:
            #     print("After ", steps, " steps, the height is: ", height)
            if height <= top and height >= bottom:
                # if vy == 3:
                #     print("Adding ", steps, "steps to 3!")
                if vy in y_possibilities:
                    y_possibilities[vy].append(steps)
                else:
                    y_possibilities[vy] = [steps]
            if height < bottom:
                break
            velocity -= 1

    left = input["left"]
    right = input["right"]
    min_vx = 0
    while (min_vx * (min_vx + 1)) / 2 < left:
        min_vx += 1
    print("Min X velocity: ", min_vx)

    max_vx = 0
    while (max_vx * (max_vx + 1)) / 2 < right:
        max_vx += 1
    max_vx -= 1
    print("Max X velocity: ", max_vx)
    # for vx in range(min_x, max_x):
    #     x_ways = 0
    #     for vx in range(min_x, max_x + 1):
    #         x = 0
    #         steps = 0
    #         v = vx
    #         while x < right:
    #             x += v
    #             steps += 1
    #             if x >= left and x <= right and steps == nsteps:
    #                 x_ways += 1
    #                 break
    #     x_possibilities.append(x_ways)
    # print(x_possibilities)
    # step_possibilities = set(y_possibilities.keys())
    # print(step_possibilities)
    # result = 0
    # for vy, steps in enumerate(y_possibilities):
    #     for nsteps in steps:
    #         for vx in range(min_vx, right + 1):
    #             x = 0
    #             xsteps = 0
    #             v = vx
    #             while x < right and steps <= nsteps:
    #             x += v
    #             steps += 1
    #             v -= 1
    #             if x >= left and x <= right and steps == nsteps:
    #                 result += 1
    #                 break
    # result += len(y_possibilities.keys()) * i
    combos = {}
    for vy, all_step_possibz in y_possibilities.items():
        for num_of_steps in all_step_possibz:
            for vx in range(min_vx, right + 1):
                if vy == 3:
                    print("Trying for velocity ", vx, ", steps", num_of_steps)
                vel = vx
                x_final = 0
                for _ in range(num_of_steps):
                    x_final += vel
                    if vel > 0:
                        vel -= 1
                if vy == 3:
                    print("Final X for ", vx, " is ", x_final)
                if x_final >= left and x_final <= right:
                    if vy == 3:
                        "Hit!"
                    if vy in combos:
                        combos[vy].add(vx)
                    else:
                        combos[vy] = set([vx])

    # assert len(combos[-10]) == 11
    # assert len(combos[-9]) == 11
    # assert len(combos[-8]) == 11
    # assert len(combos[-7]) == 11
    # assert len(combos[-6]) == 11
    # assert len(combos[-5]) == 11
    # assert len(combos[-4]) == 5
    # assert len(combos[-3]) == 5
    # assert len(combos[-2]) == 8
    # assert len(combos[-1]) == 5
    # assert len(combos[0]) == 4
    # assert len(combos[1]) == 3
    # print(combos[2])
    # assert len(combos[2]) == 2
    # print(combos[3])
    # assert len(combos[3]) == 2
    # # print(combos[4])
    # assert len(combos[4]) == 2
    # assert len(combos[5]) == 2
    # assert len(combos[6]) == 2
    # assert len(combos[7]) == 2
    # assert len(combos[8]) == 2
    # assert len(combos[9]) == 2

    result = 0
    for vy, vx in combos.items():
        result += len(vx)
    return result


class TestDay16(unittest.TestCase):
    def test_max_height(self):
        self.assertEqual(max_height(example["bottom"]), 45)
        self.assertEqual(max_height(real["bottom"]), 4560)

    def test_max_height(self):
        self.assertEqual(count_initial_velocities(example), 112)
        self.assertEqual(count_initial_velocities(real), 112)  # 3276 is too low


if __name__ == "__main__":
    unittest.main()


# def max_y_or_miss(velocity, top, bottom):
#     y = 0
#     max_y = y
#     v = velocity
#     while True:
#         y += v
#         if v > 0:
#             max_y = y
#         else:
#             if top >= y <= bottom:
#                 return max_y
#             else:
#                 return None


# example = {
#     "x1": 20,
#     "y1": -10,
#     "x2": 30,
#     "y2": -5,
# }


# def is_miss(initial_v, top, bottom):
#     y = 0
#     v = -initial_v - 1
#     while True:
#         y += v
#         if y <= top and y >= bottom:
#             return False
#         if y < bottom:
#             return True


# print(is_miss(6, -5, -10))


# # velocity = 0
# # max_height = 0
# # overshooting = False
# # while True:
# #     print(velocity)
# #     highest = max_y_or_miss(velocity, -5, -10)
# #     busted = highest is None
# #     if busted:
# #         if overshooting:
# #             overshooting = False
# #         else:
# #             max_height = highest
# #     if highest is None and not overshooting:
# #         break
# #     velocity += 1
# # print("Max height:")
# # print(max_height)

# # print(max_y_or_miss(9, -5, -10))

# # 1081 is too low

# # print(highest_or_bust(9, -5, -10))
# # my = 0
# # velocity = 0
# # while True:
# #     if print(highest_or_bust(9, -96, -50))

top = -50
bottom = -96
height = abs(bottom - 50)
hits = 0
# for i in range()
# x_targets = 330 - 288
# 46 ways to throw in -y directly, x_targets ways to do that
# -> each y from 0 to 46 will land in box
# each y from -47 to 0 will land in ? steps, and floor(x_targets / 2) to do that
# there's a min_x and max_x for
