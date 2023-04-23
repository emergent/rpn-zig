const std = @import("std");
const stdin_file = std.io.getStdIn();
const stdout_file = std.io.getStdOut();
const calculator = @import("calculator.zig");

const MAX_CHARS = 256;

pub fn main() !void {
    var br = std.io.bufferedReader(stdin_file.reader());
    var bw = std.io.bufferedWriter(stdout_file.writer());

    var stdin = br.reader();
    var stdout = bw.writer();

    var buf: [4096]u8 = undefined;
    while (true) {
        try stdout.print("> ", .{});
        try bw.flush();

        const bytes = try stdin.readUntilDelimiterOrEof(&buf, '\n');

        if (bytes) |b| {
            if (b.len == 0) continue;
            if (std.mem.eql(u8, b, "quit")) {
                break;
            }
            try stdout.print("input: {s}\n", .{b});
            const res = try calculator.eval(b);
            try stdout.print("result: {}\n", .{res});
        } else {
            try stdout.print("\n", .{});
            try bw.flush();
            break;
        }
    }
}
