const std = @import("std");
const os = @import("os");
const Allocator = std.mem.Allocator;

// Function to handle an incoming connection.
fn handleConnection(connection: std.net.StreamServer.Connection) !void {
    const allocator = std.heap.page_allocator;
    const buffer = try allocator.alloc(u8, 4096);
    defer allocator.free(buffer);
    _ = try connection.stream.read(buffer[0..]);

    // Prepare the response body.
    const body = "Hello, this is a zig HTTP server!";
    var response = std.fmt.allocPrint(allocator, "HTTP/1.1 200 OK\r\nContent-Length: {d}\r\n\r\n{s}", .{ body.len, body }) catch "format failed";
    _ = try connection.stream.write(response);
}

pub fn main() !void {
    const port = 8088;
    const address = std.net.Address.initIp4([4]u8{ 0, 0, 0, 0 }, port);

    var server = std.net.StreamServer.init(.{ .reuse_address = true });
    try server.listen(address);

    while (true) {
        const conn = try server.accept();
        defer conn.stream.close();

        try handleConnection(conn);
    }
}
