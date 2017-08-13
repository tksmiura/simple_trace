#include <stdio.h>
#include <string.h>

__attribute__((no_instrument_function))
void __cyg_profile_func_enter(void* func_address, void* call_site);
__attribute__((no_instrument_function))
void __cyg_profile_func_exit(void* func_address, void* call_site);


__attribute__((no_instrument_function))
void __cyg_profile_func_enter(void* func_address, void* call_site) {
    static int f = 0;
    if (! f) {
        printf("offset __cyg_profile_func_enter = %lx\n",
               (unsigned long)__cyg_profile_func_enter);
        f = 1;
    }
    printf("in %lx -> %lx\n",
           (unsigned long)call_site,
           (unsigned long)func_address);
}

__attribute__((no_instrument_function))
void __cyg_profile_func_exit(void* func_address, void* call_site) {
    printf("out %lx <- %lx\n",
           (unsigned long)call_site,
           (unsigned long)func_address);
}

