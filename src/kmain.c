#include "io.h"
#include "framebuffer.h"

#define TEST_SIZE 100

void sleep() {
    unsigned i, j;

    for(i = 0; i < 65000; i++)
        for(j = 0; j < 1000; j++) {}
}

void kmain() {
    char str[TEST_SIZE];
    int i, j, k;

    fb_clear();

    for(j = 0; j < 100; j++) {
        k = 'A';
        for(i = 0; i < TEST_SIZE; i++) {
            if(k > 'z')
                k = 'A';

            str[i] = k;
            k++;
        }
        str[TEST_SIZE-1]='\0';

        fb_write(str);

        sleep();
    }
}
