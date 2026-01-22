const std = @import("std");
const Token = @import("../Token/token.zig").Token;
const Lexer = @import("../Lexer/lexer.zig").Lexer;

const PROMPT = ">> ";

pub fn start(reader: *std.io.Reader, writer: *std.io.Writer) !void {
    //while (true) {
    try writer.print("{s}", .{PROMPT});
    // Flush here if you want the prompt to appear before reading
    try writer.flush();

    // takeDelimiterExclusive is a common way to read until a newline
    //const line = try reader.takeDelimiterExclusive('\n');
    // control flow
    while (reader.takeDelimiterExclusive('\n')) |line| {
        var l = Lexer.init(line);
        var tok = l.nextToken();
        while (tok.type != .EOF) {
            try writer.print("Type: {any}, Literal: {s}\n", .{ tok.type, tok.literal });
            tok = l.nextToken();
        }
        reader.toss(1);
        try writer.flush();

        try writer.print("{s}", .{PROMPT});
        // Flush here if you want the prompt to appear before reading
        try writer.flush();
    } else |err| {
        return std.debug.print("an error has occered {any}\n", .{err});
    }
}
