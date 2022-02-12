import operator
import unittest
from functools import reduce


hexchar_to_bits = {
    "0": "0000",
    "1": "0001",
    "2": "0010",
    "3": "0011",
    "4": "0100",
    "5": "0101",
    "6": "0110",
    "7": "0111",
    "8": "1000",
    "9": "1001",
    "A": "1010",
    "B": "1011",
    "C": "1100",
    "D": "1101",
    "E": "1110",
    "F": "1111",
}


def read_bits(bits, i, amount):
    ii = i + amount
    return bits[i:ii], ii


def bits_to_number(bits):
    return int(bits, 2)


def read_number(bits, i, amount):
    number_bits, i = read_bits(bits, i, amount)
    return bits_to_number(number_bits), i


def parse_literal(bits, i):
    number_bits = ""
    last_group = False
    while not last_group:
        group_bit, i = read_bits(bits, i, 1)
        last_group = group_bit == "0"
        group_bits, i = read_bits(bits, i, 4)
        number_bits += group_bits
    return bits_to_number(number_bits), i


typeid_to_value = {
    0: lambda values: sum(values),
    1: lambda values: reduce(operator.mul, values),
    2: lambda values: min(values),
    3: lambda values: max(values),
    5: lambda values: 1 if reduce(operator.gt, values) else 0,
    6: lambda values: 1 if reduce(operator.lt, values) else 0,
    7: lambda values: 1 if reduce(operator.eq, values) else 0,
}


def parse_packet(bits, i=0):
    packet = {}
    packet["version"], i = read_number(bits, i, 3)
    type_id, i = read_number(bits, i, 3)
    if type_id == 4:
        packet["value"], i = parse_literal(bits, i)
    else:
        packet["subpackets"] = []
        length_type_id, i = read_bits(bits, i, 1)
        if length_type_id == "0":
            subpacket_length, i = read_number(bits, i, 15)
            end_i = i + subpacket_length
            while i < end_i:
                subpacket, i = parse_packet(bits, i)
                packet["subpackets"].append(subpacket)
        else:
            num_of_subpackets, i = read_number(bits, i, 11)
            for _ in range(num_of_subpackets):
                subpacket, i = parse_packet(bits, i)
                packet["subpackets"].append(subpacket)
        subpacket_values = [p["value"] for p in packet["subpackets"]]
        packet["value"] = typeid_to_value[type_id](subpacket_values)
    return packet, i


def parse(transmission):
    bits = "".join([hexchar_to_bits[hc] for hc in transmission])
    packet, _ = parse_packet(bits)
    return packet


def sum_versions(packet):
    version = packet["version"]
    if "subpackets" in packet:
        subpackets = packet["subpackets"]
        return version + sum([sum_versions(p) for p in subpackets])
    else:
        return version


class TestDay16(unittest.TestCase):
    def setUp(self):
        self.input = open("inputs/16.txt")
        self.transmission = self.input.read()

    def tearDown(self):
        self.input.close()

    def test_literal_packet(self):
        packet = parse("D2FE28")
        self.assertEqual(packet["version"], 6)
        self.assertEqual(packet["value"], 2021)
        self.assertNotIn("subpackets", packet)

    def test_operator_with_subpacket_length(self):
        packet = parse("38006F45291200")
        self.assertEqual(packet["version"], 1)
        self.assertIn("subpackets", packet)
        subpackets = packet["subpackets"]
        self.assertEqual(len(subpackets), 2)
        self.assertEqual(subpackets[0]["value"], 10)
        self.assertEqual(subpackets[1]["value"], 20)

    def test_operator_with_subpacket_number(self):
        packet = parse("EE00D40C823060")
        self.assertEqual(packet["version"], 7)
        self.assertIn("subpackets", packet)
        subpackets = packet["subpackets"]
        self.assertEqual(len(subpackets), 3)
        self.assertEqual(subpackets[0]["value"], 1)
        self.assertEqual(subpackets[1]["value"], 2)
        self.assertEqual(subpackets[2]["value"], 3)

    def test_example_version_sums(self):
        self.assertEqual(sum_versions(parse("8A004A801A8002F478")), 16)
        self.assertEqual(sum_versions(parse("620080001611562C8802118E34")), 12)
        self.assertEqual(
            sum_versions(parse("C0015000016115A2E0802F182340")),
            23,
        )
        self.assertEqual(
            sum_versions(parse("A0016C880162017C3686B18A3D4780")),
            31,
        )

    def test_version_sum(self):
        self.assertEqual(sum_versions(parse(self.transmission)), 879)

    def test_example_values(self):
        self.assertEqual(parse("C200B40A82")["value"], 3)
        self.assertEqual(parse("04005AC33890")["value"], 54)
        self.assertEqual(parse("880086C3E88112")["value"], 7)
        self.assertEqual(parse("CE00C43D881120")["value"], 9)
        self.assertEqual(parse("D8005AC2A8F0")["value"], 1)
        self.assertEqual(parse("F600BC2D8F")["value"], 0)
        self.assertEqual(parse("9C005AC2F8F0")["value"], 0)
        self.assertEqual(parse("9C0141080250320F1802104A08")["value"], 1)

    def test_value(self):
        self.assertEqual(parse(self.transmission)["value"], 539051801941)


if __name__ == "__main__":
    unittest.main()
