// Minimal zig program using The Machinery foundation library.
//
// zig run -I /Users/Niklas/Work/themachinery/ hello-world.zig -L /Users/Niklas/Work/themachinery/bin/Debug -lfoundation

const c = @cImport({
    @cDefine("TM_LINKS_FOUNDATION", "1");
    @cInclude("../themachinery/foundation/allocator.h");
    @cInclude("../themachinery/foundation/api_registry.h");
    @cInclude("../themachinery/foundation/log.h");
});

pub fn main() void {
    c.tm_init_global_api_registry(c.tm_allocator_api.*.system);
    c.tm_logger_api.*.print.?(c.tm_log_type.TM_LOG_TYPE_INFO, "Hello world!\n");
}
