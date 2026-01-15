const std = @import("std");
const TokenType = @import("../Token/token.zig").TokenType;
const Token = @import("../Token/token.zig").Token;
const lookUpIdent = @import("../Token/token.zig").lookUpIdent;

pub const Lexer = struct {
    input: []const u8,
    position: usize,
    read_position: usize,
    char: u8,
    pub fn init(input: []const u8) Lexer {
        var l = Lexer{
            .input = input,
            .position = 0,
            .read_position = 0,
            .char = 0,
        };

        l.readChar();
        return l;
    }
    pub fn readChar(self: *Lexer) void {
        if (self.read_position >= self.input.len) {
            self.char = 0;
        } else {
            self.char = self.input[self.read_position];
        }
        self.position = self.read_position;
        self.read_position += 1;
    }
    pub fn peakChar(self: *const Lexer) u8 {
        if (self.read_position >= self.input.len) {
            return 0;
        } else {
            return self.input[self.read_position];
        }
    }
    pub fn nextToken(self: *Lexer) Token {
        var tok: Token = undefined;
        self.skipWhiteSpace();

        switch (self.char) {
            '=' => if (self.peakChar() == '=') {
                self.readChar();
                const literal = self.input[self.position - 1 .. self.position + 1];
                tok = Token{ .type = .EQ, .literal = literal };
            } else {
                tok = self.newToken(.ASSIGN);
            },
            ';' => tok = self.newToken(.SEMICOLON),
            '(' => tok = self.newToken(.LPAREN),
            ')' => tok = self.newToken(.RPAREN),
            ',' => tok = self.newToken(.COMMA),
            '+' => tok = self.newToken(.PLUS),
            '-' => tok = self.newToken(.MINUS),
            '*' => tok = self.newToken(.ASTERISK),
            '{' => tok = self.newToken(.LBRACE),
            '}' => tok = self.newToken(.RBRACE),
            '<' => tok = self.newToken(.LT),
            '>' => tok = self.newToken(.GT),
            '!' => if (self.peakChar() == '=') {
                self.readChar();
                const literal = self.input[self.position - 1 .. self.position + 1];
                tok = Token{ .type = .NOT_EQ, .literal = literal };
            } else {
                tok = self.newToken(.BANG);
            },
            '/' => tok = self.newToken(.SLASH),
            0 => {
                tok.type = .EOF;
                tok.literal = "";
            },
            else => if (isLetter(self.char)) {
                const literal = self.readIdentifier();
                const tok_type = lookUpIdent(literal);
                return Token{
                    .type = tok_type,
                    .literal = literal,
                };
            } else if (isDigit(self.char)) {
                return Token{
                    .type = .INT,
                    .literal = self.readNumber(),
                };
            } else {
                tok = self.newToken(.ILLEGAL);
            },
        }
        self.readChar();
        return tok;
    }
    pub fn newToken(self: *Lexer, token_type: TokenType) Token {
        return Token{
            .type = token_type,
            .literal = self.input[self.position .. self.position + 1],
        };
    }
    pub fn readIdentifier(self: *Lexer) []const u8 {
        const position = self.position;
        while (isLetter(self.char)) {
            self.readChar();
        }
        return self.input[position..self.position];
    }
    pub fn readNumber(self: *Lexer) []const u8 {
        const position = self.position;
        while (isDigit(self.char)) {
            self.readChar();
        }
        return self.input[position..self.position];
    }
    pub fn isLetter(ch: u8) bool {
        return ('a' <= ch and ch <= 'z') or ('A' <= ch and ch <= 'Z') or ch == '_';
    }
    pub fn isDigit(ch: u8) bool {
        return ('0' <= ch and ch <= '9');
    }
    pub fn skipWhiteSpace(self: *Lexer) void {
        while (self.char == ' ' or self.char == '\t' or self.char == '\r' or self.char == '\n') {
            self.readChar();
        }
    }
};
