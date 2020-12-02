// Zig plugin that draws a custom tab.
//
// Build on Windows:
//
//     zig build-lib tm_custom_tab.zig tm_custom_tab_helper.c -I %TM_SDK_DIR%/headers -I . -lc -dynamic
//
// Build on OS X:
//
//     zig build-lib tm_custom_tab.zig tm_custom_tab_helper.c -I $TM_SDK_DIR/headers -I . -dynamic
//
// In order to compile this you need to make some changes to the The Machinery headers to workaround C
// features not (yet?) supported by Zig.
//
// foundation/api_types.h:
//
// ~~~
// typedef struct tm_tt_id_t
// {
//     union
//     {
//         // Used for comparing objects or storing them in hash tables.
//         uint64_t u64;
// 
// #ifndef TM_ZIG
//         struct
//         {
//             // Type of the object.
//             uint64_t type : 10;
//             // Generation of the object, used to distinguish objects created at the same index.
//             uint64_t generation : 22;
//             // Index of the object.
//             uint64_t index : 32;
//         };
// #endif
//     };
// } tm_tt_id_t;
// ~~~
//
// the_machinery/the_machinery_tab.h:
//
// ~~~
// #ifdef TM_ZIG
//     struct tm_tab_vt tm_tab_vt;
// #else
//     struct tm_tab_vt;
// #endif
// ~~~
// ~~~

const std = @import("std");

const c = @cImport({
    @cDefine("TM_ZIG", "1");
    @cInclude("foundation/allocator.h");
    @cInclude("foundation/api_registry.h");
    @cInclude("plugins/ui/docking.h");
    @cInclude("plugins/ui/draw2d.h");
    @cInclude("plugins/ui/ui.h");
    @cInclude("plugins/ui/ui_custom.h");
    @cInclude("the_machinery/the_machinery_tab.h");
    @cInclude("stdio.h");
    @cInclude("tm_custom_tab_helper.h");
});

var tm_global_api_registry: c.tm_api_registry_api = undefined;

var tm_draw2d_api: *c.tm_draw2d_api = undefined;
var tm_ui_api: *c.tm_ui_api = undefined;

const TM_CUSTOM_TAB_VT_NAME = "tm_custom_tab";

const tm_tab_o = extern struct {
    tab_i: c.tm_tab_i,
    allocator: [*c]c.tm_allocator_i,
};

var custom_tab_vt: c.tm_the_machinery_tab_vt = undefined;

fn initCustomTab() void {
    std.mem.set(u8, std.mem.asBytes(&custom_tab_vt), 0);
    custom_tab_vt.tm_tab_vt.name = TM_CUSTOM_TAB_VT_NAME;
    custom_tab_vt.tm_tab_vt.name_hash = 0xbc4e3e47fbf1cdc1;
    custom_tab_vt.tm_tab_vt.create_menu_name = tab__create_menu_name;
    custom_tab_vt.tm_tab_vt.title = tab__title;
    custom_tab_vt.tm_tab_vt.destroy = tab__destroy;
    custom_tab_vt.tm_tab_vt.create = tab__create;
    custom_tab_vt.tm_tab_vt.ui = c.tab__ui_c;
}

fn tab__create_menu_name() callconv(.C) [*c]const u8 {
    return "Custom Tab";
}

fn tab__title(ctab: ?*c.tm_tab_o, ui: ?*c.tm_ui_o) callconv(.C) [*c]const u8 {
    return "Custom Tab";
}

fn tab__create(context: ?*c.tm_tab_create_context_t) callconv(.C) ?*c.tm_tab_i {
    const a = context.?.allocator;
    var id = context.?.id;

    const src = @src();
    var allocPtr = a.*.realloc.?(a, null, 0, @sizeOf(tm_tab_o), src.file, src.line);
    var ptr = @alignCast(8, allocPtr);
    var tab = @ptrCast(*tm_tab_o, ptr);
    tab.tab_i.vt = @ptrCast(*c.tm_tab_vt, &custom_tab_vt);
    tab.tab_i.inst = @ptrCast(*c.tm_tab_o, tab);
    tab.tab_i.root_id = id.*;
    tab.allocator = a;

    id = id + 1000000;
    return &tab.tab_i;
}

fn tab__destroy(ctab: ?*c.tm_tab_o) callconv(.C) void {
    var tab = @ptrCast(*tm_tab_o, @alignCast(8, ctab)).*;
    const a = tab.allocator;
    const src = @src();
    _ = a.*.realloc.?(a, &tab, @sizeOf(@TypeOf(tab)), 0, src.file, src.line);
}

export fn tab__ui_zig(ctab: ?*c.tm_tab_o, font: u32, font_info: ?*const c.tm_font_t, font_scale: f32, ui: *c.tm_ui_o, rect: *const c.tm_rect_t) callconv(.C) void {
    var uib = tm_ui_api.buffers.?(ui);
    var style: c.tm_draw2d_style_t = undefined;
    std.mem.set(u8, std.mem.asBytes(&style), 0);
    style.font = font;
    style.font_info = font_info;
    style.font_scale = font_scale;
    style.color.a = 255;
    style.color.r = 255;
    style.color.g = 255;
    tm_draw2d_api.fill_rect.?(uib.vbuffer, uib.ibuffers[0], &style, rect.*);
}

fn get(comptime T: type, reg: *c.tm_api_registry_api, name: [*c]const u8) *T {
    const voidptr = reg.*.get.?(name);
    const ptr = @ptrCast([*c]T, @alignCast(8, voidptr));
    return ptr;
}

export fn tm_load_plugin(reg: *c.tm_api_registry_api, load: bool) void {
    tm_global_api_registry = reg.*;

    tm_draw2d_api = get(c.tm_draw2d_api, reg, c.TM_DRAW2D_API_NAME);
    tm_ui_api = get(c.tm_ui_api, reg, c.TM_UI_API_NAME);

    initCustomTab();

    if (load) {
        reg.add_implementation.?(c.TM_TAB_VT_INTERFACE_NAME, &custom_tab_vt);
        reg.set.?(TM_CUSTOM_TAB_VT_NAME, &custom_tab_vt, @sizeOf(@TypeOf(custom_tab_vt)));
    } else {
        reg.remove_implementation.?(c.TM_TAB_VT_INTERFACE_NAME, &custom_tab_vt);
        reg.remove.?(&custom_tab_vt);
    }
}
