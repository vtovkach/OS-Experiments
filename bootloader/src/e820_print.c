
#include <stdint.h>

extern char *e820_buf ;
extern short *e820_count;

void print_e820()
{
    char h = 'A';
    
    __asm__ __volatile__ (
        "movb $0x0E, %%ah \n\t"
        "movb $0x00, %%bh \n\t"
        "movb $0x07, %%bl \n\t"
        "int  $0x10        \n\t"
        :
        : "a"(h)
        : "bx", "cc", "memory"
    );
    
}