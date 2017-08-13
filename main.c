#include <stdio.h>

int func3(); /* sub.c */

int func2()
{
    return 0;
}

static int func4()
{
    return 0;
}

int func1()
{
    func3();
    func2();
    func4();
    return func3();
}

int main(int argc, char* argv[])
{
    printf("%d\n",func1());
}
