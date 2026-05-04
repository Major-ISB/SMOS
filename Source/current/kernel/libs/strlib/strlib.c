
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

void strcmp(const char* a, const char* b)
{
    int egals = 0; // 0 = no

    if (strlen(a) == strlen(b))
        while(*a && *b)
        {
            if (*a != *b)
                egals = 1;
                break;
        }
    }
    else
    {
        egals = 1;
    }

    return egals;
}
