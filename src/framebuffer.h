#ifndef INCLUDE_FB_H
#define INCLUDE_FB_H

/** fb_clear:
 *  Clear the framebuffer.
 */
void fb_clear();

/** fb_move_cursor:
 *  Specify the position of the cursor in the framebuffer.
 *
 *  @param x The x position of the cursor
 *  @param y The y position of the cursor
 *  @return 0 if everything is successful
 *  @return 1 if the width is out of bound
 *  @return 2 if the height is out of bound
 */
int fb_move_cursor(short x, short y);

#endif
