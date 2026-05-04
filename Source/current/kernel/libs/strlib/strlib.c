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
void strcmp(const char* a, const char* b)
{
    int egals = 0; // 0 = yes

    if (strlen(a) == strlen(b))
    {
        while(*a && *b)
        {
            if (*a != *b)
                egals = 1; // not egals
                break;
        }
    }
    else
    {
        egals = 1;  // not egals
    }

    return egals;
}
