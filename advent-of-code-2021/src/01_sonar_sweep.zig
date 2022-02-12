const std = @import("std");

const example_input =
    \\199
    \\200
    \\208
    \\210
    \\200
    \\207
    \\240
    \\269
    \\260
    \\263
    \\
;

fn getLines(input: []const u8) std.mem.SplitIterator(u8) {
    return std.mem.split(u8, std.mem.trimRight(u8, input, "\n"), "\n");
}

fn parse(line: []const u8) !u32 {
    return try std.fmt.parseInt(u32, line, 10);
}

fn countIncreases(input: []const u8) !u32 {
    var increases: u32 = 0;
    var lines = getLines(input);
    const first_line = lines.next().?;
    var previous_measurement = try parse(first_line);
    while (lines.next()) |line| {
        const current_measurement = try parse(line);
        if (current_measurement > previous_measurement) {
            increases += 1;
        }
        previous_measurement = current_measurement;
    }
    return increases;
}

test "Day 1: Sonar Sweep (example input)" {
    const result = try countIncreases(example_input);
    try std.testing.expectEqual(@as(u32, 7), result);
}

test "Day 1: Sonar Sweep" {
    const max_bytes: usize = 4 * 1024 * 1024;
    const input = try std.fs.cwd().readFileAlloc(
        std.testing.allocator,
        "inputs/01.txt",
        max_bytes,
    );
    defer std.testing.allocator.free(input);
    const result = try countIncreases(input);
    try std.testing.expectEqual(@as(u32, 1722), result);
}

const SlidingWindow = struct {
    data: [3]?u32 = .{ null, null, null },
    index: usize = 0,

    pub fn insert(self: *SlidingWindow, measurement: u32) void {
        self.data[self.index] = measurement;
        self.index = (self.index + 1) % 3;
    }

    pub fn sum(self: *SlidingWindow) ?u32 {
        var result: u32 = 0;
        for (self.data) |n_or_null| {
            if (n_or_null) |n| {
                result += n;
            } else {
                return null;
            }
        }
        return result;
    }
};

fn countSlidingWindowIncreases(input: []const u8) !u32 {
    var increases: u32 = 0;
    var lines = getLines(input);
    var sliding_window = SlidingWindow{};
    var previous_sum = sliding_window.sum();
    while (lines.next()) |line| {
        const current_measurement = try parse(line);
        sliding_window.insert(current_measurement);
        const current_sum = sliding_window.sum();
        if (previous_sum) |psum| {
            if (current_sum) |csum| {
                if (csum > psum) {
                    increases += 1;
                }
            }
        }
        previous_sum = current_sum;
    }
    return increases;
}

test "Day 1: Sonar Sweep, Part Two (example input)" {
    const result = try countSlidingWindowIncreases(example_input);
    try std.testing.expectEqual(@as(u32, 5), result);
}

test "Day 1: Sonar Sweep, Part Two" {
    const max_bytes: usize = 4 * 1024 * 1024;
    const input = try std.fs.cwd().readFileAlloc(
        std.testing.allocator,
        "inputs/01.txt",
        max_bytes,
    );
    defer std.testing.allocator.free(input);
    const result = try countSlidingWindowIncreases(input);
    try std.testing.expectEqual(@as(u32, 1748), result);
}
