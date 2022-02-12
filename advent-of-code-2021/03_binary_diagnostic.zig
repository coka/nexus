const std = @import("std");
const ArrayList = std.ArrayList;
const fmt = std.fmt;
const parseInt = fmt.parseInt;
const print = std.debug.print;

fn filter_oxygen_generator_data(
    allocator: *std.mem.Allocator,
    lines_ptr: *ArrayList([]const u8),
    index: u64,
) !*ArrayList([]const u8) {
    const lines = lines_ptr.*.items;

    var ones: u64 = 0;
    var zeros: u64 = 0;
    for (lines) |line| {
        if (line[index] == '1') {
            ones += 1;
        } else {
            zeros += 1;
        }
    }

    const bit: u8 = if (ones >= zeros) '1' else '0';

    var filtered_lines = ArrayList([]const u8).init(allocator);
    for (lines) |line| {
        if (line[index] == bit) {
            try filtered_lines.append(line);
        }
    }
    return &filtered_lines;
}

fn filter_co2_scrubber_data(
    allocator: *std.mem.Allocator,
    lines_ptr: *ArrayList([]const u8),
    index: u64,
) !*ArrayList([]const u8) {
    const lines = lines_ptr.*.items;

    var ones: u64 = 0;
    var zeros: u64 = 0;
    for (lines) |line| {
        if (line[index] == '1') {
            ones += 1;
        } else {
            zeros += 1;
        }
    }

    const bit: u8 = if (zeros <= ones) '0' else '1';

    var filtered_lines = ArrayList([]const u8).init(allocator);
    for (lines) |line| {
        if (line[index] == bit) {
            try filtered_lines.append(line);
        }
    }
    return &filtered_lines;
}

fn parseBinary(s: []const u8) !u64 {
    return try parseInt(u64, s, 2);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    const max_bytes = 4 * 1024 * 1024;
    const input = try std.fs.cwd().readFileAlloc(
        allocator,
        "input.txt",
        max_bytes,
    );
    var line_iterator = std.mem.tokenize(u8, input, "\n");
    var lines = ArrayList([]const u8).init(allocator);
    while (line_iterator.next()) |line| {
        try lines.append(line);
    }

    const line_length = lines.items[0].len;

    var bit_counts = ArrayList(u64).init(allocator);
    var i: usize = 0;
    while (i < line_length) : (i += 1) {
        try bit_counts.append(0);
    }

    for (lines.items) |line| {
        for (line) |char, index| {
            bit_counts.items[index] += try fmt.charToDigit(char, 10);
        }
    }

    const threshold = lines.items.len / 2;
    var gamma_rate_bits = ArrayList(u8).init(allocator);
    var epsilon_rate_bits = ArrayList(u8).init(allocator);
    i = 0;
    while (i < line_length) : (i += 1) {
        if (bit_counts.items[i] > threshold) {
            try gamma_rate_bits.append('1');
            try epsilon_rate_bits.append('0');
        } else {
            try gamma_rate_bits.append('0');
            try epsilon_rate_bits.append('1');
        }
    }

    const gamma_rate = try parseBinary(gamma_rate_bits.items);
    const epsilon_rate = try parseBinary(epsilon_rate_bits.items);
    const power_consumption = gamma_rate * epsilon_rate;
    print("{}\n", .{power_consumption});

    var rating_lines: *ArrayList([]const u8) = &lines;
    i = 0;
    while (rating_lines.*.items.len != 1) : (i += 1) {
        rating_lines = try filter_oxygen_generator_data(allocator, rating_lines, i);
    }
    const oxygen_generator_rating = try parseBinary(rating_lines.*.items[0]);

    rating_lines = &lines;
    i = 0;
    while (rating_lines.*.items.len != 1) : (i += 1) {
        rating_lines = try filter_co2_scrubber_data(allocator, rating_lines, i);
    }
    const co2_scrubber_rating = try parseBinary(rating_lines.*.items[0]);

    const life_support_rating = oxygen_generator_rating * co2_scrubber_rating;
    print("{}\n", .{life_support_rating});
}
