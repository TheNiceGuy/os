#include "framebuffer.h"

void sleep() {
    unsigned int i;
    unsigned int j;

    for(i = 0; i < 65000; i++)
        for(j = 0; j < 1000; j++) {}
}

void kmain() {
    int i;

	for(i = 0; i < 10; i++) {
		fb_write("Hello World!\n");
        sleep();
    }
}
