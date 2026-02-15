#include <stdint.h>

#include "include/drivers/vga/vga_num.h"
#include "include/drivers/vga/vga_text.h"

int kmain()
{

    print("Kernel Loaded Successfully\n");
    print_uint32_b10(54);
    
    return 0;
}