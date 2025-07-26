#include <stdint.h>

#define SPI_WRITE (*(volatile uint32_t*)0x30000000)
#define SPI_READ (*(volatile uint32_t*)0x30000004)
#define UART_TX (*(volatile uint32_t*)0x20000000)

void spi_write(uint32_t val) { SPI_WRITE = val; }

int main() {
    spi_write(0xAA55AA55);

    return 0;
}
