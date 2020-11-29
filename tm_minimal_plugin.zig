// Minimal zig plugin that can be used in The Machinery.
//
// zig build-lib tm_minimal_plugin.zig -I $TM_SDK_DIR/headers -dynamic

const c = @cImport({
    @cInclude("foundation/api_registry.h");
    @cInclude("foundation/log.h");
});

var tm_logger_api: c.tm_logger_api = undefined;

export fn tm_load_plugin(reg: *c.tm_api_registry_api, load: bool) void {
    tm_logger_api = @ptrCast([*c]c.tm_logger_api, @alignCast(8, reg.*.get.?(c.TM_LOGGER_API_NAME))).*;
    _ = tm_logger_api.printf.?(c.tm_log_type.TM_LOG_TYPE_INFO, "Minimal Zig plugin %s.\n", "loaded");
}
