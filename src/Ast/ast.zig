const std = @import("std");
const Token = @import("../Token/token.zig").Token;

pub const Program = struct {
    statements: std.ArrayList(Statement),

    pub fn init() Program {
        return Program{
            .statements = .empty,
        };
    }

    pub fn deinit(self: *Program, allocator: std.mem.Allocator) void {
        self.statements.deinit(allocator);
    }

    pub fn tokenLiteral(self: Program) []const u8 {
        if (self.statements.items.len > 0) {
            return self.statements.items[0].tokenLiteral();
        } else {
            return "";
        }
    }
};

pub const Statement = union(enum) {
    let_statement: LetStatement, // Contains Token, Name (Identifier), and Value (Expression)
    return_statement: ReturnStatement, // Contains Token and ReturnValue (Expression)
    expression_statement: ExpressionStatement, // Contains Token and Expression
    //
    pub fn tokenLiteral(self: Statement) []const u8 {
        switch (self) {
            .let_statement => |s| return s.token.literal,
            .return_statement => |s| return s.token.literal,
            .expression_statement => |s| return s.token.literal,
        }
    }
};

pub const LetStatement = struct {
    token: Token,
    name: Identifier,
    value: Expression,
};

pub const Identifier = struct {
    token: Token,
    value: []const u8,
};

pub const Expression = struct {
    token: Token,
};

pub const ExpressionStatement = struct {
    token: Token,
    value: []const u8,
};

pub const ReturnStatement = struct {
    token: Token,
    placeholder: []const u8,
};
