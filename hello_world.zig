// Minimal zig program using The Machinery foundation library.
//
// zig run hello_world.zig -I $TM_SDK_DIR/headers  -L $TM_SDK_DIR/lib/gmake/Debug -lfoundation

const c = @cImport({
    @cDefine("TM_LINKS_FOUNDATION", "1");
    @cInclude("foundation/log.h");
});

pub fn main() void {
    c.tm_logger_api.*.print.?(c.tm_log_type.TM_LOG_TYPE_INFO, "Hello world!\n");
}
