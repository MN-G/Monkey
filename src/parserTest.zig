const std = @import("std");
const ast = @import("Ast/ast.zig");
const Lexer = @import("Lexer/lexer.zig").Lexer;
const Token = @import("Token/token.zig").Token;
const Parser = @import("Parser/parser.zig").Parser;

test "manual ast construction" {
    const allocator = std.testing.allocator;

    // 1. Create a Program
    var program = ast.Program{
        .statements = .empty,
    };
    defer program.deinit(allocator);

    // 2. Manually create a LetStatement
    // In the real parser, the Lexer will provide these tokens
    const let_token = Token{ .type = .LET, .literal = "let" };
    const ident_token = Token{ .type = .IDENT, .literal = "myVar" };

    const name = ast.Identifier{
        .token = ident_token,
        .value = "myVar",
    };

    // For now, Expression is just a placeholder struct
    const dummy_val = ast.Expression{ .token = Token{ .type = .INT, .literal = "5" } };

    const let_stmt = ast.LetStatement{
        .token = let_token,
        .name = name,
        .value = dummy_val,
    };

    // 3. Wrap it in the Union and add it to the program
    try program.statements.append(allocator, ast.Statement{ .let_statement = let_stmt });

    // 4. Verify the results
    try std.testing.expectEqual(@as(usize, 1), program.statements.items.len);
    try std.testing.expectEqualStrings("let", program.tokenLiteral());
}

test "test let statements" {
    const input =
        \\ let x = 5;
        \\ let y = 10;
        \\ let foobar = 838383;
    ;

    const allocator = std.testing.allocator;
    var l = Lexer.init(input);
    var p = Parser.init(allocator, &l);

    var program = try p.parseProgram();
    defer program.deinit(allocator);

    if (program.statements.items.len != 3) {
        std.debug.print("\nprogram.statements does not contain 3 statements. got={d}\n", .{program.statements.items.len});
        return error.TestUnexpectedStatementCount;
    }

    const TestCase = struct {
        expected_identifier: []const u8,
    };

    const tests = [_]TestCase{
        .{ .expected_identifier = "x" },
        .{ .expected_identifier = "y" },
        .{ .expected_identifier = "foobar" },
    };

    for (tests, 0..) |tt, i| {
        const stmt = program.statements.items[i];
        try testLetStatement(stmt, tt.expected_identifier);
    }
}

fn testLetStatement(s: ast.Statement, name: []const u8) !void {
    // 1. Check the TokenLiteral (The "Contract" check)
    if (!std.mem.eql(u8, s.tokenLiteral(), "let")) {
        std.debug.print("\nStatement.tokenLiteral not 'let'. got='{s}'\n", .{s.tokenLiteral()});
        return error.TestInvalidTokenLiteral;
    }

    switch (s) {
        .let_statement => |let_stmt| {
            if (!std.mem.eql(u8, let_stmt.name.value, name)) {
                std.debug.print("\nlet_stmt.name.value not '{s}'. got='{s}'\n", .{ name, let_stmt.name.value });
                return error.TestInvalidIdentifierValue;
            }
            if (!std.mem.eql(u8, let_stmt.name.token.literal, name)) {
                std.debug.print("\nlet_stmt.name.token.literal not '{s}'. got='{s}'\n", .{ name, let_stmt.name.token.literal });
                return error.TestInvalidTokenLiteral;
            }
        },
        else => return error.TestNotALetStatement,
    }
}
