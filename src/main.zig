const cosmo = @cImport({
    @cInclude("cosmopolitan.h");
});

pub export fn main(argc: c_int, argv: *[][:0]i8) callconv(.C) c_int {
    _ = argc;
    _ = argv;
    _ = cosmo.puts("hello world\n");
    return 0;
}
