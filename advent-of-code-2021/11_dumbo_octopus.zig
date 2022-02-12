const std = @import("std");
const print = std.debug.print;

const grid_size = 10;
const Grid = [grid_size][grid_size]u8;

const Simulation = struct {
    octopi: Grid = undefined,
    flashes: u64 = 0,

    pub fn advance_by(self: *Simulation, steps: usize) void {
        var step: usize = 0;
        while (step < steps) : (step += 1) {
            self.energize();
            while (self.flash()) {}
        }
    }

    pub fn advance_until_flash(self: *Simulation) usize {
        var steps: usize = 0;
        while (true) {
            const current_flashes = self.flashes;
            self.advance_by(1);
            steps += 1;
            if (self.flashes - current_flashes == grid_size * grid_size) {
                return steps;
            }
        }
    }

    /// Increases the energy level of each octopus by 1.
    fn energize(self: *Simulation) void {
        for (self.octopi) |row, i| {
            for (row) |_, j| {
                self.octopi[i][j] += 1;
            }
        }
    }

    /// Triggers the flash of each octopus with enough energy. Returns if
    /// surrounding energy levels have been adjusted,
    fn flash(self: *Simulation) bool {
        var adjusted = false;
        for (self.octopi) |row, i| {
            for (row) |_, j| {
                if (self.octopi[i][j] > 9) {
                    self.octopi[i][j] = 0;
                    self.flashes += 1;

                    // Because of how the Zig compiler treats potential
                    // overflows, it is somewhat simpler to manually unroll
                    // energy increasing logic for the surrounding 8 octopi.
                    if (i > 0) {
                        if (j > 0) {
                            if (self.octopi[i - 1][j - 1] != 0) {
                                self.octopi[i - 1][j - 1] += 1;
                                adjusted = true;
                            }
                        }
                        if (self.octopi[i - 1][j] != 0) {
                            self.octopi[i - 1][j] += 1;
                            adjusted = true;
                        }
                        if (j < grid_size - 1) {
                            if (self.octopi[i - 1][j + 1] != 0) {
                                self.octopi[i - 1][j + 1] += 1;
                                adjusted = true;
                            }
                        }
                    }
                    if (j > 0) {
                        if (self.octopi[i][j - 1] != 0) {
                            self.octopi[i][j - 1] += 1;
                            adjusted = true;
                        }
                    }
                    if (j < grid_size - 1) {
                        if (self.octopi[i][j + 1] != 0) {
                            self.octopi[i][j + 1] += 1;
                            adjusted = true;
                        }
                    }
                    if (i < grid_size - 1) {
                        if (j > 0) {
                            if (self.octopi[i + 1][j - 1] != 0) {
                                self.octopi[i + 1][j - 1] += 1;
                                adjusted = true;
                            }
                        }
                        if (self.octopi[i + 1][j] != 0) {
                            self.octopi[i + 1][j] += 1;
                            adjusted = true;
                        }
                        if (j < grid_size - 1) {
                            if (self.octopi[i + 1][j + 1] != 0) {
                                self.octopi[i + 1][j + 1] += 1;
                                adjusted = true;
                            }
                        }
                    }
                }
            }
        }
        return adjusted;
    }
};

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{ .read = true });
    defer file.close();
    const reader = file.reader();
    var buffer: [1024]u8 = undefined;
    var sim = Simulation{};
    var i: usize = 0;
    while (try reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (i += 1) {
        for (line) |c, j| {
            sim.octopi[i][j] = try std.fmt.charToDigit(c, 10);
        }
    }

    // sim.advance_by(100);
    // print("{}\n", .{sim.flashes});

    const steps = sim.advance_until_flash();
    print("{}\n", .{steps});
}
