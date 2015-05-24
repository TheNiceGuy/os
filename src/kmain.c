#include "io.h"
#include "framebuffer.h"

void kmain() {
    fb_clear();
    fb_move_cursor_coor(79, 24);
}
