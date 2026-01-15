const std = @import("std");

pub const TokenType = enum {
    ILLEGAL,
    EOF,

    IDENT,
    INT,

    ASSIGN,
    PLUS,
    MINUS,
    BANG,
    ASTERISK,
    SLASH,

    GT,
    LT,
    EQ,
    NOT_EQ,

    COMMA,
    SEMICOLON,

    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,

    FUNCTION,
    LET,
    IF,
    ELSE,
    TRUE,
    FALSE,
    RETURN,
};

pub const Token = struct {
    type: TokenType,
    literal: []const u8,
};

pub fn lookUpIdent(ident: []const u8) TokenType {
    const keywords = std.StaticStringMap(TokenType).initComptime(.{
        .{ "fn", .FUNCTION },
        .{ "let", .LET },
        .{ "if", .IF },
        .{ "else", .ELSE },
        .{ "true", .TRUE },
        .{ "false", .FALSE },
        .{ "return", .RETURN },
    });
    if (keywords.get(ident)) |tok_type| {
        return tok_type;
    }
    return .IDENT;
}
