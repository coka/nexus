const std = @import("std");

pub fn build(builder: *std.build.Builder) void {
    const mode = builder.standardReleaseOptions();
    const tests = builder.addTest("src/01_sonar_sweep.zig");
    tests.setBuildMode(mode);
    const test_step = builder.step("test", "Run tests");
    test_step.dependOn(&tests.step);
}
