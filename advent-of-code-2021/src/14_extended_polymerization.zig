const std = @import("std");

/// There are 26 different polymer elements (one for each letter of the English
/// alphabet).
const num_of_elements = 26;

/// An order-independent 1:1 mapping between letters and indices.
fn toIndex(letter: u8) usize {
    switch (letter) {
        'A' => return 0,
        'B' => return 1,
        'C' => return 2,
        'D' => return 3,
        'E' => return 4,
        'F' => return 5,
        'G' => return 6,
        'H' => return 7,
        'I' => return 8,
        'J' => return 9,
        'K' => return 10,
        'L' => return 11,
        'M' => return 12,
        'N' => return 13,
        'O' => return 14,
        'P' => return 15,
        'Q' => return 16,
        'R' => return 17,
        'S' => return 18,
        'T' => return 19,
        'U' => return 20,
        'V' => return 21,
        'W' => return 22,
        'X' => return 23,
        'Y' => return 24,
        'Z' => return 25,
        else => unreachable,
    }
}

const num_of_pairs = num_of_elements * num_of_elements;

const PairInsertionRules = struct {
    /// All possible pair insertion rules can fit in a 26x26 matrix. If no rule
    /// exists for an element pair, that rule will be null. Otherwise, the rule
    /// will specify the index of the element which should be inserted.
    data: [num_of_pairs]?usize = [_]?usize{null} ** num_of_pairs,

    const Self = @This();

    pub fn add(self: *Self, pair: [2]u8, element: u8) void {
        const row = toIndex(pair[0]);
        const col = toIndex(pair[1]);
        self.data[row * num_of_elements + col] = toIndex(element);
    }
};

const Polymer = struct {
    /// It's useful to keep track of element counts as rules are being applied.
    /// This saves cycles when computing the puzzle answer.
    element_counts: [num_of_elements]i64 = [_]i64{0} ** num_of_elements,
    pair_counts: [num_of_pairs]i64 = [_]i64{0} ** num_of_pairs,

    const Self = @This();

    pub fn init(template: []const u8) Self {
        var self = Self{};
        var i: usize = 0;
        while (i < template.len) : (i += 1) {
            const letter = template[i];
            const e = toIndex(letter);
            self.element_counts[e] += 1;
            // As long as we're not on the last letter, we can create a pair
            // using the letter to the right.
            if (i < template.len - 1) {
                const right_letter = template[i + 1];
                const re = toIndex(right_letter);
                self.pair_counts[e * num_of_elements + re] += 1;
            }
        }
        return self;
    }

    pub fn apply(self: *Self, rules: PairInsertionRules) void {
        // Rules are applied in parallel, so if we mutate any pair counts during
        // iteration, we won't get the right result. This is also why i64 is
        // used, instead of the more semantically correct u64.
        var deltas = [_]i64{0} ** num_of_pairs;
        for (rules.data) |rule, pair_idx| {
            if (rule) |insertion_idx| {
                const pairs = self.pair_counts[pair_idx];
                const left = pair_idx / num_of_elements;
                const right = pair_idx % num_of_elements;

                // A number of pairs will "break" after insertion...
                deltas[pair_idx] -= pairs;

                // ... and twice as many new, different pairs will form.
                deltas[left * num_of_elements + insertion_idx] += pairs;
                deltas[insertion_idx * num_of_elements + right] += pairs;

                self.element_counts[insertion_idx] += pairs;
            }
        }
        for (deltas) |d, i| {
            self.pair_counts[i] += d;
        }
    }
};

fn answer(input: []const u8, steps: u64) i64 {
    var lines = std.mem.split(u8, input, "\n");
    const polymer_template = lines.next().?;
    var polymer = Polymer.init(polymer_template);
    var rule_definitions = std.mem.split(
        u8,
        std.mem.trim(u8, lines.rest(), "\n"),
        "\n",
    );
    var rules = PairInsertionRules{};
    while (rule_definitions.next()) |rule| {
        var parts = std.mem.split(u8, rule, " -> ");
        const pair = parts.next().?;
        const element = parts.next().?;
        rules.add(pair[0..2].*, element[0]);
    }
    var step: u64 = 0;
    while (step < steps) : (step += 1) {
        polymer.apply(rules);
    }
    var most_common: ?i64 = null;
    var least_common: ?i64 = null;
    for (polymer.element_counts) |ec| {
        // Elements with a count of 0 don't exist in our polymer.
        if (ec > 0) {
            if (most_common == null or most_common.? < ec) {
                most_common = ec;
            }
            if (least_common == null or least_common.? > ec) {
                least_common = ec;
            }
        }
    }
    return most_common.? - least_common.?;
}

const example_input =
    \\NNCB
    \\
    \\CH -> B
    \\HH -> N
    \\CB -> H
    \\NH -> C
    \\HB -> C
    \\HC -> B
    \\HN -> C
    \\NN -> C
    \\BH -> H
    \\NC -> B
    \\NB -> B
    \\BN -> B
    \\BB -> N
    \\BC -> B
    \\CC -> N
    \\CN -> C
    \\
;

test "Day 14: Extended Polymerization (example input)" {
    try std.testing.expectEqual(@as(i64, 1588), answer(example_input, 10));
}

test "Day 14: Extended Polymerization" {
    const input = try std.fs.cwd().readFileAlloc(
        std.testing.allocator,
        "inputs/14.txt",
        4 * 1024 * 1024,
    );
    defer std.testing.allocator.free(input);
    try std.testing.expectEqual(@as(i64, 3284), answer(input, 10));
}

test "Day 14: Extended Polymerization, Part Two (example input)" {
    try std.testing.expectEqual(
        @as(i64, 2188189693529),
        answer(example_input, 40),
    );
}

test "Day 14: Extended Polymerization, Part Two" {
    const input = try std.fs.cwd().readFileAlloc(
        std.testing.allocator,
        "inputs/14.txt",
        4 * 1024 * 1024,
    );
    defer std.testing.allocator.free(input);
    try std.testing.expectEqual(@as(i64, 4302675529689), answer(input, 40));
}
