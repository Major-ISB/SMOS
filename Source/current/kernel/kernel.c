#include "kernel.h"
#include "libs/strlib/strlib.h"

char *vidmem = (char *) VGA_ADDRESS;

const char* smos_indicator = "user@smos";
char buffer[64];
int buffer_index = 0;

/* Voids definitions */

// completely clear the screan
void clear_screen()
{
    char *vidmem = (char *) 0xb8000;
    unsigned int i=0;

    while (i < (80*25<<1))
    {
        vidmem[i] = ' ';
        i++;
        vidmem[i] = (BG_COLOR << 4) | WHITE_TXT;
        i++;
    };  
}

// modify the current cursor position
void setCursorPos(const unsigned int raw, const unsigned column)
{
    const unsigned int position = raw * 80 + column;

    outb(0x3D4, 0x0E); // high bit
    outb(0x3D5, position >> 8);

    outb(0x3D4, 0x0F); // low bit
    outb(0x3D5, position & 0xFF);
}

// return current cursor position
unsigned int getCursorPos()
{
    // high
    outb(0x3D4, 0x0E);
    unsigned char high = inb(0x3D5);
    
    // low
    outb(0x3D4, 0x0F);
    unsigned char low = inb(0x3D5);
    
    unsigned int position = (high << 8) | low;
    return position;
}

void change_cursorshape(unsigned int start, unsigned int end)
{
    // Cursor start
    outb(0x3D4, 0x0A);
    outb(0x3D5, start);

    // Cursor end
    outb(0x3D4, 0x0B);
    outb(0x3D5, end);
}

// print a single character
void printchar(const unsigned char c, const int raw, const int column, const unsigned char color)
{
    int i = (raw * 80 + column)<<1; // <<1 = *2
    
    vidmem[i] = c;
    i++;
    vidmem[i] = (BG_COLOR << 4) | color;
}

// print formatted
void printf(const char* str, const unsigned char color)
{
    while (*str)
    {
        unsigned int curpos = getCursorPos();
        int raw = curpos / 80;
        int column = curpos % 80;
    
        if(*str=='\n') // check for a new line
	      {
	          brline();
	          *str++;
	      }
	      else
	      {
	          printchar(*str++, raw, column, color);

	          if (column < 79)
            {
                column++;
            }
            else
            {
                column = 0;
                raw++;
            }
            
            setCursorPos(raw, column);
        }
    }
}

// read and print keyboard pressed key
void handle_keyboard()
{
    if (!(inb(0x64) & 0x01))
        return;

    unsigned int curpos = getCursorPos();
    int raw = curpos / 80;
    int column = curpos % 80;
    
    unsigned char scancode = inb(0x60);
    
    if (scancode == 0x1C) // check if enter key is pressed
    {
        buffer_index = 0;

        for (int i = 0; i < 64; i++)
        {
            printchar(buffer[i], raw+1, i, WHITE_TXT);
            buffer[i] = ' ';
        }

        brline();
        brline();
        print_cmdindicator();
        return;
    }
    else if (scancode == 0x0E) // backspace logic
    {
        if (buffer_index > 0)
        {
            column--;
            setCursorPos(raw, column);
            printchar(' ', raw, column, WHITE_TXT);
            buffer_index--;
            buffer[buffer_index] = ' ';
        }
        return;
    }
    
    const char keymap[128] = {
        0,   27, '&','e','\"','\'','(', '-', 'e','_', 'c', 'a', ')', '=', '\b',
        '\t','a', 'z', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '^', '$', '\n', 0,
        'q', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'u', '`',  0,  '*',
        'w', 'x', 'c', 'v', 'b', 'n', ',', ';', ':', '!',  0,  '*',  0,  ' ',
    };
    
    unsigned char c = keymap[scancode];
    
    if (scancode < 0x80 && c && buffer_index < 63)
    {
        printchar(c, raw, column, WHITE_TXT);
        buffer[buffer_index] = c;
        column++;
        setCursorPos(raw, column);
        buffer_index++;
    }
}

void print_cmdindicator()
{
    printf(smos_indicator, GREEN_TXT);
    printf(": ", WHITE_TXT);
}

// boot log logic
void bootlog(const char* str, const enum EBootLogStatus status)
{
    unsigned char color = WHITE_TXT;
    const char* text = "None";
    
    switch (status)
    {
        case Success:
            text = "OK";
            color = GREEN_TXT;
            break;
        case Failed:
            text = "FAIL";
            color = RED_TXT;
            break;
        case Info:
            text = "Info";
            color = BLUE_TXT;
            break;
        default:
            break;
    }
    
    printf("[ ", WHITE_TXT);
    printf(text, color);
    printf(" ] ", WHITE_TXT);
    printf(str, WHITE_TXT);
    printf("\n", WHITE_TXT);
}

// new line logic
void brline()
{
    unsigned int curpos = getCursorPos();
    int raw = curpos / 80;
    int column = curpos % 80;
        
    column = 0;
    raw++;
        
    setCursorPos(raw, column);
}

/* Entry point */

void kmain()
{
    clear_screen();
    setCursorPos(0, 0);
    change_cursorshape(0, 15);
    
    bootlog("Kernel loading", Success);
    bootlog("Running SMOS on version v0.01", Info);
    bootlog("32-bits protected mode", Info);

    print_cmdindicator();

    while (1)
    {
        handle_keyboard();
    }; // the main loop for the cpu
}
