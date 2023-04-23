const std = @import("std");
const allocator = std.heap.page_allocator;

const Op = enum(u8) {
    plus = '+',
    minus = '-',
    multiple = '*',
    divide = '/',
};

const Token = union(enum) {
    op: Op,
    value: i32,
};

pub fn eval(formula: []const u8) !i32 {
    var tokens = std.mem.split(u8, formula, " ");
    var stack = std.ArrayList(i32).init(allocator);

    while (tokens.next()) |token| {
        //printStack(stack);
        //std.debug.print("token: {s}\n", .{token});

        const val = try parseToken(token) orelse continue;
        switch (val) {
            .op => |op| {
                const y = stack.popOrNull() orelse return error.SyntaxError;
                const x = stack.popOrNull() orelse return error.SyntaxError;
                const res = calc(x, y, op);
                try stack.append(res);
            },
            .value => |v| try stack.append(v),
        }
    }

    //printStack(stack);
    return stack.popOrNull() orelse error.SyntaxError;
}

fn calc(x: i32, y: i32, op: Op) i32 {
    return switch (op) {
        .plus => x + y,
        .minus => x - y,
        .multiple => x * y,
        .divide => @divTrunc(x, y),
    };
}

fn parseToken(token: []const u8) !?Token {
    return switch (token.len) {
        0 => null,
        1 => switch (token[0]) {
            '+' => Token{ .op = Op.plus },
            '-' => Token{ .op = Op.minus },
            '*' => Token{ .op = Op.multiple },
            '/' => Token{ .op = Op.divide },
            else => Token{ .value = try parseNumber(token) },
        },
        else => Token{ .value = try parseNumber(token) },
    };
}

fn parseNumber(token: []const u8) !i32 {
    return std.fmt.parseInt(i32, token, 10);
}

fn printStack(stack: std.ArrayList(i32)) void {
    std.debug.print("[ ", .{});
    for (stack.items) |item| {
        std.debug.print("{} ", .{item});
    }
    std.debug.print("]\n", .{});
}

const expect = std.testing.expect;
const expectError = std.testing.expectError;

test "tokenize" {
    try expect(try eval("1 1 +") == 2);
    try expect(try eval("  1   1   +  ") == 2);
}

test "calc" {
    try expect(try eval("1 1 +") == 2);
    try expect(try eval("12 13 + 1 -") == 24);
    try expect(try eval("1 1 + 2 1 - *") == 2);
    try expect(try eval("2 3 + 1 2 - *") == -5);
}

test "error" {
    try expectError(error.SyntaxError, eval("+"));
    try expectError(error.InvalidCharacter, eval("a"));
    try expectError(error.InvalidCharacter, eval("1.1"));
    try expectError(error.Overflow, eval("11111111111111111111111"));
}
