const std = @import("std");
const ast = @import("../Ast/ast.zig");
const Lexer = @import("../Lexer/lexer.zig").Lexer;
const Token = @import("../Token/token.zig").Token;
const TokenType = @import("../Token/token.zig").TokenType;

pub const ParserError = struct {
    errors: []const u8,
};

pub const Parser = struct {
    lexer: *Lexer,
    current_token: Token,
    peek_token: Token,
    errors: std.ArrayList([]const u8),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, l: *Lexer) Parser {
        var p = Parser{
            .lexer = l,
            .allocator = allocator,
            .current_token = undefined,
            .peek_token = undefined,
            .errors = .empty,
        };

        p.nextToken();
        p.nextToken();

        return p;
    }
    pub fn deinit(self: *Parser) void {
        for (self.errors.items) |item| {
            self.allocator.free(item);
        }
        self.errors.deinit(self.allocator);
    }
    pub fn nextToken(self: *Parser) void {
        self.current_token = self.peek_token;
        self.peek_token = self.lexer.nextToken();
    }
    pub fn parseProgram(self: *Parser) !ast.Program {
        var program: ast.Program = ast.Program.init();

        while (self.current_token.type != TokenType.EOF) {
            if (try self.parseStatement()) |statement| {
                try program.statements.append(self.allocator, statement);
            }
            self.nextToken();
        }

        return program;
    }
    pub fn parseStatement(self: *Parser) !?ast.Statement {
        return switch (self.current_token.type) {
            .LET => self.parseLetStatement(),
            else => null,
        };
    }
    pub fn parseLetStatement(self: *Parser) !?ast.Statement {
        const statement_token: Token = self.current_token;

        if (!self.expectPeekToken(.IDENT)) {
            return null;
        }

        const name: ast.Identifier = ast.Identifier{
            .token = self.current_token,
            .value = self.current_token.literal,
        };

        if (!self.expectPeekToken(.ASSIGN)) {
            return null;
        }
        while (!self.currentTokenIs(.SEMICOLON) and !self.currentTokenIs(.EOF)) {
            self.nextToken();
        }
        return ast.Statement{
            .let_statement = ast.LetStatement{
                .token = statement_token,
                .name = name,
                .value = undefined,
            },
        };
    }
    pub fn currentTokenIs(self: *Parser, token_type: TokenType) bool {
        return token_type == self.current_token.type;
    }
    pub fn peekTokenIs(self: *Parser, token_type: TokenType) bool {
        return token_type == self.peek_token.type;
    }
    pub fn peekError(self: *Parser, token_type: TokenType) void {
        const error_message =
            std.fmt.allocPrint(self.allocator, "Expected {s}, got {s}.", .{
                @tagName(token_type),
                @tagName(self.peek_token.type),
            }) catch "Out of memory while reporting error";
        self.errors.append(self.allocator, error_message) catch {};
    }
    pub fn expectPeekToken(self: *Parser, token_type: TokenType) bool {
        if (self.peekTokenIs(token_type)) {
            self.nextToken();
            return true;
        } else {
            self.peekError(token_type);
            return false;
        }
    }
};
