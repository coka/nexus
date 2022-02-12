const std = @import("std");
const print = std.debug.print;

const Simulation = struct {
    /// A histogram of adult lanternfish cycles.
    fish: [7]u64 = [7]u64{ 0, 0, 0, 0, 0, 0, 0 },

    /// It takes 2 cycles for a new lanternfish to become an adult.
    babies: [2]u64 = [2]u64{ 0, 0 },

    /// Simulates n cycles.
    pub fn advance_by(self: *Simulation, n: usize) void {
        var step: usize = 0;
        while (step < n) : (step += 1) {
            const new_adults = self.babies[0];
            self.babies[0] = self.babies[1];
            self.babies[1] = self.fish[0];
            var i: usize = 0;
            while (i < 6) : (i += 1) {
                std.mem.swap(u64, &self.fish[i], &self.fish[i + 1]);
            }
            self.fish[6] += new_adults;
        }
    }

    pub fn count(self: Simulation) u64 {
        var result: u64 = 0;
        for (self.fish) |n| result += n;
        return result + self.babies[0] + self.babies[1];
    }
};

const expect = std.testing.expect;
const eql = std.mem.eql;
const test_fish = [7]u64{ 0, 1, 1, 2, 1, 0, 0 };

test "first few steps" {
    var sim = Simulation{ .fish = test_fish };

    try expect(sim.count() == 5);

    sim.advance_by(1);
    try expect(eql(u64, &sim.fish, &[7]u64{ 1, 1, 2, 1, 0, 0, 0 }));
    try expect(eql(u64, &sim.babies, &[2]u64{ 0, 0 }));
    try expect(sim.count() == 5);

    sim.advance_by(1);
    try expect(eql(u64, &sim.fish, &[7]u64{ 1, 2, 1, 0, 0, 0, 1 }));
    try expect(eql(u64, &sim.babies, &[2]u64{ 0, 1 }));
    try expect(sim.count() == 6);

    sim.advance_by(1);
    try expect(eql(u64, &sim.fish, &[7]u64{ 2, 1, 0, 0, 0, 1, 1 }));
    try expect(eql(u64, &sim.babies, &[2]u64{ 1, 1 }));
    try expect(sim.count() == 7);
}

test "18 steps" {
    var sim = Simulation{ .fish = test_fish };
    sim.advance_by(18);
    try expect(sim.count() == 26);
}

test "80 steps" {
    var sim = Simulation{ .fish = test_fish };
    sim.advance_by(80);
    try expect(sim.count() == 5934);
}

test "256 steps" {
    var sim = Simulation{ .fish = test_fish };
    sim.advance_by(256);
    try expect(sim.count() == 26984457539);
}

pub fn main() !void {
    const input = std.mem.trimRight(
        u8,
        try std.fs.cwd().readFileAlloc(
            &std.heap.ArenaAllocator.init(std.heap.page_allocator).allocator,
            "input.txt",
            4 * 1024 * 1024,
        ),
        "\n",
    );

    var sim = Simulation{};
    var numbers = std.mem.split(u8, input, ",");
    while (numbers.next()) |n| {
        sim.fish[try std.fmt.parseInt(usize, n, 10)] += 1;
    }

    sim.advance_by(80);
    print("{}\n", .{sim.count()});
    sim.advance_by(256 - 80);
    print("{}\n", .{sim.count()});
}
