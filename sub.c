#include <stdio.h>
#include "libtrace/simple_trace.h"

extern int func4(void);

int func3()
{
    static int i=0;
    TRACE_NOTE("note %d", i);
    
    return i++;
}

int func5()
{
    func4();
    return 0;
}

