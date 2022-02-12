const std = @import("std");

// A seven-segment display has segments in 7 positions. We can assign a number
// to each position:
//
// 0: top          ( - )
// 1: top-left     (|  )
// 2: top-right    (  |)
// 3: middle       ( - )
// 4: bottom-left  (|  )
// 5: bottom-right (  |)
// 6: bottom       ( - )
//
// All display states can be represented using 7 bits. When a bit is set to 1,
// that means that the segment is ON. Starting with the least significant bit
// for the segment at position 0, these are the encodings for each segment:

const s0: u8 = 0b0_0000001;
const s1: u8 = 0b0_0000010;
const s2: u8 = 0b0_0000100;
const s3: u8 = 0b0_0001000;
const s4: u8 = 0b0_0010000;
const s5: u8 = 0b0_0100000;
const s6: u8 = 0b0_1000000;

// This is just a convention. Here we are using 8-bit values because hardware.
// Also, they play nicer with Zig's compiler messages.

// States which represent digits are given:

const d0: u8 = s0 ^ s1 ^ s2 ^ s4 ^ s5 ^ s6;
const d1: u8 = s2 ^ s5;
const d2: u8 = s0 ^ s2 ^ s3 ^ s4 ^ s6;
const d3: u8 = s0 ^ s2 ^ s3 ^ s5 ^ s6;
const d4: u8 = s1 ^ s2 ^ s3 ^ s5;
const d5: u8 = s0 ^ s1 ^ s3 ^ s5 ^ s6;
const d6: u8 = s0 ^ s1 ^ s3 ^ s4 ^ s5 ^ s6;
const d7: u8 = s0 ^ s2 ^ s5;
const d8: u8 = s0 ^ s1 ^ s2 ^ s3 ^ s4 ^ s5 ^ s6;
const d9: u8 = s0 ^ s1 ^ s2 ^ s3 ^ s5 ^ s6;

fn toDigit(display: u8) u8 {
    switch (display) {
        d0 => return '0',
        d1 => return '1',
        d2 => return '2',
        d3 => return '3',
        d4 => return '4',
        d5 => return '5',
        d6 => return '6',
        d7 => return '7',
        d8 => return '8',
        d9 => return '9',
        else => unreachable,
    }
}

// The letters "abcdefg" represent wires which map to segments. We can assign
// unique bit values to each of these wires as well.

fn encode(wire: u8) u8 {
    switch (wire) {
        'a' => return s0,
        'b' => return s1,
        'c' => return s2,
        'd' => return s3,
        'e' => return s4,
        'f' => return s5,
        'g' => return s6,
        else => unreachable,
    }
}

const empty_display: u8 = 0b0_0000000;
fn encodeLetters(letters: []const u8) u8 {
    var result: u8 = empty_display;
    for (letters) |l| {
        const wire = encode(l);
        result |= wire;
    }
    return result;
}

// Then, we can define a helper type for mapping letters to digits.

const WireMap = std.AutoHashMap(u8, u8);

/// Given two patterns, return a pattern containing only segments that are ON
/// only in the first one.
fn diff(p1: u8, p2: u8) u8 {
    return p1 & (p1 ^ p2);
}

fn determine(sequence: []const u8) !WireMap {
    // These patterns have a unique number of segments.
    var p1: u8 = undefined;
    var p4: u8 = undefined;
    var p7: u8 = undefined;
    var p8: u8 = undefined;

    // These patterns have one segment less than an 8.
    var p0_and_p6_and_p9: [3]u8 = undefined;

    var writer_idx: usize = 0;
    var letters = std.mem.split(u8, sequence, " ");
    while (letters.next()) |l| {
        switch (l.len) {
            2 => p1 = encodeLetters(l),
            3 => p7 = encodeLetters(l),
            4 => p4 = encodeLetters(l),
            7 => p8 = encodeLetters(l),
            6 => {
                p0_and_p6_and_p9[writer_idx] = encodeLetters(l);
                writer_idx += 1;
            },
            else => continue,
        }
    }

    // The wire that corresponds to the position 0 is the diff of p7 and p1.
    const w0: u8 = diff(p7, p1);

    // We can now begin populating our wire map.
    var buffer: [4096]u8 = undefined;
    var allocator = &std.heap.FixedBufferAllocator.init(&buffer).allocator;
    var wire_map = WireMap.init(allocator);
    try wire_map.putNoClobber(w0, s0);

    var w2: u8 = undefined;
    var w3_and_w4: [2]u8 = undefined;
    writer_idx = 0;
    for (p0_and_p6_and_p9) |p| {
        const single_wire = diff(p8, p);
        if (diff(single_wire, p1) == empty_display) {
            w2 = single_wire;
        } else {
            w3_and_w4[writer_idx] = single_wire;
            writer_idx += 1;
        }
    }
    try wire_map.putNoClobber(w2, s2);

    const w5 = diff(p1, w2);
    try wire_map.putNoClobber(w5, s5);

    var w3: u8 = undefined;
    var w4: u8 = undefined;
    if (diff(w3_and_w4[0], p4) == empty_display) {
        w3 = w3_and_w4[0];
        w4 = w3_and_w4[1];
    } else {
        w3 = w3_and_w4[1];
        w4 = w3_and_w4[0];
    }
    try wire_map.putNoClobber(w3, s3);
    try wire_map.putNoClobber(w4, s4);

    const w1 = diff(p4, w2 ^ w3 ^ w5);
    try wire_map.putNoClobber(w1, s1);

    const w6 = diff(p8, w0 ^ w1 ^ w2 ^ w3 ^ w4 ^ w5);
    try wire_map.putNoClobber(w6, s6);

    return wire_map;
}

fn decode(letters: []const u8, wire_map: WireMap) !u8 {
    var display: u8 = empty_display;
    for (letters) |l| {
        const wire = encode(l);
        const segment = wire_map.get(wire).?;
        display ^= segment;
    }
    return toDigit(display);
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{ .read = true });
    defer file.close();

    const reader = file.reader();
    var buffer: [1024]u8 = undefined;

    var sum: u64 = 0;

    while (try reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        var parts = std.mem.split(u8, line, " | ");
        const sequence = parts.next().?;
        const wire_map = try determine(sequence);
        const output = parts.next().?;
        var patterns = std.mem.split(u8, output, " ");
        var decoded_output: [4]u8 = undefined;
        var i: usize = 0;
        while (patterns.next()) |letters| {
            decoded_output[i] = try decode(letters, wire_map);
            i += 1;
        }
        sum += try std.fmt.parseInt(u64, decoded_output[0..], 10);
    }

    std.debug.print("{}\n", .{sum});
}
