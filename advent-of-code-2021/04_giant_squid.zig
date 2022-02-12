const std = @import("std");
const split = std.mem.split;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

/// The number of rows / columns in each bingo board.
const board_size = 5;

/// The number of numbers in each bingo board.
const board_elements = board_size * board_size;

const Board = struct {
    numbers: [board_elements]u64,

    /// An array of bits. Initialized to 0, and marked by setting to 1.
    marks: [board_elements]u1,

    /// The win state. When a board wins, it is no longer possible to mark it,
    /// and no longer necessary to compute the win condition (the value of this
    /// field will be returned directly). This field updates when the win
    /// condition is checked for a winning board.
    won: bool,

    pub fn init(numbers: [board_elements]u64) Board {
        return Board{
            .numbers = numbers,
            .marks = [_]u1{0} ** board_elements,
            .won = false,
        };
    }

    /// Attempts to mark a number on the board. Returns the number's index if
    /// successful, or null otherwise. Idempotent.
    pub fn mark(self: *Board, number: u64) ?usize {
        if (self.won) return null;

        for (self.numbers) |n, i| {
            if (n == number) {
                self.marks[i] = 1;
                return i;
            }
        }
        return null;
    }

    /// Given the index of a number, check if all numbers that belong to the
    /// associated row or column are marked.
    pub fn hasWon(self: *Board, index: usize) bool {
        if (self.won) return self.won;
        if (self.marks[index] == 0) return false;

        var win_tracker: u1 = 1;

        // To get the beginning of the row, we floor to the nearest multiple of
        // `board_size`.
        var row_index = (index / board_size) * board_size;
        const row_end = row_index + board_size;
        while (row_index < row_end) : (row_index += 1) {
            win_tracker &= self.marks[row_index];
        }

        if (win_tracker == 1) {
            self.won = true;
            return true;
        }

        win_tracker = 1;

        var col_index = index % board_size;
        while (col_index < board_elements) : (col_index += board_size) {
            win_tracker &= self.marks[col_index];
        }

        const won = win_tracker == 1;
        self.won = won;
        return won;
    }

    /// Calculate the sum of all unmarked numbers.
    pub fn unmarkedSum(self: *const Board) u64 {
        var sum: u64 = 0;
        for (self.marks) |m, i| {
            if (m == 0) {
                sum += self.numbers[i];
            }
        }
        return sum;
    }
};

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

    var input_iterator = split(u8, input, "\n\n");
    var numbers = split(u8, input_iterator.next().?, ",");
    var boards = std.ArrayList(Board).init(allocator);
    while (input_iterator.next()) |board| {
        var board_numbers: [board_elements]u64 = undefined;
        var write_index: usize = 0;
        var row = split(u8, board, "\n");
        while (row.next()) |r| {
            var numbers_or_empty_strings = split(u8, r, " ");
            while (numbers_or_empty_strings.next()) |n| {
                // Because numbers are right-aligned, we need to filter out the
                // noise caused by double-spaces.
                if (n.len > 0) {
                    board_numbers[write_index] = try parseInt(u64, n, 10);
                    write_index += 1;
                }
            }
        }
        try boards.append(Board.init(board_numbers));
    }

    var first_winning_score: ?u64 = null;
    var last_winning_score: ?u64 = null;
    var number_of_winners: u64 = 0;

    while (numbers.next()) |number| {
        if (first_winning_score != null and last_winning_score != null) {
            break;
        }

        const n = try parseInt(u64, number, 10);
        var i: usize = 0;
        while (i < boards.items.len) : (i += 1) {
            // Directly iterating over items will yield copies. I'm not aware of
            // an easier way of acquiring references to std.ArrayList elements.
            var mut_b = &boards.items[i];
            const mark_index_or_null = mut_b.mark(n);
            if (mark_index_or_null) |idx| {
                if (mut_b.hasWon(idx)) {
                    number_of_winners += 1;
                    if (first_winning_score == null) {
                        first_winning_score = n * mut_b.unmarkedSum();
                    }
                    if (number_of_winners == boards.items.len) {
                        last_winning_score = n * mut_b.unmarkedSum();
                    }
                }
            }
        }
    }

    print("{}\n", .{first_winning_score});
    print("{}\n", .{last_winning_score});
}
