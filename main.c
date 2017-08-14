#include <stdio.h>
#include "libtrace/simple_trace.h"

int func3(void); /* sub.c */
int func5(void); /* sub.c */

int func4()
{
    return 0;
}

int func2()
{
    func5();
    return 0;
}

static int func6()
{
    return 0;
}

int func1()
{
    func3();
    func2();
    TRACE_EVENT(__FILE__, "sub.c", "event");
    func6();
    return func3();
}

int main(int argc, char* argv[])
{
    printf("%d\n",func1());
}
