#include <stdint.h>

#define SPI_WRITE (*(volatile uint32_t*)0x30000000)
#define SPI_READ (*(volatile uint32_t*)0x30000004)
#define UART_TX (*(volatile uint32_t*)0x20000000)

void spi_write(uint32_t val) { SPI_WRITE = val; }

int main() {
    spi_write(0x00390000);
    for (int i = 0; i < 25000000; i++) {
    }

    uint32_t read_value = SPI_READ;
    UART_TX = 'A' + read_value;

    return 0;
}
