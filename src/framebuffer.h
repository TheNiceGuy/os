#ifndef INCLUDE_FB_H
#define INCLUDE_FB_H

/** fb_clear:
 *  Clear the framebuffer.
 */
void fb_clear();

/** fb_move_cursor_coor:
 *  Specify the position of the cursor in the framebuffer using
 *  x and y coordinates.
 *
 *  @param x The x coordinate of the cursor
 *  @param y The y coordinate of the cursor
 *  @return 0 if everything is successful
 *          1 if the width is out of bound
 *          2 if the height is out of bound
 */
int fb_move_cursor_coor(short x, short y);

/** fb_scroll_up:
 *  Scroll the framebuffer by one line.
 */
void fb_scroll_up();

/** fb_move_cursor_pos:
 *  Specify the position of the cursor in the framebuffer.
 *
 *  @param pos The position in the framebuffer.
 *  @return 0 if everything is successful
 *          1 if the position is out of bound
 */
int fb_move_cursor_pos(short pos);

/** fb_write:
 *  Write a null-terminated text buffer into the framebuffer.
 *
 *  @param buffer The pointer to the null-terminated buffer
 */
void fb_write(char* buffer);

#endif
