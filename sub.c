#include <stdio.h>

int func3()
{
    static int i=0;
    return i++;
}

