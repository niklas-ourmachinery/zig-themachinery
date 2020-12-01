
#include <plugins/ui/docking.h>
#include <the_machinery/the_machinery_tab.h>

extern void tab__ui_zig(struct tm_tab_o *tab, uint32_t font,
                        const struct tm_font_t *font_info, float font_scale,
                        struct tm_ui_o *ui, tm_rect_t *rect);

void tab__ui_c(struct tm_tab_o *tab, uint32_t font,
               const struct tm_font_t *font_info, float font_scale,
               struct tm_ui_o *ui, tm_rect_t rect) {
  tab__ui_zig(tab, font, font_info, font_scale, ui, &rect);
}