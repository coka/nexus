const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: *Allocator,
        items: []T,
        len: usize,

        pub fn init(allocator: *Allocator) Self {
            return Self{
                .allocator = allocator,
                .items = &[_]T{},
                .len = 0,
            };
        }

        pub fn deinit(self: Self) void {
            self.allocator.free(self.items);
        }

        pub fn push(self: *Self, item: T) !void {
            const new_len = self.len + 1;
            const capacity = self.items.len;
            if (new_len > capacity) {
                self.items = try self.allocator.realloc(self.items, capacity + 1);
            }
            self.items[self.len] = item;
            self.len = new_len;
        }

        pub fn pop(self: *Self) ?T {
            if (self.len > 0) {
                self.len -= 1;
                return self.items[self.len];
            } else {
                return null;
            }
        }
    };
}

const testing = std.testing;
const expectEqual = testing.expectEqual;

test "Stack" {
    var subject = Stack(u32).init(testing.allocator);
    defer subject.deinit();
    try subject.push(42);
    try subject.push(3);
    try subject.push(4);
    try expectEqual(@as(?u32, 4), subject.pop());
    try expectEqual(@as(?u32, 3), subject.pop());
    try expectEqual(@as(?u32, 42), subject.pop());
    try expectEqual(@as(?u32, null), subject.pop());
}
