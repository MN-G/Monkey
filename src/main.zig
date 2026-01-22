const std = @import("std");
const Monkey = @import("Monkey");
const REPL = @import("Repl/repl.zig");

pub fn main() !void {
    // 1. Setup an Arena for temporary allocations
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // 2. Fetch the environment variables
    const env_map = try std.process.getEnvMap(allocator);

    // 3. Check for "USER" (Linux/macOS) or "USERNAME" (Windows)
    const user = env_map.get("USER") orelse env_map.get("USERNAME") orelse "Friend";

    var stdout_buffer: [1024]u8 = undefined;
    var stdin_buffer: [1024]u8 = undefined;

    var writer = std.fs.File.stdout().writer(&stdout_buffer);
    var reader = std.fs.File.stdin().reader(&stdin_buffer);

    const stdout = &writer.interface;
    const stdin = &reader.interface;

    try stdout.print("Hello {s}! This is the Monkey programming language!\n", .{user});
    try stdout.flush();

    try REPL.start(stdin, stdout);
    try stdout.flush();
}
