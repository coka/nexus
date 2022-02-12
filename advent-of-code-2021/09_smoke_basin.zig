const std = @import("std");
const ArrayList = std.ArrayList;
const print = std.debug.print;

const Stack = @import("stack.zig").Stack;

const Coordinate = struct {
    row: usize,
    col: usize,
};

// Due to puzzle input guarantees, knowing if a height is 9 is enough to know if
// that height is a basin boundary.
fn getRowData(allocator: *std.mem.Allocator, row: []u8) ![]bool {
    var data = try allocator.alloc(bool, row.len);
    for (row) |n, i| {
        data[i] = n == 9;
    }
    return data;
}

/// https://en.wikipedia.org/wiki/Flood_fill
fn floodFill(
    allocator: *std.mem.Allocator,
    low_point: Coordinate,
    map: [][]bool,
) !u64 {
    var stack = Stack(Coordinate).init(allocator);
    defer stack.deinit();
    try stack.push(low_point);
    var size: u64 = 0;
    while (stack.pop()) |node| {
        if (map[node.row][node.col]) {
            continue;
        } else {
            map[node.row][node.col] = true;
            size += 1;
        }
        if (node.row > 0) {
            try stack.push(Coordinate{ .row = node.row - 1, .col = node.col });
        }
        if (node.row < map.len - 1) {
            try stack.push(Coordinate{ .row = node.row + 1, .col = node.col });
        }
        if (node.col > 0) {
            try stack.push(Coordinate{ .row = node.row, .col = node.col - 1 });
        }
        if (node.col < map[0].len - 1) {
            try stack.push(Coordinate{ .row = node.row, .col = node.col + 1 });
        }
    }
    return size;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{ .read = true });
    defer file.close();
    const reader = file.reader();
    var buffer: [1024]u8 = undefined;

    var allocator = &std.heap.ArenaAllocator.init(std.heap.page_allocator).allocator;
    var rows = ArrayList(ArrayList(u8)).init(allocator);
    while (try reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        var row = ArrayList(u8).init(allocator);
        try row.ensureTotalCapacity(line.len);
        for (line) |n| {
            try row.append(try std.fmt.charToDigit(n, 10));
        }
        try rows.append(row);
    }

    var sum: u64 = 0;
    var low_points = ArrayList(Coordinate).init(allocator); // needed for part 2
    for (rows.items) |row, i| {
        for (row.items) |n, j| {
            if (i > 0) {
                const up = rows.items[i - 1].items[j];
                if (!(n < up)) continue;
            }
            if (i < rows.items.len - 1) {
                const down = rows.items[i + 1].items[j];
                if (!(n < down)) continue;
            }
            if (j > 0) {
                const left = row.items[j - 1];
                if (!(n < left)) continue;
            }
            if (j < row.items.len - 1) {
                const right = row.items[j + 1];
                if (!(n < right)) continue;
            }
            try low_points.append(Coordinate{ .row = i, .col = j });
            const risk_level = n + 1;
            sum += risk_level;
        }
    }
    print("{}\n", .{sum});

    var map: [][]bool = try allocator.alloc([]bool, rows.items.len);
    for (rows.items) |row, i| {
        var row_data = try getRowData(allocator, row.items);
        map[i] = row_data;
    }

    var largest_basins = [_]u64{ 0, 0, 0 };
    var write_index: usize = 0;
    for (low_points.items) |point| {
        const basin_size = try floodFill(allocator, point, map);
        if (write_index < largest_basins.len) {
            largest_basins[write_index] = basin_size;
            write_index += 1;
        } else {
            for (largest_basins) |size, i| {
                if (basin_size > size) {
                    largest_basins[i] = basin_size;
                    break;
                }
            }
        }
    }

    var answer: u64 = 1;
    for (largest_basins) |size| {
        answer *= size;
    }

    print("{}\n", .{answer});
}
