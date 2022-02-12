const std = @import("std");
const mem = std.mem;
const split = mem.split;
const Allocator = mem.Allocator;
const ArrayList = std.ArrayList;
const StringHashMap = std.StringHashMap;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const Point = struct {
    x: u64,
    y: u64,

    /// Turning a point back into its textual representation is useful for point
    /// map keys.
    pub fn toString(self: Point, allocator: *Allocator) ![]u8 {
        return try std.fmt.allocPrint(allocator, "{},{}", .{ self.x, self.y });
    }
};

const Line = struct {
    start: Point,
    end: Point,

    /// Returns all points that the line covers if the line is orthogonal, or
    /// null otherwise.
    pub fn getOrthogonalPoints(self: Line, allocator: *Allocator) !?[]Point {
        if (!self.isOrthogonal()) return null;

        var points = ArrayList(Point).init(allocator);
        defer points.deinit();

        if (self.isHorizontal()) {
            const span = try getHorizontalSpan(self, allocator);
            const y = self.start.y;
            for (span) |x| {
                try points.append(Point{ .x = x, .y = y });
            }
        } else {
            const span = try getVerticalSpan(self, allocator);
            const x = self.start.x;
            for (span) |y| {
                try points.append(Point{ .x = x, .y = y });
            }
        }

        const result = try allocator.alloc(Point, points.items.len);
        std.mem.copy(Point, result, points.items);
        return result;
    }

    /// Returns all points that the line covers.
    pub fn getPoints(self: Line, allocator: *Allocator) ![]Point {
        var points = ArrayList(Point).init(allocator);
        defer points.deinit();

        if (self.isHorizontal()) {
            const span = try getHorizontalSpan(self, allocator);
            const y = self.start.y;
            for (span) |x| {
                try points.append(Point{ .x = x, .y = y });
            }
        } else if (self.isVertical()) {
            const span = try getVerticalSpan(self, allocator);
            const x = self.start.x;
            for (span) |y| {
                try points.append(Point{ .x = x, .y = y });
            }
        } else {
            const hspan = try getHorizontalSpan(self, allocator);
            const vspan = try getVerticalSpan(self, allocator);
            for (hspan) |x, i| {
                try points.append(Point{ .x = x, .y = vspan[i] });
            }
        }

        const result = try allocator.alloc(Point, points.items.len);
        std.mem.copy(Point, result, points.items);
        return result;
    }

    fn isHorizontal(self: Line) bool {
        return self.start.y == self.end.y;
    }

    fn isVertical(self: Line) bool {
        return self.start.x == self.end.x;
    }

    fn isOrthogonal(self: Line) bool {
        return self.isHorizontal() or self.isVertical();
    }

    fn getHorizontalSpan(self: Line, allocator: *Allocator) ![]u64 {
        var coordinates = ArrayList(u64).init(allocator);
        defer coordinates.deinit();

        var start = self.start.x;
        var end = self.end.x;
        if (start < end) {
            while (start <= end) : (start += 1) {
                try coordinates.append(start);
            }
        } else {
            while (start >= end) : (start -= 1) {
                try coordinates.append(start);
            }
        }

        const result = try allocator.alloc(u64, coordinates.items.len);
        std.mem.copy(u64, result, coordinates.items);
        return result;
    }

    fn getVerticalSpan(self: Line, allocator: *Allocator) ![]u64 {
        var coordinates = ArrayList(u64).init(allocator);
        defer coordinates.deinit();

        var start = self.start.y;
        var end = self.end.y;
        if (start < end) {
            while (start <= end) : (start += 1) {
                try coordinates.append(start);
            }
        } else {
            while (start >= end) : (start -= 1) {
                try coordinates.append(start);
            }
        }

        const result = try allocator.alloc(u64, coordinates.items.len);
        std.mem.copy(u64, result, coordinates.items);
        return result;
    }
};

fn parse_point(s: []const u8) !Point {
    var numbers = split(u8, s, ",");
    const x = try parseInt(u64, numbers.next().?, 10);
    const y = try parseInt(u64, numbers.next().?, 10);
    return Point{ .x = x, .y = y };
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{ .read = true });
    defer file.close();

    const reader = file.reader();
    var buffer: [1024]u8 = undefined;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    // Keys represent points which lines cover. Values represent if there is an
    // overlap.
    var ortho_point_map = StringHashMap(bool).init(allocator);
    defer ortho_point_map.deinit();

    var point_map = StringHashMap(bool).init(allocator);
    defer point_map.deinit();

    while (try reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |input_line| {
        var segments = split(u8, input_line, " -> ");
        const start = try parse_point(segments.next().?);
        const end = try parse_point(segments.next().?);
        const line = Line{ .start = start, .end = end };
        if (try line.getOrthogonalPoints(allocator)) |points| {
            for (points) |p| {
                const key = try p.toString(allocator);
                if (ortho_point_map.get(key)) |v| {
                    if (!v) {
                        try ortho_point_map.put(key, true);
                    }
                } else {
                    try ortho_point_map.put(key, false);
                }
            }
        }
        const points = try line.getPoints(allocator);
        for (points) |p| {
            const key = try p.toString(allocator);
            if (point_map.get(key)) |v| {
                if (!v) {
                    try point_map.put(key, true);
                }
            } else {
                try point_map.put(key, false);
            }
        }
    }

    var ortho_overlaps: u64 = 0;
    var ortho_values = ortho_point_map.valueIterator();
    while (ortho_values.next()) |v| {
        if (v.*) {
            ortho_overlaps += 1;
        }
    }

    var overlaps: u64 = 0;
    var values = point_map.valueIterator();
    while (values.next()) |v| {
        if (v.*) {
            overlaps += 1;
        }
    }

    print("{}\n", .{ortho_overlaps});
    print("{}\n", .{overlaps});
}
