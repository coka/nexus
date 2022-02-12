const std = @import("std");
const print = std.debug.print;

fn stringEquals(s1: []const u8, s2: []const u8) bool {
    return std.mem.eql(u8, s1, s2);
}

const Command = enum {
    Forward,
    Down,
    Up,
    Unknown,

    pub fn fromString(s: []const u8) Command {
        if (stringEquals(s, "forward")) {
            return .Forward;
        } else if (stringEquals(s, "down")) {
            return .Down;
        } else if (stringEquals(s, "up")) {
            return .Up;
        } else {
            return .Unknown;
        }
    }
};

const Submarine = struct {
    position: u64,
    depth: u64,

    pub fn init() Submarine {
        return Submarine{
            .position = 0,
            .depth = 0,
        };
    }

    pub fn execute(self: *Submarine, command: Command, value: u64) void {
        switch (command) {
            .Forward => self.position += value,
            .Down => self.depth += value,
            .Up => self.depth -= value,
            .Unknown => unreachable,
        }
    }
};

const SubmarineWithAim = struct {
    position: u64,
    depth: u64,
    aim: u64,

    pub fn init() SubmarineWithAim {
        return SubmarineWithAim{
            .position = 0,
            .depth = 0,
            .aim = 0,
        };
    }

    pub fn execute(self: *SubmarineWithAim, command: Command, value: u64) void {
        switch (command) {
            .Forward => {
                self.position += value;
                self.depth += self.aim * value;
            },
            .Down => self.aim += value,
            .Up => self.aim -= value,
            .Unknown => unreachable,
        }
    }
};

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{ .read = true });
    defer file.close();

    const reader = file.reader();
    var buffer: [1024]u8 = undefined;

    var submarine = Submarine.init();
    var submarine_with_aim = SubmarineWithAim.init();

    while (try reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        var tokens = std.mem.tokenize(u8, line, " ");
        if (tokens.next()) |command| {
            if (tokens.next()) |value| {
                const c = Command.fromString(command);
                const v = try std.fmt.parseInt(u64, value, 10);
                submarine.execute(c, v);
                submarine_with_aim.execute(c, v);
            }
        }
    }

    print("{}\n", .{submarine.position * submarine.depth});
    print("{}\n", .{submarine_with_aim.position * submarine_with_aim.depth});
}
