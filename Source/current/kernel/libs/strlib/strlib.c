#include "strlib.h"

// String lenght
int strlen(const char* str)
{
    int lenght = 0;

    while(*str)
    {
        lenght++;
        *str++;
    }

    return lenght;
}

// String comparison
int strcmp(const char* a, const char* b)
{
    int egals = 0; // 0 = yes

    if (strlen(a) == strlen(b))
    {
        while(*a)
        {
            if (*a != *b)
                egals = 1; // not egals
                break;

            *a++;
            *b++;
        }
    }
    else
    {
        egals = 1;  // not egals
    }

    return egals;
}
