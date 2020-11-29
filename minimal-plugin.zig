// Minimal zig plugin that can be used in The Machinery.
//
// zig build-lib -I /Users/Niklas/Work/themachinery/ minimal-plugin.zig -L /Users/Niklas/Work/themachinery/bin/Debug -lfoundation -dynamic

const c = @cImport({
    @cInclude("../themachinery/foundation/api_registry.h");
    @cInclude("../themachinery/foundation/log.h");
});

export fn tm_load_plugin(reg: *c.tm_api_registry_api, load: bool) void {
    var tm_logger_api_ptr: [*c]c.tm_logger_api = null;
    tm_logger_api_ptr = @ptrCast(@TypeOf(tm_logger_api_ptr), @alignCast(8, reg.*.get.?(c.TM_LOGGER_API_NAME)));
    var tm_logger_api = tm_logger_api_ptr.*;
    _ = tm_logger_api.printf.?(c.tm_log_type.TM_LOG_TYPE_INFO, "Minimal Zig plugin %s.\n", "loaded");
}
