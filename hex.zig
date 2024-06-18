const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len > 1) {
        const file = try std.fs.cwd().openFile(args[1], .{});
        defer file.close();

        var buf_reader = std.io.bufferedReader(file.reader());
        const reader = buf_reader.reader();

        var buf = std.ArrayList(u8).init(allocator);
        defer buf.deinit();

        var line = std.ArrayList(u8).init(allocator);
        defer line.deinit();

        const clms = if (args.len > 2)
            try std.fmt.parseInt(u8, args[2], 10)
        else
            16;
        _ = try reader.readAllArrayList(&buf, 1 << 32);

        for (buf.items, 0..) |byte, ind| {
            if (ind % clms == 0) {
                std.debug.print("{x:0>8}: ", .{ind / clms});
            }

            if (ind % 2 == 0) {
                std.debug.print(" ", .{});
            }

            try stdout.print("{x:0>2}", .{byte});
            if (byte != '\n') {
                try line.append(byte);
            } else {
                try line.appendSlice(" ");
            }

            if (ind % clms == clms - 1) {
                std.debug.print("  {s}\n", .{line.items});
                line.clearAndFree();
            }
        }
        const l = clms - line.items.len;
        for (0..l) |_| {
            std.debug.print("  ", .{});
        }
        for (0..(l / 2)) |_| {
            std.debug.print(" ", .{});
        }

        std.debug.print("  {s}\n", .{line.items});
        line.clearAndFree();
    } else {
        try stdout.print("rkxxd - github.com/rk3141", .{});
    }
}
