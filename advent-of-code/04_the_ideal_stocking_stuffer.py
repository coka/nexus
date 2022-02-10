import hashlib

input = "yzbqklnj"


def answer1(input):
    n = 1
    while True:
        hash = hashlib.md5(str.encode(input + str(n))).hexdigest()
        if hash[:5] == "00000":
            return n
        else:
            n += 1


def answer2(input):
    n = 1
    while True:
        hash = hashlib.md5(str.encode(input + str(n))).hexdigest()
        if hash[:6] == "000000":
            return n
        else:
            n += 1


print(answer1(input))  # 282749
print(answer2(input))  # 9962624
