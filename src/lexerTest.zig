const std = @import("std");
const TokenType = @import("Token/token.zig").TokenType;
const Token = @import("Token/token.zig").Token;
const Lexer = @import("Lexer/lexer.zig").Lexer;
const expect = std.testing.expectEqualStrings;

test "NextToken basic symbols" {
    const input = "=+(){},;";

    const TestExpectation = struct {
        expected_type: TokenType,
        expected_literal: []const u8,
    };

    const tests = [_]TestExpectation{
        .{ .expected_type = .ASSIGN, .expected_literal = "=" },
        .{ .expected_type = .PLUS, .expected_literal = "+" },
        .{ .expected_type = .LPAREN, .expected_literal = "(" },
        .{ .expected_type = .RPAREN, .expected_literal = ")" },
        .{ .expected_type = .LBRACE, .expected_literal = "{" },
        .{ .expected_type = .RBRACE, .expected_literal = "}" },
        .{ .expected_type = .COMMA, .expected_literal = "," },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .EOF, .expected_literal = "" },
    };

    var l = Lexer.init(input);

    for (tests, 0..) |expected, i| {
        const tok = l.nextToken();

        std.testing.expectEqual(expected.expected_type, tok.type) catch |err| {
            std.debug.print("\nTest[{d}] - type mismatch. expected={any}, got={any}\n", .{ i, expected.expected_type, tok.type });
            return err;
        };

        std.testing.expectEqualStrings(expected.expected_literal, tok.literal) catch |err| {
            std.debug.print("\nTest[{d}] - literal mismatch. expected='{s}', got='{s}'\n", .{ i, expected.expected_literal, tok.literal });
            return err;
        };
    }
}
test "NextToken intermidiate symbols" {
    const input =
        \\let five = 5;
        \\let ten = 10;
        \\
        \\let add = fn(x, y) {
        \\  x + y;
        \\};
        \\
        \\let result = add(five, ten);
    ;
    const TestExpectation = struct {
        expected_type: TokenType,
        expected_literal: []const u8,
    };

    const tests = [_]TestExpectation{
        .{ .expected_type = .LET, .expected_literal = "let" },
        .{ .expected_type = .IDENT, .expected_literal = "five" },
        .{ .expected_type = .ASSIGN, .expected_literal = "=" },
        .{ .expected_type = .INT, .expected_literal = "5" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .LET, .expected_literal = "let" },
        .{ .expected_type = .IDENT, .expected_literal = "ten" },
        .{ .expected_type = .ASSIGN, .expected_literal = "=" },
        .{ .expected_type = .INT, .expected_literal = "10" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .LET, .expected_literal = "let" },
        .{ .expected_type = .IDENT, .expected_literal = "add" },
        .{ .expected_type = .ASSIGN, .expected_literal = "=" },
        .{ .expected_type = .FUNCTION, .expected_literal = "fn" },
        .{ .expected_type = .LPAREN, .expected_literal = "(" },
        .{ .expected_type = .IDENT, .expected_literal = "x" },
        .{ .expected_type = .COMMA, .expected_literal = "," },
        .{ .expected_type = .IDENT, .expected_literal = "y" },
        .{ .expected_type = .RPAREN, .expected_literal = ")" },
        .{ .expected_type = .LBRACE, .expected_literal = "{" },
        .{ .expected_type = .IDENT, .expected_literal = "x" },
        .{ .expected_type = .PLUS, .expected_literal = "+" },
        .{ .expected_type = .IDENT, .expected_literal = "y" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .RBRACE, .expected_literal = "}" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .LET, .expected_literal = "let" },
        .{ .expected_type = .IDENT, .expected_literal = "result" },
        .{ .expected_type = .ASSIGN, .expected_literal = "=" },
        .{ .expected_type = .IDENT, .expected_literal = "add" },
        .{ .expected_type = .LPAREN, .expected_literal = "(" },
        .{ .expected_type = .IDENT, .expected_literal = "five" },
        .{ .expected_type = .COMMA, .expected_literal = "," },
        .{ .expected_type = .IDENT, .expected_literal = "ten" },
        .{ .expected_type = .RPAREN, .expected_literal = ")" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .EOF, .expected_literal = "" },
    };

    var l = Lexer.init(input);

    for (tests, 0..) |expected, i| {
        const tok = l.nextToken();

        std.testing.expectEqual(expected.expected_type, tok.type) catch |err| {
            std.debug.print("\nTest[{d}] - type mismatch. expected={any}, got={any}\n", .{ i, expected.expected_type, tok.type });
            return err;
        };

        std.testing.expectEqualStrings(expected.expected_literal, tok.literal) catch |err| {
            std.debug.print("\nTest[{d}] - literal mismatch. expected='{s}', got='{s}'\n", .{ i, expected.expected_literal, tok.literal });
            return err;
        };
    }
}

test "NextToken with (!-/*<>) symbols" {
    const input =
        \\let five = 5;
        \\let ten = 10;
        \\
        \\let add = fn(x, y) {
        \\  x + y;
        \\};
        \\
        \\let result = add(five, ten);
        \\!-/*5;
        \\5 < 10 > 5;
    ;
    const TestExpectation = struct {
        expected_type: TokenType,
        expected_literal: []const u8,
    };

    const tests = [_]TestExpectation{
        .{ .expected_type = .LET, .expected_literal = "let" },
        .{ .expected_type = .IDENT, .expected_literal = "five" },
        .{ .expected_type = .ASSIGN, .expected_literal = "=" },
        .{ .expected_type = .INT, .expected_literal = "5" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .LET, .expected_literal = "let" },
        .{ .expected_type = .IDENT, .expected_literal = "ten" },
        .{ .expected_type = .ASSIGN, .expected_literal = "=" },
        .{ .expected_type = .INT, .expected_literal = "10" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .LET, .expected_literal = "let" },
        .{ .expected_type = .IDENT, .expected_literal = "add" },
        .{ .expected_type = .ASSIGN, .expected_literal = "=" },
        .{ .expected_type = .FUNCTION, .expected_literal = "fn" },
        .{ .expected_type = .LPAREN, .expected_literal = "(" },
        .{ .expected_type = .IDENT, .expected_literal = "x" },
        .{ .expected_type = .COMMA, .expected_literal = "," },
        .{ .expected_type = .IDENT, .expected_literal = "y" },
        .{ .expected_type = .RPAREN, .expected_literal = ")" },
        .{ .expected_type = .LBRACE, .expected_literal = "{" },
        .{ .expected_type = .IDENT, .expected_literal = "x" },
        .{ .expected_type = .PLUS, .expected_literal = "+" },
        .{ .expected_type = .IDENT, .expected_literal = "y" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .RBRACE, .expected_literal = "}" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .LET, .expected_literal = "let" },
        .{ .expected_type = .IDENT, .expected_literal = "result" },
        .{ .expected_type = .ASSIGN, .expected_literal = "=" },
        .{ .expected_type = .IDENT, .expected_literal = "add" },
        .{ .expected_type = .LPAREN, .expected_literal = "(" },
        .{ .expected_type = .IDENT, .expected_literal = "five" },
        .{ .expected_type = .COMMA, .expected_literal = "," },
        .{ .expected_type = .IDENT, .expected_literal = "ten" },
        .{ .expected_type = .RPAREN, .expected_literal = ")" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .BANG, .expected_literal = "!" },
        .{ .expected_type = .MINUS, .expected_literal = "-" },
        .{ .expected_type = .SLASH, .expected_literal = "/" },
        .{ .expected_type = .ASTERISK, .expected_literal = "*" },
        .{ .expected_type = .INT, .expected_literal = "5" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .INT, .expected_literal = "5" },
        .{ .expected_type = .LT, .expected_literal = "<" },
        .{ .expected_type = .INT, .expected_literal = "10" },
        .{ .expected_type = .GT, .expected_literal = ">" },
        .{ .expected_type = .INT, .expected_literal = "5" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .EOF, .expected_literal = "" },
    };

    var l = Lexer.init(input);

    for (tests, 0..) |expected, i| {
        const tok = l.nextToken();

        std.testing.expectEqual(expected.expected_type, tok.type) catch |err| {
            std.debug.print("\nTest[{d}] - type mismatch. expected={any}, got={any}\n", .{ i, expected.expected_type, tok.type });
            return err;
        };

        std.testing.expectEqualStrings(expected.expected_literal, tok.literal) catch |err| {
            std.debug.print("\nTest[{d}] - literal mismatch. expected='{s}', got='{s}'\n", .{ i, expected.expected_literal, tok.literal });
            return err;
        };
    }
}

test "NextToken with (true/false/if/else/return) symbols" {
    const input =
        \\let five = 5;
        \\let ten = 10;
        \\
        \\let add = fn(x, y) {
        \\  x + y;
        \\};
        \\
        \\let result = add(five, ten);
        \\!-/*5;
        \\5 < 10 > 5;
        \\if (5 < 10) {
        \\    return true;
        \\} else {
        \\    return false;
        \\}
    ;

    const TestExpectation = struct {
        expected_type: TokenType,
        expected_literal: []const u8,
    };

    const tests = [_]TestExpectation{
        .{ .expected_type = .LET, .expected_literal = "let" },
        .{ .expected_type = .IDENT, .expected_literal = "five" },
        .{ .expected_type = .ASSIGN, .expected_literal = "=" },
        .{ .expected_type = .INT, .expected_literal = "5" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .LET, .expected_literal = "let" },
        .{ .expected_type = .IDENT, .expected_literal = "ten" },
        .{ .expected_type = .ASSIGN, .expected_literal = "=" },
        .{ .expected_type = .INT, .expected_literal = "10" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .LET, .expected_literal = "let" },
        .{ .expected_type = .IDENT, .expected_literal = "add" },
        .{ .expected_type = .ASSIGN, .expected_literal = "=" },
        .{ .expected_type = .FUNCTION, .expected_literal = "fn" },
        .{ .expected_type = .LPAREN, .expected_literal = "(" },
        .{ .expected_type = .IDENT, .expected_literal = "x" },
        .{ .expected_type = .COMMA, .expected_literal = "," },
        .{ .expected_type = .IDENT, .expected_literal = "y" },
        .{ .expected_type = .RPAREN, .expected_literal = ")" },
        .{ .expected_type = .LBRACE, .expected_literal = "{" },
        .{ .expected_type = .IDENT, .expected_literal = "x" },
        .{ .expected_type = .PLUS, .expected_literal = "+" },
        .{ .expected_type = .IDENT, .expected_literal = "y" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .RBRACE, .expected_literal = "}" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .LET, .expected_literal = "let" },
        .{ .expected_type = .IDENT, .expected_literal = "result" },
        .{ .expected_type = .ASSIGN, .expected_literal = "=" },
        .{ .expected_type = .IDENT, .expected_literal = "add" },
        .{ .expected_type = .LPAREN, .expected_literal = "(" },
        .{ .expected_type = .IDENT, .expected_literal = "five" },
        .{ .expected_type = .COMMA, .expected_literal = "," },
        .{ .expected_type = .IDENT, .expected_literal = "ten" },
        .{ .expected_type = .RPAREN, .expected_literal = ")" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .BANG, .expected_literal = "!" },
        .{ .expected_type = .MINUS, .expected_literal = "-" },
        .{ .expected_type = .SLASH, .expected_literal = "/" },
        .{ .expected_type = .ASTERISK, .expected_literal = "*" },
        .{ .expected_type = .INT, .expected_literal = "5" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .INT, .expected_literal = "5" },
        .{ .expected_type = .LT, .expected_literal = "<" },
        .{ .expected_type = .INT, .expected_literal = "10" },
        .{ .expected_type = .GT, .expected_literal = ">" },
        .{ .expected_type = .INT, .expected_literal = "5" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .IF, .expected_literal = "if" },
        .{ .expected_type = .LPAREN, .expected_literal = "(" },
        .{ .expected_type = .INT, .expected_literal = "5" },
        .{ .expected_type = .LT, .expected_literal = "<" },
        .{ .expected_type = .INT, .expected_literal = "10" },
        .{ .expected_type = .RPAREN, .expected_literal = ")" },
        .{ .expected_type = .LBRACE, .expected_literal = "{" },
        .{ .expected_type = .RETURN, .expected_literal = "return" },
        .{ .expected_type = .TRUE, .expected_literal = "true" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .RBRACE, .expected_literal = "}" },
        .{ .expected_type = .ELSE, .expected_literal = "else" },
        .{ .expected_type = .LBRACE, .expected_literal = "{" },
        .{ .expected_type = .RETURN, .expected_literal = "return" },
        .{ .expected_type = .FALSE, .expected_literal = "false" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .RBRACE, .expected_literal = "}" },
        .{ .expected_type = .EOF, .expected_literal = "" },
    };

    var l = Lexer.init(input);

    for (tests, 0..) |expected, i| {
        const tok = l.nextToken();

        std.testing.expectEqual(expected.expected_type, tok.type) catch |err| {
            std.debug.print("\nTest[{d}] - type mismatch. expected={any}, got={any}\n", .{ i, expected.expected_type, tok.type });
            return err;
        };

        std.testing.expectEqualStrings(expected.expected_literal, tok.literal) catch |err| {
            std.debug.print("\nTest[{d}] - literal mismatch. expected='{s}', got='{s}'\n", .{ i, expected.expected_literal, tok.literal });
            return err;
        };
    }
}

test "NextToken with (== !=) symbols" {
    const input =
        \\let five = 5;
        \\let ten = 10;
        \\
        \\let add = fn(x, y) {
        \\  x + y;
        \\};
        \\
        \\let result = add(five, ten);
        \\!-/*5;
        \\5 < 10 > 5;
        \\if (5 < 10) {
        \\    return true;
        \\} else {
        \\    return false;
        \\}
        \\ 10 == 10; 
        \\ 10 != 9;
    ;

    const TestExpectation = struct {
        expected_type: TokenType,
        expected_literal: []const u8,
    };

    const tests = [_]TestExpectation{
        .{ .expected_type = .LET, .expected_literal = "let" },
        .{ .expected_type = .IDENT, .expected_literal = "five" },
        .{ .expected_type = .ASSIGN, .expected_literal = "=" },
        .{ .expected_type = .INT, .expected_literal = "5" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .LET, .expected_literal = "let" },
        .{ .expected_type = .IDENT, .expected_literal = "ten" },
        .{ .expected_type = .ASSIGN, .expected_literal = "=" },
        .{ .expected_type = .INT, .expected_literal = "10" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .LET, .expected_literal = "let" },
        .{ .expected_type = .IDENT, .expected_literal = "add" },
        .{ .expected_type = .ASSIGN, .expected_literal = "=" },
        .{ .expected_type = .FUNCTION, .expected_literal = "fn" },
        .{ .expected_type = .LPAREN, .expected_literal = "(" },
        .{ .expected_type = .IDENT, .expected_literal = "x" },
        .{ .expected_type = .COMMA, .expected_literal = "," },
        .{ .expected_type = .IDENT, .expected_literal = "y" },
        .{ .expected_type = .RPAREN, .expected_literal = ")" },
        .{ .expected_type = .LBRACE, .expected_literal = "{" },
        .{ .expected_type = .IDENT, .expected_literal = "x" },
        .{ .expected_type = .PLUS, .expected_literal = "+" },
        .{ .expected_type = .IDENT, .expected_literal = "y" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .RBRACE, .expected_literal = "}" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .LET, .expected_literal = "let" },
        .{ .expected_type = .IDENT, .expected_literal = "result" },
        .{ .expected_type = .ASSIGN, .expected_literal = "=" },
        .{ .expected_type = .IDENT, .expected_literal = "add" },
        .{ .expected_type = .LPAREN, .expected_literal = "(" },
        .{ .expected_type = .IDENT, .expected_literal = "five" },
        .{ .expected_type = .COMMA, .expected_literal = "," },
        .{ .expected_type = .IDENT, .expected_literal = "ten" },
        .{ .expected_type = .RPAREN, .expected_literal = ")" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .BANG, .expected_literal = "!" },
        .{ .expected_type = .MINUS, .expected_literal = "-" },
        .{ .expected_type = .SLASH, .expected_literal = "/" },
        .{ .expected_type = .ASTERISK, .expected_literal = "*" },
        .{ .expected_type = .INT, .expected_literal = "5" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .INT, .expected_literal = "5" },
        .{ .expected_type = .LT, .expected_literal = "<" },
        .{ .expected_type = .INT, .expected_literal = "10" },
        .{ .expected_type = .GT, .expected_literal = ">" },
        .{ .expected_type = .INT, .expected_literal = "5" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .IF, .expected_literal = "if" },
        .{ .expected_type = .LPAREN, .expected_literal = "(" },
        .{ .expected_type = .INT, .expected_literal = "5" },
        .{ .expected_type = .LT, .expected_literal = "<" },
        .{ .expected_type = .INT, .expected_literal = "10" },
        .{ .expected_type = .RPAREN, .expected_literal = ")" },
        .{ .expected_type = .LBRACE, .expected_literal = "{" },
        .{ .expected_type = .RETURN, .expected_literal = "return" },
        .{ .expected_type = .TRUE, .expected_literal = "true" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .RBRACE, .expected_literal = "}" },
        .{ .expected_type = .ELSE, .expected_literal = "else" },
        .{ .expected_type = .LBRACE, .expected_literal = "{" },
        .{ .expected_type = .RETURN, .expected_literal = "return" },
        .{ .expected_type = .FALSE, .expected_literal = "false" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .RBRACE, .expected_literal = "}" },
        .{ .expected_type = .INT, .expected_literal = "10" },
        .{ .expected_type = .EQ, .expected_literal = "==" },
        .{ .expected_type = .INT, .expected_literal = "10" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .INT, .expected_literal = "10" },
        .{ .expected_type = .NOT_EQ, .expected_literal = "!=" },
        .{ .expected_type = .INT, .expected_literal = "9" },
        .{ .expected_type = .SEMICOLON, .expected_literal = ";" },
        .{ .expected_type = .EOF, .expected_literal = "" },
    };

    var l = Lexer.init(input);

    for (tests, 0..) |expected, i| {
        const tok = l.nextToken();

        std.testing.expectEqual(expected.expected_type, tok.type) catch |err| {
            std.debug.print("\nTest[{d}] - type mismatch. expected={any}, got={any}\n", .{ i, expected.expected_type, tok.type });
            return err;
        };

        std.testing.expectEqualStrings(expected.expected_literal, tok.literal) catch |err| {
            std.debug.print("\nTest[{d}] - literal mismatch. expected='{s}', got='{s}'\n", .{ i, expected.expected_literal, tok.literal });
            return err;
        };
    }
}
