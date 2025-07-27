#include <stdint.h>

#define SPI_WRITE (*(volatile uint32_t*)0x30000000)

void spi_write(uint32_t val) { SPI_WRITE = val; }

int main() {
    for (volatile int i = 0; i < 2500000; i++)
        ;

    spi_write(0xAA55AA55);

    return 0;
}
