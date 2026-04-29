#ifndef KERNEL_H
#define KERNEL_H

// General definitions //
#define VGA_ADDRESS 0xB8000

// VGA Colors //
#define GREEN_TXT 0x02
#define RED_TXT   0x04
#define WHITE_TXT 0x07
#define BLUE_TXT  0x09
#define BG_COLOR  0x0

// External //
extern void outb(unsigned short port, unsigned char value);
extern unsigned char inb(unsigned short port);

// Enum //
enum EBootLogStatus { Success, Failed, Info };

// Voids //
void setCursorPos(const unsigned int raw, const unsigned int column);
unsigned int getCursorPos();

void printchar(const unsigned char c, const int raw, const int column, const unsigned char color);
void printf(const char *str, const unsigned char color);

void clear_screen();
void brline();
void handle_keyboard();
void bootlog(const char *str, const enum EBootLogStatus status);

#endif
