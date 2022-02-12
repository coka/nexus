const std = @import("std");
const mem = std.mem;
const parseInt = std.fmt.parseInt;

fn fuelCost(positions: std.ArrayList(i64), target: i64) i64 {
    var result: i64 = 0;
    for (positions.items) |p| {
        var distance = p - target;
        if (distance < 0) distance = -distance;

        // Part 1:
        // result += distance;

        // Part 2:
        // Apply the formula for 1 + 2 + 3 + ... + n.
        result += @divExact(distance * (distance + 1), 2);
    }
    return result;
}

pub fn main() !void {
    const allocator = &std.heap.ArenaAllocator.init(std.heap.page_allocator).allocator;
    const file = try std.fs.cwd().readFileAlloc(allocator, "input.txt", 4 * 1024 * 1024);
    var input_stream = mem.split(u8, mem.trimRight(u8, file, "\n"), ",");

    const initial_position = try parseInt(i64, input_stream.next().?, 10);
    var positions = std.ArrayList(i64).init(allocator);
    try positions.append(initial_position);

    var optimum = initial_position;
    var fuel = fuelCost(positions, optimum);

    while (input_stream.next()) |position| {
        var p = try parseInt(i64, position, 10);
        try positions.append(p);

        // Adding new positions at the optimum doesn't add to the fuel cost.
        if (p == optimum) continue;

        var updated_fuel: i64 = fuelCost(positions, p);
        fuel = updated_fuel;

        // A new optimum will always be somewhere between the current one and
        // the new position.
        if (p > optimum) {
            var i = optimum + 1;
            while (i < p) : (i += 1) {
                updated_fuel = fuelCost(positions, i);
                if (updated_fuel > fuel) break;
                optimum = i;
                fuel = updated_fuel;
            }
        } else {
            var i = optimum - 1;
            while (i > p) : (i -= 1) {
                updated_fuel = fuelCost(positions, i);
                if (updated_fuel > fuel) break;
                optimum = i;
                fuel = updated_fuel;
            }
        }
    }

    std.debug.print("Alignment position: {} ({} fuel)\n", .{ optimum, fuel });
}
