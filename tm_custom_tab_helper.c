
#include <plugins/ui/docking.h>
#include <the_machinery/the_machinery_tab.h>

extern void tab__ui_zig(struct tm_tab_o *tab, uint32_t font,
                        const struct tm_font_t *font_info, float font_scale,
                        struct tm_ui_o *ui, const tm_rect_t *rect);

// Zig functions cannot use small structs with floats as parameters (see
// https://github.com/ziglang/zig/issues/1481), to get around that we use a C
// function to forward the rect as a pointer.
void tab__ui_c(struct tm_tab_o *tab, uint32_t font,
               const struct tm_font_t *font_info, float font_scale,
               struct tm_ui_o *ui, tm_rect_t rect) {
  tab__ui_zig(tab, font, font_info, font_scale, ui, &rect);
}