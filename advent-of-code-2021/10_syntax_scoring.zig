const std = @import("std");
const print = std.debug.print;

const Stack = @import("stack.zig").Stack;

fn isOpeningChar(c: u8) bool {
    return switch (c) {
        '(' => true,
        '[' => true,
        '{' => true,
        '<' => true,
        else => false,
    };
}

fn getOpeningChar(c: u8) u8 {
    return switch (c) {
        ')' => '(',
        ']' => '[',
        '}' => '{',
        '>' => '<',
        else => unreachable,
    };
}

fn getIllegalCharScore(c: u8) u64 {
    return switch (c) {
        ')' => 3,
        ']' => 57,
        '}' => 1197,
        '>' => 25137,
        else => unreachable,
    };
}

fn getCompletionCharScore(c: u8) u64 {
    return switch (c) {
        '(' => 1,
        '[' => 2,
        '{' => 3,
        '<' => 4,
        else => unreachable,
    };
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{ .read = true });
    defer file.close();
    const reader = file.reader();

    var buffer: [1024]u8 = undefined;

    var syntax_error_score: u64 = 0;
    var allocator = &std.heap.ArenaAllocator.init(std.heap.page_allocator).allocator;
    var completion_scores = std.ArrayList(u64).init(allocator);
    while (try reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        var stack = Stack(u8).init(allocator);
        defer stack.deinit();
        var is_corrupt = false;
        for (line) |c| {
            if (isOpeningChar(c)) {
                try stack.push(c);
            } else {
                const opening_char = stack.pop();
                if (getOpeningChar(c) != opening_char) {
                    syntax_error_score += getIllegalCharScore(c);
                    is_corrupt = true;
                    break;
                }
            }
        }
        if (!is_corrupt) {
            var score: u64 = 0;
            while (stack.pop()) |opening_char| {
                score = score * 5 + getCompletionCharScore(opening_char);
            }
            try completion_scores.append(score);
        }
    }

    print("{}\n", .{syntax_error_score});

    std.sort.sort(u64, completion_scores.items, {}, comptime std.sort.asc(u64));
    const middle_index = completion_scores.items.len / 2;
    const middle_completion_score = completion_scores.items[middle_index];
    print("{}\n", .{middle_completion_score});
}
