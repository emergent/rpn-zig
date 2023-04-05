const std = @import("std");
const stdin_file = std.io.getStdIn();
const stdout_file = std.io.getStdOut();

const MAX_CHARS = 256;

pub fn main() !void {
    var br = std.io.bufferedReader(stdin_file.reader());
    var bw = std.io.bufferedWriter(stdout_file.writer());

    var stdin = br.reader();
    var stdout = bw.writer();

    //var buf: [4096]u8 = undefined;
    var buf: [16]u8 = undefined;
    while (true) {
        try stdout.print("> ", .{});
        try bw.flush();

        const bytes = try stdin.readUntilDelimiterOrEof(&buf, '\n');

        if (bytes) |b| {
            if (std.mem.eql(u8, b, "quit")) {
                break;
            }
            try stdout.print("input: {s}\n", .{b});
        } else {
            try stdout.print("\n", .{});
            try bw.flush();
            break;
        }
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
