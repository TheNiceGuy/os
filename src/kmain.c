#include "io.h"
#include "framebuffer.h"

void kmain() {
    fb_clear();
    fb_move_cursor(0x0,0x0);
}
