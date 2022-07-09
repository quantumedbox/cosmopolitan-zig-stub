const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    var target = b.standardTargetOptions(.{});
    target.os_tag = .freestanding;
    target.abi = .gnu;

    const mode = b.standardReleaseOptions();

    // todo: Provide tiny version if desired?
    const download = b.addSystemCommand(&[_][]const u8{
        "curl", "https://justine.lol/cosmopolitan/cosmopolitan.zip", "--output", "./cosmopolitan.zip"});
    const unzip = b.addSystemCommand(&[_][]const u8{
        "unzip", "-o", "./cosmopolitan.zip"});
    unzip.step.dependOn(&download.step);

    const exe = b.addObject("cosmopolitan-zig", "src/main.zig");
    // exe.step.dependOn(&unzip.step); // todo: Should be an optional step
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.pie = false;
    exe.red_zone = false;
    exe.omit_frame_pointer = false;
    exe.addIncludePath("./");
    exe.step.make() catch @panic("Error occured");
    const obj_path = exe.getOutputSource().generated.getPath();
    // todo: Automatic resolution of cross9 under windows?
    const cc = switch (b.host.target.os.tag) {
        .windows => "x86_64-pc-linux-gnu-gcc",
        else => "gcc",
    };
    const objcopy_name = switch (b.host.target.os.tag) {
        .windows => "x86_64-pc-linux-gnu-objcopy",
        else => "objcopy",
    };
    const link = b.addSystemCommand(&[_][]const u8{
        cc, "-o", "out.com.dbg", "-static", "-fno-pie", "-no-pie", "-mno-red-zone", "-fno-omit-frame-pointer", "-nostdlib", "-nostdinc", "-Wl,--gc-sections", "-Wl,-z,max-page-size=0x1000", "-fuse-ld=bfd", "-Wl,-T,ape.lds", obj_path, "./crt.o", "./ape.o", "./cosmopolitan.a"});
    const objcopy = b.addSystemCommand(&[_][]const u8{
        objcopy_name, "-S", "-O", "binary", "out.com.dbg", "out.com"});
    objcopy.step.dependOn(&link.step);
    b.getInstallStep().dependOn(&objcopy.step);    
}
