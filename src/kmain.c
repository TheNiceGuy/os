#include "framebuffer.h"

#define FILLED "**"
#define SPACED "  "
#define false 0
#define true  1

void sleep() {
    unsigned i, j;

    for(i = 0; i < 65000; i++)
        for(j = 0; j < 1000; j++) {}
}

void draw_limit(int size, int reversed) {
    int j;

    if(reversed) {
        for(j = 0; j < size; j++) {
            if(j >= size/2 || j == 0)
                fb_write(FILLED);
            else
                fb_write(SPACED);
        }
    } else {
        for(j = 0; j < size; j++) {
            if(j <= size/2 || j == size-1)
                fb_write(FILLED);
            else
                fb_write(SPACED);
        }
    }
    fb_write("\n");
}

void draw_middle(int size, int reversed) {
    int j;

    for(j = 0; j < size; j++) {
        if(reversed) {
            if(j == 0 || j == (size-1)/2)
                fb_write(FILLED);
            else
                fb_write(SPACED);
        } else {
            if(j == size-1 || j == (size-1)/2)
                fb_write(FILLED);
            else
                fb_write(SPACED);
        }
    }
    fb_write("\n");
}

void draw_middle_line(int size) {
    int j;

    for(j = 0; j < size; j++) {
        fb_write(FILLED);
    }
    fb_write("\n");
}

void draw(int size) {
    int i;

    if(size%2 == 0)
        size++;

    for(i = 0; i < size; i++) {
        sleep();
        if(i == 0)
            draw_limit(size, false);
        else if(i == size-1)
            draw_limit(size, true);
        else if(i < (size-1)/2)
            draw_middle(size, false);
        else if(i > (size-1)/2)
            draw_middle(size, true);
        else
            draw_middle_line(size);
    }
}

void kmain() {
    draw(20);
}
